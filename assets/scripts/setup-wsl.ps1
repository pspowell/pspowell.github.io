<#
.SYNOPSIS
  Windows side of "Power-user WSL setup from scratch".
  https://pspowell.github.io/2026/11/14/power-user-wsl-setup-from-scratch.html

.DESCRIPTION
  1. Installs WSL2 and the Ubuntu distro if needed (optionally wipes it first with -Fresh).
  2. Creates your Linux user without the first-launch prompt and makes it the default.
  3. Runs wsl-bootstrap.sh inside Ubuntu (packages, wsl.conf, shell, Git, SSH, uv, nvm,
     editor, tmux, WSLg apps).
  4. Runs wsl --shutdown so /etc/wsl.conf takes effect.
  5. Installs a Nerd Font and sets Windows Terminal defaults (Ubuntu as default
     profile, font, scrollback).

  Safe to re-run. Run from an elevated PowerShell the first time (installing WSL
  needs admin). If Windows asks for a reboot, reboot and run the same command again.

.EXAMPLE
  .\setup-wsl.ps1 -GitName "Jane Smith" -GitEmail jane@example.com

.EXAMPLE
  .\setup-wsl.ps1 -GitName "Jane Smith" -GitEmail jane@example.com -Zsh -GitHub -NoGui

.EXAMPLE
  .\setup-wsl.ps1 -TerminalOnly
#>
[CmdletBinding()]
param(
    [string]$Distro   = 'Ubuntu',
    [string]$UserName = ($env:USERNAME.ToLower() -replace '[^a-z0-9_-]', ''),
    [string]$GitName,
    [string]$GitEmail,
    [switch]$Fresh,          # unregister (DELETE) the distro first
    [switch]$Force,          # skip the -Fresh confirmation
    [switch]$Zsh,            # make zsh the login shell
    [switch]$NoNode,         # skip nvm + Node
    [switch]$NoGui,          # skip WSLg GUI apps
    [switch]$NoSsh,          # skip SSH key + config
    [switch]$NoPassphrase,   # SSH key without passphrase
    [switch]$GitHub,         # install gh, sign in, upload SSH key
    [switch]$SkipTerminal,   # leave Windows Terminal alone
    [switch]$TerminalOnly,   # only do the Windows Terminal part
    [string]$FontZip  = 'CascadiaCode',              # Nerd Fonts release asset name
    [string]$FontFace = 'CaskaydiaCove Nerd Font',   # face name inside that zip
    [int]$HistorySize = 50000,
    [Nullable[bool]]$CopyOnSelect = $null,           # leave unset unless you pass $true/$false
    [string]$BootstrapUrl = 'https://pspowell.github.io/assets/scripts/wsl-bootstrap.sh'
)

$ErrorActionPreference = 'Stop'
$env:WSL_UTF8 = '1'   # plain UTF-8 output from wsl.exe

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'wsl.exe not found. This needs Windows 10 2004+ or Windows 11.'
}

