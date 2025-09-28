# ESP32-C6 THZ-504 Setup Guide

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jss-devops01/ESP32-C6_THZ-504.git
   cd ESP32-C6_THZ-504
   ```

2. **Validate project structure:**
   ```bash
   python3 validate_project.py
   ```

3. **Create secrets file:**
   ```bash
   cp secrets.yaml.template secrets.yaml
   # Edit secrets.yaml with your actual values
   ```

4. **Upload to ESP32-C6:**
   ```bash
   esphome run esp32-c6-thz504.yaml
   ```

## Hardware Setup

### ESP32-C6 to MCP2515 Wiring

| ESP32-C6 Pin | MCP2515 Pin | Function    |
|--------------|-------------|-------------|
| GPIO6        | SCK         | SPI Clock   |
| GPIO7        | MOSI        | SPI Data Out|
| GPIO2        | MISO        | SPI Data In |
| GPIO10       | CS          | Chip Select |
| 3.3V         | VCC         | Power (+)   |
| GND          | GND         | Ground (-)  |

### MCP2515 to CAN Transceiver

| MCP2515 Pin  | TJA1050 Pin | Function    |
|--------------|-------------|-------------|
| CANL         | CANL        | CAN Low     |
| CANH         | CANH        | CAN High    |
| VCC          | VCC         | Power (+)   |
| GND          | GND         | Ground (-)  |

### CAN Bus Connection

- Connect CANH and CANL from the transceiver to the heat pump's CAN bus
- Ensure proper 120Ω termination resistors at both ends of the CAN bus
- CAN bus operates at 20kbps for THZ-504

## Configuration

### secrets.yaml Example

```yaml
# WiFi Configuration
wifi_ssid: "YourHomeWiFi"
wifi_password: "your_wifi_password"

# Home Assistant API
api_encryption_key: "abcdef1234567890abcdef1234567890"

# OTA Updates
ota_password: "your_ota_password"

# Fallback Hotspot
ap_password: "esp32_fallback_pass"
```

### Home Assistant Integration

1. **Add ESP32-C6 to ESPHome dashboard:**
   - The device will appear automatically once connected

2. **Update room temperature/humidity sensors:**
   Edit `esp32-c6-thz504.yaml`:
   ```yaml
   substitutions:
     entity_room_temperature: "sensor.your_temperature_sensor"
     entity_humidity: "sensor.your_humidity_sensor"
   ```

3. **Available entities in Home Assistant:**
   - Temperature sensors (room, water tank, outside, etc.)
   - Binary sensors (heating, cooling, compressor status, etc.)
   - Controls (setpoints, operation modes, switches)
   - Performance metrics (power, efficiency, flow rates)

## Troubleshooting

### No CAN Communication

1. **Check wiring connections**
2. **Verify CAN bus termination (120Ω resistors)**
3. **Confirm heat pump allows external CAN access**
4. **Monitor ESP32-C6 logs for CAN messages**

### WiFi Connection Issues

1. **Verify credentials in secrets.yaml**
2. **Check signal strength**
3. **Use fallback hotspot if needed (ESP32-C6-THZ504)**

### No Data in Home Assistant

1. **Confirm ESPHome integration is working**
2. **Check API encryption key matches**
3. **Verify entity IDs for room sensors**
4. **Review ESP32-C6 logs for errors**

## Advanced Configuration

### Adding Custom Sensors

1. **Define new property in `src/property.h`:**
   ```cpp
   static constexpr Property kNEW_SENSOR{"NEW_SENSOR", 0x1234, Type::et_dec_val};
   ```

2. **Add to appropriate YAML file:**
   ```yaml
   NEW_SENSOR: !include { file: wp_temperature.yaml, vars: { property: "NEW_SENSOR" }}
   ```

### Modifying Update Intervals

Edit substitutions in `esp32-c6-thz504.yaml`:
```yaml
substitutions:
  interval_very_fast: 10s  # More frequent updates
  interval_fast: 20s
  interval_medium: 45s
  interval_slow: 3min
```

### CAN Bus Debugging

Enable debug logging in `esp32-c6-thz504.yaml`:
```yaml
logger:
  level: DEBUG
  logs:
    canbus: DEBUG
```

## Project Structure

```
ESP32-C6_THZ-504/
├── esp32-c6-thz504.yaml      # Main ESPHome configuration
├── src/                       # C++ source files
│   ├── property.h/.cpp        # THZ-504 property definitions
│   ├── communication.h/.cpp   # CAN bus communication
│   ├── type.h/.cpp           # Data type conversions
│   ├── mapper.h/.cpp         # Value mapping functions
│   ├── callback_handler.h    # Event callback system
│   └── simple_variant.h      # Simple variant type
├── yaml/                      # YAML template files
│   ├── common.yaml           # Common configuration
│   ├── thz504.yaml           # THZ-504 specific config
│   ├── wp_base.yaml          # Base heat pump features
│   └── wp_*.yaml             # Entity templates
├── secrets.yaml.template     # Template for secrets
└── validate_project.py       # Project validation script
```