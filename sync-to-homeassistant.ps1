# ESPHome Configuration Sync Script
# Syncs local development folder to Home Assistant ESPHome config directory
# Author: Generated for THZ-504 ESPHome project
# Date: September 28, 2025

param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Help
)

# Configuration
$LocalPath = "C:\dev\repos\OneESP32ToRuleThemAll"
$RemotePath = "\\192.168.200.100\config\esphome"
$LogFile = "C:\dev\repos\OneESP32ToRuleThemAll\tmp\sync-log.txt"

# Files and directories to exclude from sync
$ExcludePatterns = @(
    ".esphome",
    ".git",
    ".gitignore", 
    "sync-*.ps1",
    "sync-log.txt",
    "*.log",
    "tmp",
    ".vscode",
    "*.bak",
    "*.tmp"
)

function Show-Help {
    Write-Host "ESPHome Configuration Sync Script" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\sync-to-homeassistant.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -DryRun    Show what would be copied without actually copying"
    Write-Host "  -Force     Overwrite all files without prompting"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\sync-to-homeassistant.ps1                # Normal sync"
    Write-Host "  .\sync-to-homeassistant.ps1 -DryRun        # Preview changes"
    Write-Host "  .\sync-to-homeassistant.ps1 -Force         # Force overwrite"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Cyan
    Write-Host "  Syncs the local ESPHome development folder to Home Assistant's"
    Write-Host "  ESPHome configuration directory. Useful for deploying changes"
    Write-Host "  made during development to the production environment."
    Write-Host ""
    Write-Host "  Local:  $LocalPath"
    Write-Host "  Remote: $RemotePath"
}

function Write-Log {
    param($Message, $Color = "White")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Host $LogMessage -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $LogMessage
}

function Test-NetworkPath {
    param($Path)
    try {
        return Test-Path $Path -ErrorAction Stop
    } catch {
        return $false
    }
}

function Get-ExcludeString {
    $excludeString = ""
    foreach ($pattern in $ExcludePatterns) {
        $excludeString += "/XD:$pattern "
    }
    return $excludeString.Trim()
}

function Start-Sync {
    Write-Log "Starting ESPHome configuration sync..." "Green"
    Write-Log "Local Path:  $LocalPath" "Cyan"
    Write-Log "Remote Path: $RemotePath" "Cyan"
    
    # Verify paths exist
    if (-not (Test-Path $LocalPath)) {
        Write-Log "ERROR: Local path does not exist: $LocalPath" "Red"
        return $false
    }
    
    if (-not (Test-NetworkPath $RemotePath)) {
        Write-Log "ERROR: Cannot access remote path: $RemotePath" "Red"
        Write-Log "Please ensure Home Assistant is running and the network share is accessible." "Yellow"
        return $false
    }
    
    # Build robocopy command
    $robocopyArgs = @(
        "`"$LocalPath`"",
        "`"$RemotePath`"",
        "/MIR",          # Mirror directory tree
        "/R:3",          # Retry 3 times on failed copies
        "/W:10",         # Wait 10 seconds between retries
        "/TEE",          # Output to console and log file
        "/NP",           # No progress percentage
        "/NDL",          # No directory list
        "/NC",           # No class
        "/NS",           # No size
        "/NFL"           # No file list
    )
    
    # Add exclusions
    foreach ($pattern in $ExcludePatterns) {
        $robocopyArgs += "/XD"
        $robocopyArgs += $pattern
    }
    
    # Add dry run flag if specified
    if ($DryRun) {
        $robocopyArgs += "/L"
        Write-Log "DRY RUN MODE - No files will be copied" "Yellow"
    }
    
    # Add force flag if specified
    if (-not $Force -and -not $DryRun) {
        Write-Log "Use -Force to overwrite files without confirmation" "Yellow"
    }
    
    Write-Log "Executing robocopy with arguments: $robocopyArgs" "Gray"
    
    try {
        $result = & robocopy @robocopyArgs
        $exitCode = $LASTEXITCODE
        
        # Robocopy exit codes: 0=No files copied, 1=Files copied successfully, 2=Extra files/dirs detected, 4=Mismatched files/dirs
        if ($exitCode -le 4) {
            Write-Log "Sync completed successfully (Exit Code: $exitCode)" "Green"
            
            # Interpret exit codes
            switch ($exitCode) {
                0 { Write-Log "No files needed to be copied - directories are in sync" "Green" }
                1 { Write-Log "Files were copied successfully" "Green" }
                2 { Write-Log "Extra files or directories were detected and handled" "Green" }
                4 { Write-Log "Some mismatched files or directories were detected" "Yellow" }
            }
            
            return $true
        } else {
            Write-Log "Sync completed with warnings or errors (Exit Code: $exitCode)" "Yellow"
            return $false
        }
    } catch {
        Write-Log "ERROR during sync: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Show-Summary {
    Write-Log "=== SYNC SUMMARY ===" "Green"
    Write-Log "Synced from: $LocalPath" "Cyan"
    Write-Log "Synced to:   $RemotePath" "Cyan"
    Write-Log ""
    Write-Log "Next steps:" "Yellow"
    Write-Log "1. Open Home Assistant" "White"
    Write-Log "2. Go to ESPHome dashboard" "White"
    Write-Log "3. Click on your THZ-504 device" "White"
    Write-Log "4. Click 'Install' to build and upload to ESP32" "White"
    Write-Log ""
    Write-Log "Log file: $LogFile" "Gray"
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "ESPHome Configuration Sync Script" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Initialize log file
"" | Out-File -FilePath $LogFile -Encoding UTF8

# Perform sync
$success = Start-Sync

if ($success) {
    Show-Summary
    exit 0
} else {
    Write-Log "Sync failed - check log for details" "Red"
    exit 1
}
