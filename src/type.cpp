#include "type.h"
#include <string>

float convertValue(std::uint16_t raw_value, Type type) {
    switch (type) {
        case Type::et_dec_val:
            return static_cast<float>(raw_value) / 10.0f;
        case Type::et_cent_val:
            return static_cast<float>(raw_value) / 100.0f;
        case Type::et_double_val:
            return static_cast<float>(raw_value) / 1000.0f;
        case Type::et_little_endian:
            return static_cast<float>((raw_value << 8) | (raw_value >> 8));
        case Type::et_bool:
        case Type::et_little_bool:
            return raw_value != 0 ? 1.0f : 0.0f;
        case Type::et_byte:
            return static_cast<float>(raw_value & 0xFF);
        default:
            return static_cast<float>(raw_value);
    }
}

std::string convertBetriebsart(std::uint16_t raw_value) {
    switch (raw_value) {
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