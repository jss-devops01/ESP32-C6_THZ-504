#if !defined(PROPERTY_H)
#define PROPERTY_H

#include <cstdint>
#include <sstream>
#include <string>
#include <unordered_map>
#include "type.h"

namespace oe32trta {
namespace detail {
struct Property {
    std::string_view name;
    std::uint16_t id{0U};
    Type type{Type::et_default};

    constexpr Property(const std::string_view _name, const std::uint16_t _id, const Type _type)
        : name(_name), id(_id), type(_type) {}
    constexpr Property(const std::string_view _name, const std::uint16_t _id) : name(_name), id(_id) {}

    constexpr operator std::uint16_t() const { return id; }

    Property& operator=(const Property& p) {
        name = p.name;
        id = p.id;
        type = p.type;
        return *this;
    }

   protected:
    Property getProperty(const std::uint16_t id);
};

class Mapper {
   public:
    Mapper() = default;
    inline Mapper(const Property& other) { map.insert({other.id, other}); }

    Property getProperty(const std::uint16_t id);

   private:
    static inline std::unordered_map<std::uint16_t, Property> map;
};

}  // namespace detail
}  // namespace oe32trta

#define PROPERTY(NAME, VALUE, ...)                                                    \
    static constexpr oe32trta::detail::Property k##NAME{#NAME, VALUE, ##__VA_ARGS__}; \
    static constexpr bool unique##VALUE{true};                                        \
    static inline oe32trta::detail::Mapper k##NAME##_MAPPING {                        \
        k##NAME                                                                       \
    }

struct Property : public oe32trta::detail::Property {
    constexpr Property(const Property& p) : oe32trta::detail::Property{p.name, p.id, p.type} {}
    constexpr Property(const oe32trta::detail::Property& p) : oe32trta::detail::Property{p.name, p.id, p.type} {}
    Property(const std::uint16_t _id) : oe32trta::detail::Property{getProperty(_id)} {}

