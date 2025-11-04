#!/usr/bin/env bash

# Model download script
# Downloads models at container startup to avoid long build times
# Uses caching to avoid re-downloading if models already exist

set -e

COMFYUI_PATH="${COMFYUI_PATH:-/comfyui}"
MODELS_DIR="${COMFYUI_PATH}/models"

echo "========================================="
echo "Model Download Script"
echo "========================================="
echo ""

# Function to download a model if it doesn't exist
download_model() {
    local url=$1
    local output_path=$2
    local filename=$(basename "$output_path")
    local dir=$(dirname "$output_path")
    
    # Create directory if it doesn't exist
    mkdir -p "$dir"
    
    # Check if file already exists
    if [ -f "$output_path" ]; then
        echo "✓ Model already exists: $filename"
        return 0
    fi
    
    echo "Downloading: $filename"
    echo "  URL: $url"
    echo "  Path: $output_path"
    
    # Download with wget, retry on failure
    local retries=3
    local count=0
    while [ $count -lt $retries ]; do
        if wget -q --show-progress -O "$output_path" "$url"; then
            echo "✓ Successfully downloaded: $filename"
            return 0
        else
            count=$((count + 1))
            if [ $count -lt $retries ]; then
                echo "⚠ Retry $count/$retries: $filename"
                sleep 2
            else
                echo "✗ Failed to download after $retries attempts: $filename"
                return 1
            fi
        fi
    done
}

# Function to download and extract zip file
download_and_extract_zip() {
    local url=$1
    local extract_dir=$2
    local zip_file="/tmp/$(basename $url)"
    
    mkdir -p "$extract_dir"
    
    # Check if already extracted (simple check - if directory has files)
    if [ "$(ls -A $extract_dir 2>/dev/null)" ]; then
        echo "✓ Zip contents already extracted: $(basename $extract_dir)"
        return 0
    fi
    
    echo "Downloading and extracting: $(basename $url)"
    
    if wget -q --show-progress -O "$zip_file" "$url"; then
        unzip -q -o "$zip_file" -d "$extract_dir" && \
        rm -f "$zip_file" && \
        echo "✓ Successfully extracted: $(basename $extract_dir)" && \
        return 0
    else
        echo "✗ Failed to download: $(basename $url)"
        rm -f "$zip_file"
        return 1
    fi
}

echo "Creating model directories..."
mkdir -p \
    "$MODELS_DIR/checkpoints/SDXL" \
    "$MODELS_DIR/checkpoints/Wan2.2" \
    "$MODELS_DIR/clip_vision/wan" \
    "$MODELS_DIR/pulid" \
    "$MODELS_DIR/insightface" \
    "$MODELS_DIR/reswapper" \
    "$MODELS_DIR/hyperswap" \
    "$MODELS_DIR/facerestore_models" \
    "$MODELS_DIR/upscale_models" \
    "$MODELS_DIR/loras/SDXL" \
    "$MODELS_DIR/loras/Wan2.2" \
    "$MODELS_DIR/insightface/models/antelopev2"

echo ""
echo "Starting model downloads..."
echo ""

# InsightFace AntelopeV2 models (zip file)
download_and_extract_zip \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/buffalo_l.zip" \
    "$MODELS_DIR/insightface/models/"

# Checkpoint models
download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/SDXL/ultraRealisticByStable_v20FP16.safetensors" \
    "$MODELS_DIR/checkpoints/SDXL/ultraRealisticByStable_v20FP16.safetensors"

download_model \
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors" \
    "$MODELS_DIR/checkpoints/Wan2.2/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors"

# Clip vision models
download_model \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
    "$MODELS_DIR/clip_vision/wan/clip_vision_h.safetensors"

# PuLID models
download_model \
    "https://huggingface.co/huchenlei/ipadapter_pulid/resolve/main/ip-adapter_pulid_sdxl_fp16.safetensors" \
    "$MODELS_DIR/pulid/ip-adapter_pulid_sdxl_fp16.safetensors"

