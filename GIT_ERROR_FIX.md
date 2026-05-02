# Git 错误解决

## 错误：src refspec main does not match any

### 原因
本地仓库没有 `main` 分支，或者没有任何提交。

### 解决方法

#### 方法 1：创建 main 分支并推送（推荐）

```bash
# 1. 查看当前分支状态
git status

# 2. 查看所有分支
git branch -a

# 3. 创建 main 分支（如果还没有）
git checkout -b main

# 4. 添加文件并提交
git add -A
git commit -m "Initial commit: Windows 7 compatible llama.cpp"

# 5. 推送到 GitHub
git push -u origin main
```

#### 方法 2：如果本地是 master 分支

```bash
# 重命名 master 为 main
git branch -m master main

# 然后推送
git push -u origin main
```

#### 方法 3：完整流程（如果上面都不行）

```bash
# 1. 确保在正确的目录
cd "D:\Users\Zhoum\Desktop\002-编程和AI\llama.cpp改造-兼容windows7\llama.cpp-master430"

# 2. 初始化 Git（如果还没做）
git init

# 3. 添加远程仓库
git remote add origin https://github.com/Amengh/llama.cpp-windows7.git

# 4. 配置用户信息（如果还没设置）
git config user.name "Amengh"
git config user.email "your-email@example.com"

# 5. 复制 GitHub 专用 README
cp GITHUB_RELEASE.md README.md

# 6. 添加所有文件
git add -A

# 7. 创建提交
git commit -m "Initial commit: Windows 7 compatible llama.cpp

Features:
- Full Windows 7 SP1+ support
- Maintains Windows 10/11 compatibility
- Fully static linking
- 8 source files modified with minimal changes"

# 8. 创建并切换到 main 分支（如果不存在）
git checkout -b main

# 9. 推送
git push -u origin main
```

### 常见检查命令

```bash
# 查看远程仓库配置
git remote -v

# 查看提交历史
git log --oneline

# 查看文件状态
git status

# 查看所有分支
git branch -a
```

### 如果提示需要 token

GitHub 已不支持密码登录，需要使用 Personal Access Token：

1. 访问 https://github.com/settings/tokens
2. 点击 **Generate new token (classic)**
3. 勾选 `repo` 权限
4. 生成后复制 token
5. 推送时用这个 token 代替密码

或者在命令行使用：
```bash
git remote set-url origin https://TOKEN@github.com/Amengh/llama.cpp-windows7.git
```
