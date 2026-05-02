# llama.cpp Windows 7 兼容版 - GitHub 发布整理完成

## 已完成的工作

### 1. 创建了新文档文件

| 文件 | 说明 |
|------|------|
| `README_GITHUB.md` | 英文版 GitHub 主页 README |
| `README_CN.md` | 中文版 README |
| `GITHUB_RELEASE.md` | GitHub 发布说明文档 |
| `PACKAGE_README.md` | 发布包说明文档 |

### 2. 创建了补丁文件 (patches/)

| 补丁文件 | 修改内容 |
|----------|----------|
| `01-httplib-root.patch` | 根目录 httplib.h - 条件性包含 afunix.h |
| `02-vendor-httplib-h.patch` | Vendor httplib.h - 移除 Windows 10 要求 |
| `03-vendor-httplib-cpp.patch` | Vendor httplib.cpp - API 替换 |
| `04-server-http.patch` | Server - Windows 7 运行时检查 |
| `05-cmake-root.patch` | 根 CMakeLists.txt - LLAMA_WIN7_COMPAT 选项 |
| `06-cmake-vendor-httplib.patch` | Vendor CMake - Win7 标志传递 |
| `07-cmake-ggml.patch` | GGML CMake - Win7 标志传递 |
| `README.md` | 补丁说明文档 |

### 3. 创建了文档 (docs/)

| 文件 | 内容 |
|------|------|
| `WINDOWS7_BUILD_GUIDE.md` | 完整的 Windows 7 构建指南 |
| `WINDOWS7_API_CHANGES.md` | API 替换的技术细节 |
| `WINDOWS7_TROUBLESHOOTING.md` | 常见错误和解决方案 |
| `RELEASE_CHECKLIST.md` | GitHub 发布检查清单 |

### 4. 创建了脚本

| 文件 | 用途 |
|------|------|
| `apply_patches.sh` | Bash 脚本，应用所有补丁 |
| `apply_patches.bat` | Windows 批处理脚本，应用所有补丁 |
| `build_win7_final.bat` | 已有的 Windows 7 构建脚本 |

## GitHub 发布步骤

### 步骤 1: 创建新仓库

1. 在 GitHub 上创建新仓库：`llama.cpp-win7`
2. 选择 "Add a README file"
3. 添加 Topic 标签：`llama`, `windows-7`, `llm`, `ai`, `mingw`

### 步骤 2: 推送代码

```bash
# 在本地项目目录
git init
git remote add origin https://github.com/YOUR_USERNAME/llama.cpp-win7.git

# 复制 GITHUB_RELEASE.md 内容到 README.md
cp GITHUB_RELEASE.md README.md

# 提交所有文件
git add -A
git commit -m "Initial commit: Windows 7 compatible llama.cpp"
git push -u origin main
```

### 步骤 3: 创建 Release

1. 在 GitHub 上点击 "Create a new release"
2. 选择 "Choose a tag"，输入版本号如 `v1.0.0-win7`
3. 标题：`llama.cpp Windows 7 Compatibility Release v1.0.0`
4. 内容：从 `PACKAGE_README.md` 复制
5. 可选：上传预编译的二进制文件作为附件

## 项目结构（发布版）

```
llama.cpp-win7/
├── README.md                 # 主说明（从 GITHUB_RELEASE.md 复制）
├── README_CN.md             # 中文说明
├── LICENSE                  # MIT 许可证
├── build_win7_final.bat    # Windows 7 构建脚本
├── apply_patches.sh        # 补丁应用脚本 (Bash)
├── apply_patches.bat       # 补丁应用脚本 (Windows)
│
├── patches/                # 补丁目录
│   ├── 01-httplib-root.patch
│   ├── 02-vendor-httplib-h.patch
│   ├── 03-vendor-httplib-cpp.patch
│   ├── 04-server-http.patch
│   ├── 05-cmake-root.patch
│   ├── 06-cmake-vendor-httplib.patch
│   ├── 07-cmake-ggml.patch
│   └── README.md
│
├── docs/                   # 文档目录
│   ├── WINDOWS7_BUILD_GUIDE.md
│   ├── WINDOWS7_API_CHANGES.md
│   ├── WINDOWS7_TROUBLESHOOTING.md
│   └── RELEASE_CHECKLIST.md
│
├── src/                    # 源代码（已打补丁的 llama.cpp）
├── ggml/                   # GGML 库
├── vendor/                 # 第三方库
├── tools/                  # 工具（server, cli 等）
└── ...                     # 其他 llama.cpp 原文件
```

## 关键修改总结

### API 替换 (vendor/cpp-httplib/httplib.cpp)

| Windows 8+ API | Windows 7 兼容替代 |
|---------------|-------------------|
| CreateFile2 | CreateFileW |
| CreateFileMappingFromApp | CreateFileMapping |
| MapViewOfFileFromApp | MapViewOfFile |

### CMake 选项

```cmake
LLAMA_WIN7_COMPAT=ON       # 启用 Windows 7 兼容性
LLAMA_NATIVE=OFF           # 禁用原生 CPU 优化
```

### 编译标志

```bash
-D_WIN32_WINNT=0x0601      # Windows 7 API 版本
-static-libgcc             # 静态链接 GCC 运行时
-static-libstdc++          # 静态链接 C++ 标准库
-static                    # 完全静态链接
```

## 使用提示

### 对于想要直接使用 Windows 7 版本的用户

```bash
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7
./build_win7_final.bat
```

### 对于想要给原版 llama.cpp 打补丁的用户

```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cp /path/to/llama.cpp-win7/patches/*.patch ./
bash apply_patches.sh
```

## 验证清单

发布前请确认：

- [ ] 所有 7 个补丁都已应用
- [ ] `build_win7_final.bat` 可以成功构建
- [ ] 生成的可执行文件没有 DLL 依赖错误
- [ ] `llama-server.exe` 可以在 Windows 7 上运行
- [ ] 所有文档都已更新
- [ ] README.md 内容正确

## 后续维护

当上游 llama.cpp 更新时：

1. 检查修改的文件是否冲突
2. 重新应用补丁或更新补丁
3. 重新测试构建
4. 发布新版本

---

整理完成时间：2026-05-02
