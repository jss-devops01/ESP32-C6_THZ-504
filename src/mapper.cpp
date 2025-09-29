#include "mapper.h"

std::optional<std::string> Mapper::getError(const std::uint16_t id) const {
    const auto it = errorMap.find(id);
    return (it != errorMap.cend()) ? std::make_optional(it->second) : std::nullopt;
}

std::optional<std::string> Mapper::getBetriebsart(const std::uint16_t id) const {
    const auto it = betriebsartMap.find(id);
    return (it != betriebsartMap.cend()) ? std::make_optional(it->second) : std::nullopt;
}

std::optional<std::uint16_t> Mapper::getBetriebsartId(const std::string& betriebsart) const {
    for (const auto& element : betriebsartMap) {
        if (element.second == betriebsart) {
            return element.first;
        }
    }
    return {};
}

std::optional<std::string> Mapper::getKuehlmodus(const std::uint16_t id) const {
    const auto it = kuehlmodusMap.find(id);
    return (it != kuehlmodusMap.cend()) ? std::make_optional(it->second) : std::nullopt;
}

std::optional<std::uint16_t> Mapper::getKuehlmodusId(const std::string& kuehlmodus) const {
    for (const auto& element : kuehlmodusMap) {
        if (element.second == kuehlmodus) {
            return element.first;
        }
    }
    return {};
}

std::optional<std::string> Mapper::getPassivkuehlung(const std::uint16_t id) const {
    const auto it = passivkuehlungMap.find(id);
    return (it != passivkuehlungMap.end()) ? std::make_optional(it->second) : std::nullopt;
}

std::optional<std::uint16_t> Mapper::getPassivkuehlungId(const std::string& passivkuehlung) const {
    for (const auto& element : passivkuehlungMap) {
        if (element.second == passivkuehlung) {
            return element.first;
        }
    }
    return {};
}

Mapper::Mapper() {
    errorMap = {{0x0002, "CONTACTOR_STUCK"},
                {0x0003, "ERR HD-SENSOR"},
                {0x0004, "HIGH_PRESSURE"},
                {0x0005, "EVAPORATOR_SENSOR_ERROR"},
                {0x0006, "RELAY_DRIVER_ERROR"},
                {0x0007, "RELAY_LEVEL_ERROR"},
                {0x0008, "HEX_SWITCH_ERROR"},
                {0x0009, "FAN_SPEED_ERROR"},
                {0x000a, "FAN_DRIVER_ERROR"},
                {0x000b, "Reset Baustein"},
                {0x000c, "ND"},
                {0x000d, "ROM_ERROR"},
                {0x000e, "SOURCE_MIN_TEMP"},
                {0x0010, "DEFROST_ERROR"},
                {0x0012, "ERR T-HEI IWS"},
                {0x0017, "ERR T-FRO IWS"},
                {0x001a, "LOW_PRESSURE"},
                {0x001b, "ERR ND-DRUCK"},
                {0x001c, "ERR HD-DRUCK"},
                {0x001d, "HD-SENSOR-MAX"},
                {0x001e, "HEISSGAS-MAX"},
                {0x001f, "ERR HD-SENSOR"},
                {0x0020, "FREEZE_PROTECTION"},
                {0x0021, "NO_POWER"}};

    betriebsartMap = {{0x0000, "EMERGENCY_MODE"},    {0x0100, "STANDBY_MODE"}, {0x0300, "DAY_MODE"},
                      {0x0400, "HOLIDAY_MODE"}, {0x0500, "DHW_MODE"},   {0x0B00, "AUTO_MODE"},
                      {0x0E00, "MANUAL_MODE"}};

    kuehlmodusMap = {{0x0000, "SURFACE_COOLING"}, {0x0001, "FAN_COOLING"}};

    passivkuehlungMap = {
        {0x0000, "OFF"}, {0x0001, "EXHAUST_FLUSH"}, {0x0002, "FRESH_AIR_INTAKE"}, {0x0003, "BYPASS_MODE"}, {0x0004, "SUMMER_CASSETTE"}};
}