# InsightFace models
download_model \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128.onnx" \
    "$MODELS_DIR/insightface/inswapper_128.onnx"

# Reswapper models
download_model \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/reswapper_128.onnx" \
    "$MODELS_DIR/reswapper/reswapper_128.onnx"

# Hyperswap models
download_model \
    "https://huggingface.co/facefusion/models-3.3.0/resolve/main/hyperswap_1a_256.onnx" \
    "$MODELS_DIR/hyperswap/hyperswap_1a_256.onnx"

download_model \
    "https://huggingface.co/facefusion/models-3.3.0/resolve/main/hyperswap_1b_256.onnx" \
    "$MODELS_DIR/hyperswap/hyperswap_1b_256.onnx"

download_model \
    "https://huggingface.co/facefusion/models-3.3.0/resolve/main/hyperswap_1c_256.onnx" \
    "$MODELS_DIR/hyperswap/hyperswap_1c_256.onnx"

# Face restore models
download_model \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.4.pth" \
    "$MODELS_DIR/facerestore_models/GFPGANv1.4.pth"

download_model \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GPEN-BFR-512.onnx" \
    "$MODELS_DIR/facerestore_models/GPEN-BFR-512.onnx"

# SDXL LoRA models
download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/SDXL/subtle-analsex-xl3.safetensors" \
    "$MODELS_DIR/loras/SDXL/subtle-analsex-xl3.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/SDXL/LCMV2-PONYplus-PAseer.safetensors" \
    "$MODELS_DIR/loras/SDXL/LCMV2-PONYplus-PAseer.safetensors"

# Wan2.2 LoRA models
download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/DR34MJOB_I2V_14b_HighNoise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/DR34MJOB_I2V_14b_HighNoise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/DR34MJOB_I2V_14b_LowNoise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/DR34MJOB_I2V_14b_LowNoise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/W22_NSFW_Posing_Nude_i2v_HN_v1.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/W22_NSFW_Posing_Nude_i2v_HN_v1.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/W22_NSFW_Posing_Nude_i2v_LN_v1.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/W22_NSFW_Posing_Nude_i2v_LN_v1.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/huge-titfuck-high.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/huge-titfuck-high.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/huge-titfuck-low.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/huge-titfuck-low.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/mql_massage_tits_wan22_i2v_v1_high_noise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/mql_massage_tits_wan22_i2v_v1_high_noise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/mql_massage_tits_wan22_i2v_v1_low_noise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/mql_massage_tits_wan22_i2v_v1_low_noise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/nsfw_wan_14b_spooning_leg_lifted_sex_position.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/nsfw_wan_14b_spooning_leg_lifted_sex_position.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/pworship_high_noise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/pworship_high_noise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/pworship_low_noise.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/pworship_low_noise.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/spanking_for_wan_v1_e128.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/spanking_for_wan_v1_e128.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/sockjob_wan_v1.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/sockjob_wan_v1.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan-thiccum-v3.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan-thiccum-v3.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan2.2-i2v-high-oral-insertion-v1.0.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan2.2-i2v-high-oral-insertion-v1.0.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan2.2-i2v-low-oral-insertion-v1.0.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan2.2-i2v-low-oral-insertion-v1.0.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan22-jellyhips-i2v-13epoc-high-k3nk.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan22-jellyhips-i2v-13epoc-high-k3nk.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan22-jellyhips-i2v-23epoc-low-k3nk.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan22-jellyhips-i2v-23epoc-low-k3nk.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/wan_shoejob_footjob_14B_v10_e15.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/wan_shoejob_footjob_14B_v10_e15.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/zurimix-high-i2v.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/zurimix-high-i2v.safetensors"

download_model \
    "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/Wan22/zurimix-low-i2v.safetensors" \
    "$MODELS_DIR/loras/Wan2.2/zurimix-low-i2v.safetensors"

echo ""
echo "========================================="
echo "✓ Model download completed!"
echo "========================================="
echo ""

