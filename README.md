# ESP32-C6 THZ-504 Heat Pump Integration

This project provides a simplified ESP32-C6 based solution for integrating a Tecalor THZ-504 heat pump with Home Assistant using ESPHome. It is inspired by and simplified from the [OneESP32ToRuleThemAll](https://github.com/kr0ner/OneESP32ToRuleThemAll) project, focusing specifically on THZ-504 functionality.

## Features

- **ESP32-C6 Support**: Optimized for the ESP32-C6 development board
- **THZ-504 Integration**: Direct CAN bus communication with Tecalor THZ-504 heat pump
- **Simplified Codebase**: Streamlined implementation focusing only on essential THZ-504 features
- **Home Assistant Integration**: Native ESPHome integration with Home Assistant
- **Real-time Monitoring**: Monitor temperatures, status, and performance metrics
- **Remote Control**: Control heat pump settings from Home Assistant

## Hardware Requirements

- ESP32-C6 development board (e.g., ESP32-C6-DevKit-C-1)
- MCP2515 CAN bus controller
- CAN transceiver (e.g., TJA1050)
- Connecting wires and breadboard/PCB

## Wiring

| ESP32-C6 Pin | MCP2515 Pin | Description |
|--------------|-------------|-------------|
| GPIO6        | SCK         | SPI Clock   |
| GPIO7        | MOSI (SI)   | SPI Data Out|
| GPIO2        | MISO (SO)   | SPI Data In |
| GPIO10       | CS          | Chip Select |
| 3.3V         | VCC         | Power       |
| GND          | GND         | Ground      |

Connect the CAN transceiver between MCP2515 and the heat pump's CAN bus.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jss-devops01/ESP32-C6_THZ-504.git
   cd ESP32-C6_THZ-504
   ```

2. Create a `secrets.yaml` file with your configuration:
   ```yaml
   wifi_ssid: "Your_WiFi_SSID"
   wifi_password: "Your_WiFi_Password"
   api_encryption_key: "your_32_character_api_key_here"
   ota_password: "your_ota_password"
   ap_password: "fallback_hotspot_password"
   ```

3. Update the entity IDs in `esp32-c6-thz504.yaml` to match your Home Assistant sensors:
   ```yaml
   substitutions:
     entity_room_temperature: "sensor.your_room_temperature"
     entity_humidity: "sensor.your_room_humidity"
   ```

4. Upload to your ESP32-C6 using ESPHome:
   ```bash
   esphome run esp32-c6-thz504.yaml
   ```

## Configuration

The project is structured with modular YAML files:

- `esp32-c6-thz504.yaml` - Main configuration file
- `yaml/common.yaml` - Common ESPHome configuration
- `yaml/wp_base.yaml` - Base heat pump functionality
- `yaml/thz504.yaml` - THZ-504 specific configuration
- `yaml/wp_*.yaml` - Template files for different entity types

## Supported THZ-504 Features

### Temperature Sensors
- Room temperature (actual/setpoint for day/night)
- Hot water tank temperature (actual/setpoint for day/night)
- Outside temperature
- Evaporator temperature
- Exhaust air temperature
- Dew point temperature

### Status Monitoring
- Heat pump operating status
- Compressor status
- Heating/cooling modes
- Ventilation status
- Filter status
- Service indicators

### Control Functions
- Operation mode selection (Auto, Manual, etc.)
- Temperature setpoints
- Passive cooling mode
- Hot water eco mode
- Electric auxiliary heating

### Performance Metrics
- Motor current/voltage/power
- Compressor frequency
- Heating power (relative and absolute)
- Air flow rates (supply/exhaust)
- Filter differential pressure

## Troubleshooting

### CAN Bus Issues
- Verify wiring connections
- Check CAN bus termination (120Ω resistors)
- Ensure correct bit rate (20kbps for THZ-504)
- Monitor logs for CAN message activity

### No Data from Heat Pump
- Confirm heat pump CAN bus accessibility
- Check if heat pump allows external CAN communication
- Verify CAN IDs match your heat pump configuration

### Connection Issues
- Check WiFi credentials in secrets.yaml
- Verify Home Assistant API encryption key
- Ensure ESP32-C6 is within WiFi range

## Customization

To add new sensors or modify existing ones:

1. Add property definitions in `src/property.h`
2. Create or modify template YAML files in the `yaml/` directory
3. Update the packages section in relevant configuration files

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this project.

## License

This project is provided as-is under the MIT License. See LICENSE file for details.

## Acknowledgments

- Based on the excellent work of [OneESP32ToRuleThemAll](https://github.com/kr0ner/OneESP32ToRuleThemAll)
- Thanks to the ESPHome and Home Assistant communities
- Inspired by community forum discussions on heat pump integration