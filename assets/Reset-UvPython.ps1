<#
.SYNOPSIS
    Removes every Python install it can find on this Windows PC, then sets up
    Python with uv using the C:\Dev layout (uv-python, uv-cache, venvs).

.DESCRIPTION
    From the article "Python + uv + OneDrive: full install & setup (Windows 11)"
    https://pspowell.github.io/2026/03/02/python-uv-onedrive-install-path.html

    What it removes:
      - uv-managed Pythons (in C:\Dev\uv-python and uv's default AppData folder)
      - python.org installs and the Python Launcher (py.exe) - via their uninstallers
      - Microsoft Store Python / Python install manager packages
      - uv's python*.exe shims in %USERPROFILE%\.local\bin
      - leftover folders: %LOCALAPPDATA%\Programs\Python, %APPDATA%\Python, pip cache
      - Python entries in your User PATH (and Machine PATH when run as admin)
      - venvs in C:\Dev\venvs (they would be broken anyway; rebuild with uv sync)

    What it does NOT touch:
      - your project folders (OneDrive or C:\Dev\<project>)
      - Anaconda / Miniconda (reported only - remove those yourself)
      - Python embedded inside other apps (Blender, Inkscape, ArcGIS, etc.)

    Then it: installs uv if missing, sets UV_PYTHON_INSTALL_DIR and UV_CACHE_DIR,
    installs Python, and runs uv python update-shell.

.PARAMETER Version
    Python version to install afterward (e.g. 3.13). Leave it off to get the
    latest stable release uv knows about.

.PARAMETER DevRoot
    Root folder for uv-python, uv-cache and venvs. Default C:\Dev.

.PARAMETER KeepVenvs
    Do not delete the contents of <DevRoot>\venvs.

.PARAMETER DryRun
    Show what would be removed and installed, change nothing.

.PARAMETER Force
    Skip the "type YES" confirmation.

.EXAMPLE
    .\Reset-UvPython.ps1 -DryRun
    .\Reset-UvPython.ps1
    .\Reset-UvPython.ps1 -Version 3.13 -KeepVenvs

.NOTES
    Run from an elevated (Run as administrator) PowerShell to also remove
    all-users Python installs and clean the Machine PATH.
    Works in Windows PowerShell 5.1 and PowerShell 7+.
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [string]$DevRoot = "C:\Dev",
    [switch]$KeepVenvs,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

$UvPythonDir = Join-Path $DevRoot "uv-python"
$UvCacheDir  = Join-Path $DevRoot "uv-cache"
$VenvDir     = Join-Path $DevRoot "venvs"
$LocalBin    = Join-Path $env:USERPROFILE ".local\bin"

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

function Write-Step($msg) { Write-Host ""; Write-Host "== $msg" -ForegroundColor Cyan }
function Write-Item($msg) { Write-Host "   - $msg" }
function Write-Warn($msg) { Write-Host "   ! $msg" -ForegroundColor Yellow }

function Remove-PathSafe($path) {
    if (-not (Test-Path -LiteralPath $path)) { return }
    if ($DryRun) { Write-Item "[dry run] would delete $path"; return }
    try {
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        Write-Item "deleted $path"
    } catch {
        Write-Warn "could not delete $path : $($_.Exception.Message)"
    }
}

function Test-PythonPathEntry($entry) {
    $e = $entry.TrimEnd('\')
    return ($e -match '\\Python\\Python\d+(-32|-arm64)?(\\Scripts)?$') -or
           ($e -match '\\Python\d+(-32|-arm64)?(\\Scripts)?$') -or
           ($e -match '\\Python\\Launcher$') -or
           ($e -match '\\AppData\\Roaming\\Python\\Python\d+\\Scripts$')
}

# ---------------------------------------------------------------------------
# 1. Inventory
# ---------------------------------------------------------------------------
Write-Step "Looking for Python installs"

$uninstallRoots = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$regInstalls = @()
$condaFound  = @()
foreach ($root in $uninstallRoots) {
    Get-ItemProperty -Path $root -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.DisplayName
        if (-not $name) { return }
        if ($_.SystemComponent -eq 1) { return }   # hidden MSI parts; the bundle removes them
        if ($name -match '^(Anaconda|Miniconda|Miniforge)') { $condaFound += $name; return }
        if ($name -match '^Python \d+\.\d+' -or $name -match '^Python Launcher' -or $name -match '^Python install manager') {
            $regInstalls += [pscustomobject]@{
                Name      = $name
                Quiet     = $_.QuietUninstallString
                Uninstall = $_.UninstallString
                AllUsers  = ($_.PSPath -like '*HKEY_LOCAL_MACHINE*')
            }
        }
    }
}
$regInstalls = $regInstalls | Sort-Object Name -Unique

$appx = @(Get-AppxPackage -ErrorAction SilentlyContinue |
          Where-Object { $_.Name -like 'PythonSoftwareFoundation.*' })

$uvExe = Get-Command uv -ErrorAction SilentlyContinue
$uvPythons = @()
if ($uvExe) {
    $uvPythons = @(& uv python list --only-installed 2>$null)
}

$shims = @()
if (Test-Path $LocalBin) {
    # python*.exe also matches pythonw*.exe
    $shims = @(Get-ChildItem -LiteralPath $LocalBin -Filter "python*.exe" -ErrorAction SilentlyContinue)
}

$leftoverDirs = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Python"),
    (Join-Path $env:APPDATA "Python"),
    (Join-Path $env:LOCALAPPDATA "pip\cache"),
    (Join-Path $env:APPDATA "uv\python"),
    $UvPythonDir
) | Where-Object { Test-Path -LiteralPath $_ }

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$machPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPathHits = @(($userPath -split ';') | Where-Object { $_ -and (Test-PythonPathEntry $_) })
$machPathHits = @(($machPath -split ';') | Where-Object { $_ -and (Test-PythonPathEntry $_) })

