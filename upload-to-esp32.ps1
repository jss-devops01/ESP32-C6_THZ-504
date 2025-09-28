# ESPHome Direct Upload Script
# Compiles and uploads firmware directly to ESP32 device via OTA
# Author: Generated for THZ-504 ESPHome project
# Date: September 28, 2025

param(
    [switch]$CompileOnly,
    [switch]$UploadOnly,
    [switch]$Logs,
    [switch]$CleanBuild,
    [switch]$Serial,
    [switch]$ScanPorts,
    [switch]$Help,
    [string]$DeviceIP = "192.168.200.80",
    [string]$SerialPort = "COM6",
    [string]$ConfigFile = "esp32-c6-thz504.yaml"
)

# Configuration
$ProjectPath = "C:\dev\repos\OneESP32ToRuleThemAll"
$LogFile = "$ProjectPath\upload-log.txt"

function Show-Help {
    Write-Host "ESPHome Direct Upload Script" -ForegroundColor Green
    Write-Host "============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\upload-to-esp32.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -CompileOnly     Only compile, don't upload"
    Write-Host "  -UploadOnly      Only upload (skip compilation)"
    Write-Host "  -Serial          Upload via USB serial (for first flash)"
    Write-Host "  -ScanPorts       Scan and list available COM ports"
    Write-Host "  -Logs            Show device logs after upload"
    Write-Host "  -CleanBuild      Clean build cache before compiling"
    Write-Host "  -DeviceIP        Device IP address (default: 192.168.200.80)"
    Write-Host "  -SerialPort      Serial port (auto-detected if not specified)"
    Write-Host "  -ConfigFile      ESPHome config file (default: esp32-c6-thz504.yaml)"
    Write-Host "  -Help            Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\upload-to-esp32.ps1                          # Compile and upload"
    Write-Host "  .\upload-to-esp32.ps1 -CompileOnly             # Only compile"
    Write-Host "  .\upload-to-esp32.ps1 -Serial                  # Serial upload"
    Write-Host "  .\upload-to-esp32.ps1 -Serial -Logs            # Serial upload + logs"
    Write-Host "  .\upload-to-esp32.ps1 -Logs -SerialPort COM6   # Show serial logs only"
    Write-Host "  .\upload-to-esp32.ps1 -ScanPorts               # Scan for COM ports"
    Write-Host "  .\upload-to-esp32.ps1 -CleanBuild              # Clean build first"
    Write-Host "  .\upload-to-esp32.ps1 -DeviceIP 192.168.1.100  # Custom IP"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Cyan
    Write-Host "  Compiles ESPHome firmware and uploads it directly to your ESP32"
    Write-Host "  device via Over-The-Air (OTA) update. No need for Home Assistant!"
    Write-Host ""
    Write-Host "  Device IP: $DeviceIP"
    Write-Host "  Config:    $ConfigFile"
    Write-Host "  Project:   $ProjectPath"
    Write-Host ""
    Write-Host "REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "  - ESPHome installed and in PATH"
    Write-Host "  - ESP32 device connected to WiFi"
    Write-Host "  - OTA password configured (if required)"
}

function Write-Log {
    param($Message, $Color = "White")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Host $LogMessage -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $LogMessage
}

function Test-DeviceConnection {
    param($IP)
    Write-Log "Testing connection to device at ${IP}..." "Cyan"
    try {
        $ping = Test-Connection -ComputerName $IP -Count 2 -Quiet -ErrorAction Stop
        if ($ping) {
            Write-Log "Device is reachable at ${IP}" "Green"
            return $true
        } else {
            Write-Log "Device is not responding at ${IP}" "Yellow"
            return $false
        }
    } catch {
        Write-Log "Cannot reach device at ${IP}: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-ESPHomeInstalled {
    try {
        $version = & esphome version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "ESPHome found: $version" "Green"
            return $true
        } else {
            Write-Log "ESPHome command failed" "Red"
            return $false
        }
    } catch {
        Write-Log "ESPHome not found in PATH. Please install ESPHome first." "Red"
        Write-Log "Install with: pip install esphome" "Yellow"
        return $false
    }
}

