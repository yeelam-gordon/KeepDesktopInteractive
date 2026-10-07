param(
    [Parameter(Mandatory = $true)]
    [string]$TargetUser,
    [Parameter(Mandatory = $true)]
    [string]$TargetSid,
    [int]$TestSessionId = -1
)

$ErrorActionPreference = 'Stop'
$root = Join-Path $env:ProgramData 'DevboxDesktopSession'
$taskName = 'KeepDesktopInteractiveOnDisconnect'
$testTaskName = 'VerifyDesktopDisconnectOnce'
$diagnosticTaskName = 'DiagnoseUIAutomationOnDisconnect'
$diagnosticDescription = 'Run bounded desktop input diagnostics as the logged-in user after remote disconnect; save results without requiring Copilot to remain connected.'
$description = "Keep the selected user's desktop interactive after remote disconnect by transferring their disconnected session to the console. No autologon or stored credentials."
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Administrator privileges are required.'
}
$previous = $null
$diagnosticScript = Join-Path $PSScriptRoot 'test-desktop-after-disconnect.vbs'
if (-not (Test-Path -LiteralPath $diagnosticScript -PathType Leaf)) {
    throw "Diagnostic launcher is missing: $diagnosticScript"
}
$existingDiagnostic = Get-ScheduledTask -TaskName $diagnosticTaskName -ErrorAction SilentlyContinue
if ($existingDiagnostic -and (
    $existingDiagnostic.Description -ne $diagnosticDescription -or
    ([Security.Principal.NTAccount]::new($existingDiagnostic.Principal.UserId).Translate([Security.Principal.SecurityIdentifier]).Value -ne $TargetSid)
)) {
    throw "An unrelated task already exists: $diagnosticTaskName"
}
if (Test-Path $root) {
    $previousResult = Join-Path $root 'setup-result.json'
    $unexpected = @(Get-ChildItem -LiteralPath $root -Force | Where-Object {
        $_.PSIsContainer -or $_.Name -notin @('setup-result.json', 'session-handoff.log', 'session-handoff.log.previous', 'task-status.json')
    })
    if (-not (Test-Path $previousResult) -or $unexpected.Count -gt 0) {
        throw "Installation path contains unexpected existing files: $root"
    }
    $previous = Get-Content -LiteralPath $previousResult -Raw | ConvertFrom-Json
    if ($previous.Installed -ne $false -and $previous.TargetUser -ne $TargetUser) {
        throw "Installation belongs to a different user: $root"
    }
}
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask -and (
    $existingTask.Description -ne $description -or
    $existingTask.Principal.UserId -notin @('SYSTEM', 'S-1-5-18') -or
    -not $previous -or $previous.TargetUser -ne $TargetUser
)) {
    throw "An unrelated task already exists: $taskName"
}
New-Item -ItemType Directory -Path $root -Force | Out-Null
$acl = [Security.AccessControl.DirectorySecurity]::new()
$acl.SetAccessRuleProtection($true, $false)
foreach ($entry in @(
    @('S-1-5-18', 'FullControl'),
    @('S-1-5-32-544', 'FullControl'),
    @($TargetSid, 'ReadAndExecute')
)) {
    $rule = [Security.AccessControl.FileSystemAccessRule]::new(
        [Security.Principal.SecurityIdentifier]::new($entry[0]),
        [Security.AccessControl.FileSystemRights]$entry[1],
        [Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit',
        [Security.AccessControl.PropagationFlags]::None,
        [Security.AccessControl.AccessControlType]::Allow
    )
    $acl.AddAccessRule($rule)
}
Set-Acl -LiteralPath $root -AclObject $acl
try {
    $worker = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Keep-DesktopInteractive.ps1') -Raw
    $quotedUser = $TargetUser.Replace("'", "''")
    # Embed the worker in the protected task rather than execute a user-writable source file as SYSTEM.
    $command = "& {`n$worker`n} -TargetUser '$quotedUser'"
    $encodedWorker = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $escapedSid = [Security.SecurityElement]::Escape($TargetSid)
    $arguments = [Security.SecurityElement]::Escape("-NoProfile -NonInteractive -EncodedCommand $encodedWorker")
    $powershell = [Security.SecurityElement]::Escape("$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe")
    $xml = @"
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo><Description>Keep the selected user's desktop interactive after remote disconnect by transferring their disconnected session to the console. No autologon or stored credentials.</Description></RegistrationInfo>
  <Triggers><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>RemoteDisconnect</StateChange><UserId>$escapedSid</UserId><Delay>PT2S</Delay></SessionStateChangeTrigger></Triggers>
  <Principals><Principal id="System"><UserId>S-1-5-18</UserId><RunLevel>HighestAvailable</RunLevel></Principal></Principals>
  <Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT1M</ExecutionTimeLimit><Enabled>true</Enabled></Settings>
  <Actions Context="System"><Exec><Command>$powershell</Command><Arguments>$arguments</Arguments></Exec></Actions>
</Task>
"@
    Register-ScheduledTask -TaskName $taskName -Xml $xml -User 'SYSTEM' -Force | Out-Null
    $scheduler = New-Object -ComObject 'Schedule.Service'
    $scheduler.Connect()
    $registeredTask = $scheduler.GetFolder('\').GetTask($taskName)
    $registeredTask.SetSecurityDescriptor("D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GR;;;$TargetSid)", 0)
    $wscript = [Security.SecurityElement]::Escape("$env:SystemRoot\System32\wscript.exe")
    $diagnosticArguments = [Security.SecurityElement]::Escape('"' + $diagnosticScript + '"')
    $diagnosticXml = @"
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo><Description>$diagnosticDescription</Description></RegistrationInfo>
  <Triggers><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>RemoteDisconnect</StateChange><UserId>$escapedSid</UserId><Delay>PT10S</Delay></SessionStateChangeTrigger></Triggers>
  <Principals><Principal id="User"><UserId>$escapedSid</UserId><LogonType>InteractiveToken</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals>
  <Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT3M</ExecutionTimeLimit><Enabled>true</Enabled></Settings>
  <Actions Context="User"><Exec><Command>$wscript</Command><Arguments>$diagnosticArguments</Arguments></Exec></Actions>
</Task>
"@
    Register-ScheduledTask -TaskName $diagnosticTaskName -Xml $diagnosticXml -Force | Out-Null
    $registeredDiagnostic = $scheduler.GetFolder('\').GetTask($diagnosticTaskName)
    $registeredDiagnostic.SetSecurityDescriptor("D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GA;;;$TargetSid)", 0)
    $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
    @{
        Task = $taskName
        Principal = 'SYSTEM'
        TargetUser = $TargetUser
        TargetSid = $TargetSid
        Trigger = 'RemoteDisconnect'
        DiagnosticTask = $diagnosticTaskName
        DiagnosticRunAs = $TargetUser
        DiagnosticDelaySeconds = 10
        LastRunTime = [string]$taskInfo.LastRunTime
        LastTaskResult = $taskInfo.LastTaskResult
        SourceSha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Keep-DesktopInteractive.ps1') -Algorithm SHA256).Hash
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'task-status.json') -Encoding UTF8
    if ($TestSessionId -ge 0) {
        $testCommand = @"
`$ErrorActionPreference = 'Stop'
try {
    & "`$env:SystemRoot\System32\tsdiscon.exe" $TestSessionId
    if (`$LASTEXITCODE -ne 0) { throw "tsdiscon failed: `$LASTEXITCODE" }
}
finally { Unregister-ScheduledTask -TaskName '$testTaskName' -Confirm:`$false }
"@
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($testCommand))
        $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -EncodedCommand $encoded"
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(90)
        $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 30) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName $testTaskName -Action $action -Trigger $trigger -Settings $settings -User 'SYSTEM' -RunLevel Highest | Out-Null
    }
    @{ Installed = $true; Task = $taskName; DiagnosticTask = $diagnosticTaskName; TargetUser = $TargetUser; TestSessionId = $TestSessionId; Time = (Get-Date -Format o) } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'setup-result.json') -Encoding UTF8
}
catch {
    @{ Installed = $false; Error = $_.Exception.Message; Time = (Get-Date -Format o) } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'setup-result.json') -Encoding UTF8
    throw
}
