#pragma once

#include <string>
#include <optional>
#include <cstdint>

class Mapper {
public:
    static Mapper& instance() {
        static Mapper instance;
        return instance;
    }
    
    // Passive cooling mode mappings
    std::optional<std::string> getPassivkuehlung(const SimpleVariant& value) const;
    std::optional<std::uint16_t> getPassivkuehlungId(const std::string& value) const;
    
    // Operation mode mappings
    std::optional<std::string> getBetriebsart(const SimpleVariant& value) const;
    std::optional<std::uint16_t> getBetriebsartId(const std::string& value) const;
    
private:
    Mapper() = default;
    Mapper(const Mapper&) = delete;
    Mapper& operator=(const Mapper&) = delete;
};