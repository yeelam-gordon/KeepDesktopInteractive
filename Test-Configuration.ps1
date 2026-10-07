$ErrorActionPreference = 'Stop'
foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1') {
    $tokens = $null
    $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw "Invalid script $($file.Name): $($errors | Out-String)" }
}
$launchers = @{
    'launch-desktop-session-setup.vbs' = 'Launch-DesktopSessionSetup.ps1'
    'set-local-rdp-minimize-rendering.vbs' = 'Set-LocalRdpMinimizeRendering.ps1'
    'test-desktop-after-disconnect.vbs' = 'Test-DesktopAfterDisconnect.ps1'
}
foreach ($name in $launchers.Keys) {
    $text = Get-Content -LiteralPath (Join-Path $PSScriptRoot $name) -Raw
    if ($text -notmatch [regex]::Escape($launchers[$name]) -or
        $text -notmatch 'shell\.Run\(command, 0, True\)') {
        throw "Launcher $name is not wired to its expected script in hidden, synchronous mode."
    }
}
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$sessionId = (Get-Process -Id $PID).SessionId
$script = Join-Path $PSScriptRoot 'Keep-DesktopInteractive.ps1'
$command = "& '$($script.Replace("'", "''"))' -TargetUser '$($identity.Name.Replace("'", "''"))' -InspectOnly"
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
$info = [Diagnostics.ProcessStartInfo]::new()
$info.FileName = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$info.Arguments = "-NoProfile -NonInteractive -EncodedCommand $encoded"
$info.UseShellExecute = $false
$info.CreateNoWindow = $true
$info.RedirectStandardOutput = $true
$info.RedirectStandardError = $true
$process = [Diagnostics.Process]::Start($info)
try {
    if (-not $process.WaitForExit(15000)) {
        $process.Kill()
        throw "Session inspection timeout after 15 seconds; terminated launched PID=$($process.Id)."
    }
    $output = $process.StandardOutput.ReadToEnd()
    $errorText = $process.StandardError.ReadToEnd()
    if ($process.ExitCode -ne 0) { throw "Session inspection failed: $errorText" }
    $sessions = @($output | ConvertFrom-Json)
    if ($sessionId -gt 0 -and -not ($sessions | Where-Object { $_.Id -eq $sessionId -and $_.Owner -eq $identity.Name })) {
        throw 'Read-only session discovery did not find the current user session.'
    }
}
finally { $process.Dispose() }
Write-Output 'PASS: PowerShell syntax, hidden launcher wiring, and read-only user-session discovery.'
