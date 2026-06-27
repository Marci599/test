#pragma once
#include <cstdint>

// Thin adapter for Super Paper Mario USA Rev 2 (R8PE01 Disc 1 Revision 2).
// These declarations mirror the symbols used by SeekyCt's spm-headers/spm-rel-loader
// workflow and isolate version-specific names from the menu implementation.
namespace spm_us2 {
struct Vec3 { float x, y, z; };

extern "C" {
    void OSReport(const char* fmt, ...);
    uint32_t WPAD_ButtonsDown(int channel);
    uint32_t WPAD_ButtonsHeld(int channel);
    void seqSetSeq(uint32_t seq, const char* map, const char* bero, uint32_t flags);
    void windowEntry(const char* text, int x, int y, int width, int height, uint32_t color);
}

constexpr uint32_t WPAD_BUTTON_LEFT  = 0x0001;
constexpr uint32_t WPAD_BUTTON_RIGHT = 0x0002;
constexpr uint32_t WPAD_BUTTON_DOWN  = 0x0004;
constexpr uint32_t WPAD_BUTTON_UP    = 0x0008;
constexpr uint32_t WPAD_BUTTON_PLUS  = 0x1000;
constexpr uint32_t WPAD_BUTTON_2     = 0x0100;
constexpr uint32_t WPAD_BUTTON_1     = 0x0200;
constexpr uint32_t WPAD_BUTTON_B     = 0x0400;
constexpr uint32_t SEQ_MAP_CHANGE    = 0x00000002;

inline void changeMap(const char* map, const char* entrance = "") {
    OSReport("[QuickMapMenu] loading map=%s entrance=%s\n", map, entrance);
    seqSetSeq(SEQ_MAP_CHANGE, map, entrance, 0);
}
}
