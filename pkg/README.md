# Windows 7 编译工具包 - 完整安装使用指南

## 工具包内容

```
pkg/
├── README.md                      (本文件)
├── DOWNLOAD_LIST.md               (下载清单)
├── download_tools.bat             (自动下载脚本)
├── build_llama_win7.bat           (一键编译脚本)
├── check_patches.bat              (补丁检查脚本)
├── tools/                         (工具安装目录)
│   ├── cmake-3.19.8/             (CMake)
│   └── mingw-w64/                (MinGW-w64 GCC)
├── downloads/                     (下载缓存)
└── win7_patch_guide.md            (补丁应用指南)
```

---

## 快速开始 (3 步)

### 第 1 步: 下载工具
```batch
:: 方法一: 自动下载 (推荐)
cd pkg
双击运行: download_tools.bat

// 方法二: 手动下载
1. 下载 CMake 3.19.8: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.zip
2. 下载 MinGW-w64: https://winlibs.com/ (选择 x86_64-posix-seh GCC 13.2.0)
3. 解压到 pkg/tools/ 目录
```

### 第 2 步: 应用 Windows 7 补丁
在编译前，必须确保源代码已打补丁。运行检查脚本：
```batch
cd pkg
双击运行: check_patches.bat
```

如果补丁不完整，请参考 `win7_patch_guide.md` 手动应用。

### 第 3 步: 一键编译
```batch
:: 将 pkg\build_llama_win7.bat 复制到项目根目录
copy pkg\build_llama_win7.bat .

// 运行编译
双击运行: build_llama_win7.bat
```

编译完成后，输出在 `build_win7_oneclick/bin/` 目录。

---

## 详细安装步骤

### 1. 系统要求

**操作系统**: Windows 7 SP1 (Service Pack 1) 或更高版本
**内存**: 至少 4GB RAM (推荐 8GB)
**磁盘空间**: 
- 工具包: 约 350MB
- 编译中间文件: 约 2GB
- 最终输出: 约 50MB

**必需补丁** (如果使用 UCRT 版本 MinGW):
- KB2999226 - Universal C Runtime in Windows

### 2. 安装 CMake 3.19.8

#### 方法一: 使用下载脚本
```batch
cd pkg
download_tools.bat
```
脚本会自动下载并解压到 `pkg/tools/cmake-3.19.8/`。

#### 方法二: 手动安装
1. 浏览器访问: https://cmake.org/files/v3.19/
2. 下载: `cmake-3.19.8-win64-x64.msi` 或 `.zip`
3. 运行安装程序，或解压到 `C:\Program Files\CMake\`

**验证安装**:
```batch
C:\Program Files\CMake\bin\cmake.exe --version
:: 输出: cmake version 3.19.8
```

### 3. 安装 MinGW-w64

#### 方法一: 使用下载脚本
```batch
cd pkg
download_tools.bat
```

#### 方法二: 手动安装
1. 访问: https://winlibs.com/
2. 下载: `winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip`
3. 解压到 `C:\mingw-w64\` 或 `pkg/tools/mingw-w64/`

**重要**: 选择 **UCRT** 或 **MSVCRT** 版本
- UCRT: 需要 Windows 7 SP1 + KB2999226，性能更好
- MSVCRT: 更兼容旧版 Windows 7，无需额外补丁

**验证安装**:
```batch
C:\mingw-w64\bin\gcc.exe --version
:: 输出: gcc.exe (MinGW-W64 x86_64...) 13.2.0
```

### 4. 配置环境变量

#### 临时配置 (推荐，不影响系统)
创建 `setup_env.bat`:
```batch
@echo off
set "CMAKE_PATH=C:\Program Files\CMake\bin"
set "MINGW_PATH=C:\mingw-w64\bin"
set "PATH=%CMAKE_PATH%;%MINGW_PATH%;%PATH%"
echo 环境已设置
cmake --version
gcc --version
```

运行:
```batch
setup_env.bat
```

#### 永久配置 (系统环境变量)
1. 右键"计算机" -> 属性 -> 高级系统设置
2. 环境变量 -> 系统变量 -> Path
3. 添加:
   - `C:\Program Files\CMake\bin`
   - `C:\mingw-w64\bin`

---

## 编译操作步骤

### 准备工作

1. **获取 llama.cpp 源代码**
   ```batch
   git clone https://github.com/ggerganov/llama.cpp.git
   cd llama.cpp
   ```

2. **应用 Windows 7 补丁**
   - 必须修改 8 个文件（详见 win7_patch_guide.md）
   - 或运行自动补丁脚本

3. **准备编译脚本**
   ```batch
   xcopy pkg\build_llama_win7.bat .\ /Y
   ```

### 开始编译

```batch
build_llama_win7.bat
```

脚本会自动:
1. 检查工具版本
2. 创建构建目录 `build_win7_oneclick`
3. 配置 CMake (带 Windows 7 参数)
4. 编译 (使用所有 CPU 核心)
5. 复制必要 DLL
6. 创建启动脚本

### 编译选项说明

| 选项 | 值 | 说明 |
|------|-----|------|
| `-DCMAKE_BUILD_TYPE` | Release | 发布模式，优化性能 |
| `-DLLAMA_WIN7_COMPAT` | ON | 启用 Windows 7 兼容模式 |
| `-DLLAMA_NATIVE` | OFF | 禁用 CPU 原生优化，提高兼容性 |
| `-DLLAMA_AVX/AVX2` | ON | 启用 SIMD 指令集加速 |
| `-DCMAKE_CXX_FLAGS` | -static-libgcc... | 静态链接，消除 DLL 依赖 |

### 编译后验证

```batch
cd build_win7_oneclick\bin

