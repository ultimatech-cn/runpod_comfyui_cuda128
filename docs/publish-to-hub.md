# 发布到 RunPod Hub 指南

本指南将帮助您将自定义的 ComfyUI 环境发布到 RunPod Hub。

> **重要提示**: RunPod Hub 通过 GitHub Releases 索引您的仓库，而不是直接索引 Git commits。您必须先创建一个 GitHub Release 才能发布到 Hub。

## 前提条件

1. ✅ 已完成自定义 `Dockerfile` 配置
2. ✅ 已完成 `.runpod/hub.json` 配置
3. ✅ 已完成 `.runpod/tests.json` 配置
4. ✅ 拥有 RunPod 账户
5. ✅ 代码已推送到 GitHub 公开仓库

## 必需文件检查清单

在发布之前，请确保以下文件存在于您的仓库中：

### 必需文件（在根目录或 `.runpod` 目录）：
- ✅ **`Dockerfile`** - 用于构建容器镜像
- ✅ **`handler.py`** - RunPod Serverless 处理器脚本
- ✅ **`.runpod/hub.json`** - Hub 配置和元数据
- ✅ **`.runpod/tests.json`** - 测试配置（用于验证发布）

### 可选但推荐的文件：
- ✅ **`README.md`** - 项目说明文档（可以添加 RunPod Hub badge）

## 步骤 1: 准备并提交文件到 GitHub

1. **确保所有必需文件已提交**：
   ```bash
   git add .
   git commit -m "准备发布到 RunPod Hub"
   git push origin main
   ```

2. **验证文件结构**：
   您的仓库应该包含以下结构：
   ```
   您的仓库/
   ├── Dockerfile
   ├── handler.py
   ├── README.md
   └── .runpod/
       ├── hub.json
       └── tests.json
   ```

## 步骤 2: 通过 RunPod Hub UI 发布

根据官方文档，发布流程如下：