    PROPERTY(INDEX_NOT_FOUND, 0x0000);
    PROPERTY(ERROR_MESSAGE, 0x0001);
    PROPERTY(STORAGE_TEMP_SETPOINT, 0x0003, Type::et_dec_val);
    PROPERTY(FLOW_TEMP_SETPOINT, 0x0004, Type::et_dec_val);
    PROPERTY(OUTSIDE_TEMP, 0x000c, Type::et_dec_val);
    PROPERTY(STORAGE_TEMP_ACTUAL, 0x000e, Type::et_dec_val);
    PROPERTY(ADJUSTED_ROOM_TEMP_SETPOINT, 0x0012, Type::et_dec_val);
    PROPERTY(SOLAR_COLLECTOR_TEMP, 0x001a, Type::et_dec_val);
    PROPERTY(SLOPE_HC1, 0x010e, Type::et_cent_val);
    PROPERTY(DAY_OF_WEEK, 0x0121, Type::et_little_endian);
    PROPERTY(DAY_OF_MONTH, 0x0122, Type::et_little_endian);
    PROPERTY(MONTH, 0x0123, Type::et_little_endian);
    PROPERTY(YEAR, 0x0124, Type::et_little_endian);
    PROPERTY(HOUR, 0x0125, Type::et_little_endian);
    PROPERTY(MINUTE, 0x0126, Type::et_little_endian);
    PROPERTY(CONDENSER_INLET_TEMP, 0x059c, Type::et_little_endian);
    PROPERTY(OIL_PAN_TEMP, 0x0693, Type::et_little_endian);
    PROPERTY(HOT_GAS_TEMP, 0x0265, Type::et_little_endian);
    PROPERTY(FLOW_SHARE_HC1, 0x059d);
    PROPERTY(BASE_POINT_HC1, 0x059e, Type::et_dec_val);
    PROPERTY(ELECTRIC_ENERGY_DHW_DAY_WH, 0x091a);
    PROPERTY(ELECTRIC_ENERGY_DHW_DAY_KWH, 0x091b, Type::et_double_val);
    PROPERTY(ELECTRIC_ENERGY_DHW_TOTAL_KWH, 0x091c);
    PROPERTY(ELECTRIC_ENERGY_DHW_TOTAL_MWH, 0x091d, Type::et_double_val);
    PROPERTY(ELECTRIC_ENERGY_HEATING_DAY_WH, 0x091e);
    PROPERTY(ELECTRIC_ENERGY_HEATING_DAY_KWH, 0x091f, Type::et_double_val);
    PROPERTY(ELECTRIC_ENERGY_HEATING_TOTAL_KWH, 0x0920);
    PROPERTY(ELECTRIC_ENERGY_HEATING_TOTAL_MWH, 0x0921, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_DHW_DAY_WH, 0x092a);
    PROPERTY(HEAT_OUTPUT_DHW_DAY_KWH, 0x092b, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_DHW_TOTAL_KWH, 0x092c);
    PROPERTY(HEAT_OUTPUT_DHW_TOTAL_MWH, 0x092d, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_HEATING_DAY_WH, 0x092e);
    PROPERTY(HEAT_OUTPUT_HEATING_DAY_KWH, 0x092f, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_HEATING_TOTAL_KWH, 0x0930);
    PROPERTY(HEAT_OUTPUT_HEATING_TOTAL_MWH, 0x0931, Type::et_double_val);

#if defined(THZ_504) 
    PROPERTY(ROOM_TEMP_ACTUAL, 0x0011, Type::et_dec_val);
    PROPERTY(EVAPORATOR_TEMP, 0x0014, Type::et_dec_val);
    PROPERTY(RETURN_TEMP_ACTUAL, 0x0016, Type::et_dec_val);
    PROPERTY(ROOM_HUMIDITY, 0x0075, Type::et_dec_val);
    PROPERTY(ROOM_INFLUENCE, 0x010f, Type::et_little_endian);
    PROPERTY(PROGRAM_SWITCH, 0x0112, Type::et_betriebsart);
    PROPERTY(ROOM_TEMP_SETPOINT_DAY, 0x0005, Type::et_dec_val);
    PROPERTY(ROOM_TEMP_SETPOINT_NIGHT, 0x0008, Type::et_dec_val);
    PROPERTY(COLLECTOR_TEMP_ACTUAL, 0x000d, Type::et_dec_val);
    PROPERTY(FLOW_TEMP_ACTUAL, 0x000f, Type::et_dec_val);
    PROPERTY(STORAGE_TEMP_SETPOINT_DAY, 0x0013, Type::et_dec_val);
    PROPERTY(SETPOINT_MAX_HC1, 0x0028, Type::et_dec_val);
    PROPERTY(SUMMER_MODE_TEMP, 0x0116, Type::et_dec_val);
    PROPERTY(SETPOINT_MIN_HC1, 0x012b, Type::et_dec_val);
    PROPERTY(HYSTERESIS_DHW, 0x0140, Type::et_dec_val);
    PROPERTY(OPERATING_STATUS, 0x0176);
    PROPERTY(Z_SOMETHING_01, 0x0190, Type::et_dec_val);
    PROPERTY(VOLUME_FLOW, 0x01da, Type::et_dec_val);
    PROPERTY(DEWPOINT_HC1, 0x0264, Type::et_dec_val);
    PROPERTY(COOLING_MODE, 0x0287, Type::et_bool);
    PROPERTY(PUMP_SPEED_HEATING, 0x02cb, Type::et_dec_val);
    PROPERTY(FILTER_RUNTIME_DAYS, 0x0341);
    PROPERTY(HEAT_RECOVERY_DAY_WH, 0x03ae);
    PROPERTY(HEAT_RECOVERY_DAY_KWH, 0x03af);
    PROPERTY(HEAT_RECOVERY_TOTAL_KWH, 0x03b0);
    PROPERTY(HEAT_RECOVERY_TOTAL_MWH, 0x03b1);
    PROPERTY(COOLING_ROOM_SETPOINT_DAY, 0x0569, Type::et_dec_val);
    PROPERTY(COOLING_ROOM_SETPOINT_ABSENT, 0x056a, Type::et_dec_val);
    PROPERTY(COOLING_ROOM_SETPOINT_NIGHT, 0x056b, Type::et_dec_val);
    PROPERTY(VENT_LEVEL_DAY, 0x056c);
    PROPERTY(VENT_LEVEL_NIGHT, 0x056d);
    PROPERTY(VENT_LEVEL_STANDBY, 0x056f);
    PROPERTY(VENT_LEVEL_PARTY, 0x0570);
    PROPERTY(PASSIVE_COOLING, 0x0575);
    PROPERTY(VENT_UNPLANNED_DURATION_LEVEL1, 0x0572);
    PROPERTY(VENT_UNPLANNED_DURATION_LEVEL2, 0x0573);
    PROPERTY(VENT_UNPLANNED_DURATION_LEVEL3, 0x0574);
    PROPERTY(VENT_SUPPLY_LEVEL1, 0x0576);
    PROPERTY(VENT_SUPPLY_LEVEL2, 0x0577);
    PROPERTY(VENT_SUPPLY_LEVEL3, 0x0578);
    PROPERTY(VENT_EXHAUST_LEVEL1, 0x0579);
    PROPERTY(VENT_EXHAUST_LEVEL2, 0x057a);
    PROPERTY(VENT_EXHAUST_LEVEL3, 0x057b);
    PROPERTY(BACKUP_HEATER_LEVEL_DHW, 0x058a);
    PROPERTY(DHW_ECO, 0x058d, Type::et_bool);
    PROPERTY(SUPPLY_AIR_SETPOINT, 0x0596);
    PROPERTY(SUPPLY_AIR_ACTUAL, 0x0597);
    PROPERTY(EXHAUST_AIR_SETPOINT, 0x0598);
    PROPERTY(EXHAUST_AIR_ACTUAL, 0x0599);
    PROPERTY(OUTDOOR_AIR_SETPOINT, 0x059a);
    PROPERTY(OUTDOOR_AIR_ACTUAL, 0x059b);
    PROPERTY(SUMMER_MODE_HYSTERESIS, 0x05a2, Type::et_dec_val);
    PROPERTY(PUMP_CYCLES_MIN_OUTSIDE_TEMP, 0x05bb);
    PROPERTY(STORAGE_TEMP_SETPOINT_NIGHT, 0x05bf, Type::et_dec_val);
    PROPERTY(VENT_LEVEL_MANUAL, 0x0612);
    PROPERTY(COOLING_SYSTEM_TYPE, 0x0613);
    PROPERTY(HEATING_CIRCUIT_PRESSURE, 0x064a, Type::et_dec_val);
    PROPERTY(DESIGN_POWER_COOLING, 0x0692);
    PROPERTY(HEATING_POWER_RELATIVE, 0x069a, Type::et_double_val);
    PROPERTY(COMPRESSOR_SPEED, 0x069e);
    PROPERTY(MOTOR_CURRENT, 0x069f);
    PROPERTY(MOTOR_POWER, 0x06a0, Type::et_cent_val);
    PROPERTY(MOTOR_VOLTAGE, 0x06a1);
    PROPERTY(EXHAUST_AIR_TEMP, 0x0694, Type::et_dec_val);
    PROPERTY(LOW_PRESSURE_DISPLAY, 0x07a7, Type::et_dec_val);
    PROPERTY(HEAT_OUTPUT_2WE_DHW_DAY_WH, 0x0922);
    PROPERTY(HEAT_OUTPUT_2WE_DHW_DAY_KWH, 0x0923, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_2WE_DHW_TOTAL_KWH, 0x0924);
    PROPERTY(HEAT_OUTPUT_2WE_DHW_TOTAL_MWH, 0x0925, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_2WE_HEATING_DAY_WH, 0x0926);
    PROPERTY(HEAT_OUTPUT_2WE_HEATING_DAY_KWH, 0x0927, Type::et_double_val);
    PROPERTY(HEAT_OUTPUT_2WE_HEATING_TOTAL_KWH, 0x0928);
    PROPERTY(HEAT_OUTPUT_2WE_HEATING_TOTAL_MWH, 0x0929, Type::et_double_val);
    PROPERTY(HEATING_COOLING_POWER, 0xc0ee, Type::et_cent_val);
    PROPERTY(EXHAUST_AIR_HUMIDITY, 0xc0ef);
    PROPERTY(DESIGN_POWER_HEATING, 0xc0f1);
    PROPERTY(COMPRESSOR_STARTS, 0xc0f4);
    PROPERTY(COMPRESSOR_STARTS_KILO, 0xc0f5);
    PROPERTY(EXHAUST_AIR_DEWPOINT, 0xc0f6, Type::et_dec_val);
    PROPERTY(FILTER_RUNTIME, 0xc111);
    PROPERTY(DIFFERENTIAL_PRESSURE, 0xc11e);
    PROPERTY(OPERATING_STATUS_2, 0xc356);
    PROPERTY(BACKUP_HEATER_TIME_LOCK, 0x0588);
    PROPERTY(UNKNOWN_019A, 0x019a, Type::et_dec_val);
    PROPERTY(FROST_PROTECTION_TEMP_HC2, 0x013d, Type::et_dec_val);

