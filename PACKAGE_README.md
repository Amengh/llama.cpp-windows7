# llama.cpp Windows 7 Compatibility Fork

## Release Package Contents

This package contains a Windows 7 compatible version of llama.cpp with full documentation.

### New Files for GitHub Release

```
llama.cpp-win7/
├── README_GITHUB.md          # Main GitHub README (English)
├── README_CN.md              # Chinese README
├── GITHUB_RELEASE.md         # Release documentation
├── apply_patches.sh          # Bash script to apply patches
├── apply_patches.bat         # Windows batch script to apply patches
│
├── patches/                  # All Windows 7 compatibility patches
│   ├── 01-httplib-root.patch
│   ├── 02-vendor-httplib-h.patch
│   ├── 03-vendor-httplib-cpp.patch
│   ├── 04-server-http.patch
│   ├── 05-cmake-root.patch
│   ├── 06-cmake-vendor-httplib.patch
│   ├── 07-cmake-ggml.patch
│   └── README.md
│
├── docs/                     # Windows 7 specific documentation
│   ├── WINDOWS7_BUILD_GUIDE.md
│   ├── WINDOWS7_API_CHANGES.md
│   ├── WINDOWS7_TROUBLESHOOTING.md
│   └── RELEASE_CHECKLIST.md
│
└── build_win7_final.bat      # Automated build script
```

### Modified Source Files (8 files)

The following files have been modified for Windows 7 compatibility:

1. `httplib.h` - Conditional afunix.h inclusion
2. `vendor/cpp-httplib/httplib.h` - Remove Windows 10 requirement
3. `vendor/cpp-httplib/httplib.cpp` - API replacements (CreateFile2 → CreateFileW, etc.)
4. `tools/server/server-http.cpp` - Windows 7 runtime check
5. `CMakeLists.txt` - Add LLAMA_WIN7_COMPAT option
6. `vendor/cpp-httplib/CMakeLists.txt` - Propagate Win7 flags
7. `ggml/CMakeLists.txt` - Propagate Win7 flags

## Quick Start

### Option 1: Use Pre-Applied Patches (This Repo)

If you're using this fork directly, the patches are already applied:

```batch
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7
build_win7_final.bat
```

### Option 2: Apply Patches to Clean llama.cpp

To add Windows 7 support to any llama.cpp version:

```batch
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp

:: Copy patches from this release
copy path\to\patches\*.patch patches\

:: Apply patches
bash apply_patches.sh

:: Build
build_win7_final.bat
```

## Building

### Requirements

- Windows 7 SP1 or later
- CMake 3.19.x (3.19.8 is the last version supporting Windows 7)
- MinGW-w64 GCC or Visual Studio 2019

### Build Command

```batch
mkdir build
cd build

cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x0601 -static" ^
    -DCMAKE_CXX_FLAGS="-D_WIN32_WINNT=0x0601 -static-libgcc -static-libstdc++ -static" ^
    -DLLAMA_WIN7_COMPAT=ON ^
    -DLLAMA_NATIVE=OFF ^
    -DBUILD_SHARED_LIBS=OFF

mingw32-make -j4
```

## Verification

Check static linking:

```batch
objdump -p bin\llama-server.exe | findstr "DLL Name"
```

Should show only: KERNEL32.dll, ADVAPI32.dll, WS2_32.dll, api-ms-win-crt-*.dll

Should NOT show: libstdc++-6.dll, libgcc_s_seh-1.dll, libwinpthread-1.dll

## Usage

```batch
:: Server
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080

:: CLI
llama-cli.exe -m model.gguf
```

**Important**: On Windows 7, always use `--host 127.0.0.1` (TCP/IP), not Unix domain sockets.

## Documentation

- Full build guide: `docs/WINDOWS7_BUILD_GUIDE.md`
- API changes: `docs/WINDOWS7_API_CHANGES.md`
- Troubleshooting: `docs/WINDOWS7_TROUBLESHOOTING.md`

## License

MIT License - same as original llama.cpp

## Credits

- Original llama.cpp: https://github.com/ggml-org/llama.cpp
- cpp-httplib: https://github.com/yhirose/cpp-httplib