:: 检查可执行文件
llama-server.exe --version

// 检查 DLL 依赖 (应只显示系统 DLL)
objdump -p llama-server.exe | findstr "DLL Name"

// 期望输出:
// DLL Name: KERNEL32.dll
// DLL Name: ADVAPI32.dll
// DLL Name: WS2_32.dll
// (不应有 libstdc++-6.dll, libgcc_s_seh-1.dll)
```

---

## 常见问题

### Q1: CMake 报错 "无法定位程序输入点 GetSystemTimePreciseAsFileTime"
**原因**: 使用了 CMake 4.x，需要 Windows 8+
**解决**: 安装 CMake 3.19.8

### Q2: 编译时报错 "CreateFile2 has not been declared"
**原因**: 未定义 Windows API 版本
**解决**: 确保使用 `-D_WIN32_WINNT=0x0601` 编译标志

### Q3: 运行时报错 "CreateFileMappingFromApp not found"
**原因**: 使用了 Windows 8+ API
**解决**: 应用 vendor/cpp-httplib/httplib.cpp 补丁（替换为 CreateFileMapping）

### Q4: Windows 7 无法运行，提示缺少 api-ms-win-crt-runtime-l1-1-0.dll
**原因**: 缺少 UCRT (Universal C Runtime)
**解决**: 
- 方法一: 安装 Windows Update KB2999226
- 方法二: 使用 MSVCRT 版本的 MinGW

### Q5: 编译很慢
**原因**: MinGW 单线程性能较弱
**解决**: 
- 使用 `-j%NUMBER_OF_PROCESSORS%` 启用多核编译
- 关闭杀毒软件实时扫描
- 使用 SSD

---

## Windows 7 补丁清单

编译前必须确保以下修改已完成：

| 文件 | 修改 | 行号 |
|------|------|------|
| httplib.h (根目录) | 添加 _WIN32_WINNT=0x0601 | ~191 |
| httplib.h | 条件编译 afunix.h | ~43 |
| vendor/cpp-httplib/httplib.h | 注释版本检查 | ~14 |
| vendor/cpp-httplib/httplib.cpp | CreateFile2 → CreateFileW | ~1467 |
| vendor/cpp-httplib/httplib.cpp | CreateFileMappingFromApp → CreateFileMapping | ~1485 |
| vendor/cpp-httplib/httplib.cpp | MapViewOfFileFromApp → MapViewOfFile | ~1499 |
| tools/server/server-http.cpp | Windows 7 检测 | ~307 |
| CMakeLists.txt | 添加 LLAMA_WIN7_COMPAT | ~64 |

详细补丁步骤见 `win7_patch_guide.md`。

---

## 部署到 Windows 7

### 最小部署包
```
deployment/
├── llama-server.exe      (24 MB)
├── libgomp-1.dll         (322 KB)
├── run_server.bat        (启动脚本)
└── model.gguf            (模型文件)
```

### 使用方法
1. 复制 `build_win7_oneclick/bin/` 到 Windows 7 电脑
2. 修改 `run_server.bat` 中的模型路径
3. 双击运行

---

## 相关文档

- `DOWNLOAD_LIST.md` - 下载地址清单
- `win7_patch_guide.md` - 补丁应用详细指南
- `check_patches.bat` - 补丁检查脚本
- `WINDOWS7_SKILL_COMPLETE.md` (项目根目录) - 完整技能手册

---

**版本**: 1.0  
**更新日期**: 2026-05-01  
**适用**: llama.cpp master (2026-04-30)
