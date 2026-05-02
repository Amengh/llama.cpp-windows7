# llama.cpp Windows 7/11 Dual-Platform Compilation Skill

## Overview

This skill documents the successful approach to adapting llama.cpp for Windows 7 compatibility while maintaining Windows 11 support, using cpp-httplib for the HTTP server component with full static linking.

## Key Achievements

✅ Successfully compiled llama.cpp for Windows 11 with fully static linking  
✅ Modified httplib.h for Windows 7 compatibility (AF_UNIX, afunix.h)  
✅ Created dual-platform build scripts (Windows 7 & Windows 11)  
✅ Solved DLL dependency issues (libstdc++, libgcc, libwinpthread)  
✅ Resolved C++ codecvt entry point errors  

## Critical Modifications Required

### 1. httplib.h Modifications (ROOT DIRECTORY)

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\httplib.h`

#### Modification 1: Windows Version Definition (Line ~191)
```cpp
// BEFORE: No Windows version check
#include <io.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <afunix.h>  // ❌ FAILS on Windows 7

// AFTER: Conditional Windows version check
#include <io.h>
#include <winsock2.h>
#include <ws2tcpip.h>

// Windows 7 Compatibility: Define minimum Windows version
#ifndef _WIN32_WINNT
  #define _WIN32_WINNT 0x0601  // Windows 7
#endif
#ifndef WINVER
  #define WINVER 0x0601  // Windows 7
#endif

// afunix.h only available on Windows 8+ (0x0602)
#if _WIN32_WINNT >= 0x0602
  #include <afunix.h>
#endif
```

#### Modification 2: AF_UNIX Socket Handling (Line ~3541)
```cpp
// BEFORE: Direct AF_UNIX usage
if (hints.ai_family == AF_UNIX) {
    // ... Unix domain socket code
}

// AFTER: Conditional AF_UNIX for Windows 7 compatibility
#if _WIN32_WINNT >= 0x0602 || !defined(_WIN32)
  if (hints.ai_family == AF_UNIX) {
      // ... Unix domain socket code
  }
#endif
```

### 2. vendor/cpp-httplib/httplib.h Modifications (VENDOR DIRECTORY)

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\vendor\cpp-httplib\httplib.h`

**⚠️ CRITICAL**: This is a DIFFERENT file from the root httplib.h!

#### Modification: Remove Windows Version Check (Line ~14-19)
```cpp
// BEFORE: Hardcoded Windows 10 requirement
#ifdef _WIN32
#if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
#error                                                                         \
    "cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later."
#endif
#endif

// AFTER: Comment out for Windows 7 compatibility
#ifdef _WIN32
// Windows 7 compatibility: Comment out version check
// #if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
// #error                                                                         \
//     "cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later."
// #endif
#endif
```

### 3. vendor/cpp-httplib/httplib.cpp Modifications

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\vendor\cpp-httplib\httplib.cpp`

#### Modification 1: Replace CreateFile2 with CreateFileW (Line ~1467)
```cpp
// BEFORE: CreateFile2 is Windows 8+ only
hFile_ = ::CreateFile2(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       OPEN_EXISTING, NULL);

// AFTER: CreateFileW works on all Windows versions
hFile_ = ::CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
```

#### Modification 2: Replace CreateFileMappingFromApp with CreateFileMapping (Line ~1485)
```cpp
// BEFORE: Windows 8+ only
hMapping_ = ::CreateFileMappingFromApp(hFile_, NULL, PAGE_READONLY, size_, NULL);

// AFTER: Windows 7 compatible
hMapping_ = ::CreateFileMapping(hFile_, NULL, PAGE_READONLY, 0, size_, NULL);
```

#### Modification 3: Replace MapViewOfFileFromApp with MapViewOfFile (Line ~1499)
```cpp
// BEFORE: Windows 8+ only
addr_ = ::MapViewOfFileFromApp(hMapping_, FILE_MAP_READ, 0, 0);

// AFTER: Windows 7 compatible
addr_ = ::MapViewOfFile(hMapping_, FILE_MAP_READ, 0, 0, 0);
```

### 4. server-http.cpp Modifications

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\tools\server\server-http.cpp` (Line ~307)

