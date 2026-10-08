param([switch]$SyntaxOnly)

$ErrorActionPreference = 'Stop'
foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1') {
    $tokens = $null
    $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "Invalid script $($file.Name): $($errors | Out-String)" }
    if ($file.FullName -eq $PSCommandPath) { continue }
    foreach ($command in $ast.FindAll({
        param($node)
        $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Add-Type'
    }, $true)) {
        for ($index = 0; $index -lt $command.CommandElements.Count - 1; $index++) {
            $element = $command.CommandElements[$index]
            if ($element -is [Management.Automation.Language.CommandParameterAst] -and $element.ParameterName -eq 'TypeDefinition') {
                $source = $command.CommandElements[$index + 1]
                if ($source -isnot [Management.Automation.Language.StringConstantExpressionAst]) {
                    throw "Embedded C# in $($file.Name) must be a literal for static checking."
                }
                Add-Type -TypeDefinition $source.Value -ErrorAction Stop
            }
        }
    }
}
if ($SyntaxOnly) {
    Write-Output 'PASS: all PowerShell scripts parsed and embedded C# compiled; no project script or native session operation was executed.'
    return
}
$launchers = @{
    'launch-desktop-session-setup.vbs' = 'Start-DesktopSessionSetup.ps1'
    'set-local-rdp-minimize-rendering.vbs' = 'Set-LocalRdpMinimizeRendering.ps1'
    'test-desktop-after-disconnect.vbs' = 'Test-InteractiveDesktopAutomation.ps1'
}
foreach ($name in $launchers.Keys) {
    $text = Get-Content -LiteralPath (Join-Path $PSScriptRoot $name) -Raw
    if ($text -notmatch [regex]::Escape($launchers[$name]) -or
        $text -notmatch 'shell\.Run\(command, 0, True\)' -or
        $text -notmatch [regex]::Escape('%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe')) {
        throw "Launcher $name is not wired to its expected script in hidden, synchronous mode."
    }
}
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$sessionId = (Get-Process -Id $PID).SessionId
$script = Join-Path $PSScriptRoot 'Move-DisconnectedSessionToConsole.ps1'
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
    $sessions = @()
    if (-not [string]::IsNullOrWhiteSpace($output)) {
        $sessions = @($output | ConvertFrom-Json)
    }
    if ($sessionId -gt 0 -and -not ($sessions | Where-Object { $_.Id -eq $sessionId -and $_.Owner -eq $identity.Name })) {
        throw 'Read-only session discovery did not find the current user session.'
    }
}
finally { $process.Dispose() }
Write-Output 'PASS: PowerShell syntax, hidden launcher wiring, and read-only user-session discovery.'