function Start-CleanBuild {
    Write-Log "Cleaning build cache..." "Yellow"
    try {
        $result = & esphome clean $ConfigFile 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Build cache cleaned successfully" "Green"
            return $true
        } else {
            Write-Log "Clean failed: $result" "Red"
            return $false
        }
    } catch {
        Write-Log "Error during clean: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Start-Compilation {
    Write-Log "Starting compilation of $ConfigFile..." "Cyan"
    try {
        Write-Log "Running: esphome compile $ConfigFile" "Gray"
        $result = & esphome compile $ConfigFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Compilation completed successfully!" "Green"
            return $true
        } else {
            Write-Log "Compilation failed!" "Red"
            Write-Log "Error output: $result" "Red"
            return $false
        }
    } catch {
        Write-Log "Error during compilation: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Start-Upload {
    param($IP)
    Write-Log "Starting upload to device at ${IP}..." "Cyan"
    try {
        Write-Log "Running: esphome upload $ConfigFile --device ${IP}" "Gray"
        $result = & esphome upload $ConfigFile --device $IP 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Upload completed successfully!" "Green"
            Write-Log "Device should be rebooting now..." "Yellow"
            return $true
        } else {
            Write-Log "Upload failed!" "Red"
            Write-Log "Error output: $result" "Red"
            
            # Check for common issues
            if ($result -match "No serial port found") {
                Write-Log "Tip: Make sure the device is connected to WiFi and OTA is enabled" "Yellow"
            }
            if ($result -match "authentication") {
                Write-Log "Tip: Check if OTA password is required and correctly configured" "Yellow"
            }
            
            return $false
        }
    } catch {
        Write-Log "Error during upload: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Find-SerialPorts {
    Write-Log "Scanning for available serial ports..." "Cyan"
    try {
        $ports = [System.IO.Ports.SerialPort]::getportnames()
        if ($ports.Count -gt 0) {
            Write-Log "Found serial ports: $($ports -join ', ')" "Green"
            return $ports
        } else {
            Write-Log "No serial ports found" "Yellow"
            return @()
        }
    } catch {
        Write-Log "Error scanning serial ports: $($_.Exception.Message)" "Red"
        return @()
    }
}