```cpp
// BEFORE: Direct AF_UNIX socket usage
if (string_ends_with(std::string(hostname), ".sock")) {
    is_sock = true;
    srv->set_address_family(AF_UNIX);
    was_bound = srv->bind_to_port(hostname, 8080);
}

// AFTER: Windows 7 compatibility check
if (string_ends_with(std::string(hostname), ".sock")) {
#if defined(_WIN32) && (!defined(_WIN32_WINNT) || _WIN32_WINNT < 0x0602)
    // Windows 7: Unix domain sockets not supported
    LOG_ERR("Unix domain sockets are not supported on Windows 7. "
            "Please use TCP/IP instead.\n");
    return false;
#else
    is_sock = true;
    srv->set_address_family(AF_UNIX);
    was_bound = srv->bind_to_port(hostname, 8080);
#endif
}
```

### 5. CMakeLists.txt Modifications

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\CMakeLists.txt` (Line ~64)

```cmake
# Add after existing WIN32 check
if (WIN32)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    
    # Windows 7 compatibility option
    option(LLAMA_WIN7_COMPAT "llama: build with Windows 7 compatibility" OFF)
    if (LLAMA_WIN7_COMPAT)
        add_compile_definitions(_WIN32_WINNT=0x0601)
        add_compile_definitions(WINVER=0x0601)
        message(STATUS "Building with Windows 7 compatibility")
    endif()
endif()
```

### 6. vendor/cpp-httplib/CMakeLists.txt

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\vendor\cpp-httplib\CMakeLists.txt`

```cmake
# Add after target_compile_features
target_compile_features(${TARGET} PRIVATE cxx_std_17)

# Windows 7 compatibility
if (WIN32 AND LLAMA_WIN7_COMPAT)
    target_compile_definitions(${TARGET} PRIVATE _WIN32_WINNT=0x0601 WINVER=0x0601)
endif()
```

### 7. ggml/CMakeLists.txt

**File**: `D:\Users\Zhoum\Desktop\llama.cpp-master430\ggml\CMakeLists.txt`

```cmake
# In the WIN32 section (around line 79)
if (WIN32)
    set(CMAKE_STATIC_LIBRARY_PREFIX "")
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
    set(CMAKE_SHARED_MODULE_PREFIX  "")

    # Windows 7 compatibility support
    if (LLAMA_WIN7_COMPAT)
        add_compile_definitions(_WIN32_WINNT=0x0601)
        add_compile_definitions(WINVER=0x0601)
        message(STATUS "GGML: Building with Windows 7 compatibility")
    endif()
endif()
```

## Successful Build Configuration

### Critical CMake Flags for Static Linking

```batch
:: ESSENTIAL for eliminating DLL dependencies
cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    :: CRITICAL: Windows API version definition
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x0A00 -static" ^
    -DCMAKE_CXX_FLAGS="-D_WIN32_WINNT=0x0A00 -static-libgcc -static-libstdc++ -static" ^
    -DCMAKE_EXE_LINKER_FLAGS="-static" ^
    :: Build options
    -DLLAMA_WIN7_COMPAT=OFF ^
    -DLLAMA_BUILD_TESTS=OFF ^
    -DLLAMA_BUILD_EXAMPLES=OFF ^
    -DLLAMA_BUILD_TOOLS=ON ^
    -DLLAMA_BUILD_SERVER=ON ^
    -DLLAMA_NATIVE=ON ^
    -DLLAMA_AVX=ON ^
    -DLLAMA_AVX2=ON ^
    -DLLAMA_FMA=ON ^
    -DLLAMA_F16C=ON ^
    -DLLAMA_OPENSSL=OFF ^
    -DBUILD_SHARED_LIBS=OFF
```

### Static Linking Flags Explained

| Flag | Purpose | Impact |
|------|---------|--------|
| `-static` | Static link system libraries | ✅ Eliminates most DLLs |
| `-static-libgcc` | Static link GCC runtime | ✅ Eliminates libgcc_s_seh-1.dll |
| `-static-libstdc++` | Static link C++ standard library | ✅ Eliminates libstdc++-6.dll |
| `-D_WIN32_WINNT=0x0601` | Target Windows 7 API | ✅ Prevents CreateFile2 errors |
| `-D_WIN32_WINNT=0x0A00` | Target Windows 10/11 API | ✅ Enables full features |

## Failure Lessons & Solutions

### ❌ Failure 1: DLL Dependency Errors

**Error**: `无法定位程序输入点 _ZNKSt25__codecvt_utf8_utf16_base... 于动态链接库`

**Root Cause**: Dynamic linking of MinGW C++ runtime libraries

**Solution**: Add `-static-libgcc -static-libstdc++ -static` to CMAKE_CXX_FLAGS

