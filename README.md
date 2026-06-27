# SPM Quick Map Menu (R8PE01 Rev 2)

A Super Paper Mario REL mod project for the USA Disc 1 Revision 2 build (`R8PE01`, `SPM_US2`). It adds an in-game stage/map loader menu intended for practice, debugging, and level-editing workflows.

## What you get

- A C++ REL mod entry point targeting `SPM_US2`.
- A quick menu opened with `D-Pad Down + 1`.
- Chapter/stage presets backed by editable internal map IDs in `src/map_menu.cpp`.
- A Riivolution layout that loads `/mod/mod.rel` using SeekyCt's SPM REL Loader convention.
- A reproducible build wrapper that vendors `spm-rel-loader` and `spm-headers` when network access is available.

## Controls

| Input | Action |
| --- | --- |
| `D-Pad Down + 1` | Open/close menu |
| `D-Pad Up/Down` | Move selection |
| `D-Pad Left/Right` | Change category or manual digit |
| `2` | Warp to selected map |
| `B` | Close menu |

## Building

Install `devkitPPC`, `ninja`, Python 3, and the SPM REL Loader dependencies. Then run:

```bash
./tools/build_us2.sh
```

The script vendors the upstream loader/header projects into `extern/`, configures the target as `us2`, and copies the finished REL to:

```text
dist/riivolution/spm-quick-map-menu/files/mod/mod.rel
```

## Installing with Riivolution

1. Copy `dist/riivolution/spm-quick-map-menu/` to the root of your SD card.
2. Copy `riivolution/spm_quick_map_menu.xml` into `SD:/riivolution/`.
3. Enable the XML in Riivolution and boot your USA Rev 2 disc.

## Notes for modders

This project intentionally keeps all game-version-specific calls in `src/spm_us2_symbols.hpp`. If your local header set exposes newer names, update only that adapter. The menu data is in `src/map_menu.cpp`; add or rename entries there without touching the loader glue.

