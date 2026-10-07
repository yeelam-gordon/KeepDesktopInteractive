param([switch]$Installed)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DesktopSessionSecurity.ps1')
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$directory = Join-Path $env:LOCALAPPDATA ('KeepDesktopSecurityTest-' + [Guid]::NewGuid().ToString('N'))
$file = Join-Path $directory 'example.ps1'
$link = Join-Path $directory 'linked.ps1'
$junction = Join-Path $directory 'junction'
$target = Join-Path $directory 'target'
$json = Join-Path $directory 'state.json'
function Expect-Rejection([scriptblock]$Action, [string]$Name) {
    $rejected = $false
    try { & $Action }
    catch { $rejected = $true }
    if (-not $rejected) { throw "Security check did not reject $Name." }
}
try {
    New-SecuredDirectory -Path $directory -OwnerSid $sid
    Set-Content -LiteralPath $file -Value '$true' -Encoding UTF8
    Assert-TrustedSource -Directory $directory -UserSid $sid
    Expect-Rejection { Assert-TrustedPath -Path $directory -WriterSids @() } 'a user-owned protected installation'
    $original = Get-Acl -LiteralPath $file
    $writable = Get-Acl -LiteralPath $file
    $writable.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
        [Security.Principal.SecurityIdentifier]::new('S-1-5-32-545'), 'Modify', 'Allow'
    ))
    Set-Acl -LiteralPath $file -AclObject $writable
    Expect-Rejection { Assert-TrustedPath -Path $file -WriterSids @($sid) } 'other-user writable source'
    Set-Acl -LiteralPath $file -AclObject $original
    Assert-TrustedPath -Path $file -WriterSids @($sid)
    New-Item -ItemType HardLink -Path $link -Target $file | Out-Null
    Expect-Rejection { Assert-TrustedPath -Path $file -WriterSids @($sid) } 'a hard-linked executable'
    Remove-Item -LiteralPath $link -Force
    New-Item -ItemType Directory -Path $target | Out-Null
    New-Item -ItemType Junction -Path $junction -Target $target | Out-Null
    Expect-Rejection { Assert-TrustedPath -Path $junction -WriterSids @($sid) } 'a reparse-point directory'
    Write-AtomicJson -Path $json -Value @{ Installed = $false; Status = 'Staged' }
    Write-AtomicJson -Path $json -Value @{ Installed = $true; Status = 'Ready' }
    $state = Get-Content -LiteralPath $json -Raw | ConvertFrom-Json
    if (-not $state.Installed -or $state.Status -ne 'Ready') { throw 'Atomic setup state update failed.' }
    if ($Installed) {
        $root = Join-Path $env:ProgramData 'DevboxDesktopSession'
        Assert-TrustedPath -Path $root -WriterSids @()
        foreach ($name in @('DesktopSessionSecurity.ps1', 'Test-DesktopAfterDisconnect.ps1', 'test-desktop-after-disconnect.vbs')) {
            $path = Join-Path $root $name
            Assert-TrustedPath -Path $path -WriterSids @()
            $stream = $null
            $denied = $false
            try { $stream = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Write, [IO.FileShare]::Read) }
            catch [UnauthorizedAccessException] { $denied = $true }
            finally { if ($stream) { $stream.Dispose() } }
            if (-not $denied) { throw "Normal user can open installed code for writing: $name" }
        }
        $setup = Get-Content -LiteralPath (Join-Path $root 'setup-result.json') -Raw | ConvertFrom-Json
        if (-not $setup.Installed -or $setup.Status -ne 'Ready' -or $setup.TargetSid -ne $sid) {
            throw 'Protected installation is not ready for this user.'
        }
        $diagnostic = Get-ScheduledTask -TaskName 'DiagnoseUIAutomationOnDisconnect' -ErrorAction Stop
        $expected = '"' + (Join-Path $root 'test-desktop-after-disconnect.vbs') + '" --installed'
        if ($diagnostic.Actions.Arguments -ne $expected -or $diagnostic.State -eq 'Disabled') {
            throw 'Diagnostic task is not wired to enabled, protected installed code.'
        }
        $folder = New-Object -ComObject 'Schedule.Service'
        $folder.Connect()
        foreach ($name in @('KeepDesktopInteractiveOnDisconnect', 'DiagnoseUIAutomationOnDisconnect')) {
            $security = [Security.AccessControl.RawSecurityDescriptor]::new($folder.GetFolder('\').GetTask($name).GetSecurityDescriptor(5))
            if ($security.Owner.Value -ne 'S-1-5-32-544') { throw "Task owner is not Administrators: $name" }
            foreach ($ace in $security.DiscretionaryAcl) {
                if ($ace.AceType -eq [Security.AccessControl.AceType]::AccessAllowed -and
                    $ace.SecurityIdentifier.Value -notin @('S-1-5-18', 'S-1-5-32-544') -and
                    ($ace.AccessMask -band 0x500D0006)) {
                    throw "Task grants non-administrative write access: $name"
                }
            }
        }
    }
}
finally {
    if (Test-Path -LiteralPath $junction) { [IO.Directory]::Delete($junction) }
    foreach ($path in @($link, $file, $json)) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
    if (Test-Path -LiteralPath $target) { [IO.Directory]::Delete($target) }
    if (Test-Path -LiteralPath $directory) { [IO.Directory]::Delete($directory) }
}
Write-Output 'PASS: ownership/write ACL checks, hard-link and reparse rejection, atomic state updates, and requested installation checks.'
