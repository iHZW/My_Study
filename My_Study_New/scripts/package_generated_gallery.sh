#!/bin/bash
set -euo pipefail

source="${1:?需要素材目录}"
destination="${2:?需要应用资源目录}"
[[ "$destination" == /*/GeneratedGallery && ! -L "$destination" ]]

# 先构建完整的资源目录，保留分组和页序，排除视频、文稿及重复的发布图片。
stage="$(mktemp -d "${TMPDIR:-/tmp}/study-gallery.XXXXXX")"
trap '/bin/rm -rf "$stage"' EXIT
copy_images() {
    mkdir -p "$2"
    /usr/bin/rsync -rtm --exclude='发布图片/' --include='*/' \
        --include='*.[jJ][pP][gG]' --include='*.[jJ][pP][eE][gG]' \
        --include='*.[pP][nN][gG]' --exclude='*' "$1/" "$2/"
}

if [[ -d "$source" ]]; then
    for folder in "$source"/*/; do
        [[ -d "$folder" ]] || continue
        folder="${folder%/}"
        name="${folder##*/}"
        case "$name" in
            晚安故事-*) target="$stage/晚安故事/${name#晚安故事-}" ;;
            给宝宝的晚安故事-*) target="$stage/晚安故事" ;;
            抖音生活话题-*) target="$stage/生活话题/${name#抖音生活话题-}" ;;
            *) target="$stage/$name" ;;
        esac
        copy_images "$folder" "$target"
    done
fi

# 只同步到当前构建产物的作品集目录，清理旧产物中已移除的图片。
mkdir -p "$destination"
/usr/bin/rsync -rt --delete "$stage/" "$destination/"
