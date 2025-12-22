#!/bin/bash

# GitHub 仓库上传脚本

echo "🚀 准备上传 StandReminder 到 GitHub"
echo "=================================="

cd "$(dirname "$0")"

# 检查 git 状态
if [ ! -d ".git" ]; then
    echo "❌ 错误：未找到 git 仓库"
    echo "   请先运行 git init"
    exit 1
fi

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "📝 发现未提交的更改，正在提交..."
    git add .
    git commit -m "🔧 Fix EnvironmentObject error with delayed initialization

- Added loading state to ContentView
- Implemented safe environment object access
- Fixed potential crashes on app startup
- Improved error handling and user experience"
fi

echo "📋 项目信息："
echo "   - 名称: StandReminder (macOS 站立提醒应用)"
echo "   - 语言: Swift (SwiftUI)"
echo "   - 平台: macOS 13.0+"
echo "   - 许可证: MIT"
echo ""

echo "🔧 下一步操作指南："
echo "=================================="
echo ""
echo "1. 创建 GitHub 仓库："
echo "   - 访问 https://github.com/new"
echo "   - 仓库名称: StandReminder"
echo "   - 描述: macOS Stand Reminder App - 站立提醒应用"
echo "   - 设置为 Public（推荐）"
echo "   - 不要初始化 README（已有本地文件）"
echo ""

echo "2. 添加远程仓库并推送："
echo "   git remote add origin https://github.com/[你的用户名]/StandReminder.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

echo "3. 或者使用 SSH（推荐）："
echo "   git remote add origin git@github.com:[你的用户名]/StandReminder.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

echo "📊 项目统计："
echo "   - 总文件数: $(find . -type f -not -path './.git/*' | wc -l | tr -d ' ')"
echo "   - Swift 文件: $(find . -name '*.swift' | wc -l | tr -d ' ')"
echo "   - 代码行数: $(find . -name '*.swift' -exec wc -l {} + | tail -1 | awk '{print $1}')"
echo ""

echo "🎯 特色功能："
echo "   ✅ 智能提醒系统"
echo "   ✅ 菜单栏集成"
echo "   ✅ 双语支持"
echo "   ✅ 使用统计"
echo "   ✅ HealthKit 集成"
echo "   ✅ 隐私保护"
echo ""

echo "🐛 已修复问题："
echo "   ✅ EnvironmentObject 致命错误"
echo "   ✅ 延迟初始化环境对象"
echo "   ✅ 安全的设置加载"
echo "   ✅ 改进的错误处理"
echo ""

echo "💡 提示："
echo "   - 推送后记得在 GitHub 上更新 README.md 中的用户名"
echo "   - 可以添加 GitHub Actions 进行自动构建"
echo "   - 考虑添加 issue 和 PR 模板"
echo "   - 设置 GitHub Pages 展示项目"
echo ""

echo "✨ 准备完成！请按照上述步骤上传到 GitHub。"