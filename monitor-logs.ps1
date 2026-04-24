# Monitor ESPHome Logs Without Crashing
# This script monitors logs and saves them without causing Python crashes

param(
    [Parameter(Mandatory=$false)]
    [string]$DeviceIP = "192.168.200.80",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "esp32-c6-thz504.yaml",
    
    [Parameter(Mandatory=$false)]
    [string]$LogFile = "logs.txt",
    
    [switch]$FilterUnknown
)

$ProjectPath = "C:\dev\repos\OneESP32ToRuleThemAll"
Set-Location $ProjectPath

if ($FilterUnknown) {
    Write-Host "Monitoring for UNKNOWN_PROPERTY entries..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    # Monitor the log file for changes and show only UNKNOWN_PROPERTY lines
    Get-Content $LogFile -Wait -Tail 100 | Where-Object { $_ -match "UNKNOWN_PROPERTY" }
} else {
    Write-Host "Starting ESPHome log collection..." -ForegroundColor Cyan
    Write-Host "Device: $DeviceIP" -ForegroundColor Gray
    Write-Host "Output: $LogFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Logs are being saved to: $LogFile" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To monitor UNKNOWN_PROPERTY entries in another terminal:" -ForegroundColor Yellow
    Write-Host "  .\monitor-logs.ps1 -FilterUnknown" -ForegroundColor Gray
    Write-Host ""
    
    # Just save logs to file without any filtering
    & esphome logs $ConfigFile --device $DeviceIP *>&1 | Out-File -FilePath $LogFile -Encoding UTF8 -Append
}
