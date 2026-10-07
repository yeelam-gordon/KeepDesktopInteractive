param(
    [switch]$ConnectedSmokeTest,
    [switch]$MinimizedTest,
    [switch]$RequireInstalledSetup
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DesktopSessionSecurity.ps1')
$dataDirectory = Get-PrivateDesktopDataDirectory
$started = [DateTime]::UtcNow
$runDirectory = Join-Path $dataDirectory ("Diagnostics\" + $started.ToString('yyyyMMdd-HHmmss-fff') + "-$PID")
New-Item -ItemType Directory -Path $runDirectory -Force | Out-Null
$resultPath = Join-Path $runDirectory 'result.json'
$screenshotPath = Join-Path $runDirectory 'desktop-proof.png'
$latestPath = Join-Path $dataDirectory 'desktop-proof.json'
$logPath = Join-Path $runDirectory 'diagnostic.log'
$sessionId = (Get-Process -Id $PID).SessionId
$requireConsole = -not ($ConnectedSmokeTest -or $MinimizedTest)
$inputNotBeforeUtc = $started.AddSeconds($(if ($MinimizedTest) { 60 } else { 0 }))
$script:report = [ordered]@{
    Passed = $null
    Status = 'Running'
    User = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    SessionId = $sessionId
    Pid = $PID
    Mode = $(if ($MinimizedTest) { 'WhileClientMinimized' } elseif ($ConnectedSmokeTest) { 'ConnectedSmokeTest' } else { 'AfterDisconnect' })
    InputNotBeforeUtc = $inputNotBeforeUtc.ToString('o')
    ClientMinimizedState = $(if ($MinimizedTest) { 'User-controlled; not observable from the remote host' } else { 'Not applicable' })
    StartedUtc = $started.ToString('o')
    DiagnosticDirectory = $runDirectory
}
function Write-ProofResult([hashtable]$Result) {
    foreach ($key in $Result.Keys) { $script:report[$key] = $Result[$key] }
    if ($null -ne $script:report.Passed) {
        $script:report.Status = 'Completed'
        $script:report.CompletedUtc = [DateTime]::UtcNow.ToString('o')
    }
    $json = $script:report | ConvertTo-Json -Depth 6
    Set-Content -LiteralPath $resultPath -Value $json -Encoding UTF8
    Set-Content -LiteralPath $latestPath -Value $json -Encoding UTF8
}
function Write-DiagnosticLog([string]$Message) {
    Add-Content -LiteralPath $logPath -Value "$([DateTime]::UtcNow.ToString('o')) $Message" -Encoding UTF8
}
trap {
    Write-ProofResult @{ Passed = $false; Error = $_.Exception.Message; Stage = 'Unhandled error' }
    Write-DiagnosticLog "ERROR: $($_.Exception.Message)"
    exit 1
}
Write-ProofResult @{}
Write-DiagnosticLog "Started as $($script:report.User), PID=$PID, session=$sessionId, mode=$($script:report.Mode)."
if ($RequireInstalledSetup) {
    $installed = Get-Content -LiteralPath (Join-Path $env:ProgramData 'DevboxDesktopSession\setup-result.json') -Raw | ConvertFrom-Json
    if (-not $installed.Installed -or $installed.Status -ne 'Ready') {
        throw 'Setup is incomplete or inactive; diagnostics will not send input.'
    }
}
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class DesktopInput {
    [DllImport("kernel32.dll")] public static extern uint WTSGetActiveConsoleSessionId();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint x, uint y, uint data, UIntPtr extra);
    [DllImport("user32.dll", SetLastError = true)] public static extern IntPtr OpenInputDesktop(uint flags, bool inherit, uint access);
    [DllImport("user32.dll")] public static extern bool CloseDesktop(IntPtr desktop);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr window, int command);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr window);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern IntPtr GetProcessWindowStation();
    [DllImport("user32.dll")] public static extern IntPtr GetThreadDesktop(uint thread);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll", SetLastError = true)] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool GetUserObjectInformation(IntPtr obj, int index, StringBuilder buffer, int length, out int needed);
    public static string Name(IntPtr obj) {
        var buffer = new StringBuilder(256);
        int needed;
        if (!GetUserObjectInformation(obj, 2, buffer, 512, out needed))
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        return buffer.ToString();
    }
}
'@
$previousDpiContext = [DesktopInput]::SetThreadDpiAwarenessContext([IntPtr]::new(-4))
if ($previousDpiContext -eq [IntPtr]::Zero) {
    throw "Cannot establish DPI-consistent input coordinates: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())."
}
$script:report.WindowStation = [DesktopInput]::Name([DesktopInput]::GetProcessWindowStation())
$script:report.ThreadDesktop = [DesktopInput]::Name([DesktopInput]::GetThreadDesktop([DesktopInput]::GetCurrentThreadId()))
$script:report.ScreenBounds = [string][Windows.Forms.SystemInformation]::VirtualScreen
$form = [Windows.Forms.Form]::new()
$form.Text = 'Desktop automation verification'
$form.ClientSize = [Drawing.Size]::new(420, 160)
$form.StartPosition = 'CenterScreen'
$textbox = [Windows.Forms.TextBox]::new()
$textbox.Location = [Drawing.Point]::new(20, 20)
$textbox.Width = 370
$button = [Windows.Forms.Button]::new()
$button.Text = 'Verify mouse input'
$button.Location = [Drawing.Point]::new(20, 65)
$button.Size = [Drawing.Size]::new(180, 35)
$label = [Windows.Forms.Label]::new()
$label.Location = [Drawing.Point]::new(20, 115)
$label.Width = 380
$script:clicked = $false
$button.Add_Click({ $script:clicked = $true; $label.Text = 'Mouse input received.' })
$form.Controls.AddRange(@($textbox, $button, $label))
$context = [Windows.Forms.ApplicationContext]::new()
$timer = [Windows.Forms.Timer]::new()
$timer.Interval = 500
$deadline = (Get-Date).AddSeconds(150)
$script:finished = $false
$script:consoleSince = $null
function Wait-UiMessages([int]$Milliseconds) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    while ($watch.ElapsedMilliseconds -lt $Milliseconds) {
        [Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 20
    }
}
function Save-TestScreenshot {
    $bitmap = [Drawing.Bitmap]::new($form.Width, $form.Height)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($form.Location, [Drawing.Point]::Empty, $bitmap.Size)
        $bitmap.Save($screenshotPath, [Drawing.Imaging.ImageFormat]::Png)
    }
    finally { $graphics.Dispose(); $bitmap.Dispose() }
    $script:report.Screenshot = $screenshotPath
}
$timer.Add_Tick({
    if ($script:finished) { return }
    if ([DateTime]::UtcNow -lt $inputNotBeforeUtc) { return }
    $script:report.ConsoleSessionId = [DesktopInput]::WTSGetActiveConsoleSessionId()
    if ($MinimizedTest -and $script:report.ConsoleSessionId -eq $sessionId) {
        $script:finished = $true
        $timer.Stop()
        Write-ProofResult @{ Passed = $false; Error = 'Session moved to the console; this is not a connected minimized-client test.' }
        $context.ExitThread()
        return
    }
    if ($requireConsole -and $script:report.ConsoleSessionId -ne $sessionId) {
        if ((Get-Date) -lt $deadline) { return }
        $script:finished = $true
        $timer.Stop()
        Write-ProofResult @{ Passed = $false; Error = 'No console handoff within 150 seconds.' }
        $context.ExitThread()
        return
    }
    if (-not $script:consoleSince) { $script:consoleSince = Get-Date }
    $desktop = [DesktopInput]::OpenInputDesktop(0, $false, 1)
    $script:report.InputDesktopError = $(if ($desktop -eq [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::GetLastWin32Error() } else { 0 })
    $script:report.InputDesktop = ''
    if ($desktop -ne [IntPtr]::Zero) { $script:report.InputDesktop = [DesktopInput]::Name($desktop) }
    if ($desktop -eq [IntPtr]::Zero -or $script:report.InputDesktop -ne 'Default' -or ((Get-Date) - $script:consoleSince).TotalSeconds -lt 3) {
        if ($desktop -ne [IntPtr]::Zero) { [DesktopInput]::CloseDesktop($desktop) | Out-Null }
        if ((Get-Date) -lt $deadline) { return }
        $script:finished = $true
        $timer.Stop()
        Write-ProofResult @{ Passed = $false; Error = 'Console handoff did not produce an accessible Default input desktop within 150 seconds.' }
        $context.ExitThread()
        return
    }
    [DesktopInput]::CloseDesktop($desktop) | Out-Null
    $script:finished = $true
    $timer.Stop()
    $originalCursor = [Windows.Forms.Cursor]::Position
    try {
        $form.TopMost = $true
        $form.Show()
        # The hidden VBScript launcher supplies SW_HIDE on the first ShowWindow call.
        [void][DesktopInput]::ShowWindow($form.Handle, 5)
        $form.Activate()
        Wait-UiMessages 500
        $script:report.WindowVisible = [DesktopInput]::IsWindowVisible($form.Handle)
        $script:report.WindowBounds = [string]$form.Bounds
        Write-DiagnosticLog "Verification window visible=$($script:report.WindowVisible), bounds=$($form.Bounds)."
        if (-not $script:report.WindowVisible) { throw 'Verification window remained hidden.' }
        foreach ($control in @($textbox, $button)) {
            if ($requireConsole -and [DesktopInput]::WTSGetActiveConsoleSessionId() -ne $sessionId) {
                throw 'User reconnected during verification; refusing further input.'
            }
            $point = $control.PointToScreen([Drawing.Point]::new(15, 15))
            Write-DiagnosticLog "Clicking $($control.GetType().Name) at $point."
            if (-not [DesktopInput]::SetCursorPos($point.X, $point.Y)) { throw 'Cannot position the mouse.' }
            [DesktopInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
            [DesktopInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
            Wait-UiMessages 500
            if ($control -eq $textbox) {
                if (-not $textbox.Focused) { throw 'Mouse click did not focus the verification textbox; no keyboard input sent.' }
                [Windows.Forms.SendKeys]::SendWait('desktop proof')
                Wait-UiMessages 250
            }
        }
        Save-TestScreenshot
        if ($textbox.Text -ne 'desktop proof' -or -not $script:clicked) {
            throw "Real input verification failed: text='$($textbox.Text)', clicked=$script:clicked. Screenshot: $screenshotPath"
        }
        if ($requireConsole -and [DesktopInput]::WTSGetActiveConsoleSessionId() -ne $sessionId) {
            throw 'User reconnected before verification completed; result is not proof of disconnected automation.'
        }
        if ($MinimizedTest -and [DesktopInput]::WTSGetActiveConsoleSessionId() -eq $sessionId) {
            throw 'Session moved to the console during verification; this is not proof of minimized-client automation.'
        }
        Write-ProofResult @{ Passed = $true; TypedText = $textbox.Text; MouseClick = $script:clicked; Screenshot = $screenshotPath }
        Write-DiagnosticLog 'SUCCESS: real mouse, keyboard, and screen capture worked.'
    }
    catch {
        $failure = $_.Exception.Message
        $script:report.ForegroundIsTestWindow = [DesktopInput]::GetForegroundWindow() -eq $form.Handle
        if ([DesktopInput]::IsWindowVisible($form.Handle)) {
            try { Save-TestScreenshot }
            catch {
                $script:report.ScreenshotError = $_.Exception.Message
                Write-DiagnosticLog "Screenshot error: $($_.Exception.Message)"
            }
        }
        Write-ProofResult @{ Passed = $false; Error = $failure; TypedText = $textbox.Text; MouseClick = $script:clicked }
        Write-DiagnosticLog "ERROR: $failure"
    }
    finally {
        [Windows.Forms.Cursor]::Position = $originalCursor
        $form.Close()
        $context.ExitThread()
    }
})
try {
    $timer.Start()
    [Windows.Forms.Application]::Run($context)
}
finally {
    $timer.Dispose()
    $form.Dispose()
    $context.Dispose()
    [void][DesktopInput]::SetThreadDpiAwarenessContext($previousDpiContext)
}
$result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
if (-not $result.Passed) { exit 1 }
