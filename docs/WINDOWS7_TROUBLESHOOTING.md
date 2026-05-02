# Windows 7 Troubleshooting Guide

Common errors when building/running llama.cpp on Windows 7 and their solutions.

## Build Errors

### Error 1: CMake won't start

```
无法定位程序输入点 GetSystemTimePreciseAsFileTime 于动态链接库 KERNEL32.dll
```

**Cause**: CMake 4.x requires Windows 8+

**Solution**: Install CMake 3.19.8 (last version supporting Windows 7)
- Download: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi

---

### Error 2: afunix.h not found

```
httplib.h:192:10: fatal error: afunix.h: No such file or directory
  192 | #include <afunix.h>
```

**Cause**: Windows 7 doesn't have the afunix.h header

**Solution**: Apply the patches that conditionally include afunix.h:
```batch
patch -p1 < patches/01-httplib-root.patch
```

The patch adds:
```cpp
#if _WIN32_WINNT >= 0x0602
  #include <afunix.h>
#endif
```

---

### Error 3: CreateFile2 not declared

```
'::CreateFile2' has not been declared; did you mean 'CreateFileW'?
```

**Cause**: CreateFile2 is a Windows 8+ API

**Solution**: Apply the vendor cpp-httplib patch:
```batch
patch -p1 < patches/03-vendor-httplib-cpp.patch
```

This replaces `CreateFile2` with `CreateFileW`.

---

### Error 4: cpp-httplib version error

```
cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later.
```

**Cause**: Hardcoded version check in vendor/cpp-httplib/httplib.h

**Solution**: Apply the patch:
```batch
patch -p1 < patches/02-vendor-httplib-h.patch
```

This comments out the `#error` directive.

---

### Error 5: AF_UNIX not declared

```
'AF_UNIX' was not declared in this scope
```

**Cause**: Trying to use Unix domain sockets on Windows 7

**Solution**: The patches wrap AF_UNIX code with:
```cpp
#if _WIN32_WINNT >= 0x0602 || !defined(_WIN32)
  // AF_UNIX code
#endif
```

---

## Runtime Errors

### Error 6: CreateFileMappingFromApp not found

```
无法定位程序输入点 CreateFileMappingFromApp 于动态链接库 KERNEL32.dll
```

**Cause**: The binary was compiled with Windows 8+ APIs but is running on Windows 7

**Solution**: 
1. Ensure `LLAMA_WIN7_COMPAT=ON` is set when configuring CMake
2. Ensure the API replacement patches are applied
3. Rebuild from clean

---

### Error 7: GetSystemTimePreciseAsFileTime not found

```
无法定位程序输入点 GetSystemTimePreciseAsFileTime 于动态链接库 KERNEL32.dll
```

**Cause**: 
1. CMake 4.x was used (requires Windows 8+)
2. Or the C++ runtime library was compiled for Windows 8+

**Solution**:
1. Use CMake 3.19.x
2. Use MinGW-w64 with Windows 7 compatible headers

---

### Error 8: DLL dependency errors

```
无法定位程序输入点 _ZNKSt25__codecvt_utf8_utf16_base... 于动态链接库 libstdc++-6.dll
```

**Cause**: Dynamic linking of MinGW C++ runtime

**Solution**: Use static linking flags:
```batch
-DCMAKE_CXX_FLAGS="-static-libgcc -static-libstdc++ -static"
```

---

### Error 9: libstdc++-6.dll missing

```
The program can't start because libstdc++-6.dll is missing from your computer
```

**Cause**: C++ standard library not statically linked

**Solution**: Add `-static-libstdc++` to CMAKE_CXX_FLAGS

---

### Error 10: libgcc_s_seh-1.dll missing

```
The program can't start because libgcc_s_seh-1.dll is missing
```

**Cause**: GCC runtime not statically linked

**Solution**: Add `-static-libgcc` to CMAKE_CXX_FLAGS

---

### Error 11: libwinpthread-1.dll missing

```
The program can't start because libwinpthread-1.dll is missing
```

**Cause**: pthread library not statically linked

**Solution**: Add `-static` to linker flags

---

### Error 12: Unix domain socket error

```
Error: Unix domain sockets are not supported on Windows 7
```

**Cause**: Trying to use `--host /path/to/socket.sock` on Windows 7

**Solution**: Use TCP/IP instead:
```batch
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080
```

---

## Verification Commands

### Check DLL Dependencies

```batch
:: Using objdump (MinGW)
objdump -p llama-server.exe | findstr "DLL Name"

:: Expected output (acceptable DLLs):
DLL Name: KERNEL32.dll
DLL Name: ADVAPI32.dll
DLL Name: WS2_32.dll
DLL Name: api-ms-win-crt-runtime-l1-1-0.dll

:: Bad output (these DLLs indicate dynamic linking):
DLL Name: libstdc++-6.dll
DLL Name: libgcc_s_seh-1.dll
DLL Name: libwinpthread-1.dll
```

### Check PE Header Version

```batch
:: Using dumpbin
> dumpbin /headers llama-server.exe | findstr "subsystem"
    6.01 subsystem version        <- Good for Windows 7
    6.02 subsystem version        <- Requires Windows 8+
   10.00 subsystem version        <- Requires Windows 10
```

---

## Clean Build Procedure

If you encounter persistent errors, do a clean build:

```batch
:: Remove build directory completely
rmdir /s /q build_win7

:: Reconfigure from scratch
mkdir build_win7
cd build_win7

cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x0601 -static" ^
    -DCMAKE_CXX_FLAGS="-D_WIN32_WINNT=0x0601 -static-libgcc -static-libstdc++ -static" ^
    -DLLAMA_WIN7_COMPAT=ON ^
    ...

:: Rebuild
mingw32-make clean
mingw32-make -j4
```

---

## Windows 7 SP0 vs SP1

Some APIs require Windows 7 SP1:

- `WSA_FLAG_NO_HANDLE_INHERIT`: Requires Windows 7 SP1 or later
- `InetPtonW`: Requires Windows Vista SP1 or later

The patches handle these automatically by checking `_WIN32_WINNT >= 0x0601`.

**Recommendation**: Always use Windows 7 SP1 for best compatibility.
