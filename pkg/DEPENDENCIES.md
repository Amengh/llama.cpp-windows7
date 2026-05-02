# Windows 7 编译工具依赖说明

## 系统补丁要求

### 如果使用 UCRT 版本的 MinGW-w64

UCRT (Universal C Runtime) 是 Windows 10 引入的现代 C 运行时库。Windows 7 需要安装补丁才能使用。

**必需补丁**: KB2999226  
**下载地址**: https://www.microsoft.com/en-us/download/details.aspx?id=49077  
**说明**: Update for Universal C Runtime in Windows

### KB2999226 安装步骤

1. 根据系统版本选择对应安装包：

| Windows 版本 | 下载文件 |
|-------------|----------|
| Windows 7 SP1 x64 | Windows6.1-KB2999226-x64.msu |
| Windows 7 SP1 x86 | Windows6.1-KB2999226-x86.msu |

2. 下载后双击安装
3. 重启计算机（推荐）

### 检查是否已安装

```batch
:: 方法 1: 使用 wmic
wmic qfe get hotfixid | findstr "KB2999226"

// 方法 2: 查看已安装更新
打开控制面板 -> 程序和功能 -> 查看已安装更新
搜索: KB2999226
```

---

## MinGW-w64 版本选择

### 方案 A: UCRT 版本 (推荐)

**优点**: 性能更好，与 Windows 10/11 兼容  
**缺点**: Windows 7 需要 KB2999226  
**适用**: Windows 7 SP1（可安装补丁的系统）

**文件名示例**:
```
winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64ucrt-11.0.1-r4.zip
```

### 方案 B: MSVCRT 版本 (兼容更好)

**优点**: 无需额外补丁，开箱即用  
**缺点**: 较旧，部分功能可能不支持  
**适用**: Windows 7（无法安装补丁的系统）

**文件名示例**:
```
winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.4-mingw-w64msvcrt-11.0.1-r4.zip
```

---

## CMake 版本说明

### 为什么必须用 3.19.x？

CMake 4.0+ 使用了 Windows 8+ 专用 API `GetSystemTimePreciseAsFileTime`，在 Windows 7 上无法运行。

**症状**:
```
无法定位程序输入点 GetSystemTimePreciseAsFileTime 于动态链接库 KERNEL32.dll
```

**解决**: 使用 CMake 3.19.8（Windows 7 支持的最高版本）

---

## 其他系统要求

### 最低要求
- Windows 7 SP1 (Service Pack 1)
- 4GB RAM
- 10GB 磁盘空间

### 推荐配置
- Windows 7 SP1 + 所有更新
- 8GB+ RAM
- SSD 硬盘
- 多核 CPU（编译会快很多）

### 必须安装的运行时

即使完全静态链接，也需要以下系统组件：

1. **Visual C++ Redistributable** (可选但推荐)
   - 下载: https://aka.ms/vs/17/release/vc_redist.x64.exe
   - 某些工具可能依赖

2. **.NET Framework 4.5+** (如果使用 GUI 工具)

---

## 依赖检查清单

在编译前，确认以下依赖已就绪：

```
□ Windows 7 SP1
□ KB2999226 (如使用 UCRT MinGW)
□ CMake 3.19.8
□ MinGW-w64 GCC 13.2.0
□ 7-Zip 或类似解压工具
□ 10GB+ 磁盘空间
```

---

## 故障排除

### 问题: "api-ms-win-crt-runtime-l1-1-0.dll 丢失"
**原因**: 缺少 UCRT
**解决**: 安装 KB2999226 或使用 MSVCRT 版本的 MinGW

### 问题: "无法启动此程序，因为计算机中丢失 VCRUNTIME140.dll"
**原因**: 需要 Visual C++ 运行时
**解决**: 安装 Visual C++ Redistributable

### 问题: CMake 无法运行
**原因**: CMake 版本太新或缺少依赖
**解决**: 
1. 确认使用 CMake 3.19.8
2. 安装 Visual C++ Redistributable

---

## 推荐安装顺序

1. Windows 7 SP1
2. Windows Update 更新（可选但推荐）
3. KB2999226 (如使用 UCRT)
4. Visual C++ Redistributable
5. CMake 3.19.8
6. MinGW-w64
7. 编译 llama.cpp
