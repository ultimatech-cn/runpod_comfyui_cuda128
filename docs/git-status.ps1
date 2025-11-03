# Git 状态快速查看脚本
# 使用方法: .\git-status.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Git 仓库状态" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 显示远程仓库
Write-Host "远程仓库:" -ForegroundColor Yellow
git remote -v
Write-Host ""

# 显示当前分支
Write-Host "当前分支:" -ForegroundColor Yellow
git branch --show-current
Write-Host ""

# 显示状态
Write-Host "工作区状态:" -ForegroundColor Yellow
git status
Write-Host ""

# 显示最近的提交
Write-Host "最近的提交:" -ForegroundColor Yellow
git log --oneline -5
Write-Host ""

