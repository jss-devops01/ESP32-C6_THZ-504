# OneESP32ToRuleThemAll - THZ504 Simplified

This project is a simplified version derived from [OneESP32ToRuleThemAll](https://github.com/kr0ner/OneESP32ToRuleThemAll), specifically focused on controlling the **Tecalor THZ504** heat pump via CAN bus using an ESP32 board and Home Assistant.

## About

This codebase has been streamlined from the original OneESP32ToRuleThemAll project to focus exclusively on the Tecalor THZ504 model, removing support for smart meters, water meters, and other heat pump variants to provide a cleaner, more targeted solution.

## Features:

  - **Tecalor THZ504 Heat Pump Control** via CAN bus using SN65HVD230 transceiver [https://www.amazon.de/dp/B00KM6XMXO]
  - Complete climate control (heating, cooling, hot water)
  - Energy monitoring (daily/total consumption, COP calculations)
  - Ventilation control with multiple speed levels
  - Temperature sensors (room, storage, flow, return temperatures)
  - Binary sensors for system status (compressor, pumps, filters)
  - Custom ESPHome climate entities with Home Assistant integration

## Prerequisites:

  - A working Home Assistant installation [https://www.home-assistant.io/]
  - ESPHome AddOn installed [https://www.home-assistant.io/integrations/esphome/]

## Hardware Requirements:

  - ESP32-C6-Zero board
  - SN65HVD230 CAN bus transceiver module [https://www.amazon.de/dp/B00KM6XMXO]
  - Tecalor THZ504 heat pump with CAN bus interface

## Setup Instructions:

1. **Hardware Connection:**
   - Connect SN65HVD230 CAN transceiver to ESP32-C6-Zero:
     - TX: GPIO5
     - RX: GPIO4
     - VCC: 3.3V
     - GND: GND
     - Connect CAN H/L to your THZ504's CAN bus

2. **ESPHome Configuration:**
   - Navigate to your ESPHome folder
   - Clone or copy this repository
   - Use `esp32-c6-thz504.yaml` as your main configuration file
   - Update `secrets.yaml` with your WiFi credentials and API keys
   - Modify Home Assistant entity IDs in `common.yaml` for room temperature and humidity sensors

3. **Home Assistant Integration:**
   - Install ESPHome add-on if not already installed
   - Add the device to ESPHome dashboard
   - Flash the firmware to your ESP32-C6-Zero
   - Configure room temperature and humidity sensors in Home Assistant

## Project Structure

- **`esp32-c6-thz504.yaml`** - Main ESP32-C6-Zero configuration file
- **`yaml/thz504.yaml`** - THZ504-specific sensor definitions
- **`yaml/common.yaml`** - Common CAN bus and core functionality (configured for SN65HVD230)
- **`yaml/wp_base.yaml`** - Base heat pump sensors and climate entities
- **`src/`** - C++ source files for custom components
- **`components/`** - Custom ESPHome components

## Available Entities

The configuration provides comprehensive control and monitoring:

- **Climate Controls:** Heating Day/Night, Hot Water Day/Night with temperature setpoints
- **Binary Sensors:** Compressor, heating, cooling, ventilation, pumps, filter status
- **Temperature Sensors:** Room, storage tank, flow/return, outdoor, evaporator
- **Energy Monitoring:** Daily energy consumption, COP calculations, total energy counters
- **Ventilation:** 3-speed fan control with airflow monitoring
- **System Status:** Operating modes, error messages, service indicators

## Customization for THZ504

This version is specifically configured for THZ504 with:
- ESP32-C6-Zero with built-in CAN controller using SN65HVD230 transceiver
- CAN bus IDs optimized for THZ504 communication
- Temperature sensor mappings verified for THZ504
- Energy calculation formulas based on THZ504 specifications
- Ventilation control adapted to THZ504 fan characteristics

## Troubleshooting

### Heat Pump Control Issues
- Increase log level to DEBUG in your YAML configuration
- Check CAN bus wiring (CAN H/L connections)
- Verify CAN bus termination resistors are properly installed
- Monitor CAN traffic using the built-in logging

### Sensor Value Issues
- THZ504-specific sensor mappings are pre-configured in this version
- If values appear incorrect, check the heat pump display to verify scaling
- Some sensors may take time to populate after initial connection

### Connection Problems
- Ensure ESP32-C6-Zero is properly powered and connected to WiFi
- Check that the SN65HVD230 CAN transceiver is receiving 3.3V power
- Verify CAN H/L wiring connections to the THZ504
- Verify Home Assistant can communicate with the ESPHome device

## Credits & Acknowledgments

This project is **derived from** [OneESP32ToRuleThemAll](https://github.com/kr0ner/OneESP32ToRuleThemAll) by [@kr0ner](https://github.com/kr0ner) and has been simplified to focus specifically on the **Tecalor THZ504** heat pump model.

**Original project inspiration:**
- [OneESP32ToRuleThemAll](https://github.com/kr0ner/OneESP32ToRuleThemAll) - The comprehensive multi-device ESP32 solution
- Home Assistant Community Forum: [Configured my ESPHome with MCP2515 CAN bus for Stiebel Eltron heating pump](https://community.home-assistant.io/t/configured-my-esphome-with-mcp2515-can-bus-for-stiebel-eltron-heating-pump/366053)
- [ha-stiebel-control](https://github.com/bullitt186/ha-stiebel-control) by [@bullitt186](https://github.com/bullitt186)

**Special thanks to:**
- [@kr0ner](https://github.com/kr0ner) for the original comprehensive implementation
- [@hovhannes85](https://github.com/hovhannes85) for contributions to the original project
- The Home Assistant and ESPHome communities for their ongoing support

## License

This project maintains the same license as the original OneESP32ToRuleThemAll project.

### Useful links
https://www.stiebel-eltron.de/content/dam/ste/cdbassets/historic/bedienungs-_u_installationsanleitungen/ISG_Modbus__b89c1c53-6d34-4243-a630-b42cf0633361.pdf
