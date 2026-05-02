# llama.cpp Windows 编译技能 - 提示词使用指南

## 标准提示词模板

### 模板 1: 完整编译（推荐）

```
请帮我编译 llama.cpp Windows 版本：

1. 首先检查项目是否已经应用了 Windows 7/11 兼容性补丁
2. 如果没有，参考 CLAUDE_SKILL.md 应用必要的修改
3. 使用 build_win7_final.bat 或 build_win11.bat 编译
4. 验证编译结果（静态链接，无 DLL 依赖）

目标平台: [Windows 7 / Windows 11 / 双版本]
模型位置: [如果有]
需要工具: [llama-server / llama-cli / 全部]
```

### 模板 2: 代码更新后重新编译

```
llama.cpp 代码已更新，请重新编译 Windows 版本：

1. 运行 quick_patch_check.bat 检查补丁状态
2. 如果补丁丢失，参考 CLAUDE_SKILL.md 重新应用
3. 或使用 auto_patch.sh 自动应用补丁
4. 执行编译并验证

目标: [Windows 7 / Windows 11]
```

### 模板 3: 解决编译错误

```
编译 llama.cpp 时遇到错误：

错误信息: [粘贴错误]

请根据 CLAUDE_SKILL.md 中的"失败教训"部分诊断并修复。

当前平台: [Windows 7 / Windows 11]
编译器: [MinGW / Visual Studio]
```

---

## 场景化提示词示例

### 场景 1: 首次编译 Windows 7 版本

```
我需要编译 llama.cpp 的 Windows 7 版本，请帮我完成以下步骤：

1. 阅读 CLAUDE_SKILL.md 了解需要的修改
2. 检查 httplib.h、server-http.cpp、CMakeLists.txt 是否已打补丁
3. 如果未打补丁，应用这些修改：
   - httplib.h: 添加 _WIN32_WINNT 条件编译
   - server-http.cpp: 添加 Windows 7 检测
   - CMakeLists.txt: 添加 LLAMA_WIN7_COMPAT 选项
4. 运行 build_win7_final.bat 进行编译
5. 验证生成的 llama-server.exe 不依赖 libstdc++-6.dll
6. 测试启动服务器

注意：Windows 7 不支持 Unix 域套接字，需要使用 --host 127.0.0.1 --port 8080
```

### 场景 2: 首次编译 Windows 11 版本

```
请帮我编译 llama.cpp 的 Windows 11 版本：

1. 参考 CLAUDE_SKILL.md 中的 Windows 11 配置
2. 使用以下关键参数：
   - -D_WIN32_WINNT=0x0A00
   - -static-libgcc -static-libstdc++ -static
   - -DLLAMA_NATIVE=ON
3. 运行 build_win11.bat 或手动配置 CMake
4. 验证静态链接（不依赖 MinGW DLL）
5. 测试服务器启动

目标：完全静态链接，可以在任何 Windows 10/11 机器上运行
```

### 场景 3: 代码更新后快速修复

```
我更新了 llama.cpp 代码（git pull），现在需要重新应用 Windows 兼容性补丁：

1. 运行 quick_patch_check.bat 查看哪些补丁丢失
2. 对于 CMake 文件，可以直接修改（参考 CLAUDE_SKILL.md 第 3-5 节）
3. 对于 httplib.h 和 server-http.cpp，手动应用修改
4. 如果方便，可以尝试运行 auto_patch.sh 自动修复
5. 完成后编译验证

请优先处理：
- CLAUDE_SKILL.md 中标记为 CRITICAL 的修改
- Windows API 版本定义
- 静态链接配置
```

### 场景 4: 双版本编译

```
请帮我同时编译 Windows 7 和 Windows 11 版本的 llama.cpp：

Windows 7 版本：
- API: 0x0601
- Native: OFF
- Unix Sockets: 不支持
- 命令: build_win7_final.bat

Windows 11 版本：
- API: 0x0A00
- Native: ON
- Unix Sockets: 支持
- 命令: build_win11.bat

共用配置：
- 静态链接: -static-libgcc -static-libstdc++ -static
- 不依赖外部 DLL
- 纯 CPU 版本（无 GPU）

参考文档: CLAUDE_SKILL.md
```

### 场景 5: 故障排查

```
编译/运行 llama.cpp 时遇到问题：

症状: [例如：启动时提示缺少 DLL / 编译错误 / 无法启动服务器]
错误信息: [完整错误信息]

请根据 CLAUDE_SKILL.md 的"失败教训"部分进行诊断：

如果是 DLL 错误：
- 检查是否使用了 -static-libstdc++ -static-libgcc

如果是 API 错误（CreateFile2）：
- 检查是否定义了 -D_WIN32_WINNT

如果是 afunix.h 错误：
- 检查 httplib.h 是否有条件编译

如果是 .sock 文件错误：
- 确认 Windows 7 不支持 Unix 域套接字

请提供解决方案和修复步骤。
```

---

## 极简提示词

### 最短有效提示词

```
参考 CLAUDE_SKILL.md 编译 llama.cpp Windows 版本，确保静态链接无 DLL 依赖。
```

### 一句话指令

```
用 build_win7_final.bat 编译 llama.cpp，参考 CLAUDE_SKILL.md 解决任何编译错误。
```

