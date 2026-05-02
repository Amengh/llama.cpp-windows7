# GitHub 发布完整教程

## 方法一：创建全新的 GitHub 仓库（推荐）

### 步骤 1：在 GitHub 上创建仓库

1. 打开 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `llama.cpp-win7` 或你喜欢的名字
   - **Description**: `Windows 7 compatible fork of llama.cpp - Run LLMs on Windows 7 SP1+`
   - **Visibility**: Public（推荐）或 Private
   - **勾选**: ☑️ Add a README file
   - **勾选**: ☑️ Add .gitignore → 选择 "C++"
   - **勾选**: ☑️ Choose a license → 选择 "MIT License"
3. 点击 **Create repository**

### 步骤 2：克隆并准备代码

```bash
# 1. 克隆你刚创建的仓库
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7

# 2. 复制当前项目的代码（不包括 .git 目录）
# 假设你的代码在 D:\Users\Zhoum\Desktop\002-编程和AI\llama.cpp改造-兼容windows7\llama.cpp-master430

# Windows 命令提示符:
xcopy "D:\Users\Zhoum\Desktop\002-编程和AI\llama.cpp改造-兼容windows7\llama.cpp-master430\*" . /E /I /H /Y

# 或者使用 Git Bash:
cp -r /d/Users/Zhoum/Desktop/002-编程和AI/llama.cpp改造-兼容windows7/llama.cpp-master430/* .
```

### 步骤 3：复制 README

```bash
# 使用我们准备好的 GitHub 发布 README
cp GITHUB_RELEASE.md README.md

# 或者使用中文版
cp README_CN.md README.md
```

### 步骤 4：提交代码

```bash
# 添加所有文件
git add -A

# 提交
git commit -m "Initial commit: Windows 7 compatible llama.cpp

Features:
- Full Windows 7 SP1+ support
- Maintains Windows 10/11 compatibility
- Fully static linking (no DLL dependencies)
- 8 source files modified with minimal changes
- 7 patches for easy upstream sync

Changes:
- Replace Windows 8+ APIs with Windows 7 compatible versions
- Add LLAMA_WIN7_COMPAT CMake option
- Conditional AF_UNIX socket support
- Comprehensive documentation"

# 推送到 GitHub
git push origin main
```

### 步骤 5：创建 Release

1. 在 GitHub 仓库页面，点击右侧的 **"Create a new release"**
2. 点击 **"Choose a tag"**，输入 `v1.0.0-win7`，点击 **"Create new tag"**
3. **Release title**: `Windows 7 Compatibility Release v1.0.0`
4. **Description**:
```markdown
## Windows 7 Compatibility Release v1.0.0

This release adds full Windows 7 SP1 support to llama.cpp while maintaining compatibility with Windows 10/11.

### What's Included
- All source code with Windows 7 patches applied
- 7 patch files for easy upstream synchronization
- Complete build documentation
- Automated build scripts

### Key Features
✅ Windows 7 SP1+ support
✅ Windows 10/11 compatible
✅ Fully static linking (no DLL dependencies)
✅ Minimal code changes (8 files modified)
✅ Easy to apply to new llama.cpp versions

### API Replacements
| Old API (Win8+) | New API (Win7+) |
|-----------------|-----------------|
| CreateFile2 | CreateFileW |
| CreateFileMappingFromApp | CreateFileMapping |
| MapViewOfFileFromApp | MapViewOfFile |

### Requirements
- Windows 7 SP1 or later
- CMake 3.19.x (last version supporting Win7)
- MinGW-w64 GCC or Visual Studio 2019

### Quick Start
```bash
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7
build_win7_final.bat
```

### Documentation
- [Build Guide](docs/WINDOWS7_BUILD_GUIDE.md)
- [API Changes](docs/WINDOWS7_API_CHANGES.md)
- [Troubleshooting](docs/WINDOWS7_TROUBLESHOOTING.md)

### Credits
- Original llama.cpp: https://github.com/ggml-org/llama.cpp
```