### ❌ Failure 2: CreateFile2 Not Declared

**Error**: `'::CreateFile2' has not been declared`

**Root Cause**: Windows API version not defined, defaulting to old version

**Solution**: Add `-D_WIN32_WINNT=0x0A00` (Win10/11) or `0x0601` (Win7)

### ❌ Failure 3: cpp-httplib Version Error

**Error**: 
```
cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later.
```

**Root Cause**: `vendor/cpp-httplib/httplib.h` has a hardcoded Windows version check

**Solution**: Comment out the #error directive in vendor/cpp-httplib/httplib.h:
```cpp
// Windows 7 compatibility: Comment out version check
// #if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
// #error "cpp-httplib doesn't support Windows 8 or lower..."
// #endif
```

### ❌ Failure 4: CreateFile2 Not Declared (vendor)

**Error**: 
```
'::CreateFile2' has not been declared; did you mean 'CreateFileW'?
```

**Root Cause**: `vendor/cpp-httplib/httplib.cpp` uses CreateFile2 which is Windows 8+ only

**Solution**: Replace CreateFile2 with CreateFileW in vendor/cpp-httplib/httplib.cpp:
```cpp
// BEFORE (Windows 8+)
hFile_ = ::CreateFile2(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       OPEN_EXISTING, NULL);

// AFTER (All Windows)
hFile_ = ::CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
```

### ❌ Failure 5: CreateFileMappingFromApp Not Found (Runtime)

**Error**: 
```
无法定位程序输入点 CreateFileMappingFromApp 于动态链接库 KERNEL32.dll 上
```

**Root Cause**: `CreateFileMappingFromApp` is Windows 8+ API, not available on Windows 7

**Solution**: Replace with Windows 7 compatible `CreateFileMapping`:
```cpp
// vendor/cpp-httplib/httplib.cpp Line ~1485
// BEFORE:
hMapping_ = ::CreateFileMappingFromApp(hFile_, NULL, PAGE_READONLY, size_, NULL);

// AFTER:
hMapping_ = ::CreateFileMapping(hFile_, NULL, PAGE_READONLY, 0, size_, NULL);
```

Also replace `MapViewOfFileFromApp` with `MapViewOfFile` at Line ~1499.

### ❌ Failure 6: GetSystemTimePreciseAsFileTime Not Found (CMake)

**Error**: 
```
无法定位程序输入点 GetSystemTimePreciseAsFileTime 于动态链接库 KERNEL32.dll 上
```

**Root Cause**: CMake 4.x+ requires Windows 8+ APIs

**Solution**: Downgrade CMake to 3.19.x for Windows 7
- Download: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi
- CMake 3.19 is the last version supporting Windows 7

### ❌ Failure 7: afunix.h Not Found

**Error**: `afunix.h: No such file or directory`

**Root Cause**: afunix.h only available on Windows 8+ / Windows 10 1803+

**Solution**: Wrap `#include <afunix.h>` with `#if _WIN32_WINNT >= 0x0602`

### ❌ Failure 8: AF_UNIX Not Supported

**Error**: `'AF_UNIX' was not declared in this scope`

**Root Cause**: Trying to use Unix domain sockets on Windows 7

**Solution**: Use TCP/IP instead: `--host 127.0.0.1 --port 8080`

### ❌ Failure 9: Script Encoding Issues

**Error**: Garbled characters in batch files when running

**Root Cause**: UTF-8 encoding with Chinese characters in batch files

**Solution**: Use ASCII-only characters in .bat files or ensure proper BOM

## Platform-Specific Configurations

### Windows 7 Configuration

```batch
:: API Version
-D_WIN32_WINNT=0x0601
-DWINVER=0x0601

:: Compatibility Mode
-DLLAMA_WIN7_COMPAT=ON

:: Disable native optimization for broader compatibility
-DLLAMA_NATIVE=OFF

:: Server Usage (REQUIRED)
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080
:: ❌ DO NOT USE: --host "/path/socket.sock"
```

### Windows 11 Configuration

```batch
:: API Version
-D_WIN32_WINNT=0x0A00
-DWINVER=0x0A00

:: Compatibility Mode
-DLLAMA_WIN7_COMPAT=OFF

:: Enable native optimization for best performance
-DLLAMA_NATIVE=ON

:: Server Usage (FLEXIBLE)
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080
:: ✅ ALSO WORKS: --host "/path/socket.sock"
```

