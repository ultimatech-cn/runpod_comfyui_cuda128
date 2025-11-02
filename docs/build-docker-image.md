# Docker 镜像构建详细指南

本指南提供构建自定义 ComfyUI Docker 镜像的完整步骤。

## 前置要求

1. **安装 Docker Desktop**（Windows/Mac）或 Docker Engine（Linux）
   - 下载地址：https://www.docker.com/products/docker-desktop
   - 确保 Docker 正在运行

2. **Docker Hub 账户**（如果计划推送到 Docker Hub）
   - 注册地址：https://hub.docker.com/signup
   - 准备用户名和密码（或访问令牌）

3. **足够的磁盘空间**
   - 基础镜像：约 5-10 GB
   - 您的模型：约 70-80 GB
   - 建议至少 150 GB 可用空间

4. **网络连接**
   - 需要下载大量模型文件（可能数小时）

## 步骤 1: 准备项目文件

确保您的项目目录包含以下文件：

```
runpod-comfyui-cuda128/
├── Dockerfile              # ✅ 必需
├── handler.py              # ✅ 必需（从基础镜像继承，但保留以防需要修改）
├── .dockerignore           # ⚠️ 可选但推荐
└── ...其他文件
```

### 创建 .dockerignore（推荐）

在项目根目录创建 `.dockerignore` 文件，排除不需要的文件：

```
# Git 相关
.git
.gitignore

# 文档和测试文件
docs/
test_resources/
tests/
*.md
CHANGELOG.md
LICENSE

# IDE 配置
.vscode/
.idea/
*.swp
*.swo

# Python 缓存
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# 临时文件
*.log
*.tmp
.DS_Store
```

## 步骤 2: 打开终端并导航到项目目录

### Windows PowerShell
```powershell
cd "E:\Program Files\runpod-comfyui-cuda128"
```

### Windows CMD
```cmd
cd /d "E:\Program Files\runpod-comfyui-cuda128"
```

### Linux/Mac
```bash
cd /path/to/runpod-comfyui-cuda128
```

## 步骤 3: 构建 Docker 镜像

### 基本构建命令

```bash
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest .
```

### 命令参数说明

- `docker build`: Docker 构建命令
- `--platform linux/amd64`: **⚠️ 必需参数**，确保镜像兼容 RunPod（amd64 架构）
- `-t your-username/runpod-comfyui-custom:latest`: 
  - `-t`: 标签参数
  - `your-username`: 您的 Docker Hub 用户名
  - `runpod-comfyui-custom`: 镜像名称
  - `latest`: 标签（版本号）
- `.`: 构建上下文（当前目录，包含 Dockerfile）

### 使用特定版本标签（推荐）

```bash
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:v1.0.0 .
```

### 带构建缓存的优化命令

如果之前构建失败，可以使用缓存继续：

```bash
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest --cache-from your-username/runpod-comfyui-custom:latest .
```

## 步骤 4: 构建过程详解

### 阶段 1: 拉取基础镜像（约 5-15 分钟）

```
Step 1/3 : FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1
5.5.0-base-cuda12.8.1: Pulling from runpod/worker-comfyui
...
```

**说明**: Docker 会从 Docker Hub 拉取基础镜像。这是第一次，后续会使用缓存。

### 阶段 2: 安装自定义节点（约 10-30 分钟）

```
Step 2/3 : RUN comfy-node-install PuLID_ComfyUI ComfyUI-ReActor ...
```

**说明**: 下载并安装所有自定义节点。这个过程可能较慢，取决于网络速度。

### 阶段 3: 下载模型（约 1-4 小时 ⚠️ 最耗时）

```
Step 3/3 : RUN comfy model download --url https://...
Downloading ultraRealisticByStable_v20FP16.safetensors...
Downloading wan2.2-i2v-rapid-aio-v10-nsfw.safetensors...
...
```

**说明**: 这是最耗时的步骤。您的 Dockerfile 会下载约 25+ 个模型文件。整个过程可能需要 1-4 小时，取决于：
- 网络速度
- Hugging Face 服务器响应速度
- 模型文件大小

### 预期时间表

| 步骤 | 预计时间 | 说明 |
|------|---------|------|
| 拉取基础镜像 | 5-15 分钟 | 第一次较慢，后续使用缓存 |
| 安装自定义节点 | 10-30 分钟 | 7 个节点，取决于网络 |
| 下载模型 | 1-4 小时 | **最耗时**，25+ 个模型文件 |
| **总计** | **1.5-5 小时** | 取决于网络条件 |

## 步骤 5: 处理构建问题

### 问题 1: 网络超时

如果下载模型时出现超时：

```bash
# 重新运行构建命令，Docker 会从上次成功的地方继续
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest .
```

Docker 会使用已下载的模型缓存。

### 问题 2: 磁盘空间不足

检查可用空间：

**Windows PowerShell:**
```powershell
Get-PSDrive C | Select-Object Used,Free
```

**Linux/Mac:**
```bash
df -h
```

