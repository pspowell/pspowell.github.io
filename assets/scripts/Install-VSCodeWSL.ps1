<#
.SYNOPSIS
  Windows side of "Installing VS Code for WSL".
  https://pspowell.github.io/2026/11/16/installing-vscode-for-wsl.html

.DESCRIPTION
  1. Installs Visual Studio Code with winget if it isn't installed
     (user install, added to PATH, Explorer "Open with Code" menus).
  2. Installs the Windows-side extensions: WSL, PowerShell, Python, Ruff,
     Code Spell Checker, EditorConfig.
  3. Writes a starter user settings.json (backs up any existing one first).
  4. Runs setup-vscode-wsl.sh inside your WSL distro: Linux-side extensions
     (YAML, markdownlint, GitHub Actions, Liquid, Git Graph) and, if your
     Jekyll site is cloned, a .vscode folder with tasks and a new-post snippet.

  Safe to re-run. Does not need an elevated PowerShell.

.EXAMPLE
  .\Install-VSCodeWSL.ps1

.EXAMPLE
  .\Install-VSCodeWSL.ps1 -KeepSettings -SiteDir '~/dev/mysite'

.EXAMPLE
  .\Install-VSCodeWSL.ps1 -SkipWsl
#>
[CmdletBinding()]
param(
    [string]$Distro  = 'Ubuntu',
    [string]$SiteDir = '~/dev/pspowell.github.io',   # Linux path; skipped if it doesn't exist
    [switch]$KeepSettings,   # leave an existing settings.json alone
    [switch]$SkipWsl,        # Windows side only
    [switch]$ForceSiteFiles, # overwrite existing .vscode files in the site
    [string]$WslScriptUrl = 'https://pspowell.github.io/assets/scripts/setup-vscode-wsl.sh'
)

$ErrorActionPreference = 'Stop'
$env:WSL_UTF8 = '1'   # plain UTF-8 output from wsl.exe

function Say($msg)  { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Note($msg) { Write-Host "    $msg" }
function Warn($msg) { Write-Host "    ! $msg" -ForegroundColor Yellow }

# PowerShell 5.1 turns native stderr into terminating errors under 'Stop',
# so native calls whose stderr is just noise run with 'Continue'.
function Invoke-Native {
    param([string]$Exe, [string[]]$Arguments)
    $ErrorActionPreference = 'Continue'
    & $Exe @Arguments 2>&1 | ForEach-Object {
        $line = "$_"
        if ($line -notmatch 'DeprecationWarning|trace-deprecation') { Note $line }
    }
    return $LASTEXITCODE
}

function Update-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Find-Code {
    $cmd = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    return $null
}

# ---------------------------------------------------------------------------------
# 1. VS Code
# ---------------------------------------------------------------------------------
Say 'Checking for Visual Studio Code'
$code = Find-Code
if ($code) {
    Note "Found: $code"
} else {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'winget not found. Install "App Installer" from the Microsoft Store, or install VS Code from https://code.visualstudio.com and re-run.'
    }
    Note 'Installing with winget (user install)...'
    $override = '/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath'
    $rc = Invoke-Native winget.exe @('install', '--id', 'Microsoft.VisualStudioCode', '-e',
        '--scope', 'user', '--accept-source-agreements', '--accept-package-agreements',
        '--override', $override)
    Update-SessionPath
    $code = Find-Code
    if (-not $code) { throw "VS Code install did not complete (winget exit $rc)." }
    Note "Installed: $code"
}

# ---------------------------------------------------------------------------------
# 2. Windows-side extensions
# ---------------------------------------------------------------------------------
Say 'Installing Windows-side extensions'
$winExtensions = @(
    'ms-vscode-remote.remote-wsl',
    'ms-vscode.powershell',
    'ms-python.python',
    'charliermarsh.ruff',
    'streetsidesoftware.code-spell-checker',
    'editorconfig.editorconfig'
)
foreach ($ext in $winExtensions) {
    $null = Invoke-Native $code @('--install-extension', $ext)
}
Note 'Updating any outdated extensions...'
$null = Invoke-Native $code @('--update-extensions')

