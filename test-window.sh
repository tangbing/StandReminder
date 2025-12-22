#!/bin/bash

# 测试主窗口打开功能

echo "🧪 测试主窗口打开功能"
echo "===================="

cd "$(dirname "$0")"

# 构建应用
echo "🔧 构建应用..."
xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ 构建成功"
else
    echo "❌ 构建失败"
    exit 1
fi

# 查找应用路径
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug/StandReminder.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ 找不到应用"
    exit 1
fi

echo "📍 应用路径: $APP_PATH"

# 启动应用
echo "🚀 启动应用（后台模式）..."
"$APP_PATH/Contents/MacOS/StandReminder" > /tmp/standreminder.log 2>&1 &
APP_PID=$!

echo "📋 应用 PID: $APP_PID"

# 等待应用启动
echo "⏳ 等待应用启动..."
sleep 3

# 检查应用是否在运行
if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ 应用正在运行"
else
    echo "❌ 应用启动失败"
    cat /tmp/standreminder.log
    exit 1
fi

echo ""
echo "🧪 测试指南："
echo "1. 查看菜单栏是否有站立提醒图标 📊"
echo "2. 点击菜单栏图标"
echo "3. 点击'打开主界面'按钮"
echo "4. 观察是否出现主窗口（400x500）"
echo ""

echo "🔍 当前窗口列表："
osascript -e 'tell application "System Events" to get the name of every window of every process whose background only is false' 2>/dev/null

echo ""
echo "📝 预期行为："
echo "- ✅ 点击'打开主界面'应该显示主窗口"
echo "- ✅ 不应该出现 NSStatusBarWindow 警告"
echo "- ✅ 主窗口应该能够正常显示和操作"
echo ""

echo "🛑 停止测试请运行: kill $APP_PID"
echo "📊 查看日志请运行: tail -f /tmp/standreminder.log"

# 保持脚本运行以便观察
echo "⏸️  按 Ctrl+C 结束测试..."
trap "echo '🛑 正在停止应用...'; kill $APP_PID 2>/dev/null; exit 0" INT

# 监控应用状态
while kill -0 $APP_PID 2>/dev/null; do
    sleep 5
    echo "💓 应用仍在运行... (PID: $APP_PID)"
done

echo "❌ 应用已退出"
cat /tmp/standreminder.log