1. **访问 RunPod Hub 页面**：
   - 登录 [RunPod 控制台](https://www.runpod.io/console)
   - 导航到 [Hub 页面](https://www.console.runpod.io/hub)

2. **开始发布流程**：
   - 在页面上的 **"Add your repo"** 部分点击 **"Get Started"** 按钮

3. **输入 GitHub 仓库 URL**：
   - 输入您的 GitHub 仓库完整 URL（例如：`https://github.com/your-username/your-repo`）
   - 点击下一步

4. **RunPod 将自动检测并验证以下内容**：

   ### 📋 Hub Configuration（必需）
   - RunPod 会自动查找 `.runpod/hub.json` 文件
   - 验证配置正确性：
     - ✅ Title: "ComfyUI"
     - ✅ Description: "Custom ComfyUI environment with SDXL and Wan2.2 models..."
     - ✅ Type: "serverless"
     - ✅ Category: "image"
     - ✅ Container Disk: 80 GB
     - ✅ GPU: ADA_24
     - ✅ CUDA Versions: 12.8, 12.7, 12.6

   ### 🧪 Writing Tests（必需）
   - RunPod 会自动查找 `.runpod/tests.json` 文件
   - 验证测试配置是否正确
   - ⚠️ **注意**: 确保测试中的模型名称与您实际安装的模型匹配（当前测试配置使用的是 `flux1-dev-fp8.safetensors`，但您实际安装的是 SDXL 和 Wan2.2）

   ### 🐳 Dockerfile（必需）
   - RunPod 会验证 Dockerfile 是否存在
   - 构建过程会在创建 Release 后自动触发

   ### 🔧 Handler Script（必需）
   - RunPod 会验证 `handler.py` 是否存在
   - 这应该是您的 RunPod Serverless 处理器

   ### 🎖️ Badge（可选但推荐）
   - 可以在您的 `README.md` 中添加 RunPod Hub badge
   - Badge 格式：
     ```markdown
     [![RunPod](https://api.runpod.io/badge/your-username/your-repo-name)](https://www.runpod.io/console/hub/your-username/your-repo-name)
     ```

5. **创建 GitHub Release**（必需）：
   > ⚠️ **重要**: RunPod Hub 只索引 GitHub Releases，不索引普通 commits！
   
   - 在您的 GitHub 仓库中创建一个新的 Release：
     1. 访问您的 GitHub 仓库
     2. 点击 "Releases" > "Create a new release"
     3. 选择标签（例如：`v1.0.0`）
     4. 填写 Release 标题和描述
     5. 点击 "Publish release"
   
   - 创建 Release 后，RunPod Hub 会自动检测并开始构建过程

## 步骤 3: 等待构建和审核

1. **构建状态**：
   - 创建 Release 后，您的仓库状态会变为 **"Pending"**
   - RunPod 会自动构建 Docker 镜像并运行测试
   - 构建过程通常需要一段时间（可能长达一小时）

2. **测试验证**：
   - RunPod 会使用 `.runpod/tests.json` 中的配置自动运行测试
   - 测试必须返回 200 状态码才能通过

3. **人工审核**：
   - 测试通过后，RunPod 团队会进行人工审核
   - 审核通过后，您的模板将发布到 Hub

## 步骤 4: 更新仓库

当您需要更新已发布的模板时：

1. **创建新的 GitHub Release**：
   ```bash
   git add .
   git commit -m "更新模型或配置"
   git push origin main
   
   # 然后在 GitHub 上创建新的 Release
   ```

2. **自动更新**：
   - Hub 会自动检测新的 Release
   - 通常在发布后一小时内自动索引和构建

## 重要注意事项

### ⚠️ 测试配置更新
您的 `.runpod/tests.json` 中使用的模型是 `flux1-dev-fp8.safetensors`，但您实际安装的是：
- `ultraRealisticByStable_v20FP16.safetensors` (SDXL)
- `wan2.2-i2v-rapid-aio-v10-nsfw.safetensors` (Wan2.2)

**建议**: 更新测试配置以使用您实际安装的模型之一，否则测试可能会失败。

### 📦 容器磁盘大小
当前配置为 80 GB，已根据您的模型和节点需求进行调整。

### 🔑 环境变量
您的 `hub.json` 已配置了所有必要的环境变量，用户可以在部署时进行配置。

## 当前配置总结

### 已安装的自定义节点：
- PuLID_ComfyUI
- ComfyUI-ReActor
- rgthree-comfy
- ComfyUI-KJNodes
- ComfyUI-Manager
- was-node-suite-comfyui
- ComfyUI-Crystools

### 已安装的主要模型：
- **SDXL Checkpoint**: `ultraRealisticByStable_v20FP16.safetensors`
- **Wan2.2 Checkpoint**: `wan2.2-i2v-rapid-aio-v10-nsfw.safetensors`
- **CLIP Vision**: `clip_vision_h.safetensors` (Wan2.2)
- **IP-Adapter**: `ip-adapter_pulid_sdxl_fp16.safetensors`
- **ReActor 模型**: `inswapper_128.onnx`, `reswapper_128.onnx`
- **FaceRestore 模型**: `GFPGANv1.4.pth`, `GPEN-BFR-512.onnx`
- **多个 LoRA**（SDXL 和 Wan2.2）

### 系统要求：
- **容器磁盘**: 80 GB
- **GPU**: NVIDIA Ada (ADA_24) 或更高
- **CUDA**: 12.8, 12.7, 或 12.6

## 故障排除

### 构建失败
- 检查 `Dockerfile` 中的 URL 是否正确
- 确认模型下载链接仍然有效
- 验证 `comfy-node-install` 命令语法

### 镜像过大
- 考虑使用网络卷（Network Volume）存储大型模型
- 参考 [Customization Guide](customization.md#method-2-network-volume) 了解详情

### 发布被拒绝
- 检查 `.runpod/hub.json` 格式是否正确
- 确保描述清晰且准确
- 验证所有必需的字段都已填写

## 相关文档

- [Customization Guide](customization.md) - 自定义环境详细说明
- [Deployment Guide](deployment.md) - 部署端点指南
- [Configuration Guide](configuration.md) - 环境变量配置
- [RunPod Hub Documentation](https://docs.runpod.io/hub) - RunPod 官方文档