function Say($msg)  { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Note($msg) { Write-Host "    $msg" }
function Warn($msg) { Write-Host "    ! $msg" -ForegroundColor Yellow }

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# wsl.exe writes UTF-16; strip the NULs so PowerShell 5.1 can compare names.
# PowerShell 5.1 turns native stderr into terminating errors under 'Stop',
# so quiet wsl.exe calls run with 'Continue'.
function Invoke-WslQuiet {
    $ErrorActionPreference = 'Continue'
    & wsl.exe @args 2>$null
}

function Get-WslDistros {
    $out = Invoke-WslQuiet -l -q
    if ($LASTEXITCODE -ne 0 -or -not $out) { return @() }
    @($out | ForEach-Object { ($_ -replace "`0", '').Trim() } | Where-Object { $_ })
}

function Invoke-Wsl {
    param([string]$User, [string]$Command)
    & wsl.exe -d $Distro -u $User --exec bash -c $Command
    if ($LASTEXITCODE -ne 0) { throw "WSL command failed (exit $LASTEXITCODE): $Command" }
}

# ---------------------------------------------------------------------------------
# WSL + distro
# ---------------------------------------------------------------------------------
function Install-Distro {
    Say "Checking WSL and $Distro"
    $have = Get-WslDistros

    if ($Fresh -and ($have -contains $Distro)) {
        if (-not $Force) {
            Warn "This DELETES $Distro and everything in it."
            $answer = Read-Host "    Type $Distro to confirm"
            if ($answer -ne $Distro) { throw 'Cancelled.' }
        }
        & wsl.exe --unregister $Distro
        $have = Get-WslDistros
    }

    if ($have -contains $Distro) {
        Note "$Distro is already installed"
    } else {
        if (-not (Test-Admin)) {
            throw 'Installing WSL/Ubuntu needs admin. Re-run this from an elevated PowerShell.'
        }
        Invoke-WslQuiet --update | Out-Null
        Invoke-WslQuiet --set-default-version 2 | Out-Null
        Note "Installing $Distro (this downloads a few hundred MB)"
        & wsl.exe --install -d $Distro --no-launch
        $have = Get-WslDistros
        if (-not ($have -contains $Distro)) {
            # Older Store-style installs register on first launch of the app.
            $launcher = ($Distro.ToLower() -replace '[^a-z0-9]', '') + '.exe'
            if (Get-Command $launcher -ErrorAction SilentlyContinue) {
                & $launcher install --root
                $have = Get-WslDistros
            }
        }
        if (-not ($have -contains $Distro)) {
            Warn 'WSL was just enabled and Windows needs a reboot.'
            Warn 'Reboot, then run this same command again.'
            exit 3010
        }
    }

    # Make sure it is WSL2.
    $verbose = (Invoke-WslQuiet -l -v) -replace "`0", ''
    $line = $verbose | Where-Object { $_ -match "^\s*\*?\s*$([regex]::Escape($Distro))\s" }
    if ($line -and $line -match '\s1\s*$') {
        Note "Converting $Distro to WSL2"
        & wsl.exe --set-version $Distro 2
    }
}

function New-LinuxUser {
    Say "Creating Linux user '$UserName'"
    if (-not $UserName) { throw 'Pass -UserName (lowercase letters, digits, - or _).' }
    Invoke-WslQuiet -d $Distro -u root --exec id -u $UserName | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Note "$UserName already exists"
    } else {
        Invoke-Wsl root "useradd -m -s /bin/bash -G sudo $UserName"
        Note 'Choose a Linux password (used for sudo):'
        & wsl.exe -d $Distro -u root --exec passwd $UserName
        if ($LASTEXITCODE -ne 0) { throw 'Setting the password failed.' }
    }
}

function Invoke-Bootstrap {
    Say 'Running wsl-bootstrap.sh inside Ubuntu'
    $local = Join-Path $PSScriptRoot 'wsl-bootstrap.sh'
    if (-not (Test-Path $local)) {
        $local = Join-Path $env:TEMP 'wsl-bootstrap.sh'
        Note "Downloading $BootstrapUrl"
        Invoke-WebRequest -Uri $BootstrapUrl -OutFile $local -UseBasicParsing
    }
    $linuxPath = ((& wsl.exe -d $Distro -u root --exec wslpath -a ($local -replace '\\', '/')) -replace "`0", '').Trim()

    # Pass options through WSLENV so names with spaces survive.
    $env:BOOT_GIT_NAME      = $GitName
    $env:BOOT_GIT_EMAIL     = $GitEmail
    $env:BOOT_ZSH           = [int][bool]$Zsh
    $env:BOOT_NO_NODE       = [int][bool]$NoNode
    $env:BOOT_NO_GUI        = [int][bool]$NoGui
    $env:BOOT_NO_SSH        = [int][bool]$NoSsh
    $env:BOOT_NO_PASSPHRASE = [int][bool]$NoPassphrase
    $env:BOOT_GITHUB        = [int][bool]$GitHub
    $vars = 'BOOT_GIT_NAME','BOOT_GIT_EMAIL','BOOT_ZSH','BOOT_NO_NODE','BOOT_NO_GUI','BOOT_NO_SSH','BOOT_NO_PASSPHRASE','BOOT_GITHUB'
    $oldWslEnv = $env:WSLENV
    $env:WSLENV = (@($vars) + @($oldWslEnv | Where-Object { $_ })) -join ':'

    # Temporary passwordless sudo so the run is unattended; removed afterwards.
    $sudoers = '/etc/sudoers.d/99-wsl-bootstrap-tmp'
    Invoke-Wsl root "echo '$UserName ALL=(ALL) NOPASSWD:ALL' > $sudoers && chmod 440 $sudoers"
    try {
        # tr strips CRLF in case the file passed through a Windows editor or git autocrlf.
        Invoke-Wsl $UserName "tr -d '\r' < '$linuxPath' > /tmp/wsl-bootstrap.sh && bash /tmp/wsl-bootstrap.sh"
    } finally {
        & wsl.exe -d $Distro -u root --exec rm -f $sudoers
        $env:WSLENV = $oldWslEnv
    }

    Say 'Restarting WSL so /etc/wsl.conf takes effect'
    & wsl.exe --shutdown
    Note 'done'
}

