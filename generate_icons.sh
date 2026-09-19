#!/bin/bash

set -euo pipefail

echo "🎨 开始生成 macOS App Icons..."

MASTER_SOURCE="${1:-./AppIcon_Master.png}"
ASSETS_DIR="./StandReminder/Assets.xcassets/AppIcon.appiconset"

if ! command -v magick >/dev/null 2>&1; then
    echo "❌ 错误: 需要安装 ImageMagick"
    echo "请运行: brew install imagemagick"
    exit 1
fi

if [ ! -f "$MASTER_SOURCE" ]; then
    echo "❌ 错误: 找不到图标母版 $MASTER_SOURCE"
    exit 1
fi

mkdir -p "$ASSETS_DIR"

declare -a sizes=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

for size_info in "${sizes[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "  生成 ${size}x${size} -> ${filename}"
    magick "$MASTER_SOURCE" \
        -colorspace sRGB \
        -filter Lanczos \
        -resize "${size}x${size}" \
        -strip \
        "$ASSETS_DIR/$filename"
done

echo "✅ 图标生成完成"
echo "📁 母版: $MASTER_SOURCE"
echo "📁 AppIcon: $ASSETS_DIR"
