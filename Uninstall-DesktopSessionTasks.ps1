param(
    [Parameter(Mandatory = $true)]
    [string]$TargetUser,
    [Parameter(Mandatory = $true)]
    [string]$TargetSid
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Initialize-DesktopSessionSecurity.ps1')
$principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Administrator privileges are required.'
}
Assert-TrustedSource -Directory $PSScriptRoot -UserSid $TargetSid
$installation = Join-Path $env:ProgramData 'DevboxDesktopSession\setup-result.json'
Assert-TrustedPath -Path (Split-Path -Parent $installation) -WriterSids @()
Assert-TrustedPath -Path $installation -WriterSids @()
$saved = Get-Content -LiteralPath $installation -Raw | ConvertFrom-Json
if ($saved.TargetUser -ne $TargetUser) { throw 'The installed tasks belong to another user.' }
if ([Security.Principal.NTAccount]::new($TargetUser).Translate([Security.Principal.SecurityIdentifier]).Value -ne $TargetSid) {
    throw 'TargetUser and TargetSid do not identify the same account.'
}
$expectedDescriptions = @{
    KeepDesktopInteractiveOnDisconnect = "Keep the selected user's desktop interactive after remote disconnect by transferring their disconnected session to the console. No autologon or stored credentials."
    DiagnoseUIAutomationOnDisconnect = 'Run bounded desktop input diagnostics as the logged-in user after remote disconnect; save results without requiring Copilot to remain connected.'
}
$tasks = @(Get-ScheduledTask -ErrorAction Stop | Where-Object {
    $_.TaskPath -eq '\' -and $_.TaskName -in @($expectedDescriptions.Keys)
})
foreach ($task in $tasks) {
    if ($task.Description -ne $expectedDescriptions[$task.TaskName]) {
        throw "Refusing to remove an unrelated task: $($task.TaskName)"
    }
    if ($task.State -eq 'Running') {
        throw "Task $($task.TaskName) is running; wait for it to finish before uninstalling."
    }
}
foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskName $task.TaskName -TaskPath '\' | Out-Null
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
