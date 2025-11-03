# Docker Hub 发布脚本
# 使用方法: .\publish-to-dockerhub.ps1 -DockerHubUsername "your-username" -ImageName "runpod-comfyui-cuda128" -Version "v1.0.0"

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerHubUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$ImageName = "runpod-comfyui-cuda128",
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "latest",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipPush = $false
)

$ErrorActionPreference = "Stop"

$FullImageName = "$DockerHubUsername/$ImageName"
$TaggedImage = "$FullImageName:$Version"
$LatestTag = "$FullImageName:latest"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Docker Hub 发布脚本" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Docker Hub 用户名: $DockerHubUsername" -ForegroundColor Yellow
Write-Host "镜像名称: $ImageName" -ForegroundColor Yellow
Write-Host "版本标签: $Version" -ForegroundColor Yellow
Write-Host "完整镜像名: $TaggedImage" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 构建镜像
if (-not $SkipBuild) {
    Write-Host "[步骤 1/3] 构建 Docker 镜像..." -ForegroundColor Green
    Write-Host "这可能需要 1.5-5 小时，取决于网络速度..." -ForegroundColor Yellow
    Write-Host ""
    
    docker build --platform linux/amd64 -t $TaggedImage .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "构建失败！请检查错误信息。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✓ 镜像构建成功！" -ForegroundColor Green
    Write-Host ""
    
    # 如果版本不是 latest，也创建 latest 标签
    if ($Version -ne "latest") {
        Write-Host "创建 latest 标签..." -ForegroundColor Yellow
        docker tag $TaggedImage $LatestTag
        Write-Host "✓ latest 标签已创建" -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "[跳过] 构建步骤" -ForegroundColor Yellow
    Write-Host ""
}

# 步骤 2: 登录 Docker Hub
if (-not $SkipPush) {
    Write-Host "[步骤 2/3] 登录 Docker Hub..." -ForegroundColor Green
    Write-Host "请输入您的 Docker Hub 凭据：" -ForegroundColor Yellow
    docker login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "登录失败！请检查凭据。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✓ 登录成功！" -ForegroundColor Green
    Write-Host ""
    
    # 步骤 3: 推送镜像
    Write-Host "[步骤 3/3] 推送镜像到 Docker Hub..." -ForegroundColor Green
    Write-Host "这可能需要 30 分钟到 2 小时，取决于镜像大小和网络速度..." -ForegroundColor Yellow
    Write-Host ""
    
    # 推送带版本的标签
    Write-Host "推送标签: $TaggedImage" -ForegroundColor Cyan
    docker push $TaggedImage
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "推送失败！请检查网络连接和 Docker Hub 状态。" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✓ $TaggedImage 推送成功！" -ForegroundColor Green
    
    # 如果版本不是 latest，也推送 latest 标签
    if ($Version -ne "latest") {
        Write-Host ""
        Write-Host "推送标签: $LatestTag" -ForegroundColor Cyan
        docker push $LatestTag
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "推送 latest 标签失败！" -ForegroundColor Red
            exit 1
        }
        
        Write-Host ""
        Write-Host "✓ $LatestTag 推送成功！" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "✓ 发布完成！" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "镜像地址：" -ForegroundColor Yellow
    Write-Host "  - https://hub.docker.com/r/$FullImageName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "在 RunPod 中使用以下镜像：" -ForegroundColor Yellow
    Write-Host "  - $TaggedImage" -ForegroundColor Cyan
    if ($Version -ne "latest") {
        Write-Host "  - $LatestTag" -ForegroundColor Cyan
    }
    Write-Host ""
} else {
    Write-Host "[跳过] 推送步骤" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "镜像已准备好，可以手动推送到 Docker Hub：" -ForegroundColor Yellow
    Write-Host "  docker login" -ForegroundColor Cyan
    Write-Host "  docker push $TaggedImage" -ForegroundColor Cyan
    if ($Version -ne "latest") {
        Write-Host "  docker push $LatestTag" -ForegroundColor Cyan
    }
    Write-Host ""
}

