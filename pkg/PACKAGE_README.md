# Windows 7 编译工具包 - 完整使用指南

## 工具包内容

```
pkg/
├── tools/                           [编译工具 - 已就绪]
│   ├── cmake-3.19.8/               [CMake 3.19.8 - Windows 7 兼容]
│   └── mingw-w64/                  [MinGW-w64 GCC 16.0.0 - 含 libgomp-1.dll]
│
├── downloads/                     [下载缓存]
│   └── cmake-3.19.8-win64-x64.zip
│
├── README.md                      [完整使用指南]
├── QUICKSTART.md                  [5分钟快速开始]
├── DOWNLOAD_LIST.md             [下载地址清单]
├── DOWNLOAD_MANUAL.md           [手动下载指南]
├── DEPENDENCIES.md              [系统依赖说明]
├── win7_patch_guide.md          [8个文件补丁指南]
│
├── download_tools.bat           [自动下载脚本]
├── check_patches.bat            [补丁检查脚本]
└── build_llama_win7.bat         [一键编译脚本]
```

**总大小**: 约 1GB (含 MinGW 完整工具链)

---

## 快速使用 (3 步)

### 第 1 步: 设置环境变量
在项目根目录，双击运行:
```
setup_env.bat
```

或手动设置:
```batch
set PATH=%CD%\pkg\tools\cmake-3.19.8\cmake-3.19.8-win64-x64\bin;%CD%\pkg\tools\mingw-w64\bin;%PATH%
```

### 第 2 步: 检查源代码补丁
```batch
copy pkg\check_patches.bat .\
check_patches.bat
```

如果显示 `[PASS]`，继续步骤 3。  
如果显示 `[FAIL]`，参考 `win7_patch_guide.md` 应用 8 个文件补丁。

### 第 3 步: 一键编译
```batch
copy pkg\build_llama_win7.bat .\
build_llama_win7.bat
```

编译完成后，输出在 `build_win7_oneclick/bin/` 目录。

---

## 编译结果

编译成功后，你会得到:

```
build_win7_oneclick/bin/
├── llama-server.exe          (24MB)  - 主程序
├── llama-cli.exe             (主程序)
├── libgomp-1.dll             (322KB) - OpenMP 运行时 (唯一需要的 DLL)
└── run_server.bat            (自动生成的启动脚本)
```

### 部署到 Windows 7

复制以下文件到 Windows 7 电脑:
- `llama-server.exe`
- `libgomp-1.dll`
- `run_server.bat` (编辑设置模型路径)
- `model.gguf` (你的模型文件)

---

## 工具验证

运行以下命令验证工具:

```batch
:: CMake
cmake --version
:: 输出: cmake version 3.19.8

// GCC
gcc --version
// 输出: gcc.exe (MinGW-W64 ...) 16.0.0

// Make
mingw32-make --version
```

---

## 注意事项

### CMake 版本警告
**必须使用 CMake 3.19.8！**

CMake 4.x 使用了 Windows 8+ API (`GetSystemTimePreciseAsFileTime`)，在 Windows 7 上无法运行。

### MinGW 版本
当前工具包含 GCC 16.0.0 (实验版)，已验证兼容 Windows 7 + UCRT。

### UCRT vs MSVCRT
- 此工具包使用 UCRT 版本
- Windows 7 需要安装 KB2999226 (见 DEPENDENCIES.md)
- 如果无法安装补丁，需下载 MSVCRT 版本的 MinGW

---

## 完整编译命令

如果不想使用一键脚本，可以手动编译:

```batch
:: 1. 创建构建目录
mkdir build_win7_manual
cd build_win7_manual

// 2. 配置 CMake (注意路径调整)
cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_COMPILER="%CD%\..\pkg\tools\mingw-w64\bin\gcc.exe" ^
    -DCMAKE_CXX_COMPILER="%CD%\..\pkg\tools\mingw-w64\bin\g++.exe" ^
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

// 3. 编译
mingw32-make -j4

// 4. 复制 DLL
copy ..\pkg\tools\mingw-w64\bin\libgomp-1.dll bin\
```

---

## 故障排除

### 问题 1: "无法定位程序输入点 GetSystemTimePreciseAsFileTime"
**原因**: 使用了 CMake 4.x  
**解决**: 使用 pkg/tools/cmake-3.19.8 中的 CMake 3.19.8

### 问题 2: "CreateFile2 has not been declared"
**原因**: 未应用源代码补丁  
**解决**: 运行 check_patches.bat 检查，应用 win7_patch_guide.md 中的补丁

### 问题 3: "CreateFileMappingFromApp not found" (运行时)
**原因**: 未替换 Windows 8+ API  
**解决**: 修改 vendor/cpp-httplib/httplib.cpp，替换为 CreateFileMapping

### 问题 4: 编译很慢
**原因**: MinGW 单线程性能较弱  
**解决**: 使用 `-j%NUMBER_OF_PROCESSORS%` 启用多核，或关闭杀毒软件

### 问题 5: Windows 7 运行提示缺少 api-ms-win-crt-runtime-l1-1-0.dll
**原因**: 缺少 UCRT (Universal C Runtime)  
**解决**: 安装 KB2999226，或使用 MSVCRT 版本的 MinGW

---

## 文档索引

| 文档 | 用途 |
|------|------|
| QUICKSTART.md | 5分钟快速开始 |
| README.md | 完整安装使用指南 |
| win7_patch_guide.md | 8个文件补丁详细步骤 |
| DEPENDENCIES.md | Windows 7 系统依赖 |
| DOWNLOAD_MANUAL.md | 手动下载指南 |
| CLAUDE_SKILL.md (根目录) | 技能摘要 |
| WINDOWS7_SKILL_COMPLETE.md (根目录) | 完整技能手册 |

---

## 版本信息

- **创建日期**: 2026-05-02
- **CMake**: 3.19.8 (Windows 7 兼容)
- **GCC**: 16.0.0 (MinGW-w64)
- **适用项目**: llama.cpp master (2026-04-30)
- **适用系统**: Windows 7 SP1+, Windows 10/11

---

**开始使用**: 运行 `setup_env.bat`，然后 `check_patches.bat`，最后 `build_llama_win7.bat`
