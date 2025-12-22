# macOS Stand Reminder - 站立提醒应用

一个使用 SwiftUI 开发的 macOS 站立提醒应用，帮助用户养成定时站立活动的健康习惯。

## 📱 功能特性

### 🕒 智能提醒系统
- ✅ 自定义提醒间隔（15分钟 - 2小时）
- ✅ 智能活跃时间段设置（如工作时间 9:00-18:00）
- ✅ 精确的倒计时显示
- ✅ 小憩功能（5/10/15分钟延迟）

### 🔔 多样化提醒方式
- ✅ macOS 原生通知系统
- ✅ 自定义提醒文字内容
- ✅ 可选择是否启用提醒声音
- ✅ 菜单栏快速访问

### 🎨 优雅界面设计
- ✅ 符合 macOS Big Sur/Monterey 设计风格
- ✅ 支持浅色/深色模式自动切换
- ✅ 菜单栏驻留，方便快速访问
- ✅ 简洁优雅的主界面

### ⚙️ 个性化设置
- ✅ 多种提醒间隔选项
- ✅ 工作时间段自定义
- ✅ 提醒内容个性化
- ✅ 多语言支持（英语、简体中文、繁体中文）

### 📊 使用统计功能
- ✅ 每日提醒次数统计
- ✅ 响应率追踪
- ✅ 历史记录查看
- ✅ 简单的图表展示

### 🔧 高级功能
- ✅ 应用内快捷键支持
- ✅ 可选的 HealthKit 集成
- ✅ 低资源占用
- ✅ 数据本地存储，保护隐私

## 🖥️ 系统要求

- **系统版本**: macOS 13.0 或更高版本
- **开发环境**: Xcode 15.0 或更高版本
- **编程语言**: Swift 5.0
- **界面框架**: SwiftUI

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/[你的用户名]/StandReminder.git
cd StandReminder
```

### 2. 打开项目

```bash
open StandReminder.xcodeproj
```

### 3. 构建运行

- 在 Xcode 中选择目标设备为 Mac
- 按 `⌘ + R` 构建并运行
- 或者使用命令行：

```bash
# 构建项目
xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build

# 快速运行（推荐）
./run.sh
```

### 4. 首次使用

1. 启动应用后会自动请求通知权限，请点击"允许"
2. 应用会最小化到菜单栏，点击图标可快速访问
3. 在设置中配置您的提醒间隔和工作时间段
4. 点击"开始提醒"即可开始使用

## 📁 项目结构

```
StandReminder/
├── StandReminder/
│   ├── StandReminderApp.swift          # 应用入口和配置
│   ├── ReminderManager.swift           # 核心提醒逻辑管理
│   ├── ContentView.swift               # 主界面UI组件
│   ├── SettingsView.swift              # 设置界面
│   ├── HistoryView.swift               # 历史记录与统计
│   ├── MenuBarView.swift               # 菜单栏界面
│   ├── KeyboardShortcutManager.swift   # 快捷键管理
│   ├── HealthKitManager.swift          # 健康数据集成
│   ├── Info.plist                      # 应用配置文件
│   ├── StandReminder.entitlements      # 权限配置
│   └── Assets.xcassets/                # 应用图标等资源
├── README.md                           # 项目说明文档
├── PROJECT_STATUS.md                   # 项目状态报告
├── run.sh                              # 快速运行脚本
└── debug.sh                            # 调试运行脚本
```

## 🎯 使用说明

### 基本操作

1. **开始提醒**: 点击主界面的"开始提醒"按钮
2. **暂停提醒**: 点击"停止提醒"
3. **小憩功能**: 在提醒运行时，可选择延迟 5/10/15 分钟
4. **查看统计**: 点击"历史"查看使用记录和统计

### 菜单栏操作

- 点击菜单栏图标查看当前状态
- 快速开始/停止提醒
- 查看今日统计
- 访问主界面进行详细设置

### 个性化设置

1. 点击"设置"按钮进入设置界面
2. **提醒间隔**: 选择合适的提醒间隔（15分钟-2小时）
3. **工作时间**: 设置只在特定时间段内提醒
4. **提醒内容**: 自定义提醒文字
5. **语言选择**: 应用自动跟随系统语言（支持英语、简体中文、繁体中文）
6. **声音设置**: 开启或关闭提醒声音

## 🌍 国际化支持

### 支持语言
- 🇺🇸 English (英语)
- 🇨🇳 简体中文 (Simplified Chinese)
- 🇹🇼 繁體中文 (Traditional Chinese)

### 特性
- 使用 Apple 标准的本地化系统
- 自动跟随系统语言设置
- 所有文本集中管理，易于维护
- 符合 Apple 最佳实践

详细信息请查看 [本地化指南](LOCALIZATION_GUIDE.md)

## 🔧 技术实现

### 核心组件

- **ReminderManager**: 负责定时器管理、通知调度、设置持久化
- **ContentView**: 主界面，包含倒计时显示、控制按钮、统计信息
- **SettingsView**: 设置界面，支持所有个性化配置
- **HistoryView**: 历史记录界面，显示使用统计和图表
- **MenuBarView**: 菜单栏界面，提供快速控制功能

### 数据管理

- 使用 UserDefaults 进行设置持久化
- JSON 编码存储历史记录
- 所有数据都存储在本地，确保隐私安全

### 权限处理

- 友好的通知权限请求流程
- 可选的 HealthKit 权限集成
- 符合 macOS 沙盒安全要求

## 🐛 故障排除

### 常见问题

1. **应用无法启动**
   ```bash
   # 运行调试脚本查看详细错误信息
   ./debug.sh
   ```

2. **通知权限被拒绝**
   - 前往"系统偏好设置" > "通知与专注模式"
   - 找到 StandReminder 并启用通知权限

3. **菜单栏图标不显示**
   - 检查是否允许应用在后台运行
   - 重启应用或重新构建项目

4. **环境对象错误 (EnvironmentObject error)**
   ```bash
   # 清理构建缓存
   xcodebuild clean -project StandReminder.xcodeproj -scheme StandReminder
   
   # 重新构建
   xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build
   ```

### 调试模式

项目包含详细的调试输出，运行时会在控制台显示：
- ReminderManager 初始化状态
- 环境对象绑定情况
- 通知权限状态
- 应用生命周期事件

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 这个项目
2. 创建您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

### 报告问题

如果您发现了 bug 或有功能建议，请：

1. 检查是否已有相关的 issue
2. 创建新的 issue 并提供详细信息：
   - 操作系统版本
   - 应用版本
   - 重现步骤
   - 期望行为
   - 实际行为
   - 截图（如果适用）

## 📋 待办事项

- [ ] 添加应用图标设计
- [x] 完善多语言本地化（英语、简体中文、繁体中文）
- [ ] 添加单元测试
- [ ] 支持更多自定义选项
- [ ] 添加使用教程
- [ ] 性能优化
- [ ] 支持导出数据功能

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情



---

**⭐ 如果这个项目对您有帮助，请给它一个星标！**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)
