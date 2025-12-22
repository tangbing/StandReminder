# App Icon 设计说明

## 🎨 设计理念

### 核心元素
1. **站立的人形** - 双臂向上伸展，象征站立和活动
2. **提醒铃铛** - 金色铃铛带波纹，清晰表达"提醒"功能
3. **活力配色** - 蓝色渐变背景，传达健康、活力、科技感

### 设计特点
- ✅ **一目了然**: 人形+铃铛，直接传达"站立提醒"概念
- ✅ **简洁现代**: 扁平化设计，符合 macOS Big Sur+ 风格
- ✅ **高识别度**: 在菜单栏小尺寸下依然清晰可辨
- ✅ **符合规范**: 标准圆角、渐变、阴影符合苹果设计指南

## 🎯 符合 Apple 设计规范

### 1. 圆角规范
- 使用 macOS 标准圆角半径 (226px @ 1024x1024)
- 自动适配不同尺寸

### 2. 配色方案
- **主色**: 蓝色渐变 (#00C6FF → #0072FF) - 科技感、信任感
- **强调色**: 金色 (#FFD700) - 提醒、重要性
- **对比色**: 纯白 (#FFFFFF) - 清晰、简洁

### 3. 视觉层次
- 前景: 白色人形 (主体)
- 中景: 金色铃铛 (功能标识)
- 背景: 蓝色渐变 (品牌色)

## 📦 使用方法

### 方法一: 自动生成 (推荐)

```bash
# 1. 安装依赖
brew install imagemagick librsvg

# 2. 运行生成脚本
./generate_icons.sh
```

### 方法二: 手动导入

1. 使用设计工具 (Sketch/Figma/Affinity Designer) 打开 `AppIcon.svg`
2. 导出以下尺寸的 PNG:
   - 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024
   - 每个尺寸需要 @1x 和 @2x 版本
3. 在 Xcode 中拖入 Assets.xcassets/AppIcon.appiconset

### 方法三: 在线工具

1. 访问 https://appicon.co 或 https://makeappicon.com
2. 上传 `AppIcon.svg` 或导出的 1024x1024 PNG
3. 下载生成的 macOS 图标集
4. 导入到 Xcode 项目

## 🔧 自定义修改

如果需要调整设计，编辑 `AppIcon.svg`:

```svg
<!-- 修改背景渐变颜色 -->
<linearGradient id="bgGradient">
  <stop offset="0%" style="stop-color:#YOUR_COLOR"/>
  <stop offset="100%" style="stop-color:#YOUR_COLOR"/>
</linearGradient>

<!-- 调整人形位置/大小 -->
<g transform="translate(512, 512) scale(1.1)">
  <!-- 人形元素 -->
</g>

<!-- 修改铃铛颜色 -->
<path fill="#YOUR_COLOR" ... />
```

## 📐 尺寸规格

macOS App Icon 需要的所有尺寸:

| 尺寸 | 用途 | 文件名 |
|------|------|--------|
| 16x16 @1x | 菜单栏 | icon_16x16.png |
| 16x16 @2x | 菜单栏 Retina | icon_16x16@2x.png |
| 32x32 @1x | 通知 | icon_32x32.png |
| 32x32 @2x | 通知 Retina | icon_32x32@2x.png |
| 128x128 @1x | Dock | icon_128x128.png |
| 128x128 @2x | Dock Retina | icon_128x128@2x.png |
| 256x256 @1x | 应用列表 | icon_256x256.png |
| 256x256 @2x | 应用列表 Retina | icon_256x256@2x.png |
| 512x512 @1x | App Store | icon_512x512.png |
| 512x512 @2x | App Store Retina | icon_512x512@2x.png |

## 🎨 设计替代方案

如果当前设计不满意，可以考虑:

1. **方案 A**: 时钟+人形 (强调时间管理)
2. **方案 B**: 向上箭头+人形 (强调站起来)
3. **方案 C**: 简化为纯铃铛 (极简风格)

需要其他方案请告知！

## 📚 参考资源

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [macOS Icon Template](https://developer.apple.com/design/resources/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
