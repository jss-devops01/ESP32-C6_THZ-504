# Start ESPHome Log Collection in Background
# This script starts logging in the background and provides management commands

param(
    [Parameter(Mandatory=$false)]
    [string]$DeviceIP = "192.168.200.80",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "esp32-c6-thz504.yaml",
    
    [Parameter(Mandatory=$false)]
    [string]$LogFile = "logs.txt",
    
    [switch]$Stop,
    [switch]$Status,
    [switch]$View
)

$ProjectPath = "C:\dev\repos\OneESP32ToRuleThemAll"
$JobName = "ESPHomeBackgroundLogs"

function Start-BackgroundLogging {
    # Check if job already exists
    $existingJob = Get-Job -Name $JobName -ErrorAction SilentlyContinue
    if ($existingJob) {
        Write-Host "Background logging is already running (Job ID: $($existingJob.Id))" -ForegroundColor Yellow
        Write-Host "Use -Stop to stop it first, or -Status to check status" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Starting background log collection..." -ForegroundColor Cyan
    Write-Host "  Device: $DeviceIP" -ForegroundColor Gray
    Write-Host "  Config: $ConfigFile" -ForegroundColor Gray
    Write-Host "  Output: $LogFile" -ForegroundColor Gray
    Write-Host ""
    
    # Start the background job
    # Use direct output redirection instead of Tee-Object to avoid Unicode encoding issues
    $job = Start-Job -Name $JobName -ScriptBlock {
        param($Path, $Config, $Device, $Output)
        Set-Location $Path
        # Direct redirection avoids PowerShell's stream processing that causes Unicode errors
        & esphome logs $Config --device $Device > $Output 2>&1
    } -ArgumentList $ProjectPath, $ConfigFile, $DeviceIP, "$ProjectPath\$LogFile"
    
    Start-Sleep -Seconds 2
    
    $jobStatus = Get-Job -Name $JobName
    if ($jobStatus.State -eq "Running") {
        Write-Host "Background logging started successfully!" -ForegroundColor Green
        Write-Host "  Job Name: $JobName" -ForegroundColor Gray
        Write-Host "  Job ID:   $($jobStatus.Id)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Yellow
        Write-Host "  .\start-background-logging.ps1 -Status    # Check status"
        Write-Host "  .\start-background-logging.ps1 -View      # View recent logs"
        Write-Host "  .\start-background-logging.ps1 -Stop      # Stop logging"
        Write-Host ""
    } else {
        Write-Host "Failed to start background logging" -ForegroundColor Red
        Receive-Job -Name $JobName
        Remove-Job -Name $JobName -Force
    }
}

function Stop-BackgroundLogging {
    $job = Get-Job -Name $JobName -ErrorAction SilentlyContinue
    if (-not $job) {
        Write-Host "No background logging job found" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Stopping background log collection..." -ForegroundColor Cyan
    Stop-Job -Name $JobName
    Remove-Job -Name $JobName -Force
    Write-Host "Background logging stopped" -ForegroundColor Green
}

function Show-JobStatus {
    $job = Get-Job -Name $JobName -ErrorAction SilentLyContinue
    if (-not $job) {
        Write-Host "No background logging job found" -ForegroundColor Yellow
        Write-Host "Use .\start-background-logging.ps1 to start logging" -ForegroundColor Gray
        return
    }
    
    Write-Host ""
    Write-Host "Background Logging Status" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    Write-Host "Job Name:  $($job.Name)" -ForegroundColor Cyan
    Write-Host "Job ID:    $($job.Id)" -ForegroundColor Cyan
    Write-Host "State:     $($job.State)" -ForegroundColor $(if ($job.State -eq "Running") { "Green" } else { "Yellow" })
    Write-Host "Started:   $($job.PSBeginTime)" -ForegroundColor Gray
    
    if (Test-Path "$ProjectPath\$LogFile") {
        $fileInfo = Get-Item "$ProjectPath\$LogFile"
        Write-Host "Log File:  $LogFile" -ForegroundColor Cyan
        Write-Host "Size:      $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
        Write-Host "Modified:  $($fileInfo.LastWriteTime)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Recent output (last 10 lines):" -ForegroundColor Yellow
    if (Test-Path "$ProjectPath\$LogFile") {
        Get-Content "$ProjectPath\$LogFile" -Tail 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

function Show-LogView {
    if (-not (Test-Path "$ProjectPath\$LogFile")) {
        Write-Host "Log file not found: $LogFile" -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "Recent Logs (last 30 lines)" -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Green
    Get-Content "$ProjectPath\$LogFile" -Tail 30
    Write-Host ""
    Write-Host "To view UNKNOWN_PROPERTY entries:" -ForegroundColor Yellow
    Write-Host "  Get-Content $LogFile | Select-String 'UNKNOWN_PROPERTY'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To analyze unknown properties:" -ForegroundColor Yellow
    Write-Host "  .\analyze-unknown-properties.ps1 -LogFile '$LogFile'" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
if ($Stop) {
    Stop-BackgroundLogging
} elseif ($Status) {
    Show-JobStatus
} elseif ($View) {
    Show-LogView
} else {
    Start-BackgroundLogging
}
