#pragma once

#include <cstdint>
#include <vector>
#include <functional>
#include <chrono>
#include <optional>
#include "property.h"
#include "simple_variant.h"

// CAN member definitions
enum CanMember : std::uint16_t {
    Kessel = 0x180,     // Heat pump controller
    HK1 = 0x301,        // Heating circuit 1  
    HK2 = 0x302,        // Heating circuit 2
    Manager = 0x6a1,    // Manager
    ESPClient = 0x6a2   // ESP client
};

// Structure for conditional requests
struct ConditionalRequest {
    std::pair<CanMember, Property> _request;
    std::function<bool()> _condition;
    
    ConditionalRequest(std::pair<CanMember, Property> request, std::function<bool()> condition)
        : _request(request), _condition(condition) {}
};

// Global variables for request handling
extern std::vector<ConditionalRequest> conditionalRequests;

// Function declarations
std::pair<Property, SimpleVariant> processCanMessage(const std::vector<std::uint8_t>& data);
void requestData(CanMember member, const Property& property);
void sendData(CanMember member, const Property& property, std::uint16_t value);
void queueRequest(CanMember member, const Property& property);
void scheduleRequest(CanMember member, const Property& property, std::chrono::seconds delay);
void syncTime();

// Helper functions
std::optional<CanMember> getCanMemberByCanId(std::uint32_t can_id);
std::optional<CanMember> getCanMemberByName(const std::string& name);