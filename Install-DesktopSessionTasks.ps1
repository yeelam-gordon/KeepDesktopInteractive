param(
    [Parameter(Mandatory = $true)][string]$TargetUser,
    [Parameter(Mandatory = $true)][string]$TargetSid,
    [int]$TestSessionId = -1,
    [switch]$RemovePreviousFirst
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Initialize-DesktopSessionSecurity.ps1')
$root = Join-Path $env:ProgramData 'DevboxDesktopSession'
$statePath = Join-Path $root 'setup-result.json'
$taskName = 'KeepDesktopInteractiveOnDisconnect'
$diagnosticTaskName = 'DiagnoseUIAutomationOnDisconnect'
$descriptions = @{
    KeepDesktopInteractiveOnDisconnect = "Keep the selected user's desktop interactive after remote disconnect by transferring their disconnected session to the console. No autologon or stored credentials."
    DiagnoseUIAutomationOnDisconnect = 'Run bounded desktop input diagnostics as the logged-in user after remote disconnect; save results without requiring Copilot to remain connected.'
}
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Administrator privileges are required.'
}
if ((Resolve-AccountSid $TargetUser) -ne $TargetSid) { throw 'TargetUser and TargetSid do not identify the same account.' }
Assert-TrustedSource -Directory $PSScriptRoot -UserSid $TargetSid
if ($TestSessionId -ge 0) { throw 'Use a normal manual disconnect for verification; setup never forces a disconnect.' }
$files = @('Initialize-DesktopSessionSecurity.ps1', 'Test-InteractiveDesktopAutomation.ps1', 'test-desktop-after-disconnect.vbs')
$sourceBytes = @{}
foreach ($name in $files) {
    $path = Join-Path $PSScriptRoot $name
    Assert-TrustedPath -Path $path -WriterSids @($TargetSid)
    $sourceBytes[$name] = [IO.File]::ReadAllBytes($path)
}
$workerPath = Join-Path $PSScriptRoot 'Move-DisconnectedSessionToConsole.ps1'
Assert-TrustedPath -Path $workerPath -WriterSids @($TargetSid)
$worker = [IO.File]::ReadAllText($workerPath)
$existingTasks = @(Get-ScheduledTask -ErrorAction Stop | Where-Object {
    $_.TaskPath -eq '\' -and $_.TaskName -in @($descriptions.Keys)
})
foreach ($task in $existingTasks) {
    if ($task.Description -ne $descriptions[$task.TaskName]) { throw "An unrelated task already exists: $($task.TaskName)" }
    $expectedSid = $TargetSid
    if ($task.TaskName -eq $taskName) { $expectedSid = 'S-1-5-18' }
    if ((Resolve-AccountSid $task.Principal.UserId) -ne $expectedSid) {
        throw "Unexpected principal on existing task: $($task.TaskName)"
    }
    if ($task.State -eq 'Running') { throw "Wait for task $($task.TaskName) to finish before reinstalling." }
}
if (Test-Path -LiteralPath $root) {
    Assert-TrustedPath -Path $root -WriterSids @()
    foreach ($item in Get-ChildItem -LiteralPath $root -Force) {
        if ($item.PSIsContainer) { throw "Unexpected directory in protected installation: $($item.FullName)" }
        Assert-TrustedPath -Path $item.FullName -WriterSids @()
    }
    if (Test-Path -LiteralPath $statePath) {
        $previous = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
        if ($previous.TargetUser -and $previous.TargetUser -ne $TargetUser -and
            ($previous.Installed -or $previous.Status -ne 'Uninstalled' -or $existingTasks.Count)) {
            throw 'This installation belongs to another automation user.'
        }
    }
}
else {
    if ($existingTasks.Count) { throw 'Managed tasks exist without a protected installation. Remove them as an administrator before setup.' }
    New-SecuredDirectory -Path $root -OwnerSid 'S-1-5-32-544' -ReaderSid $TargetSid
}
if ($RemovePreviousFirst -and $existingTasks.Count) {
    & (Join-Path $PSScriptRoot 'Uninstall-DesktopSessionTasks.ps1') -TargetUser $TargetUser -TargetSid $TargetSid
    $remaining = @(Get-ScheduledTask -ErrorAction Stop | Where-Object {
        $_.TaskPath -eq '\' -and $_.TaskName -in @($descriptions.Keys)
    })
    if ($remaining.Count) { throw 'Previous tasks were not completely removed; replacement installation was not started.' }
    $existingTasks = @()
}

