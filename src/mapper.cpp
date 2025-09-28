#include "mapper.h"
#include "simple_variant.h"

std::optional<std::string> Mapper::getPassivkuehlung(const SimpleVariant& value) const {
    auto val = static_cast<std::uint16_t>(value);
    switch (val) {
        case 0: return "Aus";
        case 1: return "Ablüften";
        case 2: return "Zulüften";
        case 3: return "Bypass";
        case 4: return "Sommerkassette";
        default: return "Unbekannt";
    }
}

std::optional<std::uint16_t> Mapper::getPassivkuehlungId(const std::string& value) const {
    if (value == "Aus") return 0;
    if (value == "Ablüften") return 1;
    if (value == "Zulüften") return 2;
    if (value == "Bypass") return 3;
    if (value == "Sommerkassette") return 4;
    return std::nullopt;
}

std::optional<std::string> Mapper::getBetriebsart(const SimpleVariant& value) const {
    auto val = static_cast<std::uint16_t>(value);
    switch (val) {
        case 0: return "Notbetrieb";
        case 1: return "Bereitschaft";
        case 2: return "Automatik";
        case 3: return "Tagbetrieb";
        case 4: return "Absenkbetrieb";
        case 5: return "Warmwasser";
        case 6: return "Handbetrieb";
        default: return "Unbekannt";
    }
}

std::optional<std::uint16_t> Mapper::getBetriebsartId(const std::string& value) const {
    if (value == "Notbetrieb") return 0;
    if (value == "Bereitschaft") return 1;
    if (value == "Automatik") return 2;
    if (value == "Tagbetrieb") return 3;
    if (value == "Absenkbetrieb") return 4;
    if (value == "Warmwasser") return 5;
    if (value == "Handbetrieb") return 6;
    return std::nullopt;
}