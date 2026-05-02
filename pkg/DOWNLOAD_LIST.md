# Windows 7 编译工具包下载清单

## 下载地址

### 1. CMake 3.19.8 (Windows 7 支持的最高版本)
- **官方下载**: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi
- **备用 ZIP**: https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.zip
- **文件大小**: ~24 MB
- **说明**: CMake 3.19 是最后一个支持 Windows 7 的版本，4.x 需要 Windows 8+

### 2. MinGW-w64 GCC 13.2.0 (Windows 7 兼容版本)
- **WinLibs 官方**: https://github.com/brechtsanders/winlibs_mingw/releases/
- **推荐版本**: winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip
- **UCRT 版本**: 适用于 Windows 7 SP1+ (需安装 KB2999226 补丁)
- **MSVCRT 版本**: 更兼容旧版 Windows 7
- **文件大小**: ~300 MB

### 3. Windows 7 必要补丁 (如使用 UCRT 版本)
- **KB2999226**: Universal C Runtime (UCRT) 更新
- **下载地址**: 通过 Windows Update 或 Microsoft Update Catalog

## 下载清单

```batch
@echo off
:: download_tools.bat - 下载 Windows 7 编译工具

echo ==========================================
echo  Windows 7 编译工具下载脚本
echo ==========================================

:: 创建目录
mkdir cmake-3.19.8 2>nul
mkdir mingw-w64 2>nul

echo.
echo [1/2] 下载 CMake 3.19.8...
powershell -Command "Invoke-WebRequest -Uri 'https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.zip' -OutFile 'cmake-3.19.8/cmake-3.19.8-win64-x64.zip'"

echo.
echo [2/2] 下载 MinGW-w64 GCC 13.2.0...
echo 请从以下地址手动下载：
echo https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0posix-17.0.4-11.0.1-ucrt-r4/winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip
echo.
echo 下载后保存到: mingw-w64\mingw-w64.zip

echo.
echo ==========================================
echo 下载完成！
echo ==========================================
pause
```

## 手动下载步骤

### 步骤 1: 下载 CMake
1. 浏览器访问: https://cmake.org/files/v3.19/
2. 下载: `cmake-3.19.8-win64-x64.msi` 或 `.zip`
3. 安装到: `C:\Program Files\CMake\` 或解压到 `pkg\cmake-3.19.8\`

### 步骤 2: 下载 MinGW-w64
1. 浏览器访问: https://winlibs.com/
2. 找到 GCC 13.2.0 (或 12.x) 版本
3. 选择: `x86_64-posix-seh` 版本
4. 下载 ZIP 文件
5. 解压到: `pkg\mingw-w64\`

### 步骤 3: 配置环境变量
```batch
set PATH=C:\mingw-w64\bin;C:\Program Files\CMake\bin;%PATH%
```

## 文件清单 (下载后)

```
pkg/
├── cmake-3.19.8-win64-x64.zip          (24 MB)
├── mingw-w64/
│   └── mingw-w64.zip                   (300 MB)
├── README.md                           (本文件)
└── download_tools.bat                  (下载脚本)
```

## 验证安装

```batch
cmake --version    :: 应显示 3.19.8
gcc --version      :: 应显示 13.2.0 或类似
mingw32-make --version
```

## Windows 7 特别注意事项

1. **CMake 版本**: 必须使用 3.19.x，4.x 需要 Windows 8+ API
2. **UCRT 依赖**: 如果使用 UCRT 版本的 MinGW，需安装 KB2999226
3. **静态链接**: 编译时使用 `-static` 避免运行时 DLL 依赖

Sources:
- [CMake 3.19.8 Downloads](https://cmake.org/files/v3.19/)
- [WinLibs MinGW-w64 Releases](https://github.com/brechtsanders/winlibs_mingw/releases/)
