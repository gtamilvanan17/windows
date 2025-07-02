# ========================================
# Script: Get-Top20-Folders.ps1
# Purpose: List top 20 largest folders in C:\ drive
# ========================================

# Informing the user
Write-Host "🔍 Scanning C:\ drive for folder sizes..." -ForegroundColor Cyan

# Get the top 20 folders by size
Get-ChildItem -Path "C:\" -Directory -Force -ErrorAction SilentlyContinue |
ForEach-Object {
    # For each folder, calculate the total size (recursively)
    $folderPath = $_.FullName
    $folderSize = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue |
                   Measure-Object -Property Length -Sum).Sum

    # Output a custom object with size and path
    [PSCustomObject]@{
        Folder = $folderPath
        SizeGB = [math]::Round($folderSize / 1GB, 2)
    }
} |
Sort-Object SizeGB -Descending |
Select-Object -First 20 |
Format-Table -AutoSize

# Done message
Write-Host "`n✅ Completed! Displayed top 20 largest folders in C:\" -ForegroundColor Green
