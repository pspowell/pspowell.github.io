# Toggle Start full-screen mode (Windows 10/11)
# Author: ChatGPT
# Date: 2025-11-03

$RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$ValueName = "Start_ShowFullScreen"

try {
    # Read current value
    $current = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName
} catch {
    # Create key/value if missing
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    New-ItemProperty -Path $RegPath -Name $ValueName -Value 0 -PropertyType DWord -Force | Out-Null
    $current = 0
}

# Toggle value: 1 = Full-screen ON, 0 = OFF
$new = if ($current -eq 1) { 0 } else { 1 }
Set-ItemProperty -Path $RegPath -Name $ValueName -Value $new

Write-Host "Start full-screen mode is now" -NoNewline
if ($new -eq 1) { Write-Host " ENABLED." -ForegroundColor Green } else { Write-Host " DISABLED." -ForegroundColor Yellow }

# Optionally restart Explorer to apply immediately
$response = Read-Host "Restart Explorer to apply now? (Y/N)"
if ($response -match '^[Yy]') {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}
