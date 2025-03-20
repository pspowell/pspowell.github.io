---
layout: post
title:  "**How to stop using OneDrive**"
date:   2025-03-20
categories: tech
---


## Removing OneDrive

It's a common issue to want to revert your system's folder locations after OneDrive has taken over. Here's a detailed, step-by-step guide to help you quit OneDrive, move your files, and restore your default folder locations:

#### 1. Stop OneDrive Folder Backup:

>This is the most critical step. You must disable OneDrive's folder backup before moving files.

**Windows:**
1. Click the OneDrive cloud icon in the system tray.
2. Click the gear icon (Settings), and select "Settings."
3. Go to the "Sync and backup" tab, and click "Manage backup."
4. Turn off the backup for Desktop, Documents, and Pictures (or any folders being backed up).
5. Click "Stop backup" and confirm.

#### 2. Unlink Your OneDrive Account:

Now that the backup is stopped, you can unlink your account.

**Windows:**

1. In the OneDrive settings window (from the previous step), go to the "Account" tab.
2. Click "Unlink this PC," and then "Unlink account."

#### 3. Move Your Files to Their Original Locations:

**Open File Explorer.**
1. Navigate to your OneDrive folder (usually C:\Users\YourUserName\OneDrive).
2. Carefully move the contents of the Desktop, Documents, and Pictures folders (or any folders you backed up) to their corresponding locations:

    Desktop: C:\Users\YourUserName\Desktop/
    Documents: C:\Users\YourUserName\Documents/
    Pictures: C:\Users\YourUserName\Pictures/
    
>**Important note:** If when you try to move the files, you get a message saying that there are already files in the destination folder, you may have to merge the folders, or move the files within the folders, instead of moving the entire folder at once.

#### 4. Restore Default Folder Locations:

1. Right-click on the Desktop, Documents, or Pictures folder in File Explorer, and select "Properties."
2. Go to the "Location" tab.
3. Click "Restore Default."
4. Click "Apply," and then "OK."
5. If prompted, confirm that you want to move the files to the default location.
6. Repeat this process for each of the folders you moved.

#### 5. Uninstall OneDrive (Optional):

If you no longer want OneDrive on your system:

**Windows:**

1. Go to "Settings" > "Apps" > "Installed apps".
2. Find "Microsoft OneDrive" and click "Uninstall."
3. Follow the on-screen instructions.
 

#### Important Reminders:

#### Cloud Copies:
Unlinking and uninstalling OneDrive does not delete your files from the OneDrive cloud storage. If you want to remove those files, you'll need to do so through the OneDrive website.

#### Folder Redirection:
Be very careful when changing folder locations. Mistakes can lead to lost files or system instability.

#### Backups:
Before making any significant changes to your file system, it's always a good idea to create a backup of your important data.
If you find that your computer is still acting oddly after these steps, restarting your computer can solve many issues.

>**In Summary:** By following these detailed instructions, you should be able to successfully quit using OneDrive, move your files back to their original locations, and restore your default folder settings.

## Extra
Sometimes the special folder locations get messed up and need to be reset.  This script first backs up the existing special folder locations to the desktop, then resets them to defaults and restarts explorer.  If the default location does not exist, it is created first.  Copy and paste the code into a file "Reset user shell folders to defaults.ps1", then execute as Administrator.

```powershell
# Define output path for backup
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$BackupFile = "$desktopPath\SpecialFoldersBackup.reg"

# Registry keys to back up
$KeysToBackup = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
)

# Function to export registry keys

foreach ($Key in $KeysToBackup) {
    $KeyPath = $Key -replace "HKCU:", "HKEY_CURRENT_USER"
    reg export $KeyPath $BackupFile /y
    
}
    Write-Host "Backed up $Key to $BackupFile"

# Define output path for backup
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$BackupFile = "$desktopPath\SpecialFoldersBackup.reg"

# Clear the .reg file at the start
New-Item -ItemType File -Path $BackupFile -Force | Out-Null
Write-Host "Cleared existing backup file: $BackupFile"

# Registry keys to back up
$KeysToBackup = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
)

# Backup each key and append to the .reg file
foreach ($Key in $KeysToBackup) {
    $KeyPath = $Key -replace "HKCU:", "HKEY_CURRENT_USER"
    $TempFile = "$env:TEMP\TempBackup.reg"

    # Export the registry key to a temporary file
    reg export $KeyPath $TempFile /y

    # Append the content of the temporary file to the main backup file
    Get-Content $TempFile | Add-Content $BackupFile
    Write-Host "Appended backup for $Key to $BackupFile"
}

# Clean up the temporary file
Remove-Item $TempFile -Force

# Now, reset to defaults

# Define default folder paths
$DefaultFolders = @{
    'Desktop'   = "$env:USERPROFILE\Desktop"
    'Documents' = "$env:USERPROFILE\Documents"
    'Downloads' = "$env:USERPROFILE\Downloads"
    'Music'     = "$env:USERPROFILE\Music"
    'Pictures'  = "$env:USERPROFILE\Pictures"
    'Videos'    = "$env:USERPROFILE\Videos"
}

# Registry paths for Shell Folders and User Shell Folders
$UserShellFoldersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$ShellFoldersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

foreach ($Folder in $DefaultFolders.Keys) {
    $Path = $DefaultFolders[$Folder]

    # Check if the new folder exists, and create it if it doesn't
    if (-Not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Host "Created folder: $Path"
    }

    # Update User Shell Folders
    Set-ItemProperty -Path $UserShellFoldersPath -Name $Folder -Value $Path
    Write-Host "Reset $Folder in User Shell Folders to $Path"

    # Update Shell Folders
    Set-ItemProperty -Path $ShellFoldersPath -Name $Folder -Value $Path
    Write-Host "Reset $Folder in Shell Folders to $Path"
}

# Restart Windows Explorer
Write-Host "Restarting Windows Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer.exe
Write-Host "Windows Explorer has been restarted. Changes should now be applied."

# Notify completion
Write-Host "Registry keys have been backed up and special folder locations reset to their default values."
```