# ---------------------------------------------------------------------------------
# 3. User settings
# ---------------------------------------------------------------------------------
$settingsDir  = Join-Path $env:APPDATA 'Code\User'
$settingsPath = Join-Path $settingsDir 'settings.json'
if ($KeepSettings -and (Test-Path $settingsPath)) {
    Say 'Keeping your existing settings.json (-KeepSettings)'
} else {
    Say 'Writing starter user settings.json'
    New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null
    if (Test-Path $settingsPath) {
        $backup = "$settingsPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $settingsPath $backup
        Note "Backed up the old one to $backup"
    }
    $settings = @'
{
  // ---- Editor ----
  "editor.fontSize": 14,
  "editor.renderWhitespace": "boundary",
  "editor.minimap.enabled": false,
  "editor.bracketPairColorization.enabled": true,
  "editor.formatOnSave": false,
  "editor.unicodeHighlight.ambiguousCharacters": true,
  "workbench.startupEditor": "none",

  // ---- Files: Linux line endings, clean whitespace ----
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "files.autoSave": "onFocusChange",

  // ---- Markdown (Jekyll posts) ----
  "[markdown]": {
    "editor.wordWrap": "on",
    "files.trimTrailingWhitespace": false,
    "editor.quickSuggestions": { "other": "off" }
  },
  "markdownlint.config": {
    "MD013": false,
    "MD033": false,
    "MD041": false,
    "MD025": false
  },

  // ---- YAML (_config.yml, front matter, workflows) ----
  "[yaml]": {
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.autoIndent": "keep"
  },

  // ---- PowerShell: UTF-8 with BOM, CRLF, flag non-ASCII characters ----
  "[powershell]": {
    "files.encoding": "utf8bom",
    "files.eol": "\r\n",
    "editor.unicodeHighlight.nonBasicASCII": true
  },
  "powershell.codeFormatting.preset": "OTBS",
  "powershell.integratedConsole.showOnStartup": false,

  // ---- Python (uv-managed) ----
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true
  },
  "python.terminal.activateEnvironment": false,

  // ---- Git ----
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "git.pruneOnFetch": true,

  // ---- Terminal ----
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.scrollback": 5000,

  // ---- Spell check ----
  "cSpell.language": "en-US",
  "cSpell.userWords": [
    "Jekyll", "kramdown", "permalink", "rbenv", "rsync", "WSL", "winget",
    "robocopy", "pwsh", "uv", "cPanel", "GnuCash", "Beancount"
  ]
}
'@
    # UTF-8 without BOM, LF line endings
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($settingsPath, ($settings -replace "`r`n", "`n"), $utf8NoBom)
    Note "Wrote $settingsPath"
}

# ---------------------------------------------------------------------------------
# 4. WSL side
# ---------------------------------------------------------------------------------
if ($SkipWsl) {
    Say 'Skipping the WSL side (-SkipWsl)'
} else {
    Say "Setting up the WSL side in $Distro"
    $ErrorActionPreference = 'Continue'
    $list = & wsl.exe -l -q 2>$null
    $ErrorActionPreference = 'Stop'
    $distros = @($list | ForEach-Object { ($_ -replace "`0", '').Trim() } | Where-Object { $_ })
    if ($distros -notcontains $Distro) {
        Warn "WSL distro '$Distro' not found (found: $($distros -join ', '))."
        Warn 'Install WSL first, or re-run with -Distro <name> or -SkipWsl.'
    } else {
        $forceArg = ''
        if ($ForceSiteFiles) { $forceArg = ' --force' }
        $bash = "set -e; f=`$(mktemp); curl -fsSL '$WslScriptUrl' -o `"`$f`"; bash `"`$f`" --site $SiteDir$forceArg; rm -f `"`$f`""
        & wsl.exe -d $Distro --exec bash -lc $bash
        if ($LASTEXITCODE -ne 0) { Warn "The WSL part reported an error (exit $LASTEXITCODE). See the messages above." }
    }
}

Say 'Done'
Note 'Open a project from Ubuntu with:  cd ~/dev/pspowell.github.io && code .'
Note 'The bottom-left corner of VS Code should read "WSL: Ubuntu".'
