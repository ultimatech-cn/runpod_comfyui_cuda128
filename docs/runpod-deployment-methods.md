# RunPod 部署方式详解：GitHub Repo vs Docker 镜像

## 📋 概述

RunPod 提供两种方式创建 Serverless Endpoint：

1. **GitHub Repo 方式** - RunPod 从 GitHub 仓库构建镜像
2. **Docker 镜像方式** - 使用已构建好的 Docker 镜像

两种方式的核心原理相同，只是**构建时机**不同。

---

## 🔄 核心工作流程

### 两种方式的共同点

无论使用哪种方式，**最终都是运行一个 Docker 容器**，容器内部的工作流程完全一致：

```
┌─────────────────────────────────────────┐
│  Docker 容器启动                        │
├─────────────────────────────────────────┤
│  1. 执行入口脚本 (start.sh)             │
│     - 配置内存管理                       │
│     - 设置 ComfyUI-Manager 离线模式     │
│     - 启动 ComfyUI 后台服务             │
│                                         │
│  2. 运行 handler.py                     │
│     - 启动 RunPod Serverless Worker     │
│     - 监听 /run, /runsync, /health     │
│     - 处理 API 请求                     │
└─────────────────────────────────────────┘
```

### 关键文件说明

#### 1. `src/start.sh` - 启动脚本

这是容器的**入口点**（ENTRYPOINT），负责：
- 启动 ComfyUI 服务（后台运行）
- 启动 RunPod Handler（处理 API 请求）

```bash
#!/usr/bin/env bash
# 1. 配置内存优化
export LD_PRELOAD="${TCMALLOC}"

# 2. 设置 ComfyUI-Manager 离线模式
comfy-manager-set-mode offline

# 3. 启动 ComfyUI（后台运行）
python -u /comfyui/main.py --disable-auto-launch ... &

# 4. 启动 RunPod Handler（前台运行，处理 API）
python -u /handler.py
```

#### 2. `handler.py` - 请求处理器

这是**RunPod Serverless Worker 的核心**，负责：
- 接收 HTTP 请求（`/run`, `/runsync`）
- 解析输入（workflow JSON + 图片）
- 执行 ComfyUI 工作流
- 返回结果（图片 base64 或 S3 URL）

```python
def handler(job):
    # 1. 解析输入
    workflow = job["input"]["workflow"]
    images = job["input"].get("images", [])
    
    # 2. 上传输入图片到 ComfyUI
    upload_images(images)
    
    # 3. 提交工作流到 ComfyUI API
    queue_workflow(workflow, client_id)
    
    # 4. 通过 WebSocket 监听执行状态
    # 5. 获取输出图片
    # 6. 返回结果
    return {"images": [...]}

# 启动 RunPod Worker
if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
```

---

## 🆚 两种方式对比

### 方式 1: GitHub Repo 方式

**工作流程：**
```
GitHub Repo 
  └─> RunPod 构建服务器
       └─> 执行 Dockerfile 构建镜像
            └─> 推送到 RunPod 内部镜像仓库
                 └─> 部署到 Endpoint
```

**特点：**
- ✅ RunPod **自动构建**镜像（每次 push 触发）
- ✅ 不需要本地构建
- ✅ 支持 CI/CD（git push 即部署）
- ❌ 需要 GitHub 仓库权限
- ❌ 首次构建可能较慢

**配置步骤：**
1. 在 GitHub 创建仓库，包含：
   - `Dockerfile`
   - `handler.py`（可选，基础镜像已包含）
   - `requirements.txt`（可选）
   - `src/start.sh`（可选，基础镜像已包含）

2. 在 RunPod 创建 Endpoint：
   - 选择 "Start from GitHub Repo"
   - 选择仓库和分支
   - 指定 Dockerfile 路径
   - RunPod 自动构建和部署

**重要：**
- 如果使用 `runpod/worker-comfyui:5.5.0-base-cuda12.8.1` 作为基础镜像，**不需要**手动复制 `handler.py` 和 `start.sh`，因为基础镜像已经包含它们！

```dockerfile
# 您的 Dockerfile（GitHub Repo 方式）
FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# 只需要添加自定义内容
RUN comfy-node-install pulid_comfyui comfyui-reactor ...
RUN comfy model download --url https://...
```

### 方式 2: Docker 镜像方式（当前项目使用）

**工作流程：**
```
本地/CI 构建
  └─> docker build
       └─> docker push (到 Docker Hub/GitHub Container Registry)
            └─> RunPod 拉取镜像
                 └─> 部署到 Endpoint
```

**特点：**
- ✅ 完全控制构建过程
- ✅ 可以使用本地资源加速构建
- ✅ 支持多平台构建
- ❌ 需要本地/CI 环境
- ❌ 需要手动推送镜像

**当前项目配置：**

```dockerfile
# Dockerfile
FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# 安装自定义节点
RUN comfy-node-install pulid_comfyui comfyui-reactor ...

# 下载模型
RUN comfy model download --url https://...
```

**注意：**
- 基础镜像 `runpod/worker-comfyui:5.5.0-base-cuda12.8.1` **已经包含**：
  - ✅ `handler.py` - 位于 `/handler.py`
  - ✅ `start.sh` - 已设置为 ENTRYPOINT
  - ✅ ComfyUI - 位于 `/comfyui`
  - ✅ RunPod SDK - 已安装

**因此您的 Dockerfile 只需要：**
- 添加自定义节点（`comfy-node-install`）
- 下载模型（`comfy model download`）
- **不需要**复制 `handler.py` 或 `start.sh`！

