#pragma once

#include <cstdint>
#include <string_view>
#include "type.h"

struct Property {
    std::string_view name;
    std::uint16_t id{0U};
    Type type{Type::et_default};

    constexpr Property(const std::string_view _name, const std::uint16_t _id, const Type _type = Type::et_default)
        : name(_name), id(_id), type(_type) {}

    constexpr operator std::uint16_t() const { return id; }

    // THZ-504 specific properties
    static constexpr Property kRAUMISTTEMP{"RAUMISTTEMP", 0x0011, Type::et_dec_val};
    static constexpr Property kRAUMSOLLTEMP_TAG{"RAUMSOLLTEMP_TAG", 0x0005, Type::et_dec_val};
    static constexpr Property kRAUMSOLLTEMP_NACHT{"RAUMSOLLTEMP_NACHT", 0x0008, Type::et_dec_val};
    static constexpr Property kSPEICHERISTTEMP{"SPEICHERISTTEMP", 0x000e, Type::et_dec_val};
    static constexpr Property kSPEICHERSOLLTEMP_TAG{"SPEICHERSOLLTEMP_TAG", 0x0013, Type::et_dec_val};
    static constexpr Property kSPEICHERSOLLTEMP_NACHT{"SPEICHERSOLLTEMP_NACHT", 0x05bf, Type::et_dec_val};
    static constexpr Property kAUSSENTEMP{"AUSSENTEMP", 0x000c, Type::et_dec_val};
    static constexpr Property kVERDAMPFERTEMP{"VERDAMPFERTEMP", 0x0014, Type::et_dec_val};
    static constexpr Property kABLUFTTEMP{"ABLUFTTEMP", 0x0694, Type::et_dec_val};
    static constexpr Property kABLUFT_TAUPUNKT{"ABLUFT_TAUPUNKT", 0xc0f6, Type::et_dec_val};
    
    // Status properties
    static constexpr Property kBETRIEBS_STATUS{"BETRIEBS_STATUS", 0x0176};
    static constexpr Property kBETRIEBS_STATUS_2{"BETRIEBS_STATUS_2", 0xc356};
    static constexpr Property kPROGRAMMSCHALTER{"PROGRAMMSCHALTER", 0x0112, Type::et_betriebsart};
    static constexpr Property kPASSIVKUEHLUNG{"PASSIVKUEHLUNG", 0x0575};
    
    // Ventilation properties
    static constexpr Property kZULUFT_SOLL{"ZULUFT_SOLL", 0x0596};
    static constexpr Property kZULUFT_IST{"ZULUFT_IST", 0x0597};
    static constexpr Property kABLUFT_SOLL{"ABLUFT_SOLL", 0x0598};
    static constexpr Property kABLUFT_IST{"ABLUFT_IST", 0x0599};
    static constexpr Property kFORTLUFT_SOLL{"FORTLUFT_SOLL", 0x059a};
    static constexpr Property kFORTLUFT_IST{"FORTLUFT_IST", 0x059b};
    
    // Filter properties
    static constexpr Property kDIFFERENZDRUCK{"DIFFERENZDRUCK", 0xc11e};
    static constexpr Property kLAUFZEIT_FILTER_TAGE{"LAUFZEIT_FILTER_TAGE", 0x0341};
    static constexpr Property kLAUFZEIT_FILTER{"LAUFZEIT_FILTER", 0xc111};
    
    // Performance properties
    static constexpr Property kMOTORSTROM{"MOTORSTROM", 0x069f};
    static constexpr Property kMOTORSPANNUNG{"MOTORSPANNUNG", 0x06a1};
    static constexpr Property kMOTORLEISTUNG{"MOTORLEISTUNG", 0x06a0, Type::et_cent_val};
    static constexpr Property kVERDICHTERDREHZAHL{"VERDICHTERDREHZAHL", 0x069e};
    static constexpr Property kHEIZLEISTUNG_RELATIV{"HEIZLEISTUNG_RELATIV", 0x069a, Type::et_double_val};
    static constexpr Property kHEIZ_KUEHL_LEISTUNG{"HEIZ_KUEHL_LEISTUNG", 0xc0ee, Type::et_cent_val};
    
    // Cooling properties  
    static constexpr Property kKUEHL_RAUMSOLL_TAG{"KUEHL_RAUMSOLL_TAG", 0x0569, Type::et_dec_val};
    static constexpr Property kKUEHL_RAUMSOLL_NACHT{"KUEHL_RAUMSOLL_NACHT", 0x056b, Type::et_dec_val};
    static constexpr Property kKUEHLMODE{"KUEHLMODE", 0x0287, Type::et_bool};
    
    // Hot water properties
    static constexpr Property kNE_STUFE_WW{"NE_STUFE_WW", 0x058a};
    static constexpr Property kWARMWASSER_ECO{"WARMWASSER_ECO", 0x058d, Type::et_bool};
};