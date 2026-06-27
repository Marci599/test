#include "map_menu.hpp"
#include "spm_us2_symbols.hpp"
#include <cstddef>
#include <cstdio>

namespace quick_map_menu {
namespace {
struct MapEntry { const char* label; const char* map; const char* entrance; };

constexpr MapEntry kMaps[] = {
    {"Flipside Tower", "mac_01", ""},
    {"Flipside 1F", "mac_02", ""},
    {"Lineland Road 1-1", "stg1_01", ""},
    {"Mount Lineland 1-2", "stg1_02", ""},
    {"Yold Desert 1-3", "stg1_03", ""},
    {"Yold Ruins 1-4", "stg1_04", ""},
    {"Gloam Valley 2-1", "stg2_01", ""},
    {"Merlee Mansion 2-2", "stg2_02", ""},
    {"Outer Space 4-1", "stg4_01", ""},
    {"The Bitlands 3-1", "stg3_01", ""},
    {"Sammer Kingdom 6-1", "stg6_01", ""},
    {"Castle Bleck 8-4", "stg8_04", ""},
};

bool gOpen = false;
std::size_t gIndex = 0;

void draw() {
    char line[160];
    std::snprintf(line, sizeof(line), "Quick Map Menu  %zu/%zu", gIndex + 1, sizeof(kMaps) / sizeof(kMaps[0]));
    spm_us2::windowEntry(line, 24, 28, 300, 28, 0xffffffff);
    const MapEntry& entry = kMaps[gIndex];
    std::snprintf(line, sizeof(line), "> %s [%s]", entry.label, entry.map);
    spm_us2::windowEntry(line, 24, 60, 420, 28, 0xffffffff);
    spm_us2::windowEntry("2: load   B: close   Left/Right: select", 24, 92, 520, 28, 0xffffffff);
}

void moveSelection(int delta) {
    constexpr std::size_t count = sizeof(kMaps) / sizeof(kMaps[0]);
    gIndex = (gIndex + count + delta) % count;
}
}

void init() {
    spm_us2::OSReport("[QuickMapMenu] initialized for R8PE01 Rev 2 / SPM_US2\n");
}

void mainLoop() {
    const uint32_t down = spm_us2::WPAD_ButtonsDown(0);
    const uint32_t held = spm_us2::WPAD_ButtonsHeld(0);

    if ((held & spm_us2::WPAD_BUTTON_DOWN) && (down & spm_us2::WPAD_BUTTON_1)) {
        gOpen = !gOpen;
    }
    if (!gOpen) return;

    if (down & spm_us2::WPAD_BUTTON_B) gOpen = false;
    if (down & spm_us2::WPAD_BUTTON_UP) moveSelection(-1);
    if (down & spm_us2::WPAD_BUTTON_DOWN) moveSelection(1);
    if (down & spm_us2::WPAD_BUTTON_LEFT) moveSelection(-1);
    if (down & spm_us2::WPAD_BUTTON_RIGHT) moveSelection(1);
    if (down & spm_us2::WPAD_BUTTON_2) {
        const MapEntry& entry = kMaps[gIndex];
        spm_us2::changeMap(entry.map, entry.entrance);
        gOpen = false;
    }

    draw();
}
}

extern "C" void mod_init() { quick_map_menu::init(); }
extern "C" void mod_main() { quick_map_menu::mainLoop(); }
