![ComfyUI Worker Banner](https://cpjrphpz3t5wbwfe.public.blob.vercel-storage.com/worker-comfyui_banner-CDZ6JIEByEePozCT1ZrmeVOsN5NX3U.jpeg)

---

Run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) workflows as a serverless endpoint.

---

[![RunPod](https://api.runpod.io/badge/runpod-workers/worker-comfyui)](https://www.runpod.io/console/hub/runpod-workers/worker-comfyui)

---

## What is included?

This custom ComfyUI worker includes:

### Pre-installed Models:
- **SDXL Checkpoint**: `ultraRealisticByStable_v20FP16.safetensors`
- **Wan2.2 Checkpoint**: `wan2.2-i2v-rapid-aio-v10-nsfw.safetensors`
- **CLIP Vision**: `clip_vision_h.safetensors` (for Wan2.2)
- **IP-Adapter**: `ip-adapter_pulid_sdxl_fp16.safetensors` (for SDXL)
- **ReActor Models**: `inswapper_128.onnx`, `reswapper_128.onnx`, `hyperswap_1a/b/c_256.onnx`
- **FaceRestore Models**: `GFPGANv1.4.pth`, `GPEN-BFR-512.onnx`
- **Multiple LoRAs**: SDXL and Wan2.2 LoRAs for various styles and effects

### Custom Nodes:
- **PuLID_ComfyUI** - Advanced face control
- **ComfyUI-ReActor** - Face swapping and restoration
- **rgthree-comfy** - Additional utility nodes
- **ComfyUI-KJNodes** - Enhanced workflow nodes
- **ComfyUI-Manager** - Node and model management
- **was-node-suite-comfyui** - Advanced image processing
- **ComfyUI-Crystools** - Workflow utilities

## Usage

The worker accepts the following input parameters:

| Parameter  | Type     | Default | Required | Description                                                                                                                                                                                                                                    |
| :--------- | :------- | :------ | :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `workflow` | `object` | `None`  | **Yes**  | The entire ComfyUI workflow in the API JSON format. See the main project [README.md](https://github.com/runpod-workers/worker-comfyui#how-to-get-the-workflow-from-comfyui) for instructions on how to export this from the ComfyUI interface. |
| `images`   | `array`  | `[]`    | No       | An optional array of input images. Each image object should contain `name` (string, required, filename to reference in the workflow) and `image` (string, required, base64-encoded image data **or** HTTP/HTTPS URL to the image).                                                |

> [!NOTE]
> The `input.images` array supports two formats:
> - **Base64 encoded string**: Use `data:image/png;base64,<base64_string>` or just `<base64_string>`
> - **Image URL**: Use `http://` or `https://` URL to the image (handler will download automatically)
> 
> **Size Constraints**: RunPod API limits (10MB for `/run`, 20MB for `/runsync`) apply to the entire request. Using image URLs instead of base64 can significantly reduce request size. See the main [README.md](https://github.com/runpod-workers/worker-comfyui#inputimages) for details.

### Example Request

This example shows a simplified SDXL image-to-image workflow using an image URL:

```json
{
  "input": {
    "images": [
      {
        "name": "test_img.jpg",
        "image": "https://pic.imgdd.cc/item/69071860c1e67097311264a1.jpg"
      }
    ],
    "workflow": {
      "3": {
        "inputs": {
          "seed": 814583843642114,
          "steps": 8,
          "cfg": 1.1,
          "sampler_name": "lcm",
          "scheduler": "exponential",
          "denoise": 1,
          "model": ["4", 0],
          "positive": ["22", 0],
          "negative": ["23", 0],
          "latent_image": ["46", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "4": {
        "inputs": {
          "ckpt_name": "SDXL\\ultraRealisticByStable_v20FP16.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "8": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "12": {
        "inputs": {
          "image": "test_img.jpg"
        },
        "class_type": "LoadImage",
        "_meta": {
          "title": "Load Image"
        }
      },
      "22": {
        "inputs": {
          "text": "a beautiful woman, high quality, detailed",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "23": {
        "inputs": {
          "text": "lowres, low quality, worst quality, artifacts",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Negative Prompt)"
        }
      },
      "46": {
        "inputs": {
          "dimensions": " 832 x 1216  (portrait)",
          "clip_scale": 1,
          "batch_size": 1
        },
        "class_type": "SDXL Empty Latent Image (rgthree)",
        "_meta": {
          "title": "SDXL Empty Latent Image (rgthree)"
        }
      },
      "112": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      }
    }
  }
}
```

### Example Response

```json
{
  "id": "sync-uuid-string",
  "status": "COMPLETED",
  "output": {
    "images": [
      {
        "filename": "ComfyUI_00001_.png",
        "type": "base64",
        "data": "iVBORw0KGgoAAAANSUhEUg..."
      }
    ]
  },
  "delayTime": 123,
  "executionTime": 4567
}
```

> **Note**: The output format changed in version 5.0.0+. Images are returned as an array in `output.images`. Each image object contains `filename`, `type` (either `"base64"` or `"s3_url"`), and `data` (the base64 string or S3 URL).
