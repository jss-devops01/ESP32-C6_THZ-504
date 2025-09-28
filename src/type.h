#pragma once

#include <cstdint>

enum class Type : std::uint8_t {
    et_default = 0,
    et_dec_val,      // decimal value (divide by 10)
    et_cent_val,     // centimal value (divide by 100)  
    et_double_val,   // double value (divide by 1000)
    et_little_endian,
    et_bool,
    et_little_bool,
    et_byte,
    et_betriebsart   // operation mode
};

// Function to convert raw CAN data based on type
float convertValue(std::uint16_t raw_value, Type type);
std::string convertBetriebsart(std::uint16_t raw_value);