# ✅ 构建完成 - 下一步操作

## 构建成功信息

- ✅ **镜像名称**: `robinl9527/runpod-comfyui-custom:v1.0.0`
- ✅ **镜像大小**: 115 GB（包含所有模型和节点）
- ✅ **标签**: `v1.0.0` 和 `latest` 已创建

## 下一步：推送到 Docker Hub

### 步骤 1: 登录 Docker Hub

```powershell
docker login
```

输入您的：
- **Username**: `robinl9527`
- **Password**: 您的密码或访问令牌（推荐使用访问令牌）

> 💡 **推荐使用访问令牌**（更安全）:
> 1. 访问 https://hub.docker.com/settings/security
> 2. 创建新的访问令牌（Access Token）
> 3. 使用令牌作为密码

### 步骤 2: 推送镜像

```powershell
# 推送版本标签（预计 30 分钟 - 2 小时）
docker push robinl9527/runpod-comfyui-custom:v1.0.0

# 推送 latest 标签
docker push robinl9527/runpod-comfyui-custom:latest
```

**预计推送时间**: 
- 115 GB 镜像
- 取决于网络速度
- 通常需要 30 分钟到 2 小时

### 步骤 3: 验证推送成功

访问：
```
https://hub.docker.com/r/robinl9527/runpod-comfyui-custom
```

应该能看到两个标签：
- `v1.0.0`
- `latest`

---

## 在 RunPod 上使用

推送完成后，在 RunPod 上创建 Endpoint：

### 1. 创建 Template（推荐）

1. 访问：https://runpod.io/console/serverless/user/templates
2. 点击 "New Template"
3. 配置：
   - **Template Name**: `comfyui-custom`
   - **Template Type**: `serverless`
   - **Container Image**: `robinl9527/runpod-comfyui-custom:latest`
   - **Container Disk**: `120 GB`（镜像大小 115GB，建议设置 120GB+）
   - **Container Registry Credentials**: 默认（公开镜像）
4. 点击 "Save Template"

### 2. 创建 Endpoint

1. 访问：https://www.runpod.io/console/serverless/user/endpoints
2. 点击 "New Endpoint"
3. 配置：
   - **Endpoint Name**: `comfyui-custom`
   - **GPU Type**: RTX 4090 (24GB) 或更高
   - **Active Workers**: `0`
   - **Max Workers**: `3`
   - **GPUs/Worker**: `1`
   - **Idle Timeout**: `5`
   - **Flash Boot**: `enabled`
   - **Select Template**: `comfyui-custom`（或直接在 Container Image 输入镜像名）
4. 点击 "Deploy"

### 3. 获取 Endpoint ID 和 API Key

- **Endpoint ID**: 在 Endpoint 详情页查看
- **API Key**: https://www.runpod.io/console/serverless/user/settings → API Keys

### 4. 测试 Endpoint

```powershell
$endpointId = "your-endpoint-id"
$apiKey = "your-api-key"
$url = "https://api.runpod.ai/v2/$endpointId/runsync"

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
}

$body = Get-Content "test_input copy 4.json" -Raw
$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$response | ConvertTo-Json -Depth 10
```

---

## 重要提醒

⚠️ **镜像大小**: 115 GB
- 确保 Container Disk 设置为 **120 GB 或更大**
- 推送时间较长，请保持网络稳定
- 如果推送中断，可以重新运行 `docker push` 命令（支持断点续传）

---

## 完整命令清单

```powershell
# 1. 登录 Docker Hub
docker login

# 2. 推送镜像
docker push robinl9527/runpod-comfyui-custom:v1.0.0
docker push robinl9527/runpod-comfyui-custom:latest

# 3. 验证（在浏览器中）
# https://hub.docker.com/r/robinl9527/runpod-comfyui-custom
```

---

## 构建统计

- **构建总时间**: 约 5 小时（包含所有模型下载）
- **镜像层数**: 6 层
- **包含内容**:
  - ✅ 自定义 handler.py（URL 下载、路径标准化）
  - ✅ 7 个自定义节点
  - ✅ 2 个大模型（WAN2.2 + SDXL）
  - ✅ 25+ 个 LoRA 模型

