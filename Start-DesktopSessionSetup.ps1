param(
    [switch]$Uninstall,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = 'Stop'
$resultPath = $null
try {
    if ($Uninstall -and $ReplaceExisting) { throw 'Uninstall and ReplaceExisting cannot be combined.' }
    . (Join-Path $PSScriptRoot 'Initialize-DesktopSessionSecurity.ps1')
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $resultPath = Join-Path (Get-PrivateDesktopDataDirectory) 'elevation-result.json'
    Assert-TrustedSource -Directory $PSScriptRoot -UserSid $identity.User.Value
    $installer = Join-Path $PSScriptRoot 'Install-DesktopSessionTasks.ps1'
    if ($Uninstall) {
        $installer = Join-Path $PSScriptRoot 'Uninstall-DesktopSessionTasks.ps1'
    }
    $arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$installer`" -TargetUser `"$($identity.Name)`" -TargetSid `"$($identity.User.Value)`""
    if ($ReplaceExisting) { $arguments += ' -RemovePreviousFirst' }
    $process = Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru
    try {
        if (-not $process.WaitForExit(60000)) {
            $closed = $process.CloseMainWindow()
            if (-not $process.WaitForExit(3000)) {
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
            }
            throw "Elevated setup exceeded 60 seconds; PID=$($process.Id); graceful-close-request=$closed; process stopped."
        }
        @{ ExitCode = $process.ExitCode; Pid = $process.Id; Time = (Get-Date -Format o) } |
            ConvertTo-Json | Set-Content -LiteralPath $resultPath -Encoding UTF8
        if ($process.ExitCode -ne 0) { exit 1 }
    }
    finally { $process.Dispose() }
}
catch {
    if ($resultPath) {
        @{ Error = $_.Exception.Message; Time = (Get-Date -Format o) } |
            ConvertTo-Json | Set-Content -LiteralPath $resultPath -Encoding UTF8
    }
    Write-Error -ErrorRecord $_ -ErrorAction Continue
    exit 1
}
