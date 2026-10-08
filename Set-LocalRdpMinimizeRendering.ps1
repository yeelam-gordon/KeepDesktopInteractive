param([switch]$Restore)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Initialize-DesktopSessionSecurity.ps1')
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
Assert-TrustedSource -Directory $PSScriptRoot -UserSid $identity.User.Value
$dataDirectory = Get-PrivateDesktopDataDirectory
$backupPath = Join-Path $dataDirectory 'local-rdp-minimize-backup.json'
$resultPath = Join-Path $dataDirectory 'local-rdp-minimize-result.json'
$registryPath = 'Software\Microsoft\Terminal Server Client'
$valueName = 'RemoteDesktop_SuppressWhenMinimized'
$views = @([Microsoft.Win32.RegistryView]::Registry32)
if ([Environment]::Is64BitOperatingSystem) {
    $views += [Microsoft.Win32.RegistryView]::Registry64
}

try {
    Add-Type -AssemblyName System.Windows.Forms
    if ([Windows.Forms.SystemInformation]::TerminalServerSession) {
        throw 'Run this script on the local PC running Windows App, not inside the Devbox or another remote desktop.'
    }
    if (-not $Restore -and -not (Test-Path -LiteralPath $backupPath)) {
        $originalValues = foreach ($view in $views) {
            $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::CurrentUser, $view)
            $key = $null
            try {
                $key = $base.OpenSubKey($registryPath)
                $exists = $null -ne $key -and $key.GetValueNames() -contains $valueName
                [pscustomobject]@{
                    View = [string]$view
                    Exists = $exists
                    Kind = $(if ($exists) { [string]$key.GetValueKind($valueName) } else { $null })
                    Value = $(if ($exists) { $key.GetValue($valueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) } else { $null })
                }
            }
            finally {
                if ($key) { $key.Dispose() }
                $base.Dispose()
            }
        }
        @{
            Computer = $env:COMPUTERNAME
            UserSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
            Values = @($originalValues)
        } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $backupPath -Encoding UTF8
    }
    $backup = Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json
    if ($backup.Computer -ne $env:COMPUTERNAME -or $backup.UserSid -ne [Security.Principal.WindowsIdentity]::GetCurrent().User.Value) {
        throw 'The registry backup belongs to another computer or user. Do not reuse it here.'
    }
    if (@($backup.Values).Count -ne $views.Count -or
        @($backup.Values | Select-Object -ExpandProperty View -Unique).Count -ne $views.Count) {
        throw 'The registry backup does not contain the expected registry views.'
    }
    foreach ($entry in $backup.Values) {
        if ($entry.View -notin @($views | ForEach-Object { [string]$_ })) {
            throw "Unexpected registry view in backup: $($entry.View)"
        }
        $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
            [Microsoft.Win32.RegistryHive]::CurrentUser,
            [Microsoft.Win32.RegistryView]$entry.View
        )
        $key = $null
        try {
            $key = $base.CreateSubKey($registryPath)
            if ($Restore) {
                if ($entry.Exists) {
                    $value = $entry.Value
                    $kind = [Microsoft.Win32.RegistryValueKind]$entry.Kind
                    if ($kind -eq [Microsoft.Win32.RegistryValueKind]::Binary) { $value = [byte[]]$value }
                    if ($kind -eq [Microsoft.Win32.RegistryValueKind]::MultiString) { $value = [string[]]$value }
                    $key.SetValue($valueName, $value, $kind)
                    $actual = $key.GetValue($valueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                    if ($key.GetValueKind($valueName) -ne $kind -or (ConvertTo-Json -InputObject $actual -Compress) -ne (ConvertTo-Json -InputObject $value -Compress)) {
                        throw "Restore verification failed for registry view $($entry.View)."
                    }
                }
                else {
                    $key.DeleteValue($valueName, $false)
                    if ($key.GetValueNames() -contains $valueName) { throw "Restore verification failed for registry view $($entry.View)." }
                }
            }
            else {
                $key.SetValue($valueName, 2, [Microsoft.Win32.RegistryValueKind]::DWord)
                if ($key.GetValue($valueName) -ne 2 -or $key.GetValueKind($valueName) -ne [Microsoft.Win32.RegistryValueKind]::DWord) {
                    throw "Registry verification failed for view $($entry.View)."
                }
            }
        }
        finally {
            if ($key) { $key.Dispose() }
            $base.Dispose()
        }
    }
    @{
        Succeeded = $true
        Restored = [bool]$Restore
        Computer = $env:COMPUTERNAME
        TimeUtc = [DateTime]::UtcNow.ToString('o')
        WindowsAppMinimizedAutomationVerified = $false
    } | ConvertTo-Json | Set-Content -LiteralPath $resultPath -Encoding UTF8
    Write-Output 'Registry settings verified. Close and reopen Windows App. Minimized UI automation still needs a live test.'
}
catch {
    @{ Succeeded = $false; Error = $_.Exception.Message; TimeUtc = [DateTime]::UtcNow.ToString('o') } |
        ConvertTo-Json | Set-Content -LiteralPath $resultPath -Encoding UTF8
    throw
}