$state = @{
    Installed = $false
    Status = 'Staged'
    TargetUser = $TargetUser
    TargetSid = $TargetSid
    Task = $taskName
    DiagnosticTask = $diagnosticTaskName
    Time = [DateTime]::UtcNow.ToString('o')
}
$touchedTasks = [Collections.Generic.List[string]]::new()
try {
    $scheduler = New-Object -ComObject 'Schedule.Service'
    $scheduler.Connect()
    $folder = $scheduler.GetFolder('\')
    foreach ($task in @($existingTasks | Sort-Object @{ Expression = { if ($_.TaskName -eq $diagnosticTaskName) { 0 } else { 1 } } })) {
        $touchedTasks.Add($task.TaskName)
        Disable-ScheduledTask -TaskName $task.TaskName -TaskPath '\' | Out-Null
        if ($folder.GetTask($task.TaskName).GetInstances(0).Count -gt 0) {
            throw "An instance of $($task.TaskName) started during setup. Wait for it to finish and rerun setup."
        }
    }
    Set-InstalledDirectoryPermissions -Path $root -ReaderSid $TargetSid
    Write-AtomicJson -Path $statePath -Value $state
    foreach ($name in $files) {
        $temporary = Join-Path $root ([IO.Path]::GetRandomFileName() + '.tmp')
        $stream = [IO.FileStream]::new($temporary, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        try { $stream.Write($sourceBytes[$name], 0, $sourceBytes[$name].Length); $stream.Flush($true) }
        finally { $stream.Dispose() }
        $destination = Join-Path $root $name
        if (Test-Path -LiteralPath $destination) { [IO.File]::Replace($temporary, $destination, [NullString]::Value) }
        else { [IO.File]::Move($temporary, $destination) }
        Assert-TrustedPath -Path $destination -WriterSids @()
        if ([Convert]::ToBase64String([IO.File]::ReadAllBytes($destination)) -ne [Convert]::ToBase64String($sourceBytes[$name])) {
            throw "Installed file verification failed: $name"
        }
    }
    $quotedUser = $TargetUser.Replace("'", "''")
    $command = "& {`n$worker`n} -TargetUser '$quotedUser'"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $powershell = [Security.SecurityElement]::Escape("$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe")
    $wscript = [Security.SecurityElement]::Escape("$env:SystemRoot\System32\wscript.exe")
    $sid = [Security.SecurityElement]::Escape($TargetSid)
    $diagnosticArguments = [Security.SecurityElement]::Escape('"' + (Join-Path $root 'test-desktop-after-disconnect.vbs') + '" --installed')
    $xml = @{}
    $xml[$taskName] = @"
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo><Description>$($descriptions[$taskName])</Description></RegistrationInfo>
  <Triggers><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>RemoteDisconnect</StateChange><UserId>$sid</UserId><Delay>PT2S</Delay></SessionStateChangeTrigger></Triggers>
  <Principals><Principal id="System"><UserId>S-1-5-18</UserId><RunLevel>HighestAvailable</RunLevel></Principal></Principals>
  <Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT1M</ExecutionTimeLimit><Enabled>false</Enabled></Settings>
  <Actions Context="System"><Exec><Command>$powershell</Command><Arguments>-NoProfile -NonInteractive -EncodedCommand $encoded</Arguments></Exec></Actions>
</Task>
"@
    $xml[$diagnosticTaskName] = @"
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo><Description>$($descriptions[$diagnosticTaskName])</Description></RegistrationInfo>
  <Triggers><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>RemoteDisconnect</StateChange><UserId>$sid</UserId><Delay>PT10S</Delay></SessionStateChangeTrigger></Triggers>
  <Principals><Principal id="User"><UserId>$sid</UserId><LogonType>InteractiveToken</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals>
  <Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><ExecutionTimeLimit>PT3M</ExecutionTimeLimit><Enabled>false</Enabled></Settings>
  <Actions Context="User"><Exec><Command>$wscript</Command><Arguments>$diagnosticArguments</Arguments></Exec></Actions>
</Task>
"@
    foreach ($name in @($taskName, $diagnosticTaskName)) {
        $account = 'SYSTEM'
        $logonType = 5
        $userRights = 'GR'
        if ($name -eq $diagnosticTaskName) { $account = $TargetSid; $logonType = 3; $userRights = 'GRGX' }
        $sddl = "O:BAG:BAD:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;$userRights;;;$TargetSid)"
        $touchedTasks.Add($name)
        # CREATE_OR_UPDATE plus DONT_ADD_PRINCIPAL_ACE preserves the explicit read/execute-only user grant.
        $registrationFlags = 0x6 -bor 0x10
        $registered = $folder.RegisterTask($name, $xml[$name], $registrationFlags, $account, $null, $logonType, $sddl)
        if ($registered.Enabled) { throw "Task unexpectedly enabled during staging: $name" }
        $security = [Security.AccessControl.RawSecurityDescriptor]::new($registered.GetSecurityDescriptor(5))
        if ($security.Owner.Value -ne 'S-1-5-32-544') { throw "Task owner is not Administrators: $name" }
        foreach ($ace in $security.DiscretionaryAcl) {
            if ($ace.AceType -eq [Security.AccessControl.AceType]::AccessAllowed -and
                $ace.SecurityIdentifier.Value -notin @('S-1-5-18', 'S-1-5-32-544') -and
                ($ace.AccessMask -band 0x500D0006)) {
                throw "Task grants non-administrative write access: $name"
            }
        }
        $actual = Get-ScheduledTask -TaskName $name -TaskPath '\' -ErrorAction Stop
        if ((Resolve-AccountSid $actual.Principal.UserId) -ne $(if ($name -eq $taskName) { 'S-1-5-18' } else { $TargetSid })) {
            throw "Task principal verification failed: $name"
        }
    }
    Write-AtomicJson -Path (Join-Path $root 'task-status.json') -Value @{
        Task = $taskName; Principal = 'SYSTEM'; DiagnosticTask = $diagnosticTaskName
        TargetUser = $TargetUser; TargetSid = $TargetSid; InstalledCodeDirectory = $root
    }
    foreach ($name in @($taskName, $diagnosticTaskName)) {
        Enable-ScheduledTask -TaskName $name -TaskPath '\' | Out-Null
    }
    # Staged tasks refuse to act until this final, atomic activation record is durable.
    $state.Installed = $true
    $state.Status = 'Ready'
    Write-AtomicJson -Path $statePath -Value $state
}
catch {
    $failure = $_
    $cleanupErrors = @()
    foreach ($name in @($touchedTasks | Select-Object -Unique)) {
        try { Disable-ScheduledTask -TaskName $name -TaskPath '\' -ErrorAction Stop | Out-Null }
        catch { $cleanupErrors += $_.Exception.Message }
    }
    $state.Installed = $false
    $state.Status = 'Failed'
    $state.Error = $failure.Exception.Message
    $state.CleanupErrors = $cleanupErrors
    Write-AtomicJson -Path $statePath -Value $state
    throw $failure
}
