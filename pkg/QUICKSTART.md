# Windows 7 编译工具包 - 快速开始

## 5 分钟快速上手

### 步骤 1: 下载工具 (2 分钟)
```batch
cd pkg
双击: download_tools.bat
```
等待下载完成 (约 330MB)。

### 步骤 2: 检查补丁 (1 分钟)
将 `check_patches.bat` 复制到项目根目录，双击运行：
```batch
copy pkg\check_patches.bat .\
check_patches.bat
```

如果显示 `[PASS]`，继续步骤 3。  
如果显示 `[FAIL]`，参考 `win7_patch_guide.md` 应用补丁。

### 步骤 3: 一键编译 (10-30 分钟)
```batch
copy pkg\build_llama_win7.bat .\
build_llama_win7.bat
```

编译完成后，输出在 `build_win7_oneclick/bin/` 目录。

### 步骤 4: 部署到 Windows 7
复制以下文件到 Windows 7 电脑：
```
build_win7_oneclick/bin/llama-server.exe
build_win7_oneclick/bin/libgomp-1.dll
build_win7_oneclick/bin/run_server.bat  (可选)
```

---

## 目录说明

```
pkg/
├── README.md                    # 完整使用指南
├── QUICKSTART.md               # 本文档 (快速开始)
├── DOWNLOAD_LIST.md            # 下载地址清单
├── DEPENDENCIES.md             # 系统依赖说明
├── win7_patch_guide.md         # 补丁应用指南
│
├── download_tools.bat          # [运行] 自动下载工具
├── check_patches.bat           # [运行] 检查补丁状态
├── build_llama_win7.bat        # [运行] 一键编译
│
├── downloads/                  # [生成] 下载缓存
└── tools/                      # [生成] 工具安装目录
    ├── cmake-3.19.8/
    └── mingw-w64/
```

---

## 一键命令 (高级用户)

```batch
:: 1. 下载工具
pkg\download_tools.bat

// 2. 检查并应用补丁
pkg\check_patches.bat
:: 如果失败，手动修改 8 个文件

// 3. 编译
copy pkg\build_llama_win7.bat .\
build_llama_win7.bat

// 4. 验证
build_win7_oneclick\bin\llama-server.exe --version
```

---

## 常见问题速查

| 问题 | 解决 |
|------|------|
| CMake 无法运行 | 使用 CMake 3.19.8 (不是 4.x) |
| 缺少 libgomp-1.dll | 从 MinGW 的 bin 目录复制 |
| CreateFile2 错误 | 应用 httplib.cpp 补丁 |
| UCRT 错误 | 安装 KB2999226 或使用 MSVCRT MinGW |
| 编译慢 | 使用 `-j4` 或更多核心 |

---

详细说明请参考 `README.md`