function Show-DetailedSerialPorts {
    Write-Host "=== SERIAL PORT SCAN ===" -ForegroundColor Green
    Write-Host ""
    
    # Method 1: Basic port enumeration
    try {
        $basicPorts = [System.IO.Ports.SerialPort]::getportnames()
        if ($basicPorts.Count -gt 0) {
            Write-Host "Available COM Ports:" -ForegroundColor Yellow
            foreach ($port in $basicPorts) {
                Write-Host "  $port" -ForegroundColor White
            }
        } else {
            Write-Host "No basic COM ports found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error scanning basic ports: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # Method 2: Detailed device information
    try {
        Write-Host "Detailed Device Information:" -ForegroundColor Yellow
        $devices = Get-WmiObject -Class Win32_PnPEntity | Where-Object {$_.Caption -match "COM\d+"} | Sort-Object Caption
        
        if ($devices) {
            foreach ($device in $devices) {
                $comPort = ""
                if ($device.Caption -match "(COM\d+)") {
                    $comPort = $matches[1]
                }
                
                Write-Host "  Port: $comPort" -ForegroundColor Cyan
                Write-Host "    Device: $($device.Caption)" -ForegroundColor White
                Write-Host "    Status: $($device.Status)" -ForegroundColor Gray
                
                # Highlight likely ESP32 devices
                if ($device.Caption -match "CP210x|CH340|ESP32|Silicon Labs|USB.*UART|USB.*Serial") {
                    Write-Host "    >>> LIKELY ESP32 DEVICE <<<" -ForegroundColor Green
                }
                Write-Host ""
            }
        } else {
            Write-Host "  No devices with COM ports found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error getting detailed device info: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Connect your ESP32 via USB cable" -ForegroundColor White
    Write-Host "2. Look for devices containing: CP210x, CH340, ESP32, or 'USB to UART'" -ForegroundColor White
    Write-Host "3. Note the COM port (e.g., COM3, COM4)" -ForegroundColor White
    Write-Host "4. Use: .\upload-to-esp32.ps1 -Serial -SerialPort COMX" -ForegroundColor White
    Write-Host ""
}

function Start-SerialUpload {
    param($Port)
    
    if (-not $Port) {
        $availablePorts = Find-SerialPorts
        if ($availablePorts.Count -eq 0) {
            Write-Log "No serial ports available. Make sure ESP32 is connected via USB." "Red"
            return $false
        } elseif ($availablePorts.Count -eq 1) {
            $Port = $availablePorts[0]
            Write-Log "Auto-selected serial port: $Port" "Yellow"
        } else {
            Write-Log "Multiple serial ports found: $($availablePorts -join ', ')" "Yellow"
            Write-Log "Please specify port with -SerialPort parameter" "Yellow"
            return $false
        }
    }
    
    Write-Log "Starting serial upload to $Port..." "Cyan"
    try {
        Write-Log "Running: esphome upload $ConfigFile --device $Port" "Gray"
        $result = & esphome upload $ConfigFile --device $Port 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Serial upload completed successfully!" "Green"
            Write-Log "Device should be rebooting now..." "Yellow"
            return $true
        } else {
            Write-Log "Serial upload failed!" "Red"
            Write-Log "Error output: $result" "Red"
            
            # Check for common issues
            if ($result -match "permission denied" -or $result -match "access denied") {
                Write-Log "Tip: Close any serial monitors or other programs using the port" "Yellow"
            }
            if ($result -match "no such file or directory") {
                Write-Log "Tip: Make sure the ESP32 is properly connected and drivers are installed" "Yellow"
            }
            
            return $false
        }
    } catch {
        Write-Log "Error during serial upload: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Start-LogMonitoring {
    param($IP)
    Write-Log "Starting log monitoring for device at ${IP}..." "Cyan"
    Write-Log "Press Ctrl+C to stop log monitoring" "Yellow"
    try {
        & esphome logs $ConfigFile --device $IP
    } catch {
        Write-Log "Error during log monitoring: $($_.Exception.Message)" "Red"
    }
}

function Start-SerialLogMonitoring {
    param($Port)
    
    if (-not $Port) {
        $availablePorts = Find-SerialPorts
        if ($availablePorts.Count -eq 0) {
            Write-Log "No serial ports available. Make sure ESP32 is connected via USB." "Red"
            return $false
        } elseif ($availablePorts.Count -eq 1) {
            $Port = $availablePorts[0]
            Write-Log "Auto-selected serial port: $Port" "Yellow"
        } else {
            Write-Log "Multiple serial ports found: $($availablePorts -join ', ')" "Yellow"
            Write-Log "Using default port: COM6" "Yellow"
            $Port = "COM6"
        }
    }
    
    Write-Log "Starting serial log monitoring on ${Port}..." "Cyan"
    Write-Log "Press Ctrl+C to stop log monitoring" "Yellow"
    Write-Log "Connecting to ESP32 serial output..." "White"
    
    try {
        & esphome logs $ConfigFile --device $Port
    } catch {
        Write-Log "Error during serial log monitoring: $($_.Exception.Message)" "Red"
        Write-Log "Tips for serial logging:" "Yellow"
        Write-Log "- Make sure ESP32 is connected to $Port" "White"
        Write-Log "- Close any other serial monitors (Arduino IDE, PuTTY, etc.)" "White"
        Write-Log "- Try a different COM port if needed" "White"
    }
}

function Show-Summary {
    param($CompileSuccess, $UploadSuccess)
    Write-Log "=== OPERATION SUMMARY ===" "Green"
    Write-Log "Config File: $ConfigFile" "Cyan"
    Write-Log "Device IP:   $DeviceIP" "Cyan"
    Write-Log "Project:     $ProjectPath" "Cyan"
    Write-Log ""
    
    if ($CompileSuccess -ne $null) {
        $status = if ($CompileSuccess) { "SUCCESS" } else { "FAILED" }
        $color = if ($CompileSuccess) { "Green" } else { "Red" }
        Write-Log "Compilation: $status" $color
    }
    
    if ($UploadSuccess -ne $null) {
        $status = if ($UploadSuccess) { "SUCCESS" } else { "FAILED" }
        $color = if ($UploadSuccess) { "Green" } else { "Red" }
        Write-Log "Upload:      $status" $color
    }
    
    Write-Log ""
    Write-Log "Log file: $LogFile" "Gray"
    
    if ($UploadSuccess) {
        Write-Log "Next steps:" "Yellow"
        Write-Log "- Device should be running new firmware" "White"
        Write-Log "- Check Home Assistant for updated sensors" "White"
        Write-Log "- Monitor device logs with: .\upload-to-esp32.ps1 -Logs" "White"
    }
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "ESPHome Direct Upload Script" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Change to project directory  
Set-Location $ProjectPath

# Initialize log file
"" | Out-File -FilePath $LogFile -Encoding UTF8

Write-Log "Starting ESPHome direct upload process..." "Green"
Write-Log "Project path: $ProjectPath" "Cyan"
Write-Log "Config file:  $ConfigFile" "Cyan"
Write-Log "Device IP:    $DeviceIP" "Cyan"

# Pre-flight checks
if (-not (Test-Path $ConfigFile)) {
    Write-Log "ERROR: Config file not found: $ConfigFile" "Red"
    exit 1
}

if (-not (Test-ESPHomeInstalled)) {
    exit 1
}

# Variables to track success
$compileSuccess = $null
$uploadSuccess = $null

# Handle port scanning mode
if ($ScanPorts) {
    Show-DetailedSerialPorts
    exit 0
}

# Handle logs-only mode
if ($Logs -and -not $CompileOnly -and -not $UploadOnly -and -not $Serial) {
    # Check if SerialPort is specified for serial logs
    if ($SerialPort -and $SerialPort -ne "") {
        Start-SerialLogMonitoring $SerialPort
    } else {
        if (Test-DeviceConnection $DeviceIP) {
            Start-LogMonitoring $DeviceIP
        }
    }
    exit 0
}

# Handle upload-only mode
if ($UploadOnly) {
    if (Test-DeviceConnection $DeviceIP) {
        $uploadSuccess = Start-Upload $DeviceIP
        if ($uploadSuccess -and $Logs) {
            Start-Sleep -Seconds 5
            Start-LogMonitoring $DeviceIP
        }
    } else {
        $uploadSuccess = $false
    }
    Show-Summary $null $uploadSuccess
    exit $(if ($uploadSuccess) { 0 } else { 1 })
}

# Clean build if requested
if ($CleanBuild) {
    if (-not (Start-CleanBuild)) {
        exit 1
    }
}

# Compilation phase
$compileSuccess = Start-Compilation

if (-not $compileSuccess) {
    Show-Summary $compileSuccess $null
    exit 1
}

# If compile-only mode, we're done
if ($CompileOnly) {
    Show-Summary $compileSuccess $null
    exit 0
}

# Upload phase
if ($Serial) {
    Write-Log "Using serial upload mode..." "Yellow"
    $uploadSuccess = Start-SerialUpload $SerialPort
    
    # Show logs if requested and upload succeeded
    if ($uploadSuccess -and $Logs) {
        Write-Log "Waiting 5 seconds for device to reboot..." "Yellow"
        Start-Sleep -Seconds 5
        Start-SerialLogMonitoring $SerialPort
    }
} else {
    if (Test-DeviceConnection $DeviceIP) {
        $uploadSuccess = Start-Upload $DeviceIP
        
        # Show logs if requested and upload succeeded
        if ($uploadSuccess -and $Logs) {
            Write-Log "Waiting 5 seconds for device to reboot..." "Yellow"
            Start-Sleep -Seconds 5
            Start-LogMonitoring $DeviceIP
        }
    } else {
        $uploadSuccess = $false
    }
}

Show-Summary $compileSuccess $uploadSuccess

# Exit with appropriate code
$exitCode = 0
if (-not $compileSuccess) { $exitCode = 1 }
if (-not $uploadSuccess) { $exitCode = 1 }
exit $exitCode
