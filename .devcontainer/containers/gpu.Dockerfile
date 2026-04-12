# =============================
# GPU container
# =============================
# This image is intended to extend the CPU baseline with GPU-related utilities.
FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MPLBACKEND=Agg

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    libdbus-1-3 \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    libsm6 \
    libxext6 \
    libxkbcommon0 \
    lsb-release \
    sudo \
    wget \
    zsh \
    zstd \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Best-effort NVIDIA utilities installation from distro repositories.
RUN set -e; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
      sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources || true; \
    fi; \
    apt-get update -y; \
    candidate="$(apt-cache policy nvidia-smi | awk '/Candidate:/ { print $2; exit }')"; \
    if [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; then \
      apt-get install -y --no-install-recommends nvidia-smi; \
    else \
      echo "nvidia-smi not available in current repos; GPU passthrough still works via --gpus all."; \
    fi; \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir uv
RUN curl -fsSL https://ollama.com/install.sh | sh

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /workspaces/llm_engineering

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell

CMD ["zsh"]
