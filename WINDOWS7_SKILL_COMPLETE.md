# llama.cpp Windows 7 编译完整技能手册

## 版本信息
- **Created**: 2026-05-01
- **Status**: ✅ 验证成功（Windows 7 SP1 运行通过）
- **Compiler**: MinGW-w64 GCC 16.0.0
- **CMake**: 3.19.8 (Windows 7 最高支持版本)

---

## 核心要点

Windows 7 编译 llama.cpp 的关键是：**替换所有 Windows 8+ 专用 API**

### 主要障碍
1. cpp-httplib 默认要求 Windows 10+
2. 使用了 Windows 8+ 专用 API（CreateFile2, CreateFileMappingFromApp 等）
3. Unix 域套接字（AF_UNIX）不支持
4. CMake 4.x 不支持 Windows 7

### 解决方案概览
- 修改 8 个文件，替换/注释 Windows 8+ 代码
- 使用 CMake 3.19.x（Windows 7 最高支持版本）
- 完全静态链接，避免 DLL 依赖

---

## 需要修改的 8 个文件

### 1. httplib.h (根目录)
**路径**: `httplib.h`  
**行号**: ~191-206, ~3541-3587

**修改 1**: 添加 Windows 7 API 版本定义
```cpp
// 在 #include <winsock2.h> 之后添加：

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

**修改 2**: AF_UNIX 条件编译
```cpp
// 在创建 socket 的代码中：
#if _WIN32_WINNT >= 0x0602 || !defined(_WIN32)
  if (hints.ai_family == AF_UNIX) {
      // ... Unix domain socket code
  }
#endif
```

---

### 2. vendor/cpp-httplib/httplib.h
**路径**: `vendor/cpp-httplib/httplib.h`  
**行号**: ~14-19

**修改**: 注释掉 Windows 10 强制要求
```cpp
// BEFORE:
#ifdef _WIN32
#if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
#error "cpp-httplib doesn't support Windows 8 or lower..."
#endif
#endif

// AFTER:
#ifdef _WIN32
// Windows 7 compatibility: Comment out version check
// #if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
// #error "cpp-httplib doesn't support Windows 8 or lower..."
// #endif
#endif
```

---

### 3. vendor/cpp-httplib/httplib.cpp ⭐ 关键文件
**路径**: `vendor/cpp-httplib/httplib.cpp`  
**行号**: ~1467, ~1485, ~1499

**修改 1**: CreateFile2 → CreateFileW (第 1467 行)
```cpp
// BEFORE (Windows 8+):
hFile_ = ::CreateFile2(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       OPEN_EXISTING, NULL);

// AFTER (Windows 7 兼容):
hFile_ = ::CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
```

**修改 2**: CreateFileMappingFromApp → CreateFileMapping (第 1485 行)
```cpp
// BEFORE (Windows 8+):
hMapping_ = ::CreateFileMappingFromApp(hFile_, NULL, PAGE_READONLY, size_, NULL);

// AFTER (Windows 7 兼容):
hMapping_ = ::CreateFileMapping(hFile_, NULL, PAGE_READONLY, 0, size_, NULL);
```

**修改 3**: MapViewOfFileFromApp → MapViewOfFile (第 1499 行)
```cpp
// BEFORE (Windows 8+):
addr_ = ::MapViewOfFileFromApp(hMapping_, FILE_MAP_READ, 0, 0);

// AFTER (Windows 7 兼容):
addr_ = ::MapViewOfFile(hMapping_, FILE_MAP_READ, 0, 0, 0);
```

---

### 4. tools/server/server-http.cpp
**路径**: `tools/server/server-http.cpp`  
**行号**: ~307-326

**修改**: 添加 Windows 7 检测
```cpp
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

---

### 5. CMakeLists.txt (根目录)
**路径**: `CMakeLists.txt`  
**行号**: ~64-73

**修改**: 添加 Windows 7 兼容选项
```cmake
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

---

### 6. vendor/cpp-httplib/CMakeLists.txt
**路径**: `vendor/cpp-httplib/CMakeLists.txt`  
**行号**: 在 `target_compile_features` 之后

**修改**: 传递 Windows 7 宏定义
```cmake
target_compile_features(${TARGET} PRIVATE cxx_std_17)

