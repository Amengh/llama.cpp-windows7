# Windows 7 补丁应用指南

本文档详细说明如何修改 llama.cpp 源代码以支持 Windows 7 编译。

## 快速检查

运行 `check_patches.bat` 快速检查补丁状态。

## 8 个文件修改清单

### 1. httplib.h (根目录)

**文件**: `httplib.h`
**行号**: ~191

**修改内容**:
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

**AF_UNIX 条件编译** (行号 ~3541):
```cpp
// BEFORE:
if (hints.ai_family == AF_UNIX) {
    // ... Unix domain socket code
}

// AFTER:
#if _WIN32_WINNT >= 0x0602 || !defined(_WIN32)
  if (hints.ai_family == AF_UNIX) {
      // ... Unix domain socket code
  }
#endif
```

---

### 2. vendor/cpp-httplib/httplib.h

**文件**: `vendor/cpp-httplib/httplib.h`
**行号**: ~14-19

**修改**: 注释掉 Windows 10 强制要求

```cpp
// BEFORE:
#ifdef _WIN32
#if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
#error                                                                         \
    "cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later."
#endif
#endif

// AFTER:
#ifdef _WIN32
// Windows 7 compatibility: Comment out version check
// #if defined(_WIN32_WINNT) && _WIN32_WINNT < 0x0A00
// #error                                                                         \
//     "cpp-httplib doesn't support Windows 8 or lower. Please use Windows 10 or later."
// #endif
#endif
```

---

### 3. vendor/cpp-httplib/httplib.cpp ⭐ 关键文件

**文件**: `vendor/cpp-httplib/httplib.cpp`

**修改 1**: CreateFile2 → CreateFileW (第 ~1467 行)
```cpp
// BEFORE (Windows 8+):
hFile_ = ::CreateFile2(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       OPEN_EXISTING, NULL);

// AFTER (Windows 7 兼容):
hFile_ = ::CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ,
                       nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
```

**修改 2**: CreateFileMappingFromApp → CreateFileMapping (第 ~1485 行)
```cpp
// BEFORE (Windows 8+):
hMapping_ = ::CreateFileMappingFromApp(hFile_, NULL, PAGE_READONLY, size_, NULL);

// AFTER (Windows 7 兼容):
hMapping_ = ::CreateFileMapping(hFile_, NULL, PAGE_READONLY, 0, size_, NULL);
```

**修改 3**: MapViewOfFileFromApp → MapViewOfFile (第 ~1499 行)
```cpp
// BEFORE (Windows 8+):
addr_ = ::MapViewOfFileFromApp(hMapping_, FILE_MAP_READ, 0, 0);

// AFTER (Windows 7 兼容):
addr_ = ::MapViewOfFile(hMapping_, FILE_MAP_READ, 0, 0, 0);
```

---

### 4. tools/server/server-http.cpp

**文件**: `tools/server/server-http.cpp`
**行号**: ~307-326

**修改**: 添加 Windows 7 检测
```cpp
// BEFORE:
if (string_ends_with(std::string(hostname), ".sock")) {
    is_sock = true;
    srv->set_address_family(AF_UNIX);
    was_bound = srv->bind_to_port(hostname, 8080);
}

// AFTER:
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

**文件**: `CMakeLists.txt`
**行号**: ~64-73 (在 WIN32 检查之后)

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

**文件**: `vendor/cpp-httplib/CMakeLists.txt`
**位置**: 在 `target_compile_features` 之后

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

**文件**: `ggml/CMakeLists.txt`
**行号**: ~79-90 (在 WIN32 部分)

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

## 一键应用补丁脚本

创建 `apply_patches.bat`:

```batch
@echo off
echo Applying Windows 7 patches...

:: 文件 1: httplib.h
echo Patching httplib.h...
:: 手动编辑，或使用 sed/awk 工具

:: 文件 2: vendor/cpp-httplib/httplib.h
echo Patching vendor/cpp-httplib/httplib.h...

:: 文件 3: vendor/cpp-httplib/httplib.cpp
echo Patching vendor/cpp-httplib/httplib.cpp...

echo Done.
pause
```

**注意**: 由于 patch 语法复杂，建议手动修改或使用项目根目录的现成修改版本。

---

## 补丁验证

修改完成后，运行：
```batch
check_patches.bat
```

所有检查项应显示 `[OK]`。

---

## API 替换对照表

| Windows 8+ API | Windows 7 替代 | 文件位置 |
|---------------|---------------|----------|
| CreateFile2 | CreateFileW | vendor/cpp-httplib/httplib.cpp:~1467 |
| CreateFileMappingFromApp | CreateFileMapping | vendor/cpp-httplib/httplib.cpp:~1485 |
| MapViewOfFileFromApp | MapViewOfFile | vendor/cpp-httplib/httplib.cpp:~1499 |
| AF_UNIX | TCP/IP | tools/server/server-http.cpp |

---

## 常见编译错误

### 错误: CreateFile2 has not been declared
**解决**: 应用修改 3-1 (CreateFile2 → CreateFileW)

### 错误: CreateFileMappingFromApp not found (运行时)
**解决**: 应用修改 3-2 和 3-3

### 错误: afunix.h: No such file or directory
**解决**: 应用修改 1 (条件编译 afunix.h)

### 错误: cpp-httplib doesn't support Windows 8 or lower
**解决**: 应用修改 2 (注释版本检查)

---

## 参考文档

- `WINDOWS7_SKILL_COMPLETE.md` (项目根目录) - 完整技能手册
- `CLAUDE_SKILL.md` (项目根目录) - 技能摘要
- `check_patches.bat` - 补丁检查脚本