    // ======================================================================
    // Identified properties — cross-referenced against goelster Elster table
    // (https://github.com/andig/goelster/blob/master/readings.go)
    // Remaining UNKNOWN_xxxx entries still need identification.
    // Run analyze-unknown-properties.ps1 after a menu-browsing session to discover more.
    // ======================================================================

    // --- Refrigerant circuit (0x07xx block, near LOW_PRESSURE_DISPLAY=0x07a7) ---
    PROPERTY(HIGH_PRESSURE_DISPLAY,   0x07a6, Type::et_dec_val);  // ANZEIGE_HOCHDRUCK — src=Kessel seen=2 raw=1643 (scale/unit TBD)
    PROPERTY(COMPRESSOR_OUTPUT,       0x07a8, Type::et_dec_val);  // Compressor — src=Kessel seen=26 raw=19 → 1.9 (speed/stage unit TBD)
    PROPERTY(EXV_OPENING_DEGREE,      0x07ca);                    // EXV_OEFFNUNGSGRAD — Electronic expansion valve position; src=Kessel seen=4 raw=0
    PROPERTY(HP_OPERATING_MODE,       0x07f2);                    // BETRIEBSART_WP — Heat pump operating mode; src=Kessel seen=4 raw=0
    PROPERTY(SUPERHEAT_SETPOINT,      0x07f3, Type::et_dec_val);  // SOLLWERT_UEBERHITZUNG — Superheat setpoint; src=Kessel seen=4 raw=80 → 8.0 K
    PROPERTY(SUPERHEAT_EVAPORATOR,    0x07f4, Type::et_dec_val);  // ISTWERT_UEBERHITZUNG_VERDAMPFER — Evaporator superheat actual; src=Kessel seen=4 raw=321..324 → 32.1..32.4 K
    PROPERTY(SUPERHEAT_RECUPERATOR,   0x07f5, Type::et_dec_val);  // ISTWERT_UEBERHITZUNG_REKUPERATOR_KUEHLEN — Recuperator superheat (cooling); src=Kessel seen=4 raw=382..383 → 38.2..38.3 K
    PROPERTY(EXV_FEEDFORWARD,         0x07f6, Type::et_dec_val);  // VORSTEUER_OEFFNUNGSGRAD — EXV feedforward opening degree; src=Kessel seen=4 raw=168 → 16.8 %
    PROPERTY(EXV_P_TERM,              0x07f7, Type::et_dec_val);  // P_ANTEIL_EXV — EXV P-controller term; src=Kessel seen=4 raw=984..988 → 98.4..98.8
    PROPERTY(EXV_I_TERM,              0x07f8, Type::et_cent_val); // I_ANTEIL_EXV — EXV I-controller term; src=Kessel seen=4 raw=1245 → 12.45
    PROPERTY(EXV_D_TERM,              0x07f9, Type::et_dec_val);  // D_ANTEIL_EXV — EXV D-controller term; src=Kessel seen=4 raw=1000 → 100.0
    PROPERTY(EXV_OSCILLATION,         0x07fa, Type::et_bool);     // PENDELN_RELATIV — Relative oscillation flag; src=Kessel seen=4 raw=0
    PROPERTY(CONTROL_DYNAMICS_FACTOR, 0x07fb, Type::et_dec_val);  // FAKTOR_REGELDYNAMIK — Control dynamics factor; src=Kessel seen=4 raw=200 → 20.0
    PROPERTY(UNKNOWN_081C,            0x081c, Type::et_bool);     // src=Kessel seen=4 raw=0

