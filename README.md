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

Install `devkitPPC`, `ninja`, Python 3, and the SPM REL Loader dependencies. The build script accepts Python as `python3`, `python`, or Windows' Python Launcher `py -3`. On Linux, macOS, WSL, Git Bash, or MSYS2, run:

```bash
./tools/build_us2.sh
```

On Windows PowerShell, run the wrapper instead:

```powershell
.\tools\build_us2.ps1
```

The PowerShell wrapper looks for Git Bash first and then WSL. WSL 2 with Ubuntu is recommended because the devkitPPC toolchain and upstream REL loader dependencies are easiest to install there. It also converts Windows paths such as `C:\Users\...` to Git-Bash paths such as `/c/Users/...`, so run it from PowerShell rather than editing the `.sh` path manually. When PowerShell finds Windows `python.exe` or `py.exe`, it passes that executable into MSYS2/Git Bash so devkitPro's bash can use Python even if it is not on the MSYS2 `PATH`.


### Windows build notes

You do not double-click `build_us2.sh` on Windows. Use one of these options:

- **Recommended:** install WSL 2 + Ubuntu, install the toolchain there, then run `./tools/build_us2.sh` from the repo folder.
- **PowerShell helper:** run `.\tools\build_us2.ps1`; it will find Git Bash or WSL and call `build_us2.sh` for you.
- **Git Bash/MSYS2:** open the repo in that shell and run `./tools/build_us2.sh`.


If you see `Missing required command: python3` or a Python-related error on Windows, check the command name in the same terminal:

```powershell
py -3 --version
python --version
python3 --version
```

The build script now accepts all three forms, but Git Bash/PowerShell must be able to find one of them in `PATH`.

If PowerShell blocks the script, run this from the repo root for the current process only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\build_us2.ps1
```



If you see `Please set TTYDTOOLS in your environment`, update to the latest script. The build now vendors `PistonMiner/ttyd-tools` into `extern/ttyd-tools`, exports `TTYDTOOLS` automatically to the inner project folder `extern/ttyd-tools/ttyd-tools` when present, and ensures `$(TTYDTOOLS)/bin/elf2rel` exists before invoking the upstream Makefile. The `TTYDTOOLS` name is historical: the SPM REL loader is based on the TTYD REL tooling, and `elf2rel` is the generic ELF-to-REL converter used for this Super Paper Mario mod. If `elf2rel` must be compiled from source under devkitPro MSYS2, install the host dependencies with `pacman -S --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-boost`.

If you see `make: *** No rule to make target 'us2'. Stop.`, update to the latest script. That error means `make` was being run from the cloned repository root instead of the upstream REL framework directory `extern/spm-rel-loader/spm-rel-loader/rel`.

The script vendors the upstream loader/header/tool projects into `extern/`, including `spm-rel-loader`, `spm-headers`, and `ttyd-tools`. It exports `TTYDTOOLS` automatically to `extern/ttyd-tools/ttyd-tools` when that inner folder exists, builds or copies the required `elf2rel` tool into `$(TTYDTOOLS)/bin/elf2rel`, enters the upstream REL framework at `extern/spm-rel-loader/spm-rel-loader/rel`, builds the `us2` target, and copies the finished REL to:

```text
dist/riivolution/spm-quick-map-menu/files/mod/mod.rel
```

## Installing with Riivolution

1. Copy `dist/riivolution/spm-quick-map-menu/` to the root of your SD card.
2. Copy `riivolution/spm_quick_map_menu.xml` into `SD:/riivolution/`.
3. Enable the XML in Riivolution and boot your USA Rev 2 disc.


## Installing in Dolphin Emulator

After building, Dolphin can launch the same Riivolution layout directly:

1. Confirm your game dump is the USA Rev 2 disc. In Dolphin, the game ID should start with `R8PE01`; this XML is scoped to first-disc index `0`, USA region `E`, and revision/version `2`.
2. Put the generated files in Dolphin's Riivolution load folder:
   - Windows: `Documents\Dolphin Emulator\Load\Riivolution\`
   - Linux: `~/.local/share/dolphin-emu/Load/Riivolution/`
   - macOS: `~/Library/Application Support/Dolphin/Load/Riivolution/`
3. The final Dolphin folder should contain:

   ```text
   Load/Riivolution/riivolution/spm_quick_map_menu.xml
   Load/Riivolution/spm-quick-map-menu/files/mod/mod.rel
   ```

   If the `riivolution/` folder does not exist under `Load/Riivolution/`, create it and place the XML there. Keep the `spm-quick-map-menu/` folder next to it, not inside it.

If Dolphin says the XML is "not for the selected game or game revision", check **Properties → Info** for the selected game. This XML expects:

- Game ID prefix: `R8P`
- Region: `E` / USA
- Maker/developer: `01`
- Disc index: `0` for the first disc
- Revision/version: `2`

If your dump shows revision `0` or another value, it is not the USA Rev 2 dump and Dolphin will correctly reject this XML.

4. In Dolphin's game list, right-click Super Paper Mario and choose **Start with Riivolution Patches...**.
5. Enable **SPM Quick Map Menu** and click **Start**.
6. In-game, press `D-Pad Down + 1` to open the menu, select a stage, and press `2` to warp.

## Notes for modders

This project intentionally keeps all game-version-specific calls in `src/spm_us2_symbols.hpp`. If your local header set exposes newer names, update only that adapter. The menu data is in `src/map_menu.cpp`; add or rename entries there without touching the loader glue.

