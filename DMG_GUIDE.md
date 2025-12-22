# DMG 安装包制作指南

## 📦 快速开始

### 1. 构建 Release 版本

```bash
xcodebuild -project StandReminder.xcodeproj \
    -scheme StandReminder \
    -configuration Release \
    -derivedDataPath ./Build \
    build
```

### 2. 创建 DMG

```bash
./create-dmg.sh
```

完成后会生成 `StandReminder-Installer-1.0.0.dmg`

## 🎨 背景图片设计

### 设计特点
- **尺寸**: 660x400 像素（标准 DMG 窗口大小）
- **布局**: 左侧 App 图标 → 箭头 → 右侧 Applications 文件夹
- **配色**: 简洁优雅的浅色系，符合 macOS 风格
- **文字**: 中英文双语说明

### 图标位置
- **App 图标**: (150, 200)
- **Applications**: (510, 200)

### 自定义背景

编辑 `dmg-background.svg` 修改:

```svg
<!-- 修改标题 -->
<text x="330" y="50">你的应用名称</text>

<!-- 修改配色 -->
<linearGradient id="bgGradient">
  <stop offset="0%" style="stop-color:#YOUR_COLOR"/>
</linearGradient>

<!-- 修改说明文字 -->
<text x="330" y="340">你的安装说明</text>
```

## 🛠️ 依赖安装

脚本需要以下工具：

```bash
# 安装 librsvg (用于 SVG 转 PNG)
brew install librsvg

# 系统自带工具
# - hdiutil (创建 DMG)
# - osascript (设置 DMG 外观)
```

## 📋 DMG 配置说明

### 窗口设置
- **窗口大小**: 660x450 像素
- **图标大小**: 80x80 像素
- **背景**: 自定义图片
- **工具栏**: 隐藏
- **状态栏**: 隐藏

### 文件布局
```
DMG 根目录/
├── StandReminder.app      # 应用程序
├── Applications (链接)     # 指向 /Applications
└── .background/           # 隐藏文件夹
    └── dmg-background.png # 背景图片
```

## 🎯 使用流程

### 用户安装步骤
1. 双击 `.dmg` 文件
2. 窗口打开，显示背景图片和安装说明
3. 将 App 图标拖放到 Applications 文件夹
4. 安装完成，可以推出 DMG

### 开发者发布步骤
1. 构建 Release 版本
2. 运行 `./create-dmg.sh`
3. 测试生成的 DMG
4. 上传到 GitHub Releases 或网站

## 🔧 高级配置

### 修改 DMG 大小

编辑 `create-dmg.sh`:

```bash
# 修改 DMG 容量（默认 200MB）
-size 200m
```

### 修改压缩级别

```bash
# 压缩级别 1-9，9 最高压缩
-imagekey zlib-level=9
```

### 添加许可协议

```bash
# 在创建 DMG 时添加
hdiutil create ... \
    -license license.txt
```

## 🐛 常见问题

### 1. 背景图片不显示

**原因**: 图片路径错误或权限问题

**解决**:
```bash
# 检查背景图片
ls -la "$MOUNT_DIR/.background/"

# 重新设置权限
chmod 644 "$MOUNT_DIR/.background/dmg-background.png"
```

### 2. 图标位置不对

**解决**: 编辑 `create-dmg.sh` 中的 AppleScript 部分:

```applescript
set position of item "StandReminder.app" to {150, 200}
set position of item "Applications" to {510, 200}
```

### 3. DMG 创建失败

**检查**:
```bash
# 确保没有挂载的 DMG
hdiutil info | grep StandReminder

# 强制卸载
hdiutil detach /Volumes/StandReminder -force

# 清理临时文件
rm -rf dmg_temp *.dmg
```

### 4. App 未签名警告

**解决**: 对 App 进行代码签名

```bash
# 签名应用
codesign --force --deep --sign "Developer ID Application: Your Name" \
    StandReminder.app

# 公证应用（需要 Apple Developer 账号）
xcrun notarytool submit StandReminder-Installer-1.0.0.dmg \
    --apple-id "your@email.com" \
    --team-id "TEAM_ID" \
    --password "app-specific-password"
```

## 📚 参考资源

- [Apple DMG 最佳实践](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)
- [hdiutil 文档](https://ss64.com/osx/hdiutil.html)
- [create-dmg 工具](https://github.com/create-dmg/create-dmg)

## 🎨 设计建议

### 背景图片
- 使用浅色背景，避免干扰图标
- 箭头要明显，指示拖放方向
- 文字清晰易读，支持多语言
- 保持简洁，不要过度设计

### 用户体验
- 窗口大小适中，不要太大或太小
- 图标间距合理，方便拖放
- 说明文字简短明了
- 支持深色模式（可选）

## 📝 版本管理

建议在文件名中包含版本号：

```bash
StandReminder-Installer-1.0.0.dmg
StandReminder-Installer-1.1.0.dmg
```

在 `create-dmg.sh` 中修改 `VERSION` 变量。

## ✅ 检查清单

发布前检查：

- [ ] App 已签名
- [ ] 版本号正确
- [ ] DMG 可以正常打开
- [ ] 背景图片显示正常
- [ ] 拖放安装功能正常
- [ ] 在不同 macOS 版本测试
- [ ] 文件大小合理（< 50MB）
- [ ] 文件名规范