Write-Host "   Installed programs:"
if ($regInstalls) { $regInstalls | ForEach-Object { Write-Item ("{0}{1}" -f $_.Name, $(if ($_.AllUsers) { "  (all users)" } else { "" })) } }
else { Write-Item "(none)" }
Write-Host "   Store / MSIX packages:"
if ($appx) { $appx | ForEach-Object { Write-Item $_.Name } } else { Write-Item "(none)" }
Write-Host "   uv-managed Pythons:"
if ($uvPythons) { $uvPythons | ForEach-Object { Write-Item $_ } } elseif ($uvExe) { Write-Item "(none)" } else { Write-Item "(uv not installed)" }
Write-Host "   Shims in $LocalBin :"
if ($shims) { $shims | ForEach-Object { Write-Item $_.Name } } else { Write-Item "(none)" }
Write-Host "   Folders to delete:"
if ($leftoverDirs) { $leftoverDirs | ForEach-Object { Write-Item $_ } } else { Write-Item "(none)" }
if (-not $KeepVenvs -and (Test-Path $VenvDir)) { Write-Item "$VenvDir\* (venvs)" }
Write-Host "   PATH entries to remove:"
@($userPathHits | ForEach-Object { "User:    $_" }) + @($machPathHits | ForEach-Object { "Machine: $_" }) |
    ForEach-Object { Write-Item $_ }
if (-not ($userPathHits -or $machPathHits)) { Write-Item "(none)" }

if ($condaFound) {
    Write-Warn "Conda found (NOT removed): $($condaFound -join ', ')"
}
if (-not $IsAdmin -and (($regInstalls | Where-Object AllUsers) -or $machPathHits)) {
    Write-Warn "Some items are all-users. Re-run as administrator to remove them."
}

Write-Host ""
$VersionLabel = $(if ($Version) { $Version } else { "(latest stable)" })
Write-Host "   Then install: uv (if missing), Python $VersionLabel into $UvPythonDir, cache at $UvCacheDir"

if ($DryRun) {
    Write-Host ""
    Write-Host "Dry run - nothing changed." -ForegroundColor Green
    return
}

if (-not $Force) {
    Write-Host ""
    $answer = Read-Host "Type YES to remove the items above and reinstall"
    if ($answer -cne "YES") { Write-Host "Cancelled."; return }
}

# ---------------------------------------------------------------------------
# 2. Remove uv-managed Pythons
# ---------------------------------------------------------------------------
Write-Step "Removing uv-managed Pythons"
if ($uvExe) {
    & uv python uninstall --all 2>&1 | ForEach-Object { Write-Item $_ }
}
foreach ($s in $shims) { Remove-PathSafe $s.FullName }

