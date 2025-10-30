<# 
.SYNOPSIS
Prompts for a user profile folder rename (C:\Users\OldName -> C:\Users\NewName),
updates the registry mapping, repairs ACLs, and guards against running in the
profile being changed. If needed, it can create a temporary local admin account
and copy this script to C:\Users\Public for easy re-run.

.NOTES
- Run from an elevated PowerShell.
- If you're currently signed into the profile you want to rename, the script
  will offer to create a helper admin for you and then exit.

#>

# ======== Safety & Helpers ========
$ErrorActionPreference = "Stop"

function Fail($msg) { Write-Error $msg; exit 1 }
function Info($msg) { Write-Host "[*] $msg" }
function Warn($msg) { Write-Warning $msg }

# Ensure elevation
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Fail "Please run this script in an elevated PowerShell (Run as Administrator)."
}

# Ask for names
Write-Host ""
$OldName = Read-Host "Enter the CURRENT profile folder name under C:\Users (e.g., john)"
$NewName = Read-Host "Enter the NEW desired profile folder name under C:\Users (e.g., john.doe)"

if ([string]::IsNullOrWhiteSpace($OldName) -or [string]::IsNullOrWhiteSpace($NewName)) {
    Fail "Both names are required."
}
if ($OldName -eq $NewName) { Fail "Old and new names cannot be the same." }

$oldPath = Join-Path "C:\Users" $OldName
$newPath = Join-Path "C:\Users" $NewName

if (-not (Test-Path $oldPath)) { Fail "Old profile path not found: $oldPath" }
if (Test-Path $newPath) { Fail "New profile path already exists: $newPath" }

# Resolve current user SID and target user SID
$currentSid = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
Info "Current admin SID: $currentSid"

# Try to resolve the SID of the target by local user name first
$targetSid = $null
try {
    $local = Get-LocalUser -Name $OldName -ErrorAction Stop
    $targetSid = $local.SID.Value
} catch {
    # Fallback: read owner of the profile folder and translate to SID
    $ownerNT = (Get-Acl $oldPath).Owner
    try {
        $nt = New-Object System.Security.Principal.NTAccount($ownerNT)
        $sidObj = $nt.Translate([System.Security.Principal.SecurityIdentifier])
        $targetSid = $sidObj.Value
    } catch {
        Fail "Could not resolve the SID for '$OldName'. Folder owner: $ownerNT"
    }
}
Info "Target user SID: $targetSid"

# Check if we are running inside the target profile context
$currentUserProfile = $env:USERPROFILE
if ($currentUserProfile -and ($currentUserProfile.TrimEnd('\') -ieq $oldPath.TrimEnd('\'))) {
    Warn "You are currently running inside the profile you want to rename: $currentUserProfile"
    $ans = Read-Host "Create a temporary local admin to run the rename from? (Y/N)"
    if ($ans -match '^(?i)y') {
        $helperName = "Admin-Rename-Helper"
        # Avoid collision
        if (Get-LocalUser -Name $helperName -ErrorAction SilentlyContinue) {
            $helperName = "Admin-Rename-Helper_$([Guid]::NewGuid().ToString('N').Substring(0,6))"
        }

        $pwPlain = Read-Host "Enter a password for $helperName (you will need this to sign in)"
        if ([string]::IsNullOrWhiteSpace($pwPlain)) { Fail "Password required to create the helper admin." }
        $pw = ConvertTo-SecureString $pwPlain -AsPlainText -Force

        Info "Creating local admin account '$helperName'..."
        New-LocalUser -Name $helperName -Password $pw -FullName $helperName -PasswordNeverExpires -AccountNeverExpires | Out-Null
        Add-LocalGroupMember -Group "Administrators" -Member $helperName

        # Copy this script to a neutral location for easy access
        $selfPath = $MyInvocation.MyCommand.Path
        $publicCopy = "C:\Users\Public\Rename-UserProfile.ps1"
        try {
            Copy-Item -LiteralPath $selfPath -Destination $publicCopy -Force
        } catch {
            Warn "Could not copy script to $publicCopy. You can manually browse to: $selfPath"
            $publicCopy = $selfPath
        }

        Write-Host ""
        Write-Host "=== NEXT STEPS ==="
        Write-Host "1) Sign out of this account."
        Write-Host "2) Sign in as:  $helperName"
        Write-Host "3) Open Windows Terminal (Admin) and run:"
        Write-Host "   powershell -ExecutionPolicy Bypass -File `"$publicCopy`""
        Write-Host "Then choose the SAME Old/New names when prompted."
        exit 0
    } else {
        Fail "Please sign out and run this script from a different administrator account."
    }
}

# Also guard by comparing SIDs (if hives are loaded)
$loadedHives = Get-ChildItem HKU: | Select-Object -ExpandProperty PSChildName
if ($loadedHives -contains $targetSid -and $currentSid -eq $targetSid) {
    Fail "The target user hive is loaded for the current session. Run this from another admin."
}

# Warn about OneDrive
Warn "If the target account uses OneDrive, unlink it first: OneDrive app → Settings → Account → Unlink this PC."
$cont = Read-Host "Continue? (Y/N)"
if ($cont -notmatch '^(?i)y') { Fail "Cancelled by user." }

# Registry key for the profile mapping
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$targetSid"
if (-not (Test-Path $regPath)) { Fail "Profile registry key not found: $regPath" }

# Ensure target hive not loaded (the user must be signed out)
if ($loadedHives -contains $targetSid) {
    Fail "The target profile hive is loaded (user likely signed in). Sign out that user and try again."
}

# Best-effort: stop services that commonly lock files
$svcNames = @("OneDrive","MicrosoftEdgeUpdate","DiagTrack","WpnService")
foreach ($name in $svcNames) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        try { Stop-Service -Name $name -Force -ErrorAction SilentlyContinue } catch {}
    }
}

# Update ProfileImagePath
$oldRegPath = (Get-ItemProperty -Path $regPath -Name ProfileImagePath).ProfileImagePath
Info "Current ProfileImagePath: $oldRegPath"
$newRegPath = $newPath
Info "Setting ProfileImagePath to: $newRegPath"
Set-ItemProperty -Path $regPath -Name ProfileImagePath -Value $newRegPath

# Attempt the rename
Info "Renaming folder:"
Info "  $oldPath"
Info "to"
Info "  $newPath"
Rename-Item -Path $oldPath -NewName $NewName

# Repair ownership & permissions for the SID (works for local/Microsoft accounts)
Info "Repairing ACLs..."
& icacls "$newPath" /setowner "*$targetSid" /T | Out-Null
& icacls "$newPath" /inheritance:e /T | Out-Null
& icacls "$newPath" /grant "*$targetSid":(OI)(CI)F /T | Out-Null

Write-Host ""
Write-Host "Success! Reboot the PC, then sign into the renamed account to verify."
Write-Host "Check with: `$env:USERPROFILE` (should be $newPath)"