# Windows 7 compatibility
if (WIN32 AND LLAMA_WIN7_COMPAT)
    target_compile_definitions(${TARGET} PRIVATE _WIN32_WINNT=0x0601 WINVER=0x0601)
endif()
```

---

### 7. ggml/CMakeLists.txt
**路径**: `ggml/CMakeLists.txt`  
**行号**: ~79-90

**修改**: 添加 Windows 7 支持
```cmake
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

---

## 编译步骤

### 步骤 1: 安装工具链

**CMake** (必须是 3.19.x，Windows 7 不支持 4.x):
```
https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi
```

**MinGW-w64**:
```
# 通过 MSYS2
pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-make

# 或下载独立版本
https://winlibs.com/
```

### 步骤 2: 应用 8 个文件的修改

参考上面的"需要修改的 8 个文件"部分。

### 步骤 3: 配置 CMake

```batch
mkdir build_win7
cd build_win7

cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x0601 -static" ^
    -DCMAKE_CXX_FLAGS="-D_WIN32_WINNT=0x0601 -static-libgcc -static-libstdc++ -static" ^
    -DCMAKE_EXE_LINKER_FLAGS="-static" ^
    -DLLAMA_WIN7_COMPAT=ON ^
    -DLLAMA_NATIVE=OFF ^
    -DLLAMA_BUILD_TESTS=OFF ^
    -DLLAMA_BUILD_EXAMPLES=OFF ^
    -DLLAMA_BUILD_TOOLS=ON ^
    -DLLAMA_BUILD_SERVER=ON ^
    -DLLAMA_AVX=ON ^
    -DLLAMA_AVX2=ON ^
    -DLLAMA_FMA=ON ^
    -DLLAMA_F16C=ON ^
    -DLLAMA_OPENSSL=OFF ^
    -DBUILD_SHARED_LIBS=OFF
```

### 步骤 4: 编译

```batch
mingw32-make -j4
```

### 步骤 5: 复制必要 DLL

```batch
copy "C:\msys64\ucrt64\bin\libgomp-1.dll" bin\
```

### 步骤 6: 验证

```batch
objdump -p bin\llama-server.exe | findstr "DLL Name"
```

应该只显示系统 DLL，没有 libstdc++-6.dll 等。

---

## 常见错误及解决方案

### 错误 1: CMake 无法运行
```
无法定位程序输入点 GetSystemTimePreciseAsFileTime 于动态链接库 KERNEL32.dll
```
**原因**: CMake 版本太新（4.x+）  
**解决**: 安装 CMake 3.19.8

### 错误 2: CreateFile2 未声明
```
'::CreateFile2' has not been declared
```
**原因**: 使用了 Windows 8+ API  
**解决**: 替换为 CreateFileW（见文件 3 修改 1）

### 错误 3: CreateFileMappingFromApp 未找到
```
无法定位程序输入点 CreateFileMappingFromApp 于动态链接库 KERNEL32.dll
```
**原因**: Windows 8+ API  
**解决**: 替换为 CreateFileMapping（见文件 3 修改 2）

### 错误 4: cpp-httplib 版本错误
```
cpp-httplib doesn't support Windows 8 or lower
```
**原因**: vendor/cpp-httplib/httplib.h 中的版本检查  
**解决**: 注释掉 #error 行（见文件 2）

### 错误 5: afunix.h 未找到
```
afunix.h: No such file or directory
```
**原因**: Windows 7 没有这个头文件  
**解决**: 条件编译（见文件 1 修改 1）

---

## 快速复用检查清单

### 代码更新后，检查这些修改是否还在：

- [ ] 根目录 httplib.h 有 _WIN32_WINNT 定义
- [ ] vendor/cpp-httplib/httplib.h 的版本检查被注释
- [ ] vendor/cpp-httplib/httplib.cpp 的 3 处 API 已替换
- [ ] server-http.cpp 有 Windows 7 检测
- [ ] CMakeLists.txt 有 LLAMA_WIN7_COMPAT 选项

