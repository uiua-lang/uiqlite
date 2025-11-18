#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_dependency() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] $cmd is required but not installed${NC}"
        return 1
    else
        echo -e "${GREEN}[OK] $cmd found${NC}"
        return 0
    fi
}

echo "=== SQLite Multi-Platform Build Script ==="
echo ""

echo "=== Checking Dependencies ==="

MISSING_DEPS=0

check_dependency git || MISSING_DEPS=1
check_dependency make || MISSING_DEPS=1
check_dependency autoconf || MISSING_DEPS=1
check_dependency gcc || MISSING_DEPS=1
check_dependency clang || MISSING_DEPS=1
check_dependency ar || MISSING_DEPS=1
check_dependency ranlib || MISSING_DEPS=1
check_dependency x86_64-w64-mingw32-gcc || MISSING_DEPS=1
check_dependency x86_64-w64-mingw32-ar || MISSING_DEPS=1
check_dependency x86_64-w64-mingw32-ranlib || MISSING_DEPS=1
check_dependency i686-w64-mingw32-gcc || MISSING_DEPS=1
check_dependency i686-w64-mingw32-ar || MISSING_DEPS=1
check_dependency i686-w64-mingw32-ranlib || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${RED}=== Missing Required Dependencies ===${NC}"
    echo "Please install all missing dependencies before running this script."
    exit 1
fi

echo ""

if [ -d "sqlite" ]; then
    echo "Removing existing SQLite directory..."
    rm -rf sqlite
fi

echo "Removing existing build artifacts..."
rm -f sqlite3-*

# Create compat directory if it doesn't exist
mkdir -p compat

echo "Cloning SQLite repository (shallow clone)..."
git clone --depth 1 https://github.com/sqlite/sqlite.git sqlite

cd sqlite

OS=$(uname -s)
echo "Host OS: $OS"

echo ""
echo "=== Building for Linux x86_64 ==="
./configure --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3.a" ] && [ -f "libsqlite3.so" ]; then
    # Compile compat wrapper
    gcc -fPIC -O2 -I. -I../compat -c ../compat/uiua_compat.c -o ../compat/uiua_compat_linux_x86_64.o
    # Link static library + compat into new shared library
    gcc -shared -o ../sqlite3-linux-x86_64.so -Wl,--whole-archive libsqlite3.a -Wl,--no-whole-archive ../compat/uiua_compat_linux_x86_64.o -lm -lz -lpthread -ldl
    strip ../sqlite3-linux-x86_64.so
    echo "[OK] Linux x86_64 build complete: sqlite3-linux-x86_64.so (with compat)"
else
    echo -e "${RED}[ERROR] Could not find Linux .a or .so output${NC}"
fi

echo ""
echo "=== Building for macOS x86_64 ==="
CFLAGS="-target x86_64-apple-darwin" ./configure --enable-shared --host=x86_64-apple-darwin 2>/dev/null || \
./configure --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3.dylib" ] && [ -f "libsqlite3.a" ]; then
    # Compile compat wrapper
    clang -fPIC -O2 -target x86_64-apple-darwin -I. -I../compat -c ../compat/uiua_compat.c -o ../compat/uiua_compat_macos_x86_64.o
    # Link static library + compat into new shared library
    clang -dynamiclib -o ../sqlite3-macos-x86_64.dylib -target x86_64-apple-darwin -Wl,-force_load,libsqlite3.a ../compat/uiua_compat_macos_x86_64.o -lz
    strip ../sqlite3-macos-x86_64.dylib
    echo "[OK] macOS x86_64 build complete: sqlite3-macos-x86_64.dylib (with compat)"
elif [ -f "libsqlite3.a" ]; then
    # Compile compat wrapper (cross-compile fallback)
    gcc -fPIC -O2 -I. -I../compat -c ../compat/uiua_compat.c -o ../compat/uiua_compat_macos_x86_64.o
    # Link static library + compat into new shared library
    gcc -shared -o ../sqlite3-macos-x86_64.dylib -Wl,--whole-archive libsqlite3.a -Wl,--no-whole-archive ../compat/uiua_compat_macos_x86_64.o -lm -lz -lpthread -ldl
    strip ../sqlite3-macos-x86_64.dylib
    echo "[OK] macOS x86_64 build complete: sqlite3-macos-x86_64.dylib (cross-compiled with compat)"
else
    echo -e "${RED}[ERROR] Could not find macOS .a output${NC}"
fi

echo ""
echo "=== Building for Windows x86_64 ==="
./configure --host=x86_64-w64-mingw32 --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3.a" ]; then
    # Compile compat wrapper
    x86_64-w64-mingw32-gcc -O2 -I. -I../compat -c ../compat/uiua_compat.c -o ../compat/uiua_compat_win_x86_64.o
    # Link static library + compat into new shared library
    x86_64-w64-mingw32-gcc -shared -o ../sqlite3-win-x86_64.dll -Wl,--whole-archive libsqlite3.a -Wl,--no-whole-archive ../compat/uiua_compat_win_x86_64.o -lz
    x86_64-w64-mingw32-strip ../sqlite3-win-x86_64.dll
    echo "[OK] Win x86_64 build complete: sqlite3-win-x86_64.dll (with compat)"
else
    echo -e "${RED}[ERROR] Could not find Win x86_64 .a output${NC}"
fi

echo ""
echo "=== Building for Windows x86 ==="
./configure --host=i686-w64-mingw32 --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3.a" ]; then
    # Compile compat wrapper
    i686-w64-mingw32-gcc -O2 -I. -I../compat -c ../compat/uiua_compat.c -o ../compat/uiua_compat_win_x86.o
    # Link static library + compat into new shared library
    i686-w64-mingw32-gcc -shared -o ../sqlite3-win-x86.dll -Wl,--whole-archive libsqlite3.a -Wl,--no-whole-archive ../compat/uiua_compat_win_x86.o -lz
    i686-w64-mingw32-strip ../sqlite3-win-x86.dll
    echo "[OK] Win x86 build complete: sqlite3-win-x86.dll (with compat)"
else
    echo -e "${RED}[ERROR] Could not find Win x86 .a output${NC}"
fi

cd ..

echo ""
echo "=== Build Summary ==="
echo "Output files in current directory:"
ls -lh sqlite3-* 2>/dev/null || echo "No output files found"
echo ""
echo "Done!"