    // --- Error log readback (0x0b9x — fields of a single error log entry broadcast) ---
    PROPERTY(ERROR_LOG_INDEX,  0x0b9a); // FEHLERSPEICHER_FELDINDEX — which entry is being broadcast; src=Manager seen=44 raw=0..9
    PROPERTY(ERROR_LOG_CODE,   0x0b9b); // FEHLERSPEICHER_FEHLERNUMMER — error code number; src=Kessel seen=18 raw=0..15
    PROPERTY(ERROR_LOG_MINUTE, 0x0b9f); // FEHLERSPEICHER_MINUTE — error timestamp minute; src=Kessel seen=20 raw=0..59
    PROPERTY(ERROR_LOG_HOUR,   0x0ba0); // FEHLERSPEICHER_STUNDE — error timestamp hour; src=Kessel seen=23 raw=0..23
    PROPERTY(ERROR_LOG_DAY,    0x0ba1); // FEHLERSPEICHER_TAG — error timestamp day; src=Kessel seen=19 raw=0
    PROPERTY(ERROR_LOG_MONTH,  0x0ba2); // FEHLERSPEICHER_MONAT — error timestamp month; src=Kessel seen=20 raw=0
    PROPERTY(ERROR_LOG_YEAR,   0x0ba3); // FEHLERSPEICHER_JAHR — error timestamp year (2-digit); src=Kessel seen=23 raw=0..26 (2026=26)

