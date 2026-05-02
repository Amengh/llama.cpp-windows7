# llama.cpp Windows 7 Compatibility Fork

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows 7+](https://img.shields.io/badge/platform-Windows%207%2B-blue)](https://www.microsoft.com/windows/windows-7)
[![Build: MinGW](https://img.shields.io/badge/build-MinGW-green)](https://www.mingw-w64.org/)

> **This is a Windows 7 compatible fork of [llama.cpp](https://github.com/ggml-org/llama.cpp)**

This fork enables llama.cpp to run on Windows 7 SP1 and later, while maintaining full compatibility with Windows 10/11.

## What's Different?

| Feature | Original llama.cpp | This Fork |
|---------|-------------------|-----------|
| Windows 7 Support | ❌ No | ✅ Yes |
| Windows 10/11 Support | ✅ Yes | ✅ Yes |
| Unix Domain Sockets | ✅ Yes (Win10 1803+) | ❌ TCP/IP only on Win7 |
| CreateFile2 API | ✅ Windows 8+ | ✅ Windows 7 compatible |
| Performance | Baseline | Same on Win10/11 |

## Quick Start

### Prerequisites

- Windows 7 SP1 or later (Windows 10/11 also supported)
- [CMake 3.19.x](https://cmake.org/files/v3.19/) (3.19.8 is the last version supporting Windows 7)
- [MinGW-w64 GCC](https://www.msys2.org/) or Visual Studio 2019

### Build

```batch
:: Clone this repository
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7

:: Run the build script
build_win7_final.bat
```

Or manually:

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

### Usage

```batch
:: Start the server
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080

:: Or use the CLI
llama-cli.exe -m model.gguf
```

**Note**: On Windows 7, always use TCP/IP (`--host 127.0.0.1`) instead of Unix domain sockets.

## Technical Details

### Modified Files

This fork makes minimal changes to 8 files:

1. **httplib.h** (root) - Conditional afunix.h inclusion
2. **vendor/cpp-httplib/httplib.h** - Remove Windows 10 requirement
3. **vendor/cpp-httplib/httplib.cpp** - Replace Windows 8+ APIs:
   - `CreateFile2` → `CreateFileW`
   - `CreateFileMappingFromApp` → `CreateFileMapping`
   - `MapViewOfFileFromApp` → `MapViewOfFile`
4. **tools/server/server-http.cpp** - Add Windows 7 runtime check
5. **CMakeLists.txt** (root) - Add `LLAMA_WIN7_COMPAT` option
6. **vendor/cpp-httplib/CMakeLists.txt** - Propagate Win7 flags
7. **ggml/CMakeLists.txt** - Propagate Win7 flags

See [patches/](patches/) directory for detailed diffs.

### API Replacements

| Windows 8+ API | Windows 7 Compatible |
|---------------|---------------------|
| `CreateFile2` | `CreateFileW` |
| `CreateFileMappingFromApp` | `CreateFileMapping` |
| `MapViewOfFileFromApp` | `MapViewOfFile` |
| `GetSystemTimePreciseAsFileTime` | `GetSystemTimeAsFileTime` (CMake internal) |

### Static Linking

This fork uses fully static linking to eliminate DLL dependencies:

- ✅ `libstdc++-6.dll` → statically linked
- ✅ `libgcc_s_seh-1.dll` → statically linked
- ✅ `libwinpthread-1.dll` → statically linked
- ⚠️ `libgomp-1.dll` → still required (OpenMP)

## Documentation

- [Complete Build Guide](docs/WINDOWS7_BUILD_GUIDE.md) - Detailed step-by-step instructions
- [API Changes](docs/WINDOWS7_API_CHANGES.md) - Technical details of API replacements
- [Troubleshooting](docs/WINDOWS7_TROUBLESHOOTING.md) - Common errors and solutions
- [Original README](README_ORIGINAL.md) - Upstream llama.cpp documentation

## Verification

To verify your build is correctly static-linked:

```batch
objdump -p llama-server.exe | findstr "DLL Name"
```

Expected output should only show system DLLs:
- `KERNEL32.dll`
- `ADVAPI32.dll`
- `WS2_32.dll`
- `api-ms-win-crt-*.dll` (Universal CRT)

**Not allowed**: `libstdc++-6.dll`, `libgcc_s_seh-1.dll`, `libwinpthread-1.dll`

## Limitations

- Unix domain sockets (AF_UNIX) are not supported on Windows 7
- Some advanced networking features require Windows 8+
- CMake 4.x is not supported on Windows 7 (use 3.19.x)

## Credits

- Original [llama.cpp](https://github.com/ggml-org/llama.cpp) by ggml-org
- [cpp-httplib](https://github.com/yhirose/cpp-httplib) by yhirose

## License

This fork maintains the same [MIT license](LICENSE) as the original llama.cpp project.

---

**Note**: This is an unofficial fork. For the official llama.cpp project, visit https://github.com/ggml-org/llama.cpp
