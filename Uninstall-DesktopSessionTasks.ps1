param(
    [Parameter(Mandatory = $true)]
    [string]$TargetUser,
    [Parameter(Mandatory = $true)]
    [string]$TargetSid,
    [switch]$LegacyInstallation
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Initialize-DesktopSessionSecurity.ps1')
$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Administrator privileges are required.'
}
Assert-TrustedSource -Directory $PSScriptRoot -UserSid $TargetSid
$root = Join-Path $env:ProgramData 'KeepDesktopInteractive'
$legacyRoot = Join-Path $env:ProgramData 'DevboxDesktopSession'
if ($LegacyInstallation -or -not (Test-Path -LiteralPath $root)) { $root = $legacyRoot }
$installation = Join-Path $root 'setup-result.json'
Assert-TrustedPath -Path (Split-Path -Parent $installation) -WriterSids @()
foreach ($item in Get-ChildItem -LiteralPath $root -Force) {
    if ($item.PSIsContainer) { throw "Unexpected directory in protected installation: $($item.FullName)" }
    Assert-TrustedPath -Path $item.FullName -WriterSids @()
}
Assert-TrustedPath -Path $installation -WriterSids @()
$saved = Get-Content -LiteralPath $installation -Raw | ConvertFrom-Json
if ($saved.TargetUser -ne $TargetUser) { throw 'The installed tasks belong to another user.' }
if ([Security.Principal.NTAccount]::new($TargetUser).Translate([Security.Principal.SecurityIdentifier]).Value -ne $TargetSid) {
    throw 'TargetUser and TargetSid do not identify the same account.'
}
$expectedDescriptions = $script:DesktopSessionTaskDescriptions
$tasks = @(Get-ScheduledTask -ErrorAction Stop | Where-Object {
    $_.TaskPath -eq '\' -and $_.TaskName -in @($expectedDescriptions.Keys)
})
foreach ($task in $tasks) {
    if ($task.Description -ne $expectedDescriptions[$task.TaskName] -and
        -not ($task.TaskName -eq 'DiagnoseUIAutomationOnDisconnect' -and $task.Description -eq $script:LegacyDesktopDiagnosticDescription)) {
        throw "Refusing to remove an unrelated task: $($task.TaskName)"
    }
    if ($task.State -eq 'Running') {
        throw "Task $($task.TaskName) is running; wait for it to finish before uninstalling."
    }
    $expectedSid = $TargetSid
    if ($task.TaskName -eq 'KeepDesktopInteractiveOnDisconnect') { $expectedSid = 'S-1-5-18' }
    if ((Resolve-AccountSid $task.Principal.UserId) -ne $expectedSid) {
        throw "Refusing to remove a task with an unexpected principal: $($task.TaskName)"
    }
}
$scheduler = New-Object -ComObject 'Schedule.Service'
$scheduler.Connect()
foreach ($task in @($tasks | Sort-Object @{ Expression = { if ($_.TaskName -eq 'DiagnoseUIAutomationOnDisconnect') { 0 } else { 1 } } })) {
    Disable-ScheduledTask -TaskName $task.TaskName -TaskPath '\' | Out-Null
    if ($scheduler.GetFolder('\').GetTask($task.TaskName).GetInstances(0).Count -gt 0) {
        throw "Task $($task.TaskName) started during removal. Wait for it to finish and rerun setup."
    }
}
$saved.Installed = $false
$saved | Add-Member -MemberType NoteProperty -Name Status -Value 'Uninstalled' -Force
Write-AtomicJson -Path $installation -Value $saved
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath '\' -Confirm:$false
}
$saved.Installed = $false
$saved.Time = [DateTime]::UtcNow.ToString('o')
Write-AtomicJson -Path $installation -Value $saved
Write-Output 'Tasks removed. Logs and diagnostics were retained. Client registry settings were not changed.'
