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
check_dependency x86_64-w64-mingw32-gcc || MISSING_DEPS=1
check_dependency i686-w64-mingw32-gcc || MISSING_DEPS=1

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
if [ -f "libsqlite3.so" ]; then
    cp libsqlite3.so ../sqlite3-linux-x86_64.so
    strip ../sqlite3-linux-x86_64.so
    echo "[OK] Linux x86_64 build complete: sqlite3-linux-x86_64.so"
else
    echo -e "${RED}[ERROR] Could not find Linux .so output${NC}"
fi

echo ""
echo "=== Building for macOS x86_64 ==="
CFLAGS="-target x86_64-apple-darwin" ./configure --enable-shared --host=x86_64-apple-darwin 2>/dev/null || \
./configure --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3.dylib" ]; then
    cp libsqlite3.dylib ../sqlite3-macos-x86_64.dylib
    strip ../sqlite3-macos-x86_64.dylib
    echo "[OK] macOS x86_64 build complete: sqlite3-macos-x86_64.dylib"
elif [ -f "libsqlite3.so" ]; then
    cp libsqlite3.so ../sqlite3-macos-x86_64.dylib
    strip ../sqlite3-macos-x86_64.dylib
    echo "[OK] macOS x86_64 build complete: sqlite3-macos-x86_64.dylib (cross-compiled)"
else
    echo -e "${RED}[ERROR] Could not find macOS dylib output${NC}"
fi

echo ""
echo "=== Building for Windows x86_64 ==="
./configure --host=x86_64-w64-mingw32 --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3-0.dll" ]; then
    cp libsqlite3-0.dll ../sqlite3-win-x86_64.dll
    x86_64-w64-mingw32-strip ../sqlite3-win-x86_64.dll
    echo "[OK] Win x86_64 build complete: sqlite3-win-x86_64.dll"
elif [ -f "sqlite3.dll" ]; then
    cp sqlite3.dll ../sqlite3-win-x86_64.dll
    x86_64-w64-mingw32-strip ../sqlite3-win-x86_64.dll
    echo "[OK] Win x86_64 build complete: sqlite3-win-x86_64.dll"
else
    echo -e "${RED}[ERROR] Could not find Win x86_64 DLL output${NC}"
fi

echo ""
echo "=== Building for Windows x86 ==="
./configure --host=i686-w64-mingw32 --enable-shared
make clean 2>/dev/null || true
make
if [ -f "libsqlite3-0.dll" ]; then
    cp libsqlite3-0.dll ../sqlite3-win-x86.dll
    i686-w64-mingw32-strip ../sqlite3-win-x86.dll
    echo "[OK] Win x86 build complete: sqlite3-win-x86.dll"
elif [ -f "sqlite3.dll" ]; then
    cp sqlite3.dll ../sqlite3-win-x86.dll
    i686-w64-mingw32-strip ../sqlite3-win-x86.dll
    echo "[OK] Win x86 build complete: sqlite3-win-x86.dll"
else
    echo -e "${RED}[ERROR] Could not find Win x86 DLL output${NC}"
fi

cd ..

echo ""
echo "=== Build Summary ==="
echo "Output files in current directory:"
ls -lh sqlite3-* 2>/dev/null || echo "No output files found"
echo ""
echo "Done!"