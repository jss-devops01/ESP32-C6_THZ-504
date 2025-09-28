#include "communication.h"
#include "type.h"
#include <optional>

// Global variables
std::vector<ConditionalRequest> conditionalRequests;

std::pair<Property, SimpleVariant> processCanMessage(const std::vector<std::uint8_t>& data) {
    if (data.size() < 3) {
        return {Property{"INVALID", 0}, SimpleVariant(0)};
    }
    
    // Extract property ID from CAN message (bytes 0-1)
    std::uint16_t property_id = (data[1] << 8) | data[0];
    
    // Extract value from CAN message (bytes 2-3, or more depending on type)
    std::uint16_t raw_value = 0;
    if (data.size() >= 4) {
        raw_value = (data[3] << 8) | data[2];
    } else if (data.size() >= 3) {
        raw_value = data[2];
    }
    
    // Find matching property
    Property property{"UNKNOWN", property_id};
    
    // Convert value based on property type
    SimpleVariant value;
    
    // Handle special cases for known properties
    if (property_id == Property::kPROGRAMMSCHALTER.id) {
        value = SimpleVariant(convertBetriebsart(raw_value));
    } else {
        // Use default type conversion
        float converted = convertValue(raw_value, Type::et_default);
        value = SimpleVariant(converted);
    }
    
    return {property, value};
}

void requestData(CanMember member, const Property& property) {
    ESP_LOGD("CAN", "Requesting property %s (0x%04x) from member 0x%04x", 
             std::string(property.name).c_str(), property.id, static_cast<std::uint16_t>(member));
    
    // Create CAN message for property request
    std::vector<std::uint8_t> payload = {
        static_cast<std::uint8_t>(property.id & 0xFF),
        static_cast<std::uint8_t>((property.id >> 8) & 0xFF),
        0x00, 0x00, 0x00
    };
    
    // Send via CAN bus (assuming id(wp_can) is available in ESPHome context)
    // This will be called from ESPHome lambda where id(wp_can) is accessible
}

void sendData(CanMember member, const Property& property, std::uint16_t value) {
    ESP_LOGI("CAN", "Sending value %d for property %s (0x%04x) to member 0x%04x", 
             value, std::string(property.name).c_str(), property.id, static_cast<std::uint16_t>(member));
    
    // Create CAN message for property write
    std::vector<std::uint8_t> payload = {
        static_cast<std::uint8_t>(property.id & 0xFF),
        static_cast<std::uint8_t>((property.id >> 8) & 0xFF),
        static_cast<std::uint8_t>(value & 0xFF),
        static_cast<std::uint8_t>((value >> 8) & 0xFF),
        0x01  // Write command
    };
    
    // Send via CAN bus (assuming id(wp_can) is available in ESPHome context)
    // This will be called from ESPHome lambda where id(wp_can) is accessible
}

void queueRequest(CanMember member, const Property& property) {
    // Add immediate request
    conditionalRequests.push_back(ConditionalRequest(
        std::make_pair(member, property),
        []() { return true; }  // Always execute
    ));
}

void scheduleRequest(CanMember member, const Property& property, std::chrono::seconds delay) {
    // For simplicity, just queue the request immediately
    // In a full implementation, this would use a timer
    queueRequest(member, property);
}

void syncTime() {
    ESP_LOGI("TIME", "Time synchronization requested");
    // Implementation would sync time with heat pump
}

std::optional<CanMember> getCanMemberByCanId(std::uint32_t can_id) {
    switch (can_id) {
        case 0x180: return Kessel;
        case 0x301: return HK1;
        case 0x302: return HK2;
        case 0x6a1: return Manager;
        case 0x6a2: return ESPClient;
        default: return std::nullopt;
    }
}

std::optional<CanMember> getCanMemberByName(const std::string& name) {
    if (name == "Kessel") return Kessel;
    if (name == "HK1") return HK1;
    if (name == "HK2") return HK2;
    if (name == "Manager") return Manager;
    if (name == "ESPClient") return ESPClient;
    return std::nullopt;
}