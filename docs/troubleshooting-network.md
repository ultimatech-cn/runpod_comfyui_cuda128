# Docker 网络连接问题排查

## 问题现象

```
ERROR: failed to solve: failed to fetch oauth token: Post "https://auth.docker.io/token": 
dial tcp [2a03:2880:f12d:83:face:b00c:0:25de]:443: connectex: A connection attempt failed...
```

这是典型的 Docker Hub 网络连接问题，通常是 IPv6 连接失败导致的。

## 解决方案

### 方案 1: 重试构建（最简单）

网络问题可能是暂时的，直接重试：

```powershell
docker build --platform linux/amd64 -t robinl9527/runpod-comfyui-custom:v1.0.0 .
```

### 方案 2: 禁用 IPv6（推荐）

在 Docker Desktop 中禁用 IPv6：

1. 打开 Docker Desktop
2. 点击右上角 ⚙️ Settings
3. 进入 Docker Engine
4. 在 JSON 配置中添加：

```json
{
  "ipv6": false,
  "fixed-cidr-v6": ""
}
```

5. 点击 "Apply & Restart"
6. 重新构建

### 方案 3: 配置代理（如果在中国大陆）

如果您在中国大陆，可能需要配置代理：

1. Docker Desktop → Settings → Resources → Proxies
2. 配置 HTTP/HTTPS 代理
3. 或者在 Dockerfile 中暂时使用镜像源

### 方案 4: 手动拉取基础镜像

先手动拉取基础镜像，然后再构建：

```powershell
# 手动拉取基础镜像
docker pull runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# 然后再构建
docker build --platform linux/amd64 -t robinl9527/runpod-comfyui-custom:v1.0.0 .
```

### 方案 5: 检查 DNS

如果问题持续，检查 DNS 设置：

```powershell
# 检查当前 DNS
ipconfig /all | findstr DNS

# 尝试使用公共 DNS
# 在 Docker Desktop Settings → Docker Engine 中添加：
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

## 快速修复脚本

```powershell
# 1. 禁用 IPv6（需要重启 Docker Desktop）
# 在 Docker Desktop Settings → Docker Engine 中添加：
# { "ipv6": false }

# 2. 手动拉取基础镜像
docker pull runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# 3. 重试构建
docker build --platform linux/amd64 -t robinl9527/runpod-comfyui-custom:v1.0.0 .
```

