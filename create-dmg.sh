#!/bin/bash

# 一键构建 StandReminder 并打包为 macOS DMG 安装包。
# 用法：
#   ./create-dmg.sh
#   VERSION=1.2.0 ./create-dmg.sh

set -euo pipefail

APP_NAME="StandReminder"
PROJECT_NAME="StandReminder.xcodeproj"
SCHEME_NAME="StandReminder"
CONFIGURATION="Release"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/Build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
PRODUCTS_DIR="$DERIVED_DATA_DIR/Build/Products/$CONFIGURATION"
APP_PATH="$PRODUCTS_DIR/$APP_NAME.app"

DIST_DIR="$ROOT_DIR/dist"
DMG_STAGING_DIR="$BUILD_DIR/dmg-staging"
TEMP_DMG="$BUILD_DIR/$APP_NAME-temp.dmg"
VOLUME_NAME="$APP_NAME"

VERSION="${VERSION:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/$APP_NAME/Info.plist" 2>/dev/null || true)"
fi
if [ -z "$VERSION" ] || [[ "$VERSION" == *'$('* ]]; then
    VERSION="1.0.0"
fi

FINAL_DMG="$DIST_DIR/$APP_NAME-Installer-$VERSION.dmg"
BACKGROUND_SOURCE_PNG="$ROOT_DIR/dmg-background.png"
BACKGROUND_SOURCE_SVG="$ROOT_DIR/dmg-background.svg"
BACKGROUND_NAME="dmg-background.png"
MOUNT_DIR=""

log() {
    printf "\n%s\n" "$1"
}

cleanup_mount() {
    if [ -n "$MOUNT_DIR" ] && [ -d "$MOUNT_DIR" ]; then
        hdiutil detach "$MOUNT_DIR" -quiet || hdiutil detach "$MOUNT_DIR" -force -quiet || true
    fi
}

cleanup() {
    cleanup_mount
    rm -rf "$DMG_STAGING_DIR"
    rm -f "$TEMP_DMG"
}

trap cleanup EXIT

cd "$ROOT_DIR"

log "==> 清理旧构建"
xcodebuild clean \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME_NAME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_DIR"

log "==> 构建 Release 版本"
xcodebuild \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME_NAME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    build

if [ ! -d "$APP_PATH" ]; then
    echo "错误：构建产物不存在：$APP_PATH" >&2
    exit 1
fi

log "==> 准备 DMG 内容"
rm -rf "$DMG_STAGING_DIR"
rm -f "$TEMP_DMG" "$FINAL_DMG"
mkdir -p "$DMG_STAGING_DIR" "$DIST_DIR"

ditto "$APP_PATH" "$DMG_STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$DMG_STAGING_DIR/Applications"

if [ -f "$BACKGROUND_SOURCE_PNG" ]; then
    mkdir -p "$DMG_STAGING_DIR/.background"
    cp "$BACKGROUND_SOURCE_PNG" "$DMG_STAGING_DIR/.background/$BACKGROUND_NAME"
elif [ -f "$BACKGROUND_SOURCE_SVG" ] && command -v rsvg-convert >/dev/null 2>&1; then
    mkdir -p "$DMG_STAGING_DIR/.background"
    rsvg-convert -w 660 -h 450 "$BACKGROUND_SOURCE_SVG" -o "$DMG_STAGING_DIR/.background/$BACKGROUND_NAME"
fi

log "==> 创建临时 DMG"
hdiutil create \
    -srcfolder "$DMG_STAGING_DIR" \
    -volname "$VOLUME_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size 200m \
    "$TEMP_DMG"

log "==> 挂载并设置窗口布局"
ATTACH_OUTPUT="$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG")"
MOUNT_DIR="$(printf "%s\n" "$ATTACH_OUTPUT" | awk '/\/Volumes\// {print substr($0, index($0, "/Volumes/")); exit}')"

if [ -z "$MOUNT_DIR" ] || [ ! -d "$MOUNT_DIR" ]; then
    echo "错误：DMG 挂载失败" >&2
    printf "%s\n" "$ATTACH_OUTPUT" >&2
    exit 1
fi

if [ -f "$MOUNT_DIR/.background/$BACKGROUND_NAME" ]; then
    osascript <<EOF
tell application "Finder"
    set dmgFolder to POSIX file "$MOUNT_DIR" as alias
    set backgroundAlias to POSIX file "$MOUNT_DIR/.background/$BACKGROUND_NAME" as alias
    open dmgFolder
    delay 1
    set current view of container window of dmgFolder to icon view
    set toolbar visible of container window of dmgFolder to false
    set statusbar visible of container window of dmgFolder to false
    set the bounds of container window of dmgFolder to {100, 100, 760, 550}
    set viewOptions to the icon view options of container window of dmgFolder
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 80
    set background picture of viewOptions to backgroundAlias
    set position of item "$APP_NAME.app" of dmgFolder to {170, 215}
    set position of item "Applications" of dmgFolder to {490, 215}
    update dmgFolder without registering applications
    delay 1
    close container window of dmgFolder
end tell
EOF
else
    echo "提示：未找到背景图片，跳过 Finder 背景设置。"
fi

sync
cleanup_mount
MOUNT_DIR=""

log "==> 压缩生成最终 DMG"
hdiutil convert "$TEMP_DMG" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$FINAL_DMG"

log "==> 校验 DMG"
hdiutil verify "$FINAL_DMG"

log "完成：$FINAL_DMG"
du -h "$FINAL_DMG"
