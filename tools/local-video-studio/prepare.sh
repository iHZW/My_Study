#!/bin/bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data="${1:-${VIDEO_STUDIO_DATA:-$root/.data}}"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if [[ "$(uname -m)" != "arm64" ]]; then
    printf '%s\n' '此模型需要 Apple Silicon。' >&2
    exit 1
fi
mkdir -p "$data"
data="$(cd -- "$data" && pwd)"
remaining="$(df -Pk "$data" | awk 'NR == 2 {print $4}')"
if [[ -f "$data/.ready" ]]; then
    printf '本地模型已准备好：%s\n' "$data"
    exit 0
fi
# 已下载的权重计入预算，以便在同一目录恢复下载。
existing="$(du -sk "$data" | awk '{print $1}')"
if [[ "$remaining" -lt $((3 * 1024 * 1024)) || $((remaining + existing)) -lt $((32 * 1024 * 1024)) ]]; then
    printf '该磁盘还剩约 %s GiB。首次安装请预留至少 32 GiB，可传入外置盘上的空目录。\n' "$((remaining / 1024 / 1024))" >&2
    exit 1
fi
for dependency in git uv ffmpeg; do
    if ! command -v "$dependency" >/dev/null; then
        printf '找不到 %s。请先完成 README 中的依赖准备。\n' "$dependency" >&2
        exit 1
    fi
done

engine="$data/engine"
export UV_CACHE_DIR="$data/uv-cache"
export UV_PYTHON_INSTALL_DIR="$data/python"
export HF_HOME="$data/hf-cache"
if [[ ! -d "$engine/.git" ]]; then
    git clone --depth 1 --branch v0.18.0 https://github.com/dgrauet/ltx-2-mlx.git "$engine"
fi
git -C "$engine" rev-parse --verify HEAD | grep -q '^b82b97e' || {
    printf '%s\n' '运行环境版本不匹配，请选择另一个数据目录。' >&2
    exit 1
}
(
    cd -- "$engine"
    uv sync --frozen --no-dev --python 3.12
)
"$engine/.venv/bin/ltx-2-mlx" generate --help >/dev/null
# 只取文生与图生短片共用的蒸馏权重，省去另一版权重和编辑模型。
"$engine/.venv/bin/hf" download dgrauet/ltx-2.3-mlx-q4 \
    --revision f306259 --local-dir "$data/model" \
    config.json embedded_config.json quantize_config.json split_model.json \
    spatial_upscaler_x2_v1_1_config.json LICENSE transformer-distilled-1.1.safetensors \
    'connector.safetensors' 'vae_encoder.safetensors' 'vae_decoder.safetensors' \
    'spatial_upscaler_x2_v1_1.safetensors' 'audio_vae.safetensors' 'vocoder.safetensors'
"$engine/.venv/bin/hf" download mlx-community/gemma-3-12b-it-4bit --local-dir "$data/gemma"
touch "$data/.ready"
printf '准备完成。用 bash "%s/start.sh" "%s" 启动。\n' "$root" "$data"