```
检查并重新应用 Windows 7 补丁后编译 llama.cpp（参考 CLAUDE_SKILL.md）。
```

---

## 分步骤提示词

### Step 1: 诊断

```
诊断 llama.cpp 当前状态：
1. 运行 quick_patch_check.bat
2. 检查 httplib.h 是否有 Windows 7 补丁
3. 检查 CMakeLists.txt 是否有 LLAMA_WIN7_COMPAT
4. 报告哪些补丁已应用，哪些需要应用
```

### Step 2: 修复

```
根据诊断结果修复 llama.cpp：
[上一步的输出]

应用 CLAUDE_SKILL.md 中描述的修改。
```

### Step 3: 编译

```
编译修复后的 llama.cpp：
- 平台: [Windows 7 / Windows 11]
- 使用 build_*.bat 脚本或手动配置 CMake
- 关键参数: [static linking, API version]
```

### Step 4: 验证

```
验证编译结果：
1. 检查 llama-server.exe 存在且大小正常 (~20-25MB)
2. 用 objdump 检查 DLL 依赖
3. 测试启动服务器
4. 测试 API 端点
```

---

## 高级提示词技巧

### 包含上下文

```
项目位置: D:\Projects\llama.cpp-newversion
目标平台: Windows 7 SP1
编译器: MinGW-w64

任务: 参考 D:\Users\Zhoum\Desktop\llama.cpp-master430\CLAUDE_SKILL.md，
将 Windows 兼容性补丁应用到这个新项目。

注意：新项目可能有不同的代码结构，请适当调整补丁位置。
```

### 指定输出

```
请提供：
1. 需要修改的文件清单
2. 每个文件的具体修改位置（行号或代码片段）
3. 编译命令
4. 验证步骤

参考: CLAUDE_SKILL.md
```

### 迭代优化

```
第一轮: 应用 CLAUDE_SKILL.md 中的 CMake 修改
第二轮: 应用 httplib.h 和 server-http.cpp 修改
第三轮: 编译并修复任何错误
第四轮: 验证并优化
```

---

## 常见错误提示词

### 错误：缺少 DLL

```
用户报告运行 llama-server.exe 时提示缺少 libstdc++-6.dll

请根据 CLAUDE_SKILL.md 的"失败教训"部分：
1. 解释为什么会这样
2. 提供解决方案（重新编译，添加 -static-libstdc++）
3. 给出完整的修复命令
```

### 错误：编译失败

```
编译 llama.cpp 时出现错误：
[错误信息]

请根据 CLAUDE_SKILL.md 诊断：
- 是否定义了 _WIN32_WINNT？
- 是否有 afunix.h 错误？
- 其他常见错误和解决方案
```

### 错误：运行时错误

```
llama-server 启动时出错：
[错误信息]

参考 CLAUDE_SKILL.md：
1. 检查是否是 Windows 7 使用了 .sock 文件
2. 检查 API 版本是否匹配
3. 提供正确的启动命令
```

---

## 提示词检查清单

好的提示词应包含：

- [ ] 明确目标（Windows 7 / Windows 11 / 双版本）
- [ ] 参考文档（CLAUDE_SKILL.md）
- [ ] 当前状态（首次编译 / 代码更新后 / 修复错误）
- [ ] 关键约束（静态链接 / 无 DLL 依赖）
- [ ] 验证要求（测试运行 / API 测试）

避免：

- ❌ 模糊的目标（"编译一下"）
- ❌ 缺少上下文（不说平台版本）
- ❌ 不验证结果
- ❌ 不指定参考文档

---

## 示例对话

### 示例 1: 完整流程

**User:**
```
请帮我编译 llama.cpp Windows 7 版本。

项目位置：D:\llama.cpp-new
参考文档：CLAUDE_SKILL.md
要求：完全静态链接，不依赖外部 DLL

步骤：
1. 检查现有补丁状态
2. 应用缺失的补丁
3. 编译
4. 验证无 DLL 依赖
5. 测试启动
```

**Assistant 应执行：**
1. 检查文件是否存在补丁
2. 应用 CLAUDE_SKILL.md 中的修改
3. 运行 build_win7_final.bat
4. 验证 objdump 输出
5. 测试服务器启动

### 示例 2: 快速修复

**User:**
```
我更新了 llama.cpp，现在编译失败，提示 afunix.h 找不到。

请根据 CLAUDE_SKILL.md 快速修复：
- 应用 httplib.h 的补丁
- 重新编译
- 验证
```

**Assistant 应执行：**
1. 检查 httplib.h
2. 应用条件编译补丁
3. 编译
4. 验证

---

## 总结

最有效的提示词结构：

```
任务：[编译/修复/更新] llama.cpp Windows [7/11] 版本

参考：[CLAUDE_SKILL.md 路径]

步骤：
1. [检查/诊断]
2. [应用补丁/修复]
3. [编译]
4. [验证]

约束：
- 静态链接（-static-libgcc -static-libstdc++）
- 目标 API [0x0601/0x0A00]
- [其他要求]

验证：
- [检查点1]
- [检查点2]
```

---

Created: 2026-05-01
Purpose: Quick reference for effective prompts when reusing llama.cpp Windows compilation skill
