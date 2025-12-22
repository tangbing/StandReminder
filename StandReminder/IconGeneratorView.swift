import SwiftUI

struct IconGeneratorView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("App Icon Generator")
                .font(.headline)
            
            // 图标预览
            IconView()
                .frame(width: 256, height: 256)
                .shadow(radius: 10)
            
            Button("Save to Desktop") {
                saveIcon()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 400, height: 450)
    }
    
    @MainActor
    private func saveIcon() {
        let renderer = ImageRenderer(content: IconView().frame(width: 1024, height: 1024))
        renderer.scale = 1.0 // 1024x1024 points = 1024x1024 pixels at 1x scale, or adjust as needed
        
        if let nsImage = renderer.nsImage {
            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            let fileURL = desktopURL.appendingPathComponent("StandReminderIcon.png")
            
            if let tiffData = nsImage.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                try? pngData.write(to: fileURL)
                print("✅ Icon saved to: \(fileURL.path)")
                
                // 打开 Finder 选中文件
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            }
        }
    }
}

struct IconView: View {
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [
                    Color(red: 52/255, green: 199/255, blue: 89/255), // Apple Green
                    Color(red: 48/255, green: 176/255, blue: 199/255) // Teal
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 内容
            ZStack {
                // 外环
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 120) // 相对宽度调整 (1024下的60 -> 256下的15)
                    .padding(120)
                
                // 进度环
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 120, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(120)
                
                // 小人
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let cx = w / 2
                    let cy = h / 2
                    
                    // 相对比例
                    let scale = w / 1024.0
                    
                    Path { path in
                        // Head
                        path.addEllipse(in: CGRect(x: cx - 70 * scale, y: cy - 160 * scale - 70 * scale, width: 140 * scale, height: 140 * scale))
                        
                        // Body
                        path.addRoundedRect(in: CGRect(x: cx - 40 * scale, y: cy - 70 * scale, width: 80 * scale, height: 180 * scale), cornerSize: CGSize(width: 40 * scale, height: 40 * scale))
                    }
                    .fill(Color.white)
                    
                    Path { path in
                        // Legs
                        path.move(to: CGPoint(x: cx - 20 * scale, y: cy + 100 * scale))
                        path.addLine(to: CGPoint(x: cx - 50 * scale, y: cy + 280 * scale))
                        
                        path.move(to: CGPoint(x: cx + 20 * scale, y: cy + 100 * scale))
                        path.addLine(to: CGPoint(x: cx + 50 * scale, y: cy + 280 * scale))
                        
                        // Arms
                        path.move(to: CGPoint(x: cx - 40 * scale, y: cy - 40 * scale))
                        path.addLine(to: CGPoint(x: cx - 140 * scale, y: cy - 180 * scale))
                        
                        path.move(to: CGPoint(x: cx + 40 * scale, y: cy - 40 * scale))
                        path.addLine(to: CGPoint(x: cx + 140 * scale, y: cy - 180 * scale))
                    }
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 70 * scale, lineCap: .round, lineJoin: .round))
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 20)
        }
        // 移除圆角裁剪，导出时需要方形，系统会自动切圆角
        // .clipShape(RoundedRectangle(cornerRadius: 224)) 
    }
}

#Preview {
    IconGeneratorView()
}
