# Git 快速推送脚本
# 使用方法: .\git-push.ps1 "commit message"

param(
    [Parameter(Mandatory=$true)]
    [string]$Message,
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Git 快速推送" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 检查是否有更改
Write-Host "[步骤 1/4] 检查更改..." -ForegroundColor Green
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "没有需要提交的更改" -ForegroundColor Yellow
    exit 0
}

Write-Host "发现以下更改:" -ForegroundColor Yellow
git status --short
Write-Host ""

# 步骤 2: 添加所有更改
Write-Host "[步骤 2/4] 添加所有更改..." -ForegroundColor Green
git add .
Write-Host "✓ 已添加所有更改" -ForegroundColor Green
Write-Host ""

# 步骤 3: 提交
Write-Host "[步骤 3/4] 提交更改..." -ForegroundColor Green
Write-Host "提交信息: $Message" -ForegroundColor Yellow
git commit -m $Message

if ($LASTEXITCODE -ne 0) {
    Write-Host "提交失败！" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 提交成功" -ForegroundColor Green
Write-Host ""

# 步骤 4: 推送
Write-Host "[步骤 4/4] 推送到 GitHub..." -ForegroundColor Green
git push origin $Branch

if ($LASTEXITCODE -ne 0) {
    Write-Host "推送失败！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✓ 推送完成！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "仓库地址: https://github.com/ultimatech-cn/runpod_comfyui_cuda128" -ForegroundColor Cyan
Write-Host ""

