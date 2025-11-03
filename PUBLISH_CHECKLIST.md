# 🚀 Docker Hub 发布检查清单

## ✅ 发布前准备

- [ ] Docker Desktop 已安装并运行
- [ ] Docker Hub 账户已创建（https://hub.docker.com）
- [ ] 至少 150 GB 磁盘空间可用
- [ ] 网络连接稳定（构建需要 1.5-5 小时，推送需要 30 分钟-2 小时）

## 📋 文件检查

确保以下文件存在：
- [x] `Dockerfile` - ✅ 已存在
- [x] `handler.py` - ✅ 已存在
- [x] `requirements.txt` - ✅ 已存在
- [x] `.dockerignore` - ✅ 已创建

## 🔧 快速发布方法

### 方法 1: 使用发布脚本（推荐）

```powershell
# 使用 PowerShell 脚本（最简单）
.\publish-to-dockerhub.ps1 -DockerHubUsername "your-username" -ImageName "runpod-comfyui-cuda128" -Version "v1.0.0"
```

### 方法 2: 手动命令

```powershell
# 1. 构建镜像
docker build --platform linux/amd64 -t your-username/runpod-comfyui-cuda128:v1.0.0 .

# 2. 标记为 latest
docker tag your-username/runpod-comfyui-cuda128:v1.0.0 your-username/runpod-comfyui-cuda128:latest

# 3. 登录 Docker Hub
docker login

# 4. 推送镜像
docker push your-username/runpod-comfyui-cuda128:v1.0.0
docker push your-username/runpod-comfyui-cuda128:latest
```

## ⏱️ 预计时间

| 步骤 | 预计时间 | 说明 |
|------|---------|------|
| 拉取基础镜像 | 5-15 分钟 | 首次较慢，后续使用缓存 |
| 安装自定义节点 | 10-30 分钟 | 7 个节点 |
| 下载模型 | 1-4 小时 | ⚠️ **最耗时**，25+ 个模型 |
| 推送到 Docker Hub | 30 分钟-2 小时 | 取决于网络和镜像大小 |
| **总计** | **2-7 小时** | 取决于网络条件 |

## 📝 在 RunPod 上使用

发布完成后，在 RunPod 控制台创建 Serverless Endpoint：

1. 访问：https://www.runpod.io/console
2. 创建新的 Serverless Endpoint
3. 配置：
   - **Container Image**: `your-username/runpod-comfyui-cuda128:latest`
   - **Container Disk**: 80 GB（或根据实际需要）
   - **GPU**: RTX 4090 或更高
4. 部署并测试

## 🔗 相关文档

- [详细构建指南](docs/build-docker-image.md) - 完整的构建步骤和故障排除
- [快速开始指南](QUICK_START.md) - 本地测试和发布流程
- [部署指南](docs/deployment.md) - RunPod 部署详细说明

## ⚠️ 注意事项

1. **镜像大小**: 约 70-90 GB（包含所有模型）
2. **网络稳定性**: 确保构建和推送期间网络稳定
3. **Docker Hub 限制**: 免费账户有推送限制，注意查看
4. **访问令牌**: 推荐使用访问令牌而非密码登录

## 🆘 问题排查

### 构建失败
- 重新运行构建命令（Docker 会使用缓存继续）
- 检查磁盘空间：`docker system df`

### 推送失败
- 检查网络连接
- 重新运行 push 命令（支持断点续传）
- 验证登录状态：`docker login`

### 磁盘空间不足
```powershell
# 清理 Docker 缓存
docker system prune -a

# Windows: 扩展 Docker Desktop 磁盘
# Settings → Resources → Advanced → 增加 Disk image size
```

