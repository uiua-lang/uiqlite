#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_dependency() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] $1 is required but not installed${NC}"
        return 1
    fi
    return 0
}

echo "=== SQLite Multi-Platform Build Script ==="
echo ""

echo "=== Checking Dependencies ==="

MISSING_DEPS=0
check_dependency git || MISSING_DEPS=1
check_dependency make || MISSING_DEPS=1
check_dependency gcc || MISSING_DEPS=1
check_dependency x86_64-w64-mingw32-gcc || MISSING_DEPS=1
check_dependency i686-w64-mingw32-gcc || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${RED}Missing required dependencies. Please install them first.${NC}"
    exit 1
fi

echo ""

# Clean up and prepare
rm -rf sqlite sqlite3-*

echo "Cloning SQLite repository..."
git clone --depth 1 https://github.com/sqlite/sqlite.git sqlite
cd sqlite

# Helper function to build with compat
build_with_compat() {
    local platform=$1
    local compiler=$2
    local output=$3
    local link_flags=$4
    
    ${compiler} -O2 -I. -I../compat -c ../compat/uiua_compat.c -o compat_${platform}.o
    
    ${compiler} -shared -o ../${output} -Wl,--whole-archive libsqlite3.a -Wl,--no-whole-archive compat_${platform}.o ${link_flags}
    ${compiler%gcc}strip ../${output} 2>/dev/null || strip ../${output}
    echo -e "${GREEN}[OK] ${platform} build complete${NC}"
}

echo ""
echo "=== Building for Linux x86_64 ==="
./configure --enable-shared
make
build_with_compat "linux-x86_64" "gcc" "sqlite3-linux-x86_64.so" "-lm -lz -lpthread -ldl"

echo ""
echo "=== Building for macOS x86_64 ==="
./configure --enable-shared 2>/dev/null || true
make clean 2>/dev/null
make
build_with_compat "macos-x86_64" "gcc" "sqlite3-macos-x86_64.dylib" "-lm -lz -lpthread -ldl"

echo ""
echo "=== Building for Windows x86_64 ==="
./configure --host=x86_64-w64-mingw32 --enable-shared
make clean 2>/dev/null
make
build_with_compat "win-x86_64" "x86_64-w64-mingw32-gcc" "sqlite3-win-x86_64.dll" "-lz"

echo ""
echo "=== Building for Windows x86 ==="
./configure --host=i686-w64-mingw32 --enable-shared
make clean 2>/dev/null
make
build_with_compat "win-x86" "i686-w64-mingw32-gcc" "sqlite3-win-x86.dll" "-lz"

cd ..
echo ""
echo "=== Build Complete ==="
ls -lh sqlite3-* 2>/dev/null || echo -e "${RED}No output files found${NC}"