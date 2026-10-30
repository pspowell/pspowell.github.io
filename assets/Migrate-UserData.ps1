<#
.SYNOPSIS
    Copies user data folders from one PC to another with robocopy.

.DESCRIPTION
    Copies Desktop, Documents, Downloads, Pictures, Music, Videos and Favorites
    (or the folders you list) from -Source to -Destination. Either side can be a
    local profile, an external drive, or a network share, so the same script
    covers all three migration routes:

      Old PC  -> USB drive   : run on the OLD PC with -Destination E:\Migration
      USB     -> new PC      : run on the NEW PC with -Source E:\Migration\<name>
      Old PC  -> new PC (LAN): run on the NEW PC with -Source \\OLDPC\<share>

    When a side is this PC's own profile, the script uses the real location of
    each known folder, so it follows folders that have been moved to another
    drive. Folders that live inside OneDrive are skipped (OneDrive moves those
    for you) unless you pass -IncludeOneDrive.

    Copies are additive: nothing is ever deleted at the destination, and files
    that are already identical are skipped, so it is safe to run more than once.

.PARAMETER Source
    Where to copy from. Default: this PC's user profile.

.PARAMETER Destination
    Where to copy to. Default: this PC's user profile. When copying TO a drive
    or share, a subfolder named after the user is created automatically.

.PARAMETER Folders
    Folder names to copy. Default: Desktop, Documents, Downloads, Pictures,
    Music, Videos, Favorites.

.PARAMETER Extra
    Additional full paths to copy (for example C:\Dev). Each one is copied into
    _Extra\<folder name> on a drive/share, or back to the same path on a PC.

.PARAMETER IncludeOneDrive
    Copy known folders even if they are inside OneDrive.

.PARAMETER Threads
    Robocopy /MT thread count. Default 16. Use 1-4 over slow Wi-Fi.

.PARAMETER Preview
    List what would be copied without copying anything (robocopy /L).

.EXAMPLE
    .\Migrate-UserData.ps1 -Destination E:\Migration -Preview

.EXAMPLE
    .\Migrate-UserData.ps1 -Destination E:\Migration -Extra C:\Dev

.EXAMPLE
    .\Migrate-UserData.ps1 -Source E:\Migration\Preston

.EXAMPLE
    .\Migrate-UserData.ps1 -Source \\OLDPC\Preston -Threads 8
#>
[CmdletBinding()]
param(
    [string]   $Source      = $env:USERPROFILE,
    [string]   $Destination = $env:USERPROFILE,
    [string[]] $Folders     = @('Desktop','Documents','Downloads','Pictures','Music','Videos','Favorites'),
    [string[]] $Extra       = @(),
    [switch]   $IncludeOneDrive,
    [ValidateRange(1,128)]
    [int]      $Threads     = 16,
    [switch]   $Preview
)

$ErrorActionPreference = 'Stop'

function Normalize([string]$p) {
    return [System.IO.Path]::GetFullPath($p).TrimEnd('\')
}

$Source      = Normalize $Source
$Destination = Normalize $Destination
$profileDir  = Normalize $env:USERPROFILE

if ($Source -eq $Destination) {
    Write-Error "Source and Destination are the same ($Source). Pass -Source or -Destination."
}
if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Source not found: $Source"
}

$srcIsProfile = ($Source -eq $profileDir)
$dstIsProfile = ($Destination -eq $profileDir)

# Copying from this PC to a drive/share: put everything under a per-user folder.
if ($srcIsProfile -and -not $dstIsProfile) {
    $Destination = Join-Path $Destination $env:USERNAME
}

# Map of folder name -> .NET SpecialFolder so redirected folders are followed.
$special = @{
    'Desktop'   = 'Desktop'
    'Documents' = 'MyDocuments'
    'Pictures'  = 'MyPictures'
    'Music'     = 'MyMusic'
    'Videos'    = 'MyVideos'
    'Favorites' = 'Favorites'
}

function Resolve-LocalFolder([string]$name) {
    if ($special.ContainsKey($name)) {
        $p = [Environment]::GetFolderPath($special[$name])
        if ($p) { return (Normalize $p) }
    }
    return (Join-Path $profileDir $name)
}

$oneDriveRoots = @($env:OneDrive, $env:OneDriveConsumer, $env:OneDriveCommercial) |
    Where-Object { $_ } | ForEach-Object { Normalize $_ } | Select-Object -Unique

function Test-InOneDrive([string]$path) {
    foreach ($r in $oneDriveRoots) {
        if ($path -like "$r\*" -or $path -eq $r) { return $true }
    }
    return $false
}