    // --- Active flags and status bits ---
    PROPERTY(UNKNOWN_0060, 0x0060, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0067, 0x0067, Type::et_dec_val);       // src=Kessel seen=4 raw=2
    PROPERTY(UNKNOWN_011A, 0x011a, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_01D3, 0x01d3, Type::et_bool);          // src=Kessel seen=6 raw=0
    PROPERTY(CLEAR_ERROR_LOG, 0x027a, Type::et_bool);       // GESPEICHERTE_FEHLER_LOESCHEN — write command: clears error log; src=Kessel seen=4 raw=0..1
    PROPERTY(UNKNOWN_02CE, 0x02ce, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_02F5, 0x02f5, Type::et_bool);          // src=Kessel seen=2 raw=1
    PROPERTY(UNKNOWN_03C1, 0x03c1, Type::et_bool);          // src=Kessel seen=2 raw=1
    PROPERTY(UNKNOWN_05A5, 0x05a5, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_05B8, 0x05b8, Type::et_bool);          // src=Kessel seen=2 raw=1
    PROPERTY(UNKNOWN_05B9, 0x05b9, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_05BC, 0x05bc, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_05C7, 0x05c7, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_05D1, 0x05d1, Type::et_bool);          // src=Kessel seen=4 raw=0
    PROPERTY(UNKNOWN_065A, 0x065a, Type::et_bool);          // src=Kessel seen=4 raw=0
    PROPERTY(UNKNOWN_0695, 0x0695, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_06A3, 0x06a3, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0944, 0x0944, Type::et_bool);          // src=Kessel seen=2 raw=1
    PROPERTY(UNKNOWN_C0D8, 0xc0d8, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_C0DE, 0xc0de, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_C113, 0xc113, Type::et_bool);          // src=Kessel seen=2 raw=0

    // --- Heating circuit / pump sensors (0x064x block, near HEATING_CIRCUIT_PRESSURE=0x064a) ---
    PROPERTY(UNKNOWN_0640, 0x0640);                         // src=Kessel seen=2 raw=993
    PROPERTY(UNKNOWN_0641, 0x0641);                         // src=Kessel seen=2 raw=2
    PROPERTY(UNKNOWN_0642, 0x0642);                         // src=Kessel seen=2 raw=795
    PROPERTY(UNKNOWN_0643, 0x0643, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0644, 0x0644);                         // src=Kessel seen=2 raw=944
    PROPERTY(UNKNOWN_0645, 0x0645, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0646, 0x0646);                         // src=Kessel seen=2 raw=570
    PROPERTY(UNKNOWN_0647, 0x0647);                         // src=Kessel seen=2 raw=6
    PROPERTY(UNKNOWN_0648, 0x0648, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0649, 0x0649, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_064C, 0x064c, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_064D, 0x064d);                         // src=Kessel seen=2 raw=9809
    PROPERTY(UNKNOWN_0652, 0x0652, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0653, 0x0653, Type::et_bool);          // src=Kessel seen=2 raw=0
    PROPERTY(UNKNOWN_0654, 0x0654, Type::et_bool);          // src=Kessel seen=2 raw=1
    PROPERTY(UNKNOWN_06A2, 0x06a2);                         // src=Kessel seen=2 raw=250

