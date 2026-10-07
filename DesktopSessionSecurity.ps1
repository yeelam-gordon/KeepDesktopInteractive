$ErrorActionPreference = 'Stop'
$script:AdministrativeSids = @('S-1-5-18', 'S-1-5-32-544')
$script:TrustedInstallerSid = 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'
if (-not ('DesktopFileSecurity' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
public static class DesktopFileSecurity {
    [StructLayout(LayoutKind.Sequential)]
    public struct FileInformation {
        public uint Attributes;
        public System.Runtime.InteropServices.ComTypes.FILETIME Creation;
        public System.Runtime.InteropServices.ComTypes.FILETIME Access;
        public System.Runtime.InteropServices.ComTypes.FILETIME Write;
        public uint Volume;
        public uint SizeHigh;
        public uint SizeLow;
        public uint Links;
        public uint IndexHigh;
        public uint IndexLow;
    }
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetFileInformationByHandle(SafeFileHandle file, out FileInformation info);
    public static void CheckSingleLink(string path) {
        using (var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read)) {
            FileInformation info;
            if (!GetFileInformationByHandle(stream.SafeFileHandle, out info))
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            if (info.Links != 1)
                throw new InvalidOperationException("Hard-linked files are not accepted: " + path);
        }
    }
}
'@
}

function Resolve-AccountSid([string]$Account) {
    if ($Account -match '^S-1-') { return [Security.Principal.SecurityIdentifier]::new($Account).Value }
    return [Security.Principal.NTAccount]::new($Account).Translate([Security.Principal.SecurityIdentifier]).Value
}

function Assert-TrustedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$WriterSids,
        [switch]$AncestorsOnly
    )
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    $first = $true
    while ($item) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Reparse points are not accepted: $($item.FullName)"
        }
        $acl = Get-Acl -LiteralPath $item.FullName
        $trusted = @($WriterSids) + $script:AdministrativeSids + @($script:TrustedInstallerSid)
        $owner = $acl.GetOwner([Security.Principal.SecurityIdentifier]).Value
        if ($owner -notin $trusted) { throw "Untrusted filesystem owner $owner at $($item.FullName)" }
        # Parents may allow creating new children, but must not let other users replace this path.
        $mask = 0xD0040
        if ($first -and -not $AncestorsOnly) { $mask = 0xD0156 }
        foreach ($rule in $acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
            if ($rule.AccessControlType -ne [Security.AccessControl.AccessControlType]::Allow -or
                ($rule.PropagationFlags -band [Security.AccessControl.PropagationFlags]::InheritOnly)) { continue }
            if ($rule.IdentityReference.Value -notin $trusted -and ([int]$rule.FileSystemRights -band $mask)) {
                throw "Untrusted write/replace permissions for $($rule.IdentityReference.Value) at $($item.FullName)"
            }
        }
        if ($first -and -not $item.PSIsContainer) { [DesktopFileSecurity]::CheckSingleLink($item.FullName) }
        $first = $false
        if ($item.PSIsContainer) { $item = $item.Parent }
        else { $item = $item.Directory }
    }
}

function Assert-TrustedSource([string]$Directory, [string]$UserSid) {
    Assert-TrustedPath -Path $Directory -WriterSids @($UserSid)
    foreach ($file in Get-ChildItem -LiteralPath $Directory -File) {
        if ($file.Extension -in @('.ps1', '.vbs')) {
            Assert-TrustedPath -Path $file.FullName -WriterSids @($UserSid)
        }
    }
}

function New-SecuredDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$OwnerSid,
        [string]$ReaderSid
    )
    $parent = Split-Path -Parent $Path
    Assert-TrustedPath -Path $parent -WriterSids @($OwnerSid) -AncestorsOnly
    if (Test-Path -LiteralPath $Path) {
        Assert-TrustedPath -Path $Path -WriterSids @($OwnerSid)
        return
    }
    $acl = [Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner([Security.Principal.SecurityIdentifier]::new($OwnerSid))
    foreach ($sid in @($script:AdministrativeSids + @($OwnerSid) | Select-Object -Unique)) {
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
            [Security.Principal.SecurityIdentifier]::new($sid), 'FullControl',
            'ContainerInherit, ObjectInherit', 'None', 'Allow'
        ))
    }
    if ($ReaderSid -and $ReaderSid -ne $OwnerSid) {
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
            [Security.Principal.SecurityIdentifier]::new($ReaderSid), 'ReadAndExecute',
            'ContainerInherit, ObjectInherit', 'None', 'Allow'
        ))
    }
    # Windows PowerShell/.NET Framework creates the directory with its final DACL.
    [IO.Directory]::CreateDirectory($Path, $acl) | Out-Null
    Assert-TrustedPath -Path $Path -WriterSids @($OwnerSid)
}

function Get-PrivateDesktopDataDirectory {
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    Assert-TrustedPath -Path $env:LOCALAPPDATA -WriterSids @($sid)
    $directory = Join-Path $env:LOCALAPPDATA 'KeepDesktopInteractive'
    New-SecuredDirectory -Path $directory -OwnerSid $sid
    return $directory
}

function Set-InstalledDirectoryPermissions([string]$Path, [string]$ReaderSid) {
    Assert-TrustedPath -Path $Path -WriterSids @()
    $children = @(Get-ChildItem -LiteralPath $Path -Force)
    foreach ($child in $children) {
        if ($child.PSIsContainer) { throw "Unexpected directory in protected installation: $($child.FullName)" }
        Assert-TrustedPath -Path $child.FullName -WriterSids @()
    }
    foreach ($item in @((Get-Item -LiteralPath $Path)) + $children) {
        if ($item.PSIsContainer) { $acl = [Security.AccessControl.DirectorySecurity]::new() }
        else { $acl = [Security.AccessControl.FileSecurity]::new() }
        $acl.SetAccessRuleProtection($true, $false)
        $acl.SetOwner([Security.Principal.SecurityIdentifier]::new('S-1-5-32-544'))
        foreach ($sid in @($script:AdministrativeSids + @($ReaderSid))) {
            $rights = 'FullControl'
            if ($sid -eq $ReaderSid) { $rights = 'ReadAndExecute' }
            if ($item.PSIsContainer) {
                $rule = [Security.AccessControl.FileSystemAccessRule]::new(
                    [Security.Principal.SecurityIdentifier]::new($sid), $rights,
                    'ContainerInherit, ObjectInherit', 'None', 'Allow'
                )
            }
            else {
                $rule = [Security.AccessControl.FileSystemAccessRule]::new(
                    [Security.Principal.SecurityIdentifier]::new($sid), $rights, 'Allow'
                )
            }
            $acl.AddAccessRule($rule)
        }
        Set-Acl -LiteralPath $item.FullName -AclObject $acl
    }
}

function Write-AtomicJson([string]$Path, [object]$Value) {
    $temporary = Join-Path (Split-Path -Parent $Path) ([IO.Path]::GetRandomFileName() + '.tmp')
    $json = $Value | ConvertTo-Json -Depth 8
    $stream = [IO.FileStream]::new($temporary, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        $bytes = [Text.UTF8Encoding]::new($false).GetBytes($json)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush($true)
    }
    finally { $stream.Dispose() }
    try {
        if (Test-Path -LiteralPath $Path) { [IO.File]::Replace($temporary, $Path, $null) }
        else { [IO.File]::Move($temporary, $Path) }
    }
    finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    }
}
