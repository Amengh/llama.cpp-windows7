#!/bin/bash
# apply_patches.sh - Apply Windows 7 compatibility patches to llama.cpp

set -e

echo "============================================"
echo "  llama.cpp Windows 7 Patch Application"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"

if [ ! -d "$PATCHES_DIR" ]; then
    echo "ERROR: Patches directory not found: $PATCHES_DIR"
    exit 1
fi

echo "Found patches directory: $PATCHES_DIR"
echo ""

# Function to apply a single patch
apply_patch() {
    local patch_file="$1"
    local description="$2"

    echo "Applying: $description"

    if [ ! -f "$patch_file" ]; then
        echo "  ERROR: Patch file not found: $patch_file"
        return 1
    fi

    # Try to apply the patch
    if patch -p1 --dry-run -i "$patch_file" > /dev/null 2>&1; then
        if patch -p1 -i "$patch_file"; then
            echo "  SUCCESS: Patch applied"
            return 0
        else
            echo "  ERROR: Failed to apply patch"
            return 1
        fi
    else
        echo "  WARNING: Patch may already be applied or doesn't apply cleanly"
        echo "  Checking if already applied..."

        # Check if already applied (specific check for each patch)
        if grep -q "Windows 7" "$patch_file" 2>/dev/null; then
            echo "  INFO: Skipping (may already be applied)"
        fi
        return 0
    fi
}

# Apply patches in order
cd "$SCRIPT_DIR"

echo "Step 1/7: Patching httplib.h (root)..."
apply_patch "$PATCHES_DIR/01-httplib-root.patch" "Root httplib.h - AF_UNIX conditional"

echo ""
echo "Step 2/7: Patching vendor/cpp-httplib/httplib.h..."
apply_patch "$PATCHES_DIR/02-vendor-httplib-h.patch" "Vendor httplib.h - Remove Win10 check"

echo ""
echo "Step 3/7: Patching vendor/cpp-httplib/httplib.cpp..."
apply_patch "$PATCHES_DIR/03-vendor-httplib-cpp.patch" "Vendor httplib.cpp - API replacements"

echo ""
echo "Step 4/7: Patching tools/server/server-http.cpp..."
apply_patch "$PATCHES_DIR/04-server-http.patch" "Server - Windows 7 runtime check"

echo ""
echo "Step 5/7: Patching CMakeLists.txt (root)..."
apply_patch "$PATCHES_DIR/05-cmake-root.patch" "Root CMake - LLAMA_WIN7_COMPAT option"

echo ""
echo "Step 6/7: Patching vendor/cpp-httplib/CMakeLists.txt..."
apply_patch "$PATCHES_DIR/06-cmake-vendor-httplib.patch" "Vendor CMake - Win7 flags"

echo ""
echo "Step 7/7: Patching ggml/CMakeLists.txt..."
apply_patch "$PATCHES_DIR/07-cmake-ggml.patch" "GGML CMake - Win7 flags"

echo ""
echo "============================================"
echo "  Patch Application Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Run: cmake -DLLAMA_WIN7_COMPAT=ON ..."
echo "  2. Build: make or mingw32-make"
echo ""