# ---------------------------------------------------------------------------------
# Windows Terminal
# ---------------------------------------------------------------------------------
function Install-NerdFont {
    Say "Installing font '$FontFace'"
    $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    $regPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    $pattern = ($FontFace -replace ' ', '') + '*.ttf'
    if (Get-ChildItem -Path $fontDir -Filter $pattern -ErrorAction SilentlyContinue) {
        Note 'already installed'; return
    }

    $zip = Join-Path $env:TEMP "$FontZip.zip"
    $out = Join-Path $env:TEMP "$FontZip-nerdfont"
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontZip.zip"
    Note "Downloading $url"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    if (Test-Path $out) { Remove-Item $out -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $out -Force

    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    $files = Get-ChildItem $out -Recurse -Include *.ttf | Where-Object { $_.Name -notmatch 'Propo' }
    foreach ($f in $files) {
        $dest = Join-Path $fontDir $f.Name
        Copy-Item $f.FullName $dest -Force
        New-ItemProperty -Path $regPath -Name "$($f.BaseName) (TrueType)" -Value $dest -PropertyType String -Force | Out-Null
    }
    Note "installed $($files.Count) font files (restart Windows Terminal to see them)"
}

function Set-ObjProp($obj, [string]$name, $value) {
    if ($obj.PSObject.Properties[$name]) { $obj.$name = $value }
    else { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}

function Set-WindowsTerminal {
    Say 'Configuring Windows Terminal'
    $candidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )
    $path = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $path) {
        Warn 'Windows Terminal settings not found. Open Windows Terminal once, then run: .\setup-wsl.ps1 -TerminalOnly'
        return
    }

    $raw = Get-Content $path -Raw
    # settings.json allows // comments; drop whole-line comments so ConvertFrom-Json can read it.
    $clean = ($raw -split "`r?`n" | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
    try { $json = $clean | ConvertFrom-Json }
    catch { Warn "Could not parse $path ($($_.Exception.Message)). Leaving it alone."; return }

    $wtProfile = $json.profiles.list | Where-Object {
        $_.name -eq $Distro -or ($_.source -like '*Wsl*' -and $_.name -like "$Distro*")
    } | Select-Object -First 1
    if ($wtProfile) {
        Set-ObjProp $json 'defaultProfile' $wtProfile.guid
        Note "default profile -> $($wtProfile.name)"
    } else {
        Warn "No '$Distro' profile yet. Open Windows Terminal once so it detects the distro, then run with -TerminalOnly."
    }

    if (-not $json.profiles.PSObject.Properties['defaults'] -or -not $json.profiles.defaults) {
        Set-ObjProp $json.profiles 'defaults' ([pscustomobject]@{})
    }
    $d = $json.profiles.defaults
    if (-not $d.PSObject.Properties['font'] -or -not $d.font) { Set-ObjProp $d 'font' ([pscustomobject]@{}) }
    Set-ObjProp $d.font 'face' $FontFace
    Set-ObjProp $d 'historySize' $HistorySize
    Note "font -> $FontFace, scrollback -> $HistorySize lines"
    if ($null -ne $CopyOnSelect) {
        Set-ObjProp $json 'copyOnSelect' ([bool]$CopyOnSelect)
        Note "copyOnSelect -> $CopyOnSelect"
    }

    $backup = "$path.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $path $backup
    $text = $json | ConvertTo-Json -Depth 32
    [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding($false)))
    Note "saved (backup: $backup)"
}

# ---------------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------------
if (-not $TerminalOnly) {
    Install-Distro
    New-LinuxUser
    Invoke-Bootstrap
}
if (-not $SkipTerminal) {
    Install-NerdFont
    Set-WindowsTerminal
}

Say 'Finished'
Note "Open Windows Terminal (or run: wsl -d $Distro) to start using it."
if (-not $NoSsh -and -not $GitHub -and -not $TerminalOnly) {
    Note 'Your public SSH key is printed above; add it to GitHub, GitLab or your servers.'
}