    // --- Config-range values (0x011x, 0x01bx, 0x02x, 0x03x) ---
    PROPERTY(UNKNOWN_011B, 0x011b, Type::et_cent_val);      // src=Kessel seen=4 raw=6912 → 69.12
    PROPERTY(UNKNOWN_011C, 0x011c, Type::et_dec_val);       // src=Kessel seen=4 raw=768 → 76.8
    PROPERTY(UNKNOWN_011D, 0x011d, Type::et_cent_val);      // src=Kessel seen=4 raw=6656 → 66.56
    PROPERTY(UNKNOWN_011E, 0x011e);                         // src=Manager seen=2 raw=1280
    PROPERTY(UNKNOWN_011F, 0x011f, Type::et_cent_val);      // src=Kessel seen=4 raw=1024 → 10.24
    PROPERTY(UNKNOWN_0120, 0x0120);                         // src=Manager seen=2 raw=6656
    PROPERTY(UNKNOWN_01B8, 0x01b8);                         // src=Kessel seen=2 raw=80
    PROPERTY(UNKNOWN_01BB, 0x01bb);                         // src=Kessel seen=2 raw=250
    PROPERTY(UNKNOWN_01BC, 0x01bc);                         // src=Kessel seen=2 raw=3
    PROPERTY(UNKNOWN_01BD, 0x01bd);                         // src=Kessel seen=2 raw=400
    PROPERTY(UNKNOWN_02CC, 0x02cc);                         // src=Kessel seen=2 raw=800
    PROPERTY(UNKNOWN_02F6, 0x02f6);                         // src=Kessel seen=2 raw=800
    PROPERTY(UNKNOWN_03AB, 0x03ab);                         // src=Kessel seen=2 raw=10
    PROPERTY(UNKNOWN_03B8, 0x03b8, Type::et_cent_val);      // src=Kessel seen=4 raw=1800 → 18.00
    PROPERTY(UNKNOWN_03BB, 0x03bb);                         // src=Kessel seen=2 raw=1250

    // --- Ventilation config range (0x05xx, near VENT_LEVEL_xxx) ---
    PROPERTY(UNKNOWN_058F, 0x058f);                         // src=Kessel seen=2 raw=12
    PROPERTY(UNKNOWN_05A4, 0x05a4);                         // src=Kessel seen=2 raw=13370
    PROPERTY(UNKNOWN_05A7, 0x05a7);                         // src=Kessel seen=2 raw=130
    PROPERTY(UNKNOWN_05B2, 0x05b2);                         // src=Kessel seen=2 raw=300
    PROPERTY(UNKNOWN_05B5, 0x05b5);                         // src=Kessel seen=2 raw=20
    PROPERTY(UNKNOWN_05B6, 0x05b6);                         // src=Kessel seen=2 raw=60
    PROPERTY(UNKNOWN_05B7, 0x05b7);                         // src=Kessel seen=2 raw=50
    PROPERTY(UNKNOWN_05BA, 0x05ba);                         // src=Kessel seen=2 raw=200
    PROPERTY(UNKNOWN_05BE, 0x05be);                         // src=Kessel seen=2 raw=750
    PROPERTY(UNKNOWN_05D3, 0x05d3, Type::et_dec_val);       // src=Kessel seen=4 raw=76 → 7.6

    // --- High-range / HK1 values ---
    PROPERTY(UNKNOWN_1410, 0x1410, Type::et_cent_val);      // src=HK1 seen=4 raw=6234 → 62.34
    PROPERTY(UNKNOWN_1411, 0x1411);                         // src=HK1 seen=4 raw=32896 (0x8080, may be invalid marker)
    PROPERTY(UNKNOWN_1412, 0x1412);                         // src=HK1 seen=2 raw=32896
    PROPERTY(UNKNOWN_1710, 0x1710);                         // src=Kessel seen=2 raw=14930
    PROPERTY(UNKNOWN_1711, 0x1711);                         // src=Kessel seen=2 raw=32896
    PROPERTY(UNKNOWN_1712, 0x1712);                         // src=Kessel seen=2 raw=32896
    PROPERTY(UNKNOWN_1D10, 0x1d10);                         // src=Kessel seen=2 raw=6182
    PROPERTY(UNKNOWN_1D11, 0x1d11);                         // src=Kessel seen=2 raw=11831
    PROPERTY(UNKNOWN_1D12, 0x1d12);                         // src=Kessel seen=2 raw=19030

    // --- 0xC0xx extended range ---
    PROPERTY(UNKNOWN_C0AD, 0xc0ad);                         // src=Kessel seen=2 raw=20
    PROPERTY(UNKNOWN_C0E2, 0xc0e2);                         // src=Kessel seen=2 raw=2
    PROPERTY(UNKNOWN_C0E3, 0xc0e3);                         // src=Kessel seen=2 raw=0..100 (percentage?)
#endif



};

#endif
