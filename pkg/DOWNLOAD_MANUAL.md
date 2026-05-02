# Windows 7 编译工具包 - 下载说明

## 自动下载失败时的手动下载指南

由于网络原因，自动下载可能失败。请按以下步骤手动下载工具。

---

## 工具清单

### 1. CMake 3.19.8 (必需)
- **官方下载地址**: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.zip
- **备用 MSI 安装版**: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi
- **文件大小**: 约 24 MB
- **SHA256**: `228520d3a0befe900d765fd0f5107a2e1b27a9e5ec46f633b825b6b42cc8d55c`

**下载步骤**:
1. 浏览器访问: https://cmake.org/files/v3.19/
2. 找到 `cmake-3.19.8-win64-x64.zip`
3. 点击下载
4. 保存到: `pkg/downloads/cmake-3.19.8-win64-x64.zip`

**解压步骤**:
```batch
:: 使用 PowerShell
powershell -Command "Expand-Archive -Path 'downloads\cmake-3.19.8-win64-x64.zip' -DestinationPath 'tools\cmake-3.19.8'"

// 或使用 7-Zip
7z x downloads\cmake-3.19.8-win64-x64.zip -otools\cmake-3.19.8\
```

---

### 2. MinGW-w64 GCC 13.2.0 (必需)
- **官方下载地址**: https://github.com/brechtsanders/winlibs_mingw/releases/
- **推荐文件**: `winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip`
- **文件大小**: 约 300 MB
- **备用 MSVCRT 版本** (无需 KB2999226): `winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64msvcrt-11.0.1-r4.zip`

**下载步骤**:
1. 浏览器访问: https://winlibs.com/
2. 找到 "GCC 13.2.0 (with LLVM/Clang)" 版本
3. 下载 "Win64 zip archive with POSIX threads and SEH exception handling"
4. 选择 **UCRT** 或 **MSVCRT** 版本:
   - UCRT: 性能更好，需要 KB2999226
   - MSVCRT: 兼容更好，无需额外补丁
5. 保存到: `pkg/downloads/winlibs-x86_64-....zip`

**直接下载链接**:
```
https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0posix-17.0.4-11.0.1-ucrt-r4/winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip
```

**解压步骤**:
```batch
:: 使用 PowerShell (可能需要几分钟)
powershell -Command "Expand-Archive -Path 'downloads\winlibs-*.zip' -DestinationPath 'tools\mingw-w64'"

// 或使用 7-Zip (更快)
7z x downloads\winlibs-*.zip -otools\mingw-w64\
```

---

### 3. Windows 7 补丁 KB2999226 (如使用 UCRT)
- **下载地址**: https://www.microsoft.com/en-us/download/details.aspx?id=49077
- **文件名**: `Windows6.1-KB2999226-x64.msu` (64位)
- **文件大小**: 约 1 MB

**下载步骤**:
1. 访问 Microsoft Update Catalog
2. 搜索 "KB2999226"
3. 选择 Windows 7 版本 (x64 或 x86)
4. 下载并安装

---

## 目录结构要求

下载并解压后，目录结构应为:

```
pkg/
├── downloads/                           [下载缓存目录]
│   ├── cmake-3.19.8-win64-x64.zip
│   └── winlibs-x86_64-posix-seh-...zip
│
├── tools/                               [工具安装目录]
│   ├── cmake-3.19.8/
│   │   └── cmake-3.19.8-win64-x64/
│   │       └── bin/
│   │           └── cmake.exe           [必需]
│   │
│   └── mingw-w64/
│       └── mingw64/
│           └── bin/
│               ├── gcc.exe             [必需]
│               ├── g++.exe             [必需]
│               ├── mingw32-make.exe    [必需]
│               └── libgomp-1.dll       [运行时必需]
│
└── ... (脚本和文档)
```

---

## 验证安装

下载并解压后，运行以下命令验证:

```batch
:: 验证 CMake
pkg\tools\cmake-3.19.8\cmake-3.19.8-win64-x64\bin\cmake.exe --version
:: 应输出: cmake version 3.19.8

// 验证 GCC
pkg\tools\mingw-w64\mingw64\bin\gcc.exe --version
:: 应输出: gcc.exe (MinGW-W64 ...) 13.2.0

// 验证 Make
pkg\tools\mingw-w64\mingw64\bin\mingw32-make.exe --version
```

---

## 使用现有系统工具

如果你已经在系统中安装了 CMake 3.19.8 和 MinGW-w64，可以直接使用:

1. **编辑环境变量脚本** `pkg\set_local_paths.bat`:
```batch
@echo off
:: 使用系统已安装的工具
set "CMAKE_PATH=C:\Program Files\CMake\bin"
set "MINGW_PATH=C:\mingw-w64\bin"
set "PATH=%CMAKE_PATH%;%MINGW_PATH%;%PATH%"
```

2. **修改编译脚本** `build_llama_win7.bat`:
   - 删除自动检测工具路径的代码
   - 或者直接设置环境变量后运行

---

## 离线安装包制作

如果你在一台电脑下载成功，可以制作离线安装包:

```batch
:: 打包工具目录
cd pkg
tools\mingw-w64\mingw64\bin\7z.exe a -r tools_package.7z tools\

// 分发时解压即可使用
```

---

## 下载镜像 (国内加速)

如果官方下载慢，可以使用镜像:

### CMake 镜像
- 清华大学: https://mirrors.tuna.tsinghua.edu.cn/cmake/files/v3.19/
- 阿里云: https://mirrors.aliyun.com/cmake/files/v3.19/

### MinGW-w64 镜像
- 清华大学: https://mirrors.tuna.tsinghua.edu.cn/github-release/brechtsanders/winlibs_mingw/

---

## 常见问题

### Q: 下载速度很慢
A: 使用下载工具 (IDM, 迅雷) 或更换镜像源

### Q: 文件下载不完整
A: 验证 SHA256 校验和，重新下载

### Q: 解压失败
A: 确保使用最新版 7-Zip 或 PowerShell 5.0+

---

**最后更新**: 2026-05-02
