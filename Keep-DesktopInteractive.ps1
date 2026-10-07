param(
    [Parameter(Mandatory = $true)]
    [string]$TargetUser,
    [switch]$InspectOnly
)

$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class DesktopSessions {
    [StructLayout(LayoutKind.Sequential)]
    public struct Session {
        public int Id;
        public IntPtr Station;
        public int State;
    }
    [DllImport("wtsapi32.dll", SetLastError = true)]
    public static extern bool WTSEnumerateSessions(IntPtr server, int reserved, int version, out IntPtr sessions, out int count);
    [DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool WTSQuerySessionInformation(IntPtr server, int id, int info, out IntPtr buffer, out int bytes);
    [DllImport("wtsapi32.dll")]
    public static extern void WTSFreeMemory(IntPtr buffer);
    [DllImport("kernel32.dll")]
    public static extern uint WTSGetActiveConsoleSessionId();
    public static string Query(int id, int info) {
        IntPtr buffer;
        int bytes;
        if (!WTSQuerySessionInformation(IntPtr.Zero, id, info, out buffer, out bytes))
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        try { return Marshal.PtrToStringUni(buffer) ?? ""; }
        finally { WTSFreeMemory(buffer); }
    }
    public static Session[] List() {
        IntPtr buffer;
        int count;
        if (!WTSEnumerateSessions(IntPtr.Zero, 0, 1, out buffer, out count))
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        try {
            var result = new Session[count];
            int size = Marshal.SizeOf(typeof(Session));
            for (int i = 0; i < count; ++i)
                result[i] = (Session)Marshal.PtrToStructure(IntPtr.Add(buffer, i * size), typeof(Session));
            return result;
        } finally { WTSFreeMemory(buffer); }
    }
}
'@

function Get-SessionOwner([int]$SessionId) {
    $user = [DesktopSessions]::Query($SessionId, 5)
    if (-not $user) { return '' }
    $domain = [DesktopSessions]::Query($SessionId, 7)
    if ($domain) { return "$domain\$user" }
    return $user
}

function Write-SessionLog([string]$Message) {
    $line = "$(Get-Date -Format o) $Message"
    if ($InspectOnly) { Write-Output $line; return }
    $log = Join-Path $env:ProgramData 'DevboxDesktopSession\session-handoff.log'
    if ((Test-Path $log) -and (Get-Item $log).Length -gt 1MB) {
        Move-Item $log "$log.previous" -Force
    }
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
}

try {
    $sessions = @(
        foreach ($session in [DesktopSessions]::List()) {
            if ($session.Id -gt 0 -and $session.State -in @(0, 4)) {
                $owner = Get-SessionOwner $session.Id
                if ($owner -eq $TargetUser) {
                    [pscustomobject]@{
                        Id = $session.Id
                        State = $session.State
                        Owner = $owner
                        Station = [DesktopSessions]::Query($session.Id, 6)
                    }
                }
            }
        }
    )
    if ($InspectOnly) {
        $sessions | ConvertTo-Json -Depth 3
        exit 0
    }
    $disconnected = @($sessions | Where-Object State -eq 4)
    if ($disconnected.Count -eq 0) {
        Write-SessionLog "No disconnected session for $TargetUser; no action."
        exit 0
    }
    if ($disconnected.Count -ne 1) {
        throw "Found $($disconnected.Count) disconnected sessions for $TargetUser; refusing an ambiguous handoff."
    }
    $consoleId = [DesktopSessions]::WTSGetActiveConsoleSessionId()
    if ($consoleId -ne [uint32]::MaxValue) {
        $consoleOwner = Get-SessionOwner ([int]$consoleId)
        if ($consoleOwner -and $consoleOwner -ne $TargetUser) {
            throw "Console session $consoleId belongs to another user; refusing to displace it."
        }
    }
    $id = $disconnected[0].Id
    Write-SessionLog "Transferring disconnected session $id for $TargetUser to console."
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = "$env:SystemRoot\System32\tscon.exe"
    $start.Arguments = "$id /dest:console"
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [Diagnostics.Process]::Start($start)
    try {
        if (-not $process.WaitForExit(15000)) {
            $process.Kill()
            throw "tscon timeout after 15 seconds; terminated launched PID $($process.Id)."
        }
        $output = $process.StandardOutput.ReadToEnd() + $process.StandardError.ReadToEnd()
        if ($process.ExitCode -ne 0) {
            throw "tscon PID $($process.Id) exited $($process.ExitCode): $output"
        }
    }
    finally { $process.Dispose() }
    if ([DesktopSessions]::WTSGetActiveConsoleSessionId() -ne $id) {
        throw "tscon exited successfully, but session $id is not the active console."
    }
    Write-SessionLog "SUCCESS: session $id is the active console."
}
catch {
    Write-SessionLog "ERROR: $($_.Exception.Message)"
    Write-Error -ErrorRecord $_ -ErrorAction Continue
    exit 1
}