5. 可选：勾选 **"Set as a pre-release"** 如果是测试版
6. 点击 **"Publish release"**

---

## 方法二：从已有代码推送

如果你已经有本地代码，直接推送到 GitHub：

```bash
# 进入项目目录
cd "D:\Users\Zhoum\Desktop\002-编程和AI\llama.cpp改造-兼容windows7\llama.cpp-master430"

# 初始化 Git 仓库（如果还没有）
git init

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/llama.cpp-win7.git

# 更新 README
cp GITHUB_RELEASE.md README.md

# 添加所有文件
git add -A

# 提交
git commit -m "Windows 7 compatible llama.cpp"

# 推送到 GitHub
git push -u origin main
```

---

## 方法三：创建干净的补丁仓库

如果只想要发布补丁，不发布整个代码：

### 步骤 1：创建新目录

```bash
mkdir llama.cpp-win7-patches
cd llama.cpp-win7-patches
```

### 步骤 2：复制必要文件

```bash
# 复制补丁文件
mkdir patches
cp /path/to/llama.cpp-master430/patches/*.patch patches/

# 复制文档
mkdir docs
cp /path/to/llama.cpp-master430/docs/WINDOWS7_*.md docs/

# 复制脚本
cp /path/to/llama.cpp-master430/apply_patches.* .
cp /path/to/llama.cpp-master430/build_win7_final.bat .
```

### 步骤 3：创建 README

```markdown
# llama.cpp Windows 7 Patches

Patches to make llama.cpp compatible with Windows 7.

## Usage

```bash
# 1. Clone original llama.cpp
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp

# 2. Download patches
wget https://github.com/YOUR_USERNAME/llama.cpp-win7-patches/archive/refs/tags/v1.0.0.tar.gz
tar -xzf v1.0.0.tar.gz

# 3. Apply patches
bash apply_patches.sh

# 4. Build
bash build_win7_final.bat
```

## Patches

| Patch | Description |
|-------|-------------|
| 01-httplib-root.patch | Conditional afunix.h inclusion |
| 02-vendor-httplib-h.patch | Remove Windows 10 requirement |
| 03-vendor-httplib-cpp.patch | API replacements |
| ... | ... |

## Documentation

- [Build Guide](docs/WINDOWS7_BUILD_GUIDE.md)
- [API Changes](docs/WINDOWS7_API_CHANGES.md)
```

---

## 发布后维护

### 当上游 llama.cpp 更新时

```bash
# 1. 同步上游代码
cd llama.cpp-win7
git remote add upstream https://github.com/ggml-org/llama.cpp.git
git fetch upstream
git merge upstream/master

# 2. 检查补丁是否还能应用
bash apply_patches.sh --dry-run

# 3. 如有冲突，手动修复后重新提交
# 4. 发布新版本
```

### 创建新版本 Release

1. 修改代码并提交
2. 推送代码：`git push origin main`
3. 在 GitHub 点击 "Create a new release"
4. 输入新版本号如 `v1.1.0-win7`
5. 填写更新日志
6. 发布

---

## 常见问题

### Q: 提示 "Permission denied"?
```bash
# 使用 SSH 而不是 HTTPS
git remote set-url origin git@github.com:YOUR_USERNAME/llama.cpp-win7.git
```

### Q: 文件太大无法推送?
```bash
# 使用 Git LFS
git lfs install
git lfs track "*.exe"
git lfs track "*.dll"
```

### Q: 如何删除已上传的文件?
```bash
# 从 Git 历史中删除（慎用！）
git rm --cached filename
git commit -m "Remove file"
git push origin main
```

---

## 发布检查清单

发布前确认：

- [ ] README.md 内容完整
- [ ] 所有补丁文件已包含
- [ ] 文档完整
- [ ] 构建脚本可运行
- [ ] 代码可以成功构建
- [ ] 版本号正确
- [ ] 许可证文件存在
- [ ] .gitignore 配置正确
