# 启动时下载模型（最佳实践）

## 🎯 为什么在启动时下载模型？

参考社区最佳实践（如 [MultiTalk RunPod Hub](https://github.com/wlsdml1114/Multitalk_Runpod_hub)），**不在 Dockerfile 中下载模型，而是在容器启动时下载**。

### ✅ 优势

1. **大幅减少构建时间**
   - 从 1.5-5 小时 → 5-30 分钟
   - 不需要等待模型下载完成

2. **镜像更小**
   - 基础镜像：约 5-10 GB
   - 包含模型：约 70-90 GB
   - **节省约 60-80 GB 镜像大小**

3. **更灵活**
   - 可以动态更新模型列表而不重建镜像
   - 可以按需下载模型
   - 支持使用 Network Volume 缓存模型

4. **更快的迭代**
   - 修改代码后快速重新构建
   - 不需要每次都下载模型

5. **更好的缓存利用**
   - RunPod 的 Container Disk 可以缓存模型
   - 模型下载一次，后续启动更快

### ⚠️ 注意事项

1. **首次启动时间**
   - 首次启动需要下载模型（约 1-4 小时）
   - 后续启动会检查已存在的模型，跳过下载

2. **网络依赖**
   - 容器启动时需要网络连接
   - 如果网络不稳定，可能需要重试

3. **容器磁盘大小**
   - 需要确保 Container Disk 足够大（80-100 GB）
   - 模型会存储在容器磁盘中

---

## 🔧 实现方式

### 1. 模型下载脚本 (`src/download-models.sh`)

创建独立的模型下载脚本，包含：
- 所有模型的下载逻辑
- 文件存在检查（避免重复下载）
- 重试机制
- 清晰的进度显示

### 2. 修改启动脚本 (`src/start.sh`)

在启动 ComfyUI 之前调用模型下载脚本：

```bash
# 下载模型（如果启用）
if [ "${DOWNLOAD_MODELS_ON_STARTUP:-true}" == "true" ]; then
    bash /download-models.sh
fi

# 然后启动 ComfyUI
python -u /comfyui/main.py ...
```

### 3. 环境变量控制

可以通过环境变量控制是否下载模型：

- `DOWNLOAD_MODELS_ON_STARTUP=true`（默认）：启动时下载模型
- `DOWNLOAD_MODELS_ON_STARTUP=false`：跳过模型下载

**在 RunPod 中设置**：
- Template → Environment Variables → `DOWNLOAD_MODELS_ON_STARTUP=false`

---

## 📊 对比

| 特性 | Dockerfile 下载 | 启动时下载 |
|------|----------------|-----------|
| **构建时间** | 1.5-5 小时 | 5-30 分钟 |
| **镜像大小** | 70-90 GB | 5-10 GB |
| **首次启动** | 立即可用 | 需要等待下载 |
| **后续启动** | 立即可用 | 检查缓存，跳过下载 |
| **模型更新** | 需要重建镜像 | 修改脚本，重启容器 |
| **灵活性** | 低 | 高 |
| **推荐度** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🚀 使用方式

### 默认行为（推荐）

容器启动时自动下载所有模型：

```bash
# 无需设置环境变量，默认行为
# 首次启动：下载模型（1-4 小时）
# 后续启动：检查缓存，快速启动
```

### 禁用自动下载

如果使用 Network Volume 或手动管理模型：

```bash
# 在 RunPod Template 中设置环境变量
DOWNLOAD_MODELS_ON_STARTUP=false
```

### 使用 Network Volume

1. 创建 Network Volume（S3 或其他）
2. 将模型预先下载到 Volume
3. 在 ComfyUI 中配置模型路径指向 Volume
4. 设置 `DOWNLOAD_MODELS_ON_STARTUP=false`

---

## 🔍 下载脚本特性

### 智能缓存

```bash
# 检查文件是否存在
if [ -f "$output_path" ]; then
    echo "✓ Model already exists: $filename"
    return 0
fi
```

### 自动重试

```bash
# 失败时自动重试 3 次
local retries=3
while [ $count -lt $retries ]; do
    if wget ...; then
        return 0
    else
        # 重试逻辑
    fi
done
```

### 进度显示

```bash
# 显示下载进度
wget -q --show-progress -O "$output_path" "$url"
```

---

## 📝 最佳实践建议

### 1. 首次部署

- 使用默认行为（自动下载模型）
- 等待首次启动完成（下载所有模型）
- 后续启动会很快

### 2. 生产环境

- 考虑使用 Network Volume 存储模型
- 预先下载模型到 Volume
- 设置 `DOWNLOAD_MODELS_ON_STARTUP=false`
- 更快启动，更稳定

### 3. 开发测试

- 使用默认行为
- 快速迭代代码
- 不需要等待长时间构建

---

## 🆚 与 Dockerfile 下载对比

### Dockerfile 方式（旧）

```dockerfile
# 构建时下载（耗时）
RUN wget -q -O $COMFYUI_PATH/models/... "https://..."
```

**问题**：
- ❌ 构建时间：1.5-5 小时
- ❌ 镜像大小：70-90 GB
- ❌ 每次修改代码都需要重新下载模型

### 启动时下载（新，推荐）

```dockerfile
# 只复制脚本，不下载模型
COPY src/download-models.sh /download-models.sh
COPY src/start.sh /start.sh
```

```bash
# start.sh 在启动时调用下载脚本
bash /download-models.sh
```

**优势**：
- ✅ 构建时间：5-30 分钟
- ✅ 镜像大小：5-10 GB
- ✅ 模型下载只在首次启动时进行
- ✅ 后续启动检查缓存，快速启动

---

## 💡 总结

**启动时下载模型是更好的实践**，特别适合：
- ✅ 快速迭代开发
- ✅ 频繁更新代码
- ✅ 需要灵活管理模型
- ✅ 希望镜像更小、构建更快

**Dockerfile 中下载模型适合**：
- ✅ 模型完全固定，不会变化
- ✅ 需要离线部署
- ✅ 镜像必须包含所有依赖

对于 ComfyUI 这种需要大量模型的场景，**启动时下载是更明智的选择**！

