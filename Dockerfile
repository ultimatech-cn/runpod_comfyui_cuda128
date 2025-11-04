# start from a clean base image (replace <version> with the desired [release](https://github.com/runpod-workers/worker-comfyui/releases))
FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# Set environment variables for better maintainability
ENV COMFYUI_PATH=/comfyui
ENV DEBIAN_FRONTEND=noninteractive

# Copy custom handler.py to override the base image's handler
# This allows you to use your enhanced handler with URL image support and path normalization
COPY handler.py /handler.py

# Ensure required tools are installed (wget, git, unzip should already be in base image, but verify)
# Note: build-essential, g++, and python3-dev are needed to compile insightface (Cython/C++ extensions)
# python3-dev provides Python.h header files needed for compiling Python extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        git \
        unzip \
        ffmpeg \
        curl \
        ca-certificates \
        build-essential \
        g++ \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create all necessary model directories upfront
RUN mkdir -p \
    $COMFYUI_PATH/models/checkpoints/SDXL \
    $COMFYUI_PATH/models/checkpoints/Wan2.2 \
    $COMFYUI_PATH/models/clip_vision/wan \
    $COMFYUI_PATH/models/pulid \
    $COMFYUI_PATH/models/insightface \
    $COMFYUI_PATH/models/reswapper \
    $COMFYUI_PATH/models/hyperswap \
    $COMFYUI_PATH/models/facerestore_models \
    $COMFYUI_PATH/models/upscale_models \
    $COMFYUI_PATH/models/loras/SDXL \
    $COMFYUI_PATH/models/loras/Wan2.2 \
    $COMFYUI_PATH/models/insightface/models/antelopev2

# Install all custom nodes in a single RUN block (optimizes Docker layers)
# Each node installs its requirements.txt if it exists
# Note: Using python3 instead of /venv/bin/python as the base image may not have /venv
# Remove existing directories before cloning to avoid "already exists" errors
# Configure git to avoid credential prompts and handle network issues
RUN git config --global --add safe.directory '*' && \
    git config --global credential.helper '' && \
    git config --global url."https://github.com/".insteadOf git@github.com: && \
    git config --global http.sslVerify true && \
    git config --global http.postBuffer 524288000 && \
    cd $COMFYUI_PATH/custom_nodes && \
    # Install ComfyUI-ReActor (ReActor Face Swap)
    rm -rf ComfyUI-ReActor && \
    git clone --depth 1 https://github.com/Gourieff/ComfyUI-ReActor.git ComfyUI-ReActor && \
    (cd ComfyUI-ReActor && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install rgthree-comfy
    rm -rf rgthree-comfy && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git rgthree-comfy && \
    (cd rgthree-comfy && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Manager
    rm -rf ComfyUI-Manager && \
    git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager.git ComfyUI-Manager && \
    (cd ComfyUI-Manager && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install was-node-suite-comfyui
    rm -rf was-node-suite-comfyui && \
    git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui.git was-node-suite-comfyui && \
    (cd was-node-suite-comfyui && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Crystools
    rm -rf ComfyUI-Crystools && \
    (git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools || \
     (sleep 2 && git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools)) && \
    (cd ComfyUI-Crystools && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-KJNodes
    rm -rf comfyui-kjnodes && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git comfyui-kjnodes && \
    (cd comfyui-kjnodes && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-VideoHelperSuite
    rm -rf comfyui-videohelpersuite && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git comfyui-videohelpersuite && \
    (cd comfyui-videohelpersuite && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install PuLID_ComfyUI
    rm -rf PuLID_ComfyUI && \
    git clone --depth 1 https://github.com/cubiq/PuLID_ComfyUI.git PuLID_ComfyUI && \
    (cd PuLID_ComfyUI && \
     ([ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
     python3 -m pip install --no-cache-dir facexlib || true) && \
    \
    cd $COMFYUI_PATH

# Copy model download script (models will be downloaded at container startup, not during build)
# This significantly reduces build time from hours to minutes
COPY src/download-models.sh /download-models.sh
RUN chmod +x /download-models.sh

# Copy custom start.sh that calls download script before starting ComfyUI
COPY src/start.sh /start.sh
RUN chmod +x /start.sh


