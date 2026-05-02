# Windows 7 API Changes

This document details the API replacements made for Windows 7 compatibility.

## Summary of Changes

### 1. Windows Version Definition

All modified files now define Windows version macros:

```cpp
#ifndef _WIN32_WINNT
  #define _WIN32_WINNT 0x0601  // Windows 7
#endif
#ifndef WINVER
  #define WINVER 0x0601  // Windows 7
#endif
```

Windows version hex values:
- `0x0501` - Windows XP
- `0x0600` - Windows Vista
- `0x0601` - Windows 7
- `0x0602` - Windows 8
- `0x0603` - Windows 8.1
- `0x0A00` - Windows 10/11

### 2. API Replacements

#### CreateFile2 → CreateFileW

**Location**: `vendor/cpp-httplib/httplib.cpp:1467`

```cpp
// Windows 8+ (original)
hFile_ = ::CreateFile2(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       OPEN_EXISTING, NULL);

// Windows 7 compatible
hFile_ = ::CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
```

**Rationale**: `CreateFile2` was introduced in Windows 8. `CreateFileW` has been available since Windows 2000.

**Parameters**:
- `CreateFile2`: 5 parameters (simplified for UWP apps)
- `CreateFileW`: 7 parameters (standard Win32 API)

---

#### CreateFileMappingFromApp → CreateFileMapping

**Location**: `vendor/cpp-httplib/httplib.cpp:1485`

```cpp
// Windows 8+ / UWP (original)
hMapping_ = ::CreateFileMappingFromApp(hFile_, NULL, PAGE_READONLY, size_, NULL);

// Windows 7 compatible
hMapping_ = ::CreateFileMapping(hFile_, NULL, PAGE_READONLY, 0, 0, NULL);
```

**Rationale**: `CreateFileMappingFromApp` is a Windows Store/UWP API introduced in Windows 8.

**Parameters**:
- `CreateFileMappingFromApp`: Takes `ULONG64` size directly
- `CreateFileMapping`: Takes `DWORD dwMaximumSizeHigh` and `DWORD dwMaximumSizeLow`

---

#### MapViewOfFileFromApp → MapViewOfFile

**Location**: `vendor/cpp-httplib/httplib.cpp:1499`

```cpp
// Windows 8+ / UWP (original)
addr_ = ::MapViewOfFileFromApp(hMapping_, FILE_MAP_READ, 0, 0);

// Windows 7 compatible
addr_ = ::MapViewOfFile(hMapping_, FILE_MAP_READ, 0, 0, 0);
```

**Rationale**: `MapViewOfFileFromApp` is the Windows Store variant.

**Parameters**:
- Both APIs are similar, but `MapViewOfFile` takes an additional `dwNumberOfBytesToMap` parameter (0 = entire file)

---

### 3. Header File Changes

#### afunix.h Conditional Inclusion

**Location**: `httplib.h:191`

```cpp
// afunix.h only available on Windows 8+ (0x0602)
#if _WIN32_WINNT >= 0x0602
  #include <afunix.h>
#endif
```

**Rationale**: Unix domain socket support was added to Windows in Windows 10 version 1803 and backported to Windows 8/8.1. Windows 7 does not have this header.

---

### 4. Socket API Changes

#### AF_UNIX Conditional Compilation

**Location**: `httplib.h:3541-3587`

```cpp
#if _WIN32_WINNT >= 0x0602 || !defined(_WIN32)
  if (hints.ai_family == AF_UNIX) {
      // ... Unix domain socket handling
  }
#endif
```

**Rationale**: AF_UNIX sockets are not available on Windows 7. The code now compiles out this functionality when targeting Windows 7.

---

### 5. Runtime Checks

#### Windows 7 Server Warning

**Location**: `tools/server/server-http.cpp:307`

```cpp
if (string_ends_with(std::string(hostname), ".sock")) {
#if defined(_WIN32) && (!defined(_WIN32_WINNT) || _WIN32_WINNT < 0x0602)
    LOG_ERR("Unix domain sockets are not supported on Windows 7. "
            "Please use TCP/IP instead.\n");
    return false;
#else
    // Normal Unix domain socket handling
#endif
}
```

**Rationale**: Prevents runtime errors when users try to use Unix domain sockets on Windows 7.

---

## CMake Integration

The `LLAMA_WIN7_COMPAT` option propagates the Windows version flags:

```cmake
if (WIN32)
    option(LLAMA_WIN7_COMPAT "llama: build with Windows 7 compatibility" OFF)
    if (LLAMA_WIN7_COMPAT)
        add_compile_definitions(_WIN32_WINNT=0x0601)
        add_compile_definitions(WINVER=0x0601)
    endif()
endif()
```

This ensures all compiled code uses the correct Windows API version.

---

## Testing API Compatibility

To verify which Windows version your binary targets:

```batch
:: Using dumpbin (Visual Studio)
dumpbin /headers llama-server.exe | findstr "subsystem"

:: Look for:
::    6.01 (Windows 7) - Good
::    6.02 (Windows 8) - Too new for Windows 7
::    10.00 (Windows 10) - Too new for Windows 7
```

Or check the PE header directly:

```batch
:: Read the major/minor subsystem version from PE header
:: Offset 0x40 from PE header contains major version
:: Offset 0x42 contains minor version
```
