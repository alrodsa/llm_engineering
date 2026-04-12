#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${DEVCONTAINER_DIR}/variables/.host-gpu.env"
mkdir -p "$(dirname "${OUTPUT_FILE}")"

log_info() {
    echo "ℹ️  $1"
}

log_ok() {
    echo "✅ $1"
}

log_warn() {
    echo "⚠️  $1"
}

has_nvidia_gpu=false
has_nvidia_runtime=false
detection_method="none"

os_name="$(uname -s 2>/dev/null || echo "unknown")"
linux_distro_id=""

if [ -f /etc/os-release ]; then
    linux_distro_id="$(grep '^ID=' /etc/os-release | head -1 | cut -d'=' -f2 | tr -d '"')"
fi

runtime_hint="Install NVIDIA Container Toolkit and restart Docker."

if [ "$os_name" = "Linux" ]; then
    case "$linux_distro_id" in
        ubuntu|debian)
            runtime_hint="Run NVIDIA's apt-based install for nvidia-container-toolkit, then restart Docker. See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html"
            ;;
        rhel|centos|fedora|rocky|almalinux)
            runtime_hint="Run NVIDIA's dnf/yum-based install for nvidia-container-toolkit, then restart Docker. See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html"
            ;;
        *)
            runtime_hint="Install nvidia-container-toolkit for your distro and restart Docker. See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html"
            ;;
    esac
elif [ "$os_name" = "Darwin" ]; then
    runtime_hint="Docker Desktop on macOS cannot pass through local NVIDIA GPUs. Use CPU profile or a Linux/WSL2 host with NVIDIA runtime."
elif [[ "$os_name" == MINGW* || "$os_name" == MSYS* || "$os_name" == CYGWIN* || "$os_name" == "Windows_NT" ]]; then
    runtime_hint="On Windows, use Docker Desktop with WSL2 and install NVIDIA Container Toolkit in the WSL2 environment."
fi

if command -v nvidia-smi >/dev/null 2>&1; then
    if nvidia-smi -L >/dev/null 2>&1; then
        has_nvidia_gpu=true
        detection_method="nvidia-smi"
    fi
elif [ -c /dev/nvidiactl ] || [ -d /proc/driver/nvidia ]; then
    has_nvidia_gpu=true
    detection_method="nvidia-device-files"
fi

if command -v docker >/dev/null 2>&1; then
    if docker info --format '{{json .Runtimes}}' 2>/dev/null | grep -qi 'nvidia'; then
        has_nvidia_runtime=true
    fi
fi

gpu_profile="cpu"
if [ "$has_nvidia_gpu" = true ]; then
    gpu_profile="nvidia"
fi

cat > "$OUTPUT_FILE" <<EOF
DEVCONTAINER_HAS_NVIDIA_GPU=${has_nvidia_gpu}
DEVCONTAINER_HAS_NVIDIA_RUNTIME=${has_nvidia_runtime}
DEVCONTAINER_GPU_PROFILE=${gpu_profile}
DEVCONTAINER_GPU_DETECTION_METHOD=${detection_method}
DEVCONTAINER_HOST_OS=${os_name}
DEVCONTAINER_HOST_LINUX_DISTRO=${linux_distro_id}
EOF

log_info "Host GPU detection summary:"
echo "   NVIDIA GPU detected: ${has_nvidia_gpu}"
echo "   Docker NVIDIA runtime detected: ${has_nvidia_runtime}"
echo "   Suggested profile: ${gpu_profile}"

if [ "$has_nvidia_gpu" = true ] && [ "$has_nvidia_runtime" = true ]; then
    log_ok "NVIDIA GPU and Docker runtime are both available."
fi

if [ "$has_nvidia_gpu" = true ] && [ "$has_nvidia_runtime" = false ]; then
    echo ""
    log_warn "An NVIDIA GPU was detected, but Docker does not report an NVIDIA runtime."
    log_info "$runtime_hint"
    log_info "Then use .devcontainer/profiles/devcontainer.gpu.json."
fi

if [ "$has_nvidia_gpu" = true ]; then
    log_info "If you want GPU access in the devcontainer, use .devcontainer/profiles/devcontainer.gpu.json for the next rebuild."
fi