**解决方案**:
1. 清理 Docker 缓存：
   ```bash
   docker system prune -a
   ```
2. 清理未使用的镜像：
   ```bash
   docker image prune -a
   ```

### 问题 3: 构建失败并提示 "no space left on device"

**Windows Docker Desktop:**
1. 打开 Docker Desktop
2. Settings → Resources → Advanced
3. 增加 Disk image size（建议至少 200GB）

**Linux:**
```bash
# 扩展 Docker 存储空间或移动到更大的分区
```

### 问题 4: 502 错误（推送时）

如果在推送镜像到 Docker Hub 时出现 502 错误：
- 镜像太大导致超时
- 建议：分批推送，或使用更稳定的网络

## 步骤 6: 验证构建成功

构建完成后，您应该看到：

```
Successfully built abc123def456
Successfully tagged your-username/runpod-comfyui-custom:latest
```

### 验证镜像

```bash
# 列出本地镜像
docker images | grep runpod-comfyui-custom

# 检查镜像大小
docker images your-username/runpod-comfyui-custom:latest
```

预期大小：约 70-90 GB（包含所有模型）

### 测试镜像（可选）

```bash
# 运行容器进行测试（需要 GPU，可选步骤）
docker run --rm --gpus all -it your-username/runpod-comfyui-custom:latest /bin/bash
```

## 步骤 7: 推送到 Docker Hub

### 7.1 登录 Docker Hub

```bash
docker login
```

输入您的：
- Docker Hub 用户名
- 密码（或访问令牌）

**使用访问令牌（推荐）**:
1. 访问 https://hub.docker.com/settings/security
2. 创建新的访问令牌（Access Token）
3. 使用令牌作为密码

### 7.2 推送镜像

```bash
docker push your-username/runpod-comfyui-custom:latest
```

### 推送过程

这个过程可能需要 **30 分钟到 2 小时**，取决于：
- 镜像大小（约 70-90 GB）
- 上传速度
- Docker Hub 服务器负载

**预期输出**:
```
The push refers to repository [docker.io/your-username/runpod-comfyui-custom]
...
latest: digest: sha256:abc123... size: 12345678
```

### 7.3 验证推送成功

1. 访问 https://hub.docker.com/r/your-username/runpod-comfyui-custom
2. 应该能看到您的镜像

## 步骤 8: 在 RunPod 中使用镜像

1. **登录 RunPod 控制台**
   - https://www.runpod.io/console

2. **创建 Serverless Endpoint**
   - Serverless → Endpoints → New Endpoint

3. **配置镜像**
   - **Container Image**: `your-username/runpod-comfyui-custom:latest`
   - **Container Disk**: 80 GB（或根据实际需要调整）
   - **GPU**: 选择合适的 GPU（建议 RTX 4090 或更高）

4. **部署**
   - 点击 Deploy
   - RunPod 会从 Docker Hub 拉取您的镜像

## 完整命令总结

```bash
# 1. 导航到项目目录
cd "E:\Program Files\runpod-comfyui-cuda128"

# 2. 构建镜像（替换 your-username）
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest .

# 3. 验证构建成功
docker images | grep runpod-comfyui-custom

# 4. 登录 Docker Hub
docker login

# 5. 推送镜像
docker push your-username/runpod-comfyui-custom:latest

# 6. 验证推送成功
# 访问 https://hub.docker.com/r/your-username/runpod-comfyui-custom
```

## 优化建议

### 使用多阶段构建（高级）

如果需要优化，可以考虑将模型下载和节点安装分离：

```dockerfile
# 但这需要修改 Dockerfile 结构
# 对于您的情况，当前的单层方式已经是最优的
```

### 使用 Docker BuildKit（更快）

```bash
# 启用 BuildKit（Docker Desktop 默认已启用）
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest .
```

### 后台构建（Linux/Mac）

```bash
# 在 tmux 或 screen 中运行，避免连接断开导致构建中断
tmux new-session -d -s docker-build
tmux send-keys -t docker-build "docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest ." Enter
tmux attach -t docker-build
```

## 常见问题

### Q: 构建过程中可以关闭终端吗？
A: 可以，但建议使用后台工具（tmux/screen）或在 Docker Desktop 的 GUI 中查看进度。

### Q: 构建失败了，需要重新开始吗？
A: 不需要。Docker 会缓存成功的步骤，重新运行会从失败的地方继续。

### Q: 可以暂停构建吗？
A: 可以。按 `Ctrl+C` 停止，重新运行会继续。

### Q: 镜像太大了，可以压缩吗？
A: Docker 镜像已经经过压缩和分层优化。不要手动压缩，会破坏镜像结构。

### Q: 构建时间太长，有办法加速吗？
A: 
- 使用更快的网络
- 在本地缓存基础镜像
- 考虑使用 GitHub Actions 或 CI/CD 自动构建

## 下一步

构建完成后：
1. ✅ 推送到 Docker Hub
2. ✅ 在 RunPod 中创建端点使用
3. ✅ 参考 [部署指南](deployment.md) 进行配置

