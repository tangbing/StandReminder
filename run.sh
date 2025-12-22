#!/bin/bash

# StandReminder 构建和运行脚本

echo "🔧 正在构建 StandReminder..."

cd "$(dirname "$0")"

# 清理之前的构建
xcodebuild clean -project StandReminder.xcodeproj -scheme StandReminder

# 构建项目
if xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build; then
    echo "✅ 构建成功！"
    
    # 查找构建的应用
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug/StandReminder.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "🚀 正在启动应用..."
        echo "应用路径: $APP_PATH"
        
        # 启动应用
        open "$APP_PATH"
        
        echo "✨ StandReminder 已启动！"
        echo ""
        echo "📱 应用功能："
        echo "  • 定时站立提醒"
        echo "  • 菜单栏驻留"
        echo "  • 自定义设置"
        echo "  • 使用统计"
        echo ""
        echo "💡 提示：应用启动后会显示在菜单栏中"
    else
        echo "❌ 找不到构建的应用"
        exit 1
    fi
else
    echo "❌ 构建失败"
    exit 1
fi