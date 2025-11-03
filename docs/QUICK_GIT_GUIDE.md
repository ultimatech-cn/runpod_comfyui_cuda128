# Git 快捷操作指南

本指南提供快速推送代码到 GitHub 的几种方法。

## 🚀 方法 1: 使用推送脚本（最简单）

### 基本用法

```powershell
# 快速推送（自动添加、提交、推送）
.\git-push.ps1 "Your commit message in English"
```

### 示例

```powershell
# 简单提交
.\git-push.ps1 "Update Dockerfile"

# 详细提交
.\git-push.ps1 "Add new feature: URL image support"
```

**优点：**
- ✅ 一行命令完成所有操作
- ✅ 自动添加所有更改
- ✅ 自动推送到 GitHub
- ✅ 清晰的进度显示

---

## 📊 方法 2: 查看状态

```powershell
# 快速查看仓库状态
.\git-status.ps1
```

---

## ⚡ 方法 3: Git 别名（全局设置，最快捷）

### 设置 Git 别名

```powershell
# 设置快捷别名
git config --global alias.pushall '!git add . && git commit -m "$1" && git push origin main'

# 使用方式
git pushall "Your commit message"
```

### 更多有用的别名

```powershell
# 快速状态查看
git config --global alias.st 'status'

# 快速日志
git config --global alias.lg 'log --oneline --graph --decorate'

# 快速推送当前分支
git config --global alias.pushu 'push -u origin HEAD'
```

设置后可以直接使用：
```powershell
git st          # 等同于 git status
git lg          # 查看简洁日志
```

---

## 🎯 方法 4: VS Code / Cursor 集成

如果您使用 VS Code 或 Cursor：

1. **使用 Source Control 面板**：
   - 按 `Ctrl+Shift+G` 打开 Source Control
   - 输入提交信息
   - 点击 ✓ 提交
   - 点击 "..." → "Push" 推送到 GitHub

2. **使用命令面板**：
   - 按 `Ctrl+Shift+P`
   - 输入 "Git: Push" 或 "Git: Commit"

**优点：**
- ✅ 可视化界面
- ✅ 可以选择性提交文件
- ✅ 集成在编辑器中

---

## 📝 方法 5: GitHub CLI（如果已安装）

```powershell
# 安装 GitHub CLI（如果还没有）
winget install --id GitHub.cli

# 使用方式
gh auth login
git add .
git commit -m "Your message"
gh repo sync
```

---

## 🔥 推荐工作流程

### 日常快速推送

```powershell
# 1. 查看状态
.\git-status.ps1

# 2. 快速推送（一行命令）
.\git-push.ps1 "Update documentation"
```

### 批量操作

```powershell
# 如果需要多次提交，可以手动控制
git add .
git commit -m "First change"
git add .
git commit -m "Second change"
git push origin main
```

---

## 📋 常用命令速查

| 操作 | 命令 |
|------|------|
| 查看状态 | `git status` 或 `.\git-status.ps1` |
| 快速推送 | `.\git-push.ps1 "message"` |
| 添加所有文件 | `git add .` |
| 提交更改 | `git commit -m "message"` |
| 推送到 GitHub | `git push origin main` |
| 查看远程仓库 | `git remote -v` |
| 查看提交历史 | `git log --oneline -10` |

---

## ⚠️ 注意事项

1. **提交信息使用英文**，避免乱码
2. **推送前先查看状态**，确保只推送需要的更改
3. **大文件不要提交**，使用 `.gitignore` 排除
4. **定期推送**，避免本地积压太多更改

---

## 🎁 快速设置脚本

创建一个 `setup-git-aliases.ps1` 来一键设置所有别名：

```powershell
# setup-git-aliases.ps1
git config --global alias.st 'status'
git config --global alias.co 'checkout'
git config --global alias.br 'branch'
git config --global alias.ci 'commit'
git config --global alias.pushall '!git add . && git commit -m "$1" && git push origin main'
Write-Host "Git 别名设置完成！" -ForegroundColor Green
```

---

## 💡 提示

**最快的方式：**
1. 使用 `.\git-push.ps1 "message"` 脚本（推荐）
2. 或设置 Git 别名后使用 `git pushall "message"`

**最灵活的方式：**
- 使用 VS Code/Cursor 的 Source Control 面板

**最专业的方式：**
- 使用 Git 命令行手动操作，完全控制每个步骤