# Build the list of copy jobs.
$jobs = New-Object System.Collections.Generic.List[object]

foreach ($f in $Folders) {
    $from = if ($srcIsProfile) { Resolve-LocalFolder $f } else { Join-Path $Source $f }
    $to   = if ($dstIsProfile) { Resolve-LocalFolder $f } else { Join-Path $Destination $f }

    if (-not $IncludeOneDrive -and (($srcIsProfile -and (Test-InOneDrive $from)) -or ($dstIsProfile -and (Test-InOneDrive $to)))) {
        Write-Host "SKIP  $f  (inside OneDrive - OneDrive will sync it; use -IncludeOneDrive to copy anyway)" -ForegroundColor DarkYellow
        continue
    }
    $jobs.Add([pscustomobject]@{ Name = $f; From = $from; To = $to })
}

foreach ($e in $Extra) {
    $leaf = Split-Path $e -Leaf
    if ($srcIsProfile) {
        # Extra path on this PC, going out to a drive/share.
        $from = Normalize $e
        $to   = Join-Path (Join-Path $Destination '_Extra') $leaf
    } elseif ($dstIsProfile) {
        # Coming back from a drive/share to the original path on this PC.
        $from = Join-Path (Join-Path $Source '_Extra') $leaf
        $to   = Normalize $e
    } else {
        $from = Join-Path (Join-Path $Source '_Extra') $leaf
        $to   = Join-Path (Join-Path $Destination '_Extra') $leaf
    }
    $jobs.Add([pscustomobject]@{ Name = "Extra: $leaf"; From = $from; To = $to })
}

if ($jobs.Count -eq 0) {
    Write-Host 'Nothing to copy.'
    return
}

# Log goes to TEMP, never inside the copied data.
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$logFile = Join-Path $env:TEMP "Migrate-UserData-$stamp.log"

Write-Host ''
Write-Host "Source      : $Source"
Write-Host "Destination : $Destination"
Write-Host "Threads     : $Threads"
Write-Host "Log         : $logFile"
if ($Preview) { Write-Host 'Mode        : PREVIEW (nothing will be copied)' -ForegroundColor Cyan }
Write-Host ''

# Robocopy options:
#   /E         include subfolders, including empty ones
#   /COPY:DAT  data, attributes, timestamps (no owner/ACLs - new PC has a different user SID)
#   /DCOPY:DAT same for folders
#   /XJ        skip junctions (avoids loops like "My Music" inside Documents)
#   /R:2 /W:5  retry locked/failed files twice, 5 seconds apart
#   /MT:n      multithreaded copy
#   /FFT       2-second timestamp tolerance (needed for exFAT/FAT32 USB drives)
#   /XA:ST     skip system and temporary files
#   /NP /NDL   no per-file percentage, no directory lines (keeps the log readable)
$common = @('/E','/COPY:DAT','/DCOPY:DAT','/XJ','/R:2','/W:5',"/MT:$Threads",'/FFT','/XA:ST','/NP','/NDL',"/UNILOG+:$logFile")
$excludeFiles = @('/XF','desktop.ini','thumbs.db','*.tmp','~$*')
if ($Preview) { $common += '/L' }

$results = foreach ($j in $jobs) {
    if (-not (Test-Path -LiteralPath $j.From)) {
        Write-Host "MISS  $($j.Name)  ($($j.From) not found)" -ForegroundColor DarkGray
        [pscustomobject]@{ Folder = $j.Name; Result = 'Not found'; Code = '' }
        continue
    }
    Write-Host "COPY  $($j.Name)" -ForegroundColor Green
    Write-Host "      $($j.From)  ->  $($j.To)"

    & robocopy.exe $j.From $j.To @common @excludeFiles | Out-Null
    $code = $LASTEXITCODE

    # Robocopy exit codes: 0-7 = success (bit flags), 8+ = at least one failure.
    $status = if ($code -ge 8) { 'FAILED - see log' }
              elseif ($code -band 1) { 'Copied' }
              else { 'Up to date' }
    if ($code -band 2) { $status += ' (extra files at destination left alone)' }
    [pscustomobject]@{ Folder = $j.Name; Result = $status; Code = $code }
}

Write-Host ''
$results | Format-Table -AutoSize
Write-Host "Full log: $logFile"

if ($results | Where-Object { $_.Code -ne '' -and $_.Code -ge 8 }) {
    Write-Host 'Some files failed. Search the log for "ERROR". Usually a file was open - close the app and run the script again.' -ForegroundColor Yellow
    exit 1
}
