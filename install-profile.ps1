#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installation script for the Ultimate PowerShell Profile

.DESCRIPTION
    This script helps users easily install the enhanced PowerShell profile
    with proper backup and validation.

.PARAMETER Force
    Force overwrite of existing profile without confirmation

.PARAMETER Backup
    Create a backup of the existing profile (enabled by default)

.EXAMPLE
    .\install-profile.ps1

.EXAMPLE
    .\install-profile.ps1 -Force
#>

param(
    [switch]$Force,
    [switch]$NoBackup = $false
)

# Set colors for output
$Green = "Green"
$Cyan = "Cyan"
$Yellow = "Yellow"
$Red = "Red"

# Banner
Write-Host ""
Write-Host "=================================================" -ForegroundColor $Cyan
Write-Host "     Ultimate PowerShell Profile Installation     " -ForegroundColor $Cyan
Write-Host "=================================================" -ForegroundColor $Cyan
Write-Host ""

# Check if we're in the right directory
$scriptDir = Split-Path -Parent $PSCommandPath
$profileScript = Join-Path $scriptDir "Microsoft.PowerShell_profile.ps1"
$readmeFile = Join-Path $scriptDir "README.md"

if (!(Test-Path $profileScript)) {
    Write-Host "[ERROR] Microsoft.PowerShell_profile.ps1 not found in current directory" -ForegroundColor $Red
    Write-Host "Please run this script from the PowerShell profile directory" -ForegroundColor $Yellow
    exit 1
}

if (!(Test-Path $readmeFile)) {
    Write-Host "[ERROR] README.md not found in current directory" -ForegroundColor $Red
    Write-Host "Please run this script from the PowerShell profile directory" -ForegroundColor $Yellow
    exit 1
}

Write-Host "[OK] Found profile files in current directory" -ForegroundColor $Green
Write-Host ""

# Determine correct profile path
try {
    $currentProfilePath = $PROFILE
    if (!$currentProfilePath) {
        # Fallback to default profile location
        $currentProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
} catch {
    $currentProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}

Write-Host "Profile location: $currentProfilePath" -ForegroundColor $Cyan
$currentProfileExists = Test-Path $currentProfilePath

# Backup existing profile if it exists
if ($currentProfileExists -and !$NoBackup) {
    $backupPath = "$currentProfilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        Copy-Item -Path $currentProfilePath -Destination $backupPath -Force
        Write-Host "[OK] Backed up existing profile to: $backupPath" -ForegroundColor $Green
    }
    catch {
        Write-Host "[ERROR] Failed to backup existing profile: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
}

# Confirm installation if not forced and profile exists
if ($currentProfileExists -and !$Force) {
    Write-Host ""
    Write-Host "[WARNING] Existing PowerShell profile found at: $currentProfilePath" -ForegroundColor $Yellow
    $confirmation = Read-Host "Do you want to continue? (y/N)"

    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Installation cancelled by user" -ForegroundColor $Yellow
        exit 0
    }
}

# Install the profile
try {
    Write-Host ""
    Write-Host "[INFO] Installing PowerShell profile..." -ForegroundColor $Cyan

    # Copy profile script
    Copy-Item -Path $profileScript -Destination $currentProfilePath -Force
    Write-Host "[OK] Profile script installed" -ForegroundColor $Green

    # Create PowerShell directory if it doesn't exist
    $psDir = Split-Path -Parent $currentProfilePath
    if (!(Test-Path $psDir)) {
        New-Item -ItemType Directory -Path $psDir -Force | Out-Null
    }

    # Create bookmarks directory
    $bookmarksDir = Join-Path $env:APPDATA "PowerShell"
    if (!(Test-Path $bookmarksDir)) {
        New-Item -ItemType Directory -Path $bookmarksDir -Force | Out-Null
    }

    Write-Host "[OK] Profile directories created" -ForegroundColor $Green

    # Test profile syntax
    Write-Host ""
    Write-Host "[INFO] Validating profile syntax..." -ForegroundColor $Cyan

    try {
        # Simple syntax check by attempting to parse the file
        $content = Get-Content -Path $currentProfilePath -Raw
        [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null) | Out-Null
        Write-Host "[OK] Profile syntax is valid" -ForegroundColor $Green
    }
    catch {
        Write-Host "[ERROR] Profile syntax error: $($_.Exception.Message)" -ForegroundColor $Red
        Write-Host "Please check the profile file for syntax errors" -ForegroundColor $Yellow
        exit 1
    }

}
catch {
    Write-Host "[ERROR] Installation failed: $($_.Exception.Message)" -ForegroundColor $Red
    exit 1
}

# Success message
Write-Host ""
Write-Host "[SUCCESS] Installation completed successfully!" -ForegroundColor $Green
Write-Host ""
Write-Host "[DOCS] Documentation: $(Join-Path (Get-Location) 'README.md')" -ForegroundColor $Cyan
Write-Host ""
Write-Host "[INFO] To apply changes, restart PowerShell or run:" -ForegroundColor $Yellow
Write-Host "   . `$PROFILE" -ForegroundColor $Cyan
Write-Host ""
Write-Host "[COMMANDS] Quick start commands:" -ForegroundColor $Green
Write-Host "   qs          # Quick status overview" -ForegroundColor $Cyan
Write-Host "   bookmarks   # Manage directory bookmarks" -ForegroundColor $Cyan
Write-Host "   install-pkgs # Install project packages" -ForegroundColor $Cyan
Write-Host "   perf        # System performance" -ForegroundColor $Cyan
Write-Host ""
Write-Host "Happy PowerShelling! [ROCKET]" -ForegroundColor $Green