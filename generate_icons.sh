#!/bin/bash

# macOS App Icon 生成脚本
# 需要安装 ImageMagick: brew install imagemagick librsvg

echo "🎨 开始生成 macOS App Icons..."

# 检查依赖
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "❌ 错误: 需要安装 ImageMagick"
    echo "请运行: brew install imagemagick"
    exit 1
fi

if ! command -v rsvg-convert &> /dev/null; then
    echo "❌ 错误: 需要安装 librsvg"
    echo "请运行: brew install librsvg"
    exit 1
fi

# 创建临时目录
TEMP_DIR="./icon_temp"
ASSETS_DIR="./StandReminder/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$TEMP_DIR"
mkdir -p "$ASSETS_DIR"

# macOS 需要的图标尺寸
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

# 从 SVG 生成各种尺寸
echo "📐 生成各种尺寸的图标..."
for size_info in "${sizes[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "  生成 ${size}x${size} -> ${filename}"
    rsvg-convert -w $size -h $size AppIcon_Design.svg -o "$ASSETS_DIR/$filename"
done

# 创建 Contents.json
echo "📝 创建 Contents.json..."
cat > "$ASSETS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# 清理临时文件
rm -rf "$TEMP_DIR"

echo "✅ 图标生成完成！"
echo "📁 图标位置: $ASSETS_DIR"
echo ""
echo "🔄 下一步:"
echo "1. 在 Xcode 中打开项目"
echo "2. 图标会自动显示在 Assets.xcassets/AppIcon 中"
echo "3. 重新构建项目即可看到新图标"
