#Requires -RunAsAdministrator
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

function Log($msg, $color = "Gray") {
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$ts] $msg" -ForegroundColor $color
}

Log "=== Python Nuclear Removal Starting (VERBOSE) ===" "Red"

# ------------------------------
# 0) Confirm admin
# ------------------------------
$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $admin) {
    Log "ERROR: Not running as Administrator. Re-run elevated." "Red"
    exit 1
}

# ------------------------------
# 1) Kill running python-ish processes
# ------------------------------
Log "Killing Python/Conda-related processes..." "Cyan"
$procs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match "^(python|pythonw|pip|conda|mamba|micromamba)$"
}
if ($procs) {
    $procs | ForEach-Object {
        Log "Stopping process: $($_.Name) (PID $($_.Id))" "Yellow"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
} else {
    Log "No matching processes running." "Green"
}

# ------------------------------
# 2) Find uninstallers via registry (fast, safe)
# ------------------------------
Log "Scanning uninstall registry entries (no Win32_Product)..." "Cyan"

$uninstallRoots = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$matches = @()

foreach ($root in $uninstallRoots) {
    if (Test-Path $root) {
        Log "Checking $root" "DarkCyan"
        Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
            $p = Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue
            if ($null -ne $p.DisplayName -and $p.DisplayName -match "Python|Anaconda|Miniconda|Miniforge|Conda") {
                $matches += [pscustomobject]@{
                    Root        = $root
                    KeyPath     = $_.PsPath
                    DisplayName = $p.DisplayName
                    Version     = $p.DisplayVersion
                    Publisher   = $p.Publisher
                    Uninstall   = $p.UninstallString
                    QuietUninst = $p.QuietUninstallString
                }
            }
        }
    }
}

if (-not $matches) {
    Log "No uninstall entries matching Python/Conda found." "Yellow"
} else {
    Log ("Found {0} uninstall entries:" -f $matches.Count) "Green"
    $matches | Sort-Object DisplayName | ForEach-Object {
        Log (" - {0}  (v{1})" -f $_.DisplayName, $_.Version) "Green"
    }

    # ------------------------------
    # 3) Run uninstallers (prefer QuietUninstallString)
    # ------------------------------
    Log "Attempting uninstall of found entries..." "Cyan"

    foreach ($m in ($matches | Sort-Object DisplayName)) {
        Log "Uninstalling: $($m.DisplayName)" "Yellow"

        $cmd = $m.QuietUninst
        if (-not $cmd) { $cmd = $m.Uninstall }

        if (-not $cmd) {
            Log "  No uninstall command found; skipping." "Red"
            continue
        }

        # Normalize MSI uninstall strings to quiet mode where possible
        # Examples:
        #   MsiExec.exe /I{GUID}  -> /X{GUID} /qn
        #   MsiExec.exe /X{GUID}  -> /X{GUID} /qn
        if ($cmd -match "msiexec\.exe") {
            $cmd2 = $cmd
            $cmd2 = $cmd2 -replace "\/I", "/X"
            if ($cmd2 -notmatch "\/qn") { $cmd2 += " /qn" }
            if ($cmd2 -notmatch "\/norestart") { $cmd2 += " /norestart" }
            $cmd = $cmd2
        }

        Log "  Command: $cmd" "DarkYellow"

        try {
            # Use cmd.exe to handle quoted strings consistently
            $p = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -Wait -PassThru -WindowStyle Hidden
            Log "  ExitCode: $($p.ExitCode)" (if ($p.ExitCode -eq 0) { "Green" } else { "Yellow" })
        } catch {
            Log "  ERROR running uninstall: $($_.Exception.Message)" "Red"
        }
    }
}

# ------------------------------
# 4) Remove Microsoft Store Python (AppX)
# ------------------------------
Log "Removing Microsoft Store Python (AppX)..." "Cyan"
try {
    $appx = Get-AppxPackage -AllUsers *Python* -ErrorAction SilentlyContinue
    if ($appx) {
        $appx | ForEach-Object {
            Log "Removing AppX: $($_.Name) ($($_.PackageFullName))" "Yellow"
            Remove-AppxPackage -AllUsers -Package $_.PackageFullName -ErrorAction SilentlyContinue
        }
    } else {
        Log "No Python AppX packages found." "Green"
    }
} catch {
    Log "AppX removal error: $($_.Exception.Message)" "Red"
}

# ------------------------------
# 5) Optional: winget uninstall
# ------------------------------
Log "Checking winget..." "Cyan"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Log "winget found. Attempting to uninstall common Python ids (if installed)..." "DarkCyan"
    $wingetIds = @(
        "Python.Python.3",
        "Python.Python.3.12",
        "Python.Python.3.11",
        "Python.Python.3.10",
        "Anaconda.Anaconda3",
        "Anaconda.Miniconda3"
    )
    foreach ($id in $wingetIds) {
        Log "winget uninstall --id $id" "DarkYellow"
        winget uninstall --id $id --silent --accept-source-agreements --accept-package-agreements 2>$null | Out-Null
    }
} else {
    Log "winget not found; skipping." "Yellow"
}

# ------------------------------
# 6) Optional: Chocolatey uninstall
# ------------------------------
Log "Checking choco..." "Cyan"
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Log "Chocolatey found. Attempting uninstall..." "DarkCyan"
    foreach ($pkg in @("python","python3","anaconda3","miniconda3")) {
        Log "choco uninstall $pkg -y --remove-dependencies" "DarkYellow"
        choco uninstall $pkg -y --remove-dependencies 2>$null | Out-Null
    }
} else {
    Log "Chocolatey not found; skipping." "Yellow"
}

# ------------------------------
# 7) Delete known Python/Conda directories
# ------------------------------
Log "Deleting known Python/Conda directories..." "Cyan"

$deleteTargets = @(
    "$env:LOCALAPPDATA\Programs\Python",
    "$env:LOCALAPPDATA\Python",
    "$env:LOCALAPPDATA\pip",
    "$env:LOCALAPPDATA\pypoetry",
    "$env:LOCALAPPDATA\conda",
    "$env:LOCALAPPDATA\Continuum",
    "$env:APPDATA\Python",
    "$env:APPDATA\pip",
    "$env:APPDATA\jupyter",
    "$env:APPDATA\ipython",
    "$env:USERPROFILE\.conda",
    "$env:USERPROFILE\.continuum",
    "$env:USERPROFILE\.anaconda",
    "$env:USERPROFILE\.jupyter",
    "$env:USERPROFILE\.ipython",
    "$env:USERPROFILE\.python_history",
    "$env:PROGRAMFILES\Python*",
    "$env:PROGRAMFILES(x86)\Python*",
    "C:\ProgramData\Anaconda*",
    "C:\ProgramData\Miniconda*",
    "C:\ProgramData\Miniforge*",
    "C:\ProgramData\Python",
    "C:\Python*"
)

foreach ($t in $deleteTargets) {
    Get-Item $t -ErrorAction SilentlyContinue | ForEach-Object {
        Log "Removing: $($_.FullName)" "Yellow"
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------
# 8) Clean PATH (User + Machine) with detailed reporting
# ------------------------------
Log "Cleaning PATH (User + Machine)..." "Cyan"

function CleanPathVerbose($scopeName) {
    $current = [Environment]::GetEnvironmentVariable("Path", $scopeName)
    if (-not $current) {
        Log "No PATH for scope $scopeName" "Yellow"
        return
    }

    $parts = $current -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
    $keep  = New-Object System.Collections.Generic.List[string]
    $removed = New-Object System.Collections.Generic.List[string]

    foreach ($p in $parts) {
        if ($p -match "Python|Anaconda|Miniconda|Miniforge|conda|pip") {
            $removed.Add($p) | Out-Null
        } else {
            $keep.Add($p) | Out-Null
        }
    }

    if ($removed.Count -gt 0) {
        Log "Removed from PATH ($scopeName):" "Yellow"
        $removed | ForEach-Object { Log "  - $_" "DarkYellow" }
    } else {
        Log "No Python/Conda entries found in PATH ($scopeName)." "Green"
    }

    [Environment]::SetEnvironmentVariable("Path", ($keep -join ";"), $scopeName)
}

CleanPathVerbose "User"
CleanPathVerbose "Machine"

# ------------------------------
# 9) Remove Python registry keys (remnants)
# ------------------------------
Log "Removing Python registry remnants..." "Cyan"
$regRemnants = @(
    "HKCU:\Software\Python",
    "HKLM:\Software\Python",
    "HKLM:\Software\WOW6432Node\Python",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe"
)

foreach ($rk in $regRemnants) {
    if (Test-Path $rk) {
        Log "Deleting: $rk" "Yellow"
        Remove-Item $rk -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------
# 10) Verify: where python/pip + py launcher
# ------------------------------
Log "Verification checks..." "Cyan"
foreach ($cmd in @("python","pip","py")) {
    $found = & where.exe $cmd 2>$null
    if ($found) {
        Log "WARNING: '$cmd' still found at:" "Red"
        $found | ForEach-Object { Log "  $_" "Red" }
    } else {
        Log "OK: '$cmd' not found in PATH." "Green"
    }
}

Log "=== COMPLETE. Reboot recommended. ===" "Red"
