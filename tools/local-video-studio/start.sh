#!/bin/bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build="$root/.build"
mkdir -p "$build"
binary="$build/VideoStudio"
source="$root/VideoStudio.swift"

if [[ ! -x "$binary" || "$source" -nt "$binary" ]]; then
    swiftc -parse-as-library -O -module-cache-path "$build/modules" "$source" -o "$binary"
fi
if [[ "${1:-}" == "--build-only" ]]; then
    printf '%s\n' "$binary"
    exit 0
fi

data="${1:-${VIDEO_STUDIO_DATA:-$root/.data}}"
mkdir -p "$data"
export VIDEO_STUDIO_DATA="$(cd -- "$data" && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
exec "$binary"
