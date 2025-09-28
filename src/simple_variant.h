#pragma once

#include <cstdint>
#include <string>
#include <variant>

class SimpleVariant {
public:
    using Variant = std::variant<bool, std::uint16_t, float, double, std::string>;

    SimpleVariant() = default;
    
    template<typename T>
    SimpleVariant(T&& value) : data_(std::forward<T>(value)) {}

    template<typename T>
    T get() const {
        return std::get<T>(data_);
    }

    template<typename T>
    bool holds() const {
        return std::holds_alternative<T>(data_);
    }

    operator bool() const {
        if (holds<bool>()) return get<bool>();
        if (holds<std::uint16_t>()) return get<std::uint16_t>() != 0;
        if (holds<float>()) return get<float>() != 0.0f;
        if (holds<double>()) return get<double>() != 0.0;
        if (holds<std::string>()) return !get<std::string>().empty();
        return false;
    }

    operator std::uint16_t() const {
        if (holds<std::uint16_t>()) return get<std::uint16_t>();
        if (holds<bool>()) return get<bool>() ? 1 : 0;
        if (holds<float>()) return static_cast<std::uint16_t>(get<float>());
        if (holds<double>()) return static_cast<std::uint16_t>(get<double>());
        return 0;
    }

    operator float() const {
        if (holds<float>()) return get<float>();
        if (holds<double>()) return static_cast<float>(get<double>());
        if (holds<std::uint16_t>()) return static_cast<float>(get<std::uint16_t>());
        if (holds<bool>()) return get<bool>() ? 1.0f : 0.0f;
        return 0.0f;
    }

private:
    Variant data_;
};