### 一键检查脚本

```batch
@echo off
echo Checking Windows 7 patches...

findstr /C:"_WIN32_WINNT >= 0x0602" httplib.h >nul && echo [OK] httplib.h patched || echo [FAIL] httplib.h

findstr /C:"cpp-httplib doesn't support" vendor\cpp-httplib\httplib.h | findstr /C:"//" >nul && echo [OK] vendor httplib.h patched || echo [FAIL] vendor httplib.h

findstr /C:"CreateFileW" vendor\cpp-httplib\httplib.cpp >nul && echo [OK] CreateFile2 replaced || echo [FAIL] CreateFile2

findstr /C:"CreateFileMapping" vendor\cpp-httplib\httplib.cpp | findstr /V "FromApp" >nul && echo [OK] CreateFileMappingFromApp replaced || echo [FAIL] CreateFileMappingFromApp

findstr /C:"Windows 7" tools\server\server-http.cpp >nul && echo [OK] server-http.cpp patched || echo [FAIL] server-http.cpp

findstr /C:"LLAMA_WIN7_COMPAT" CMakeLists.txt >nul && echo [OK] CMakeLists.txt patched || echo [FAIL] CMakeLists.txt

echo Done.
```

---

## Windows 7 API 替换对照表

| Windows 8+ API | Windows 7 替代 | 文件位置 |
|---------------|---------------|----------|
| CreateFile2 | CreateFileW | vendor/cpp-httplib/httplib.cpp:1467 |
| CreateFileMappingFromApp | CreateFileMapping | vendor/cpp-httplib/httplib.cpp:1485 |
| MapViewOfFileFromApp | MapViewOfFile | vendor/cpp-httplib/httplib.cpp:1499 |
| GetSystemTimePreciseAsFileTime | (CMake 内部) | 降级 CMake 到 3.19.x |

---

## 部署包内容

部署到 Windows 7 的最小文件集：

```
llama-server.exe      (24 MB)  - 主程序
libgomp-1.dll         (322 KB) - OpenMP 库
run_windows7.bat      (1 KB)   - 启动脚本
model.gguf            (模型文件)
```

**注意**: libstdc++-6.dll, libgcc_s_seh-1.dll, libwinpthread-1.dll 已静态链接，不需要。

---

## 使用提示词快速复用

### 标准提示词

```
请帮我编译 llama.cpp Windows 7 版本：

1. 检查以下 8 个文件的补丁是否完整：
   - httplib.h (根目录)
   - vendor/cpp-httplib/httplib.h
   - vendor/cpp-httplib/httplib.cpp (3 处 API 替换)
   - tools/server/server-http.cpp
   - CMakeLists.txt (根目录)
   - vendor/cpp-httplib/CMakeLists.txt
   - ggml/CMakeLists.txt

2. 确保使用 CMake 3.19.x（不是 4.x）

3. 使用以下配置编译：
   - API: 0x0601
   - Native: OFF
   - 静态链接: -static-libgcc -static-libstdc++

4. 复制 libgomp-1.dll 到输出目录

5. 验证无 DLL 依赖后打包

参考: CLAUDE_SKILL.md 和 WINDOWS7_COMPLETE_GUIDE.md
```

---

## 总结

Windows 7 编译 llama.cpp 的核心是：**修改 vendor/cpp-httplib/httplib.cpp 中的 3 个 Windows API 调用**。

最难发现的问题是 `CreateFileMappingFromApp` 运行时错误，因为它在编译时不会报错，只有在 Windows 7 上运行时才会出现。

**关键成功因素**:
1. ✅ 替换所有 Windows 8+ API
2. ✅ 使用 CMake 3.19.x
3. ✅ 完全静态链接
4. ✅ 充分测试（在 Windows 7 上实际运行）

---

**文档位置**: `CLAUDE_SKILL.md`  
**编译版本**: `build_win7_fixed/`  
**状态**: ✅ Windows 7 SP1 验证通过
