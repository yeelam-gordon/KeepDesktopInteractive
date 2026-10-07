param(
    [switch]$VerifyDisconnect,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$resultPath = Join-Path $PSScriptRoot 'elevation-result.json'
try {
    $installer = Join-Path $PSScriptRoot 'Install-DesktopSessionTask.ps1'
    if ($Uninstall) {
        if ($VerifyDisconnect) { throw 'Uninstall cannot be combined with VerifyDisconnect.' }
        $installer = Join-Path $PSScriptRoot 'Uninstall-DesktopSessionTasks.ps1'
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$installer`" -TargetUser `"$($identity.Name)`" -TargetSid `"$($identity.User.Value)`""
    if ($VerifyDisconnect) {
        $arguments += " -TestSessionId $((Get-Process -Id $PID).SessionId)"
    }
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
    @{ Error = $_.Exception.Message; Time = (Get-Date -Format o) } |
        ConvertTo-Json | Set-Content -LiteralPath $resultPath -Encoding UTF8
    exit 1
}
