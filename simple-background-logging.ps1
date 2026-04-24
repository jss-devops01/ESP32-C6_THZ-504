# Simple Background Logging - No Unicode Issues
# This script uses Start-Process to completely avoid PowerShell stream handling

param(
    [string]$DeviceIP = "192.168.200.80",
    [string]$ConfigFile = "esp32-c6-thz504.yaml",
    [string]$LogFile = "logs.txt"
)

$ProjectPath = "C:\dev\repos\OneESP32ToRuleThemAll"
$LogFilePath = Join-Path $ProjectPath $LogFile

Write-Host "Starting ESPHome log collection in background..." -ForegroundColor Cyan
Write-Host "  Device:  $DeviceIP" -ForegroundColor Gray
Write-Host "  Config:  $ConfigFile" -ForegroundColor Gray
Write-Host "  Log File: $LogFile" -ForegroundColor Gray
Write-Host ""

# Build the command to run
$esphomeCmd = "esphome logs $ConfigFile --device $DeviceIP > `"$LogFilePath`" 2>&1"

# Start in a hidden PowerShell window
$process = Start-Process powershell -ArgumentList "-NoProfile", "-Command", "cd `"$ProjectPath`"; $esphomeCmd" -WindowStyle Hidden -PassThru

if ($process) {
    Write-Host "Background logging started successfully!" -ForegroundColor Green
    Write-Host "  Process ID: $($process.Id)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  Get-Content $LogFile -Wait -Tail 20               # Monitor logs"
    Write-Host "  Get-Process -Id $($process.Id)                    # Check if running"
    Write-Host "  Stop-Process -Id $($process.Id)                   # Stop logging"
    Write-Host "  .\analyze-unknown-properties.ps1 -LogFile '$LogFile'  # Analyze"
    Write-Host ""
    Write-Host "To check for UNKNOWN_PROPERTY entries:" -ForegroundColor Yellow
    Write-Host "  Get-Content $LogFile | Select-String 'UNKNOWN_PROPERTY'" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "Failed to start background logging!" -ForegroundColor Red
}
