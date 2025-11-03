# Git 别名快速设置脚本
# 使用方法: .\setup-git-aliases.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "设置 Git 快捷别名" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 常用别名
Write-Host "设置常用别名..." -ForegroundColor Yellow

git config --global alias.st 'status'
git config --global alias.co 'checkout'
git config --global alias.br 'branch'
git config --global alias.ci 'commit'
git config --global alias.lg 'log --oneline --graph --decorate -10'
git config --global alias.pushu 'push -u origin HEAD'

Write-Host "✓ 常用别名设置完成" -ForegroundColor Green
Write-Host ""

# 快速推送别名（需要函数，不能直接用别名）
Write-Host "注意: 快速推送请使用 .\git-push.ps1 脚本" -ForegroundColor Yellow
Write-Host ""

# 显示已设置的别名
Write-Host "已设置的别名:" -ForegroundColor Yellow
git config --global --get-regexp alias
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✓ 设置完成！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "现在可以使用以下快捷命令:" -ForegroundColor Cyan
Write-Host "  git st    - 查看状态" -ForegroundColor Green
Write-Host "  git co    - 切换分支" -ForegroundColor Green
Write-Host "  git br    - 分支操作" -ForegroundColor Green
Write-Host "  git ci    - 提交更改" -ForegroundColor Green
Write-Host "  git lg    - 查看日志" -ForegroundColor Green
Write-Host "  git pushu - 推送当前分支" -ForegroundColor Green
Write-Host ""
Write-Host "快速推送请使用: .\git-push.ps1 \"commit message\"" -ForegroundColor Cyan
Write-Host ""

