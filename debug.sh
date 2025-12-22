#!/bin/bash

# StandReminder 调试运行脚本

echo "🔍 StandReminder 问题诊断工具"
echo "================================"

cd "$(dirname "$0")"

# 查找最新构建的应用
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug/StandReminder.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ 找不到构建的应用，请先运行构建："
    echo "   xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build"
    exit 1
fi

echo "📍 应用路径: $APP_PATH"
echo ""

echo "🚀 启动应用并监控调试输出..."
echo "   请观察控制台输出以查看可能的错误信息"
echo ""

# 运行应用并捕获输出
"$APP_PATH/Contents/MacOS/StandReminder" 2>&1 &
APP_PID=$!

echo "📋 应用已启动 (PID: $APP_PID)"
echo ""
echo "🔧 故障排除步骤："
echo "1. 检查上面的调试输出是否显示 'ReminderManager 初始化完成'"
echo "2. 如果看到 'Fatal error' 错误，请记录完整的错误信息"
echo "3. 检查是否有权限请求弹窗"
echo "4. 查看菜单栏是否出现站立提醒图标"
echo ""
echo "⏹️  按 Ctrl+C 停止监控"

# 等待用户停止
trap "kill $APP_PID 2>/dev/null; exit 0" INT

# 监控应用是否还在运行
while kill -0 $APP_PID 2>/dev/null; do
    sleep 1
done

echo "❌ 应用已退出"