# ---------------------------------------------------------------------------
# 3. Uninstall python.org installs and the launcher
# ---------------------------------------------------------------------------
Write-Step "Uninstalling python.org installs"
foreach ($p in $regInstalls) {
    if ($p.AllUsers -and -not $IsAdmin) { Write-Warn "skipped (needs admin): $($p.Name)"; continue }

    $cmd = $p.Quiet
    if (-not $cmd) {
        $cmd = $p.Uninstall
        if ($cmd -match 'msiexec') { $cmd = ($cmd -replace '/I', '/X') + ' /qn /norestart' }
        elseif ($cmd)              { $cmd = "$cmd /quiet" }
    }
    if (-not $cmd) { Write-Warn "no uninstaller for $($p.Name)"; continue }

    Write-Item "uninstalling $($p.Name)"
    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "`"$cmd`"" -Wait -PassThru -WindowStyle Hidden
    if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
        Write-Warn "exit code $($proc.ExitCode) for $($p.Name) - remove it from Settings > Apps if it is still listed"
    }
}

# ---------------------------------------------------------------------------
# 4. Remove Store / MSIX Python
# ---------------------------------------------------------------------------
Write-Step "Removing Microsoft Store Python packages"
foreach ($a in $appx) {
    try {
        Remove-AppxPackage -Package $a.PackageFullName -ErrorAction Stop
        Write-Item "removed $($a.Name)"
    } catch {
        Write-Warn "could not remove $($a.Name): $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------------
# 5. Leftover folders and venvs
# ---------------------------------------------------------------------------
Write-Step "Deleting leftover folders"
foreach ($d in $leftoverDirs) { Remove-PathSafe $d }
if (-not $KeepVenvs -and (Test-Path $VenvDir)) {
    Get-ChildItem -LiteralPath $VenvDir -Force | ForEach-Object { Remove-PathSafe $_.FullName }
}

# ---------------------------------------------------------------------------
# 6. Clean PATH
# ---------------------------------------------------------------------------
Write-Step "Cleaning PATH"
if ($userPathHits) {
    $newUser = (($userPath -split ';') | Where-Object { $_ -and -not (Test-PythonPathEntry $_) }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newUser, "User")
    Write-Item "User PATH cleaned"
}
if ($machPathHits) {
    if ($IsAdmin) {
        $newMach = (($machPath -split ';') | Where-Object { $_ -and -not (Test-PythonPathEntry $_) }) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newMach, "Machine")
        Write-Item "Machine PATH cleaned"
    } else {
        Write-Warn "Machine PATH has Python entries; re-run as admin to clean"
    }
}
# Old per-user variables that point Python at the wrong place
foreach ($v in "PYTHONHOME", "PYTHONPATH") {
    if ([Environment]::GetEnvironmentVariable($v, "User")) {
        [Environment]::SetEnvironmentVariable($v, $null, "User")
        Write-Item "cleared User $v"
    }
}

# ---------------------------------------------------------------------------
# 7. Install the uv setup
# ---------------------------------------------------------------------------
Write-Step "Installing the uv setup"

foreach ($d in $UvPythonDir, $UvCacheDir, $VenvDir) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
[Environment]::SetEnvironmentVariable("UV_PYTHON_INSTALL_DIR", $UvPythonDir, "User")
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR",          $UvCacheDir,  "User")
$env:UV_PYTHON_INSTALL_DIR = $UvPythonDir
$env:UV_CACHE_DIR          = $UvCacheDir
Write-Item "UV_PYTHON_INSTALL_DIR = $UvPythonDir"
Write-Item "UV_CACHE_DIR          = $UvCacheDir"

# Refresh PATH for this session (picks up the cleaned PATH and ~\.local\bin)
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($env:Path -split ';' | Where-Object { $_.TrimEnd('\') -eq $LocalBin })) {
    $env:Path = "$LocalBin;$env:Path"
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Item "uv not found - installing with Astral's installer"
    powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = "$LocalBin;$env:Path"
}
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Warn "uv still not found. Install it (winget install --id=astral-sh.uv -e), open a new PowerShell, then run: uv python install $Version"
    return
}

& uv cache clean 2>&1 | Out-Null

# Run from TEMP so a stray .python-version in the current folder can't pick the version
Push-Location $env:TEMP
try {
    if ($Version) { & uv python install $Version --force }
    else          { & uv python install --force }
    # (empty strings are passed differently by PS 5.1 and 7.3+, so branch instead)
    if ($Version) { $pyExe = (& uv python find --managed-python $Version 2>$null | Select-Object -First 1) }
    else          { $pyExe = (& uv python find --managed-python 2>$null | Select-Object -First 1) }
} finally {
    Pop-Location
}
& uv python update-shell

$Installed = ""
if ($pyExe) {
    $Installed = (& $pyExe -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null)
}

# ---------------------------------------------------------------------------
# 8. Report
# ---------------------------------------------------------------------------
Write-Step "Done"
& uv python list --only-installed
Write-Host ""
Write-Host "Next:" -ForegroundColor Green
Write-Host "  1. Close this window and open a new PowerShell."
if ($Installed) {
    Write-Host "  2. Check:  where.exe python$Installed   and   python$Installed --version"
} else {
    Write-Host "  2. Check:  uv python list --only-installed"
}
Write-Host "  3. Settings > Apps > Advanced app settings > App execution aliases:"
Write-Host "     turn off 'python.exe' and 'python3.exe' (App Installer) so they"
Write-Host "     don't open the Microsoft Store."
Write-Host "  4. In each project: set UV_PROJECT_ENVIRONMENT, then run uv sync."
Write-Host "  5. If you use uv tools (uv tool list), rebuild them:  uv tool upgrade --all --reinstall"
