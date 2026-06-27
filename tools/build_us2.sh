#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTERN="$ROOT/extern"
mkdir -p "$EXTERN" "$ROOT/dist/riivolution/spm-quick-map-menu/files/mod" "$ROOT/dist/riivolution"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need git

find_python() {
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD=(python3)
  elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD=(python)
  elif command -v py >/dev/null 2>&1; then
    PYTHON_CMD=(py -3)
  else
    echo "Missing required command: python3, python, or py -3" >&2
    echo "Python is installed on many Windows machines as 'python' or through the Python Launcher as 'py -3'." >&2
    exit 1
  fi
}
find_python

if [ ! -d "$EXTERN/spm-rel-loader/.git" ]; then
  git clone --depth 1 https://github.com/SeekyCt/spm-rel-loader "$EXTERN/spm-rel-loader"
fi
if [ ! -d "$EXTERN/spm-headers/.git" ]; then
  git clone --depth 1 https://github.com/SeekyCt/spm-headers "$EXTERN/spm-headers"
fi

REL_DIR="$EXTERN/spm-rel-loader/rel"
MOD_DIR="$REL_DIR/quick-map-menu"
rm -rf "$MOD_DIR"
mkdir -p "$MOD_DIR/src"
cp "$ROOT/src/"*.cpp "$ROOT/src/"*.hpp "$MOD_DIR/src/"

cat > "$MOD_DIR/quick-map-menu.mk" <<'MAKE'
TARGET := quick_map_menu
CXXFILES := $(wildcard src/*.cpp)
CPPFLAGS += -DSPM_US2 -DRELAX_NAMESPACING -I$(CURDIR)/src -I$(CURDIR)/../../../spm-headers/include -I$(CURDIR)/../../../spm-headers/mod
LDFLAGS += -T$(CURDIR)/../../../spm-headers/linker/us2.ld
MAKE

cd "$EXTERN/spm-rel-loader"
if [ -f configure.py ]; then
  "${PYTHON_CMD[@]}" configure.py us2
fi
if command -v ninja >/dev/null 2>&1; then
  ninja us2 || ninja
else
  make us2
fi

FOUND="$(find "$EXTERN/spm-rel-loader" -name '*.us2.rel' -o -name 'mod.rel' | head -n 1 || true)"
if [ -z "$FOUND" ]; then
  echo "Build completed but no REL was found. Check upstream loader build layout." >&2
  exit 1
fi
cp "$FOUND" "$ROOT/dist/riivolution/spm-quick-map-menu/files/mod/mod.rel"
cp "$ROOT/riivolution/spm_quick_map_menu.xml" "$ROOT/dist/riivolution/spm_quick_map_menu.xml"
echo "Wrote dist/riivolution/spm-quick-map-menu/files/mod/mod.rel"