## Quick Reuse Checklist

When updating llama.cpp codebase:

### Step 1: Check Modified Files
```batch
:: Verify these files still exist and modifications are intact:
git diff HEAD --stat
:: Check: httplib.h, server-http.cpp, CMakeLists.txt (root and subdirs)
```

### Step 2: Reapply Modifications if Needed
```batch
:: Check if modifications are still present:
grep "_WIN32_WINNT >= 0x0602" httplib.h
grep "LLAMA_WIN7_COMPAT" CMakeLists.txt
grep "Windows 7" tools/server/server-http.cpp
```

### Step 3: Run Build Script
```batch
:: For Windows 11
build_win11.bat

:: For Windows 7
build_win7_final.bat
```

### Step 4: Verify Static Linking
```batch
:: Check DLL dependencies
cd build_win*_static/bin
objdump -p llama-server.exe | grep "DLL Name"

:: Expected: Only KERNEL32.dll, ADVAPI32.dll, WS2_32.dll, api-ms-win-crt-*.dll
:: NOT ALLOWED: libstdc++-6.dll, libgcc_s_seh-1.dll, libwinpthread-1.dll
```

## Automated Patch Application

Create `apply_windows_patches.sh` (or .bat):

```bash
#!/bin/bash
# apply_windows_patches.sh - Reapply Windows 7/11 compatibility patches

echo "Applying Windows compatibility patches..."

# Check if httplib.h exists in root directory
if [ -f "httplib.h" ]; then
    echo "✓ Found httplib.h in root directory"
    
    # Check if already patched
    if grep -q "_WIN32_WINNT >= 0x0602" httplib.h; then
        echo "✓ httplib.h already patched"
    else
        echo "⚠ httplib.h needs patching - apply manual modifications"
        echo "  See skill: llama.cpp Windows 7/11 Compilation"
    fi
else
    echo "✗ httplib.h not found in root - project structure changed"
fi

# Check server-http.cpp
if [ -f "tools/server/server-http.cpp" ]; then
    if grep -q "Windows 7" tools/server/server-http.cpp; then
        echo "✓ server-http.cpp already patched"
    else
        echo "⚠ server-http.cpp needs patching"
    fi
fi

# Check CMakeLists.txt
if grep -q "LLAMA_WIN7_COMPAT" CMakeLists.txt; then
    echo "✓ CMakeLists.txt already patched"
else
    echo "⚠ CMakeLists.txt needs patching"
fi

echo "Patch check complete."
```

## Verification Commands

### Verify Build Success
```batch
:: Check executables exist
dir build_win*_static\bin\llama-server.exe
dir build_win*_static\bin\llama-cli.exe

:: Check file size (should be ~20-25MB)
ls -lh build_win*_static\bin\llama-server.exe
```

### Verify Static Linking
```batch
:: Using MinGW objdump
objdump -p llama-server.exe | grep "DLL Name"

:: Using dumpbin (Visual Studio)
dumpbin /dependents llama-server.exe

:: Expected output should NOT include:
:: - libstdc++-6.dll
:: - libgcc_s_seh-1.dll  
:: - libwinpthread-1.dll
```

### Test Server
```batch
:: Start server
build_win*_static\bin\llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080

:: Test API (in another terminal)
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/v1/models
```

## Documentation Index

Created documentation files:
- `WINDOWS7_BUILD_GUIDE.md` - Complete Windows 7 build guide
- `WINDOWS7_COMPLETE_GUIDE.md` - Detailed compilation instructions
- `WINDOWS7_QUICKREF.md` - Quick reference card
- `WINDOWS7_QUICKSTART.md` - 5-minute quick start
- `BUILD_WINDOWS.md` - General Windows build instructions
- `WIN7_WIN11_COMPARISON.md` - Platform comparison
- `BUILD_SCRIPTS_COMPARISON.md` - Script differences
- `BUILD_REPORT.md` - Windows 11 build report
- `WINDOWS_COMPAT_SUMMARY.md` - Compatibility modifications summary

## Skill Tags

#llama.cpp #windows7 #windows11 #mingw #cmake #static-linking #httplib #cpp-httplib #cross-platform #dll-dependency #compatibility

## Version Info

- Created: 2026-05-01
- Based on: llama.cpp master (commit around 2026-04-30)
- Compiler: MinGW-w64 GCC 16.0.0
- CMake: 4.1.2
- Tested on: Windows 11 (Windows 7 modifications verified)
