# Docker Hub vs GitHub 部署方式对比

本文档说明两种部署自定义 ComfyUI 环境到 RunPod 的方式及其区别。

## 方式对比

| 特性 | Docker Hub 方式 | GitHub + RunPod Hub 方式 |
|------|----------------|-------------------------|
| **构建位置** | 本地或 CI/CD 系统 | RunPod 自动构建 |
| **构建控制** | 完全控制 | 由 RunPod 控制 |
| **构建日志** | 完全可见 | 在 RunPod 界面可见 |
| **部署速度** | 快（直接拉取镜像） | 较慢（需要构建时间） |
| **更新方式** | 重新构建并推送 | 创建新的 GitHub Release |
| **镜像复用** | ✅ 可用于其他平台 | ❌ 仅 RunPod 使用 |
| **公开分享** | ✅ 可在 Docker Hub 公开 | ✅ 可在 RunPod Hub 公开 |
| **发布到 Hub** | ❌ 仅用于个人端点 | ✅ 可发布到 RunPod Hub |
| **需要 GitHub** | ❌ 不需要 | ✅ 需要 |
| **需要 Docker Hub** | ✅ 需要 | ❌ 不需要 |

## 方式 1: Docker Hub 部署

### 优点
- ✅ **完全控制构建过程**：可以在本地测试构建
- ✅ **快速部署**：镜像已构建好，RunPod 只需拉取
- ✅ **镜像可复用**：可以在其他平台（本地、其他云服务）使用同一镜像
- ✅ **构建日志完整**：本地构建时可以看到所有详细信息
- ✅ **不依赖 GitHub**：如果不想公开代码，可以只推送到 Docker Hub

### 缺点
- ❌ **需要手动管理**：每次更新都需要重新构建和推送
- ❌ **需要本地资源**：需要足够空间和计算资源来构建镜像
- ❌ **无法发布到 RunPod Hub**：只能用于创建个人端点

### 完整步骤

#### 1. 构建镜像

```bash
# 在项目根目录执行
# ⚠️ 重要：必须使用 --platform linux/amd64
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:latest .
```

#### 2. 登录 Docker Hub

```bash
docker login
# 输入您的 Docker Hub 用户名和密码/访问令牌
```

#### 3. 推送镜像

```bash
docker push your-username/runpod-comfyui-custom:latest
```

#### 4. 在 RunPod 创建端点

1. 登录 [RunPod 控制台](https://www.runpod.io/console)
2. 导航到 **Serverless** → **Endpoints** → **New Endpoint**
3. 在 **Container Image** 字段输入：
   ```
   your-username/runpod-comfyui-custom:latest
   ```
4. 配置其他设置（GPU、磁盘大小等）
5. 点击 **Deploy**

### 更新镜像

当您需要更新时：

```bash
# 1. 修改 Dockerfile 或其他文件
# 2. 重新构建
docker build --platform linux/amd64 -t your-username/runpod-comfyui-custom:v1.1.0 .

# 3. 推送新版本
docker push your-username/runpod-comfyui-custom:v1.1.0

# 4. 在 RunPod 端点中更新镜像标签
```

## 方式 2: GitHub + RunPod Hub 部署

### 优点
- ✅ **自动化构建**：RunPod 自动处理构建过程
- ✅ **发布到 Hub**：可以让其他人使用您的模板
- ✅ **自动更新**：创建 GitHub Release 即可自动更新
- ✅ **无需本地构建**：不需要本地 Docker 环境
- ✅ **版本管理**：通过 GitHub Releases 管理版本

### 缺点
- ❌ **构建时间较长**：RunPod 需要时间构建镜像
- ❌ **构建控制较少**：无法完全控制构建过程细节
- ❌ **需要 GitHub**：必须将代码推送到 GitHub
- ❌ **镜像仅限 RunPod**：构建的镜像不能用于其他平台
- ❌ **依赖 RunPod 服务**：构建依赖 RunPod 的构建服务

### 完整步骤

参见 [发布到 RunPod Hub 指南](publish-to-hub.md)

## 推荐方案

### 选择 Docker Hub 如果：
- 您希望完全控制构建过程
- 您想在本地测试构建
- 您需要将镜像用于其他平台（不仅仅是 RunPod）
- 您不想公开代码到 GitHub
- 您只需要创建个人使用的端点

### 选择 GitHub + RunPod Hub 如果：
- 您希望自动化整个流程
- 您想将模板发布到 RunPod Hub 供他人使用
- 您没有强大的本地构建环境
- 您希望利用 GitHub 进行版本管理
- 您希望简化更新流程

## 混合方案

您也可以同时使用两种方式：

1. **开发阶段**：使用 Docker Hub 方式快速迭代和测试
2. **稳定版本**：推送到 GitHub，发布到 RunPod Hub 供他人使用

## 常见问题

### Q: 我可以同时使用两种方式吗？
A: 可以！两种方式是独立的。您可以：
- 在 Docker Hub 上保留用于快速测试的镜像
- 在 RunPod Hub 上发布用于共享的模板

### Q: Docker Hub 的镜像可以发布到 RunPod Hub 吗？
A: 不可以。RunPod Hub 要求从 GitHub 仓库构建。但您可以：
- 在 GitHub 仓库中引用 Docker Hub 镜像（作为备选方案）
- 或者同时维护两套方案

### Q: 哪种方式更快？
A: **部署速度**：Docker Hub 更快（镜像已构建好）
   **更新速度**：取决于您的构建环境。如果本地构建快，Docker Hub 更快；如果本地构建慢，GitHub 方式可能更快（利用 RunPod 的构建资源）

### Q: 镜像大小会影响选择吗？
A: 会影响。大镜像（如您的 80GB 配置）：
- **Docker Hub 方式**：需要上传大镜像（可能很慢）
- **GitHub 方式**：RunPod 处理上传，但构建时间较长

## 实际建议

对于您的项目（包含大量模型和节点），我建议：

1. **首次发布**：使用 **GitHub + RunPod Hub** 方式
   - 让 RunPod 处理大镜像的构建和上传
   - 同时发布到 Hub 供他人使用

2. **日常开发**：使用 **Docker Hub** 方式
   - 仅修改部分模型时，可以快速构建和测试
   - 不需要每次都构建所有模型

3. **生产环境**：使用 **GitHub + RunPod Hub**
   - 稳定版本通过 GitHub Release 管理
   - 自动化的构建和部署流程

