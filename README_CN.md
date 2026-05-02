# llama.cpp Windows 7 兼容版

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows 7+](https://img.shields.io/badge/platform-Windows%207%2B-blue)](https://www.microsoft.com/windows/windows-7)
[![Build: MinGW](https://img.shields.io/badge/build-MinGW-green)](https://www.mingw-w64.org/)

> **这是 [llama.cpp](https://github.com/ggml-org/llama.cpp) 的 Windows 7 兼容分支**

让 llama.cpp 在 Windows 7 SP1 及更高版本上运行，同时保持对 Windows 10/11 的完全兼容。

## 与原版有什么不同？

| 功能 | 原版 llama.cpp | 此分支 |
|------|---------------|--------|
| Windows 7 支持 | ❌ 不支持 | ✅ 支持 |
| Windows 10/11 支持 | ✅ 支持 | ✅ 支持 |
| Unix 域套接字 | ✅ 支持 (Win10 1803+) | ❌ Win7 仅支持 TCP/IP |
| CreateFile2 API | ✅ Windows 8+ | ✅ Windows 7 兼容 |
| 性能 | 基准 | Win10/11 上相同 |

## 快速开始

### 前置要求

- Windows 7 SP1 或更高版本（也支持 Windows 10/11）
- [CMake 3.19.x](https://cmake.org/files/v3.19/)（3.19.8 是支持 Windows 7 的最后一个版本）
- [MinGW-w64 GCC](https://www.msys2.org/) 或 Visual Studio 2019

### 构建

```batch
:: 克隆仓库
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7

:: 运行构建脚本
build_win7_final.bat
```

或手动构建：

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

### 使用

```batch
:: 启动服务器
llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080

:: 或使用 CLI
llama-cli.exe -m model.gguf
```

**注意**：在 Windows 7 上，始终使用 TCP/IP (`--host 127.0.0.1`)，不要使用 Unix 域套接字。

## 技术细节

### 修改的文件

此分支对 8 个文件进行了最小化修改：

1. **httplib.h** (根目录) - 条件性包含 afunix.h
2. **vendor/cpp-httplib/httplib.h** - 移除 Windows 10 要求
3. **vendor/cpp-httplib/httplib.cpp** - 替换 Windows 8+ API：
   - `CreateFile2` → `CreateFileW`
   - `CreateFileMappingFromApp` → `CreateFileMapping`
   - `MapViewOfFileFromApp` → `MapViewOfFile`
4. **tools/server/server-http.cpp** - 添加 Windows 7 运行时检查
5. **CMakeLists.txt** (根目录) - 添加 `LLAMA_WIN7_COMPAT` 选项
6. **vendor/cpp-httplib/CMakeLists.txt** - 传递 Win7 标志
7. **ggml/CMakeLists.txt** - 传递 Win7 标志

详见 [patches/](patches/) 目录。

### API 替换

| Windows 8+ API | Windows 7 兼容替代 |
|---------------|-------------------|
| `CreateFile2` | `CreateFileW` |
| `CreateFileMappingFromApp` | `CreateFileMapping` |
| `MapViewOfFileFromApp` | `MapViewOfFile` |
| `GetSystemTimePreciseAsFileTime` | `GetSystemTimeAsFileTime` (CMake 内部) |

### 静态链接

此分支使用完全静态链接消除 DLL 依赖：

- ✅ `libstdc++-6.dll` → 静态链接
- ✅ `libgcc_s_seh-1.dll` → 静态链接
- ✅ `libwinpthread-1.dll` → 静态链接
- ⚠️ `libgomp-1.dll` → 仍需要 (OpenMP)

## 文档

- [完整构建指南](docs/WINDOWS7_BUILD_GUIDE.md) - 详细的分步说明
- [API 变更](docs/WINDOWS7_API_CHANGES.md) - API 替换的技术细节
- [故障排除](docs/WINDOWS7_TROUBLESHOOTING.md) - 常见错误和解决方案
- [原版 README](README_ORIGINAL.md) - 上游 llama.cpp 文档

## 验证

验证构建是否正确静态链接：

```batch
objdump -p llama-server.exe | findstr "DLL Name"
```

预期输出应只显示系统 DLL：
- `KERNEL32.dll`
- `ADVAPI32.dll`
- `WS2_32.dll`
- `api-ms-win-crt-*.dll` (Universal CRT)

**不应出现**：`libstdc++-6.dll`、`libgcc_s_seh-1.dll`、`libwinpthread-1.dll`

## 限制

- Windows 7 不支持 Unix 域套接字 (AF_UNIX)
- 某些高级网络功能需要 Windows 8+
- Windows 7 不支持 CMake 4.x（请使用 3.19.x）

## 鸣谢

- 原版 [llama.cpp](https://github.com/ggml-org/llama.cpp) 由 ggml-org 开发
- [cpp-httplib](https://github.com/yhirose/cpp-httplib) 由 yhirose 开发

## 许可证

此分支保持与原版 llama.cpp 项目相同的 [MIT 许可证](LICENSE)。

---

**注意**：这是一个非官方分支。官方 llama.cpp 项目请访问 https://github.com/ggml-org/llama.cpp
