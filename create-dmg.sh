#!/bin/bash

# DMG 打包脚本 - StandReminder
# 创建一个带背景图片的专业 macOS 安装包

set -e

echo "🎁 开始创建 DMG 安装包..."

# 配置
APP_NAME="StandReminder"
DMG_NAME="StandReminder-Installer"
VERSION="1.1.0"
APP_PATH="./Build/Build/Products/Release/${APP_NAME}.app"
DMG_TEMP_DIR="./dmg_temp"
DMG_BACKGROUND="dmg-background.png"
FINAL_DMG="${DMG_NAME}-${VERSION}.dmg"
# /Users/edy/Documents/standReminder/StandReminder/Build/Build/Products/Release/StandReminder.app
# StandReminder/Build/Build/Products/Release/StandReminder.app
# 检查 App 是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 错误: 找不到 ${APP_PATH}"
    echo "请先构建 Release 版本:"
    echo "  xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Release build"
    exit 1
fi

# 检查依赖
if ! command -v rsvg-convert &> /dev/null; then
    echo "⚠️  需要安装 librsvg 来转换 SVG"
    echo "运行: brew install librsvg"
    read -p "是否现在安装? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install librsvg
    else
        exit 1
    fi
fi

# 清理旧文件
echo "🧹 清理旧文件..."
rm -rf "$DMG_TEMP_DIR"
rm -f "$FINAL_DMG"
rm -f "${DMG_NAME}-temp.dmg"

# 创建临时目录
echo "📁 创建临时目录..."
mkdir -p "$DMG_TEMP_DIR"

# 转换 SVG 背景图为 PNG
echo "🎨 生成背景图片..."
rsvg-convert -w 600 -h 400 dmg-background.svg -o "$DMG_BACKGROUND"

# 复制 App
echo "📦 复制应用..."
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# 创建 Applications 快捷方式
echo "🔗 创建 Applications 链接..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# 创建临时 DMG
echo "💿 创建临时 DMG..."
hdiutil create -srcfolder "$DMG_TEMP_DIR" \
    -volname "$APP_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size 200m \
    "${DMG_NAME}-temp.dmg"

# 挂载 DMG
echo "📌 挂载 DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME}-temp.dmg" | grep Volumes | awk '{print $3}')

if [ -z "$MOUNT_DIR" ]; then
    echo "❌ 挂载失败"
    exit 1
fi

echo "✅ 已挂载到: $MOUNT_DIR"

# 复制背景图片到 DMG
echo "🖼️  设置背景图片..."
mkdir -p "$MOUNT_DIR/.background"
cp "$DMG_BACKGROUND" "$MOUNT_DIR/.background/"

# 使用 AppleScript 设置 DMG 外观
echo "⚙️  配置 DMG 外观..."
osascript <<EOF
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 760, 550}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 80
        set background picture of viewOptions to file ".background:${DMG_BACKGROUND}"
        
        -- 设置图标位置
        set position of item "${APP_NAME}.app" of container window to {150, 200}
        set position of item "Applications" of container window to {510, 200}
        
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# 同步并卸载
echo "💾 同步文件系统..."
sync
sleep 2

echo "📤 卸载 DMG..."
hdiutil detach "$MOUNT_DIR"

# 转换为压缩的只读 DMG
echo "🗜️  压缩 DMG..."
hdiutil convert "${DMG_NAME}-temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$FINAL_DMG"

# 清理临时文件
echo "🧹 清理临时文件..."
rm -rf "$DMG_TEMP_DIR"
rm -f "${DMG_NAME}-temp.dmg"
rm -f "$DMG_BACKGROUND"

# 完成
echo ""
echo "✅ DMG 创建完成！"
echo "📦 文件: $FINAL_DMG"
echo "📊 大小: $(du -h "$FINAL_DMG" | cut -f1)"
echo ""
echo "🎉 可以分发这个 DMG 文件了！"