---

## 🔍 深入理解：Docker 镜像中的启动流程

### 基础镜像的配置

`runpod/worker-comfyui:5.5.0-base-cuda12.8.1` 基础镜像已经配置好：

```dockerfile
# 基础镜像内部（您不需要写这些）
COPY handler.py /handler.py
COPY src/start.sh /start.sh
ENTRYPOINT ["/start.sh"]
```

### 容器启动时的执行顺序

当 RunPod 启动您的容器时：

```bash
# 1. 容器启动，执行 ENTRYPOINT
/start.sh

# 2. start.sh 执行：
#    - 启动 ComfyUI（后台）：python /comfyui/main.py &
#    - 启动 Handler（前台）：python /handler.py

# 3. handler.py 启动 RunPod Worker：
runpod.serverless.start({"handler": handler})

# 4. RunPod Worker 开始监听：
#    - POST /run        → 异步任务
#    - POST /runsync    → 同步任务
#    - GET  /health     → 健康检查
```

### API 请求流程

```
客户端请求
  └─> POST https://api.runpod.ai/v2/<endpoint_id>/runsync
       └─> RunPod 路由到容器
            └─> handler.py 接收请求
                 └─> handler() 函数执行
                      ├─> 上传图片到 ComfyUI
                      ├─> 提交工作流
                      ├─> WebSocket 监听进度
                      └─> 返回结果
```

---

## 📝 关键区别总结

| 特性 | GitHub Repo 方式 | Docker 镜像方式 |
|------|-----------------|-----------------|
| **构建位置** | RunPod 服务器 | 本地/CI 环境 |
| **构建时机** | 每次 git push | 手动触发 |
| **handler.py** | 基础镜像已包含 | 基础镜像已包含 |
| **start.sh** | 基础镜像已包含 | 基础镜像已包含 |
| **自定义内容** | Dockerfile 中定义 | Dockerfile 中定义 |
| **镜像存储** | RunPod 内部仓库 | Docker Hub/其他仓库 |
| **适用场景** | 频繁更新、CI/CD | 稳定版本、离线构建 |

---

## ✅ 验证您的镜像是否正确

### 检查镜像内容

```bash
# 运行容器
docker run -it --rm your-image:tag /bin/bash

# 检查关键文件是否存在
ls -la /handler.py        # ✅ 应该存在
ls -la /start.sh          # ✅ 应该存在
ls -la /comfyui/main.py   # ✅ 应该存在

# 检查入口点
docker inspect your-image:tag | grep -A 5 Entrypoint
# 应该显示：/start.sh
```

### 本地测试容器启动

```bash
# 测试容器能否正常启动
docker run --rm your-image:tag

# 应该看到输出：
# worker-comfyui: Starting ComfyUI
# worker-comfyui: Starting RunPod Handler
# worker-comfyui - Starting handler...
```

---

## 🎯 推荐做法

### 如果使用 GitHub Repo 方式：

1. **创建最小化 Dockerfile**：
```dockerfile
FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1
RUN comfy-node-install your-nodes...
RUN comfy model download --url ...
```

2. **不需要的文件**：
   - ❌ 不需要手动复制 `handler.py`
   - ❌ 不需要手动复制 `start.sh`
   - ❌ 不需要设置 ENTRYPOINT

### 如果使用 Docker 镜像方式（当前项目）：

1. **构建和推送**：
```powershell
docker build --platform linux/amd64 -t username/runpod-comfyui-cuda128:v1.0.0 .
docker push username/runpod-comfyui-cuda128:v1.0.0
```

2. **在 RunPod 中使用**：
   - Container Image: `username/runpod-comfyui-cuda128:v1.0.0`
   - 其他配置与 GitHub Repo 方式相同

---

## 📚 相关文档

- [RunPod 官方文档 - GitHub Integration](https://docs.runpod.io/serverless/github-integration)
- [RunPod 官方文档 - Serverless Endpoints](https://docs.runpod.io/serverless/endpoints)
- [自定义指南](customization.md)
- [部署指南](deployment.md)

---

## ❓ 常见问题

### Q: 为什么我的 Dockerfile 不需要 COPY handler.py？

**A:** 因为基础镜像 `runpod/worker-comfyui:5.5.0-base-cuda12.8.1` 已经包含：
- `handler.py` → `/handler.py`
- `start.sh` → `/start.sh`（已设置为 ENTRYPOINT）
- ComfyUI → `/comfyui`
- 所有依赖

您的 Dockerfile 只需要**添加自定义内容**（节点、模型）。

### Q: 我想修改 handler.py，怎么办？

**A:** 两种方式：

1. **继承并覆盖**（推荐）：
```dockerfile
FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1
COPY handler.py /handler.py  # 覆盖基础镜像的 handler.py
RUN comfy-node-install ...
```

2. **完全自定义**（高级）：
```dockerfile
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04
# 手动安装所有内容
```

### Q: GitHub Repo 方式和 Docker 镜像方式可以切换吗？

**A:** 可以！两者最终都生成相同的 Docker 镜像。您可以：
- 先用 Docker 镜像方式测试
- 确认无误后，将 Dockerfile 推送到 GitHub
- 切换为 GitHub Repo 方式，享受自动部署

---

**总结：两种方式的核心机制完全相同，只是构建和部署流程不同。基础镜像已经包含了所有运行时文件（handler.py、start.sh），您只需要在 Dockerfile 中添加自定义内容即可！**

