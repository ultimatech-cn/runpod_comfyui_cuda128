# RunPod tests.json 测试配置指南

## 📋 tests.json 的作用

`tests.json` 文件用于 RunPod Hub 的自动化测试。当您创建 Release 后，RunPod 会自动运行这些测试来验证您的端点是否正常工作。

**测试通过标准**: 端点返回 200 响应即可。

## ✅ 您的当前配置分析

### 优点

1. **简单有效**: 只测试基本功能（加载图片 → 保存图片）
2. **快速执行**: 不需要运行复杂的 AI 模型，测试速度快
3. **符合要求**: RunPod Hub 只需要返回 200 响应即可

### ⚠️ 发现的问题

**图片名称不匹配**：
- 输入图片名称：`test_img.jpg`
- LoadImage 节点中使用：`微信图片_20251020123908_8841_5.jpg`

**已修正**: 将 LoadImage 中的图片名称改为 `test_img.jpg`，与输入名称一致。

### 测试名称建议

已从 `test_sdxl_i2i` 改为 `test_basic_workflow`，更准确地反映测试内容。

## 📝 测试配置说明

### 当前测试（Dummy Test）

```json
{
  "name": "test_basic_workflow",
  "input": {
    "images": [
      {
        "name": "test_img.jpg",
        "image": "https://pic.imgdd.cc/item/69071860c1e67097311264a1.jpg"
      }
    ],
    "workflow": {
      "1": { "LoadImage" },
      "2": { "SaveImage" }
    }
  },
  "timeout": 600000
}
```

**测试内容**:
- ✅ 验证 URL 图片下载功能
- ✅ 验证图片上传到 ComfyUI
- ✅ 验证工作流执行
- ✅ 验证图片保存和返回

**优点**:
- ✅ 简单快速
- ✅ 不依赖模型（即使模型未下载也能测试基本功能）
- ✅ 适合验证端点基本可用性

## 🎯 测试策略建议

### 方案 1: 最简单的 Dummy Test（当前，推荐）

**适用场景**: 
- RunPod Hub 验证（只需要返回 200）
- 快速验证端点可用性
- 模型下载可能尚未完成时

**测试内容**:
- LoadImage → SaveImage（无 AI 处理）

**优点**:
- ✅ 最快
- ✅ 不依赖模型
- ✅ 验证基本功能

### 方案 2: 最小功能测试（可选）

如果需要验证实际 AI 功能，可以添加一个简单的生成测试：

```json
{
  "name": "test_simple_generation",
  "input": {
    "workflow": {
      "1": {
        "inputs": {
          "ckpt_name": "SDXL/ultraRealisticByStable_v20FP16.safetensors"
        },
        "class_type": "CheckpointLoaderSimple"
      },
      "2": {
        "inputs": {
          "text": "a simple test image",
          "clip": ["1", 1]
        },
        "class_type": "CLIPTextEncode"
      },
      "3": {
        "inputs": {
          "seed": 12345,
          "steps": 4,
          "cfg": 7,
          "sampler_name": "euler",
          "scheduler": "normal",
          "denoise": 1,
          "model": ["1", 0],
          "positive": ["2", 0],
          "negative": ["2", 0],
          "latent_image": ["4", 0]
        },
        "class_type": "KSampler"
      },
      "4": {
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage"
      },
      "5": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["1", 2]
        },
        "class_type": "VAEDecode"
      },
      "6": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["5", 0]
        },
        "class_type": "SaveImage"
      }
    }
  },
  "timeout": 300000
}
```

**注意**: 这个测试需要模型已下载，适合模型下载完成后验证。

## ⚙️ 配置说明

### 必需字段

- `name`: 测试名称（字符串）
- `input`: 输入数据（对象）
- `timeout`: 超时时间（毫秒，可选）

### 环境配置

```json
"config": {
  "gpuTypeId": "NVIDIA GeForce RTX 4090",  // GPU 类型
  "gpuCount": 1,                            // GPU 数量
  "env": [                                   // 环境变量
    {
      "key": "REFRESH_WORKER",
      "value": "false"
    }
  ],
  "allowedCudaVersions": [                  // 允许的 CUDA 版本
    "12.8", "12.7", "12.6"
  ]
}
```

## ✅ 当前配置评估

### 优点

1. ✅ **简单有效**: 只测试基本功能，速度快
2. ✅ **不依赖模型**: 即使模型未下载也能测试
3. ✅ **符合 Hub 要求**: 返回 200 响应即可通过
4. ✅ **图片名称已修正**: LoadImage 使用正确的图片名称

### 建议

1. ✅ **保持简单**: 对于 RunPod Hub 验证，简单的 dummy test 足够了
2. ✅ **名称已更新**: `test_basic_workflow` 更准确
3. ✅ **超时设置合理**: 600000ms (10分钟) 足够

## 🎯 总结

**您的修改是正确的！** 

- ✅ 简单的 dummy test 完全适合 RunPod Hub 验证
- ✅ 已修正图片名称不匹配的问题
- ✅ 测试名称更准确
- ✅ 配置符合 RunPod 要求

对于 RunPod Hub 的自动化测试，**简单的测试就足够了**。重点是验证端点能够：
1. 接收请求
2. 处理工作流
3. 返回结果（200 响应）

您的配置已经满足了这些要求！

