import SwiftUI

struct FullscreenReminderView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        ZStack {
            // 动态背景
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.25),
                    Color.purple.opacity(0.2),
                    Color.cyan.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 图标
                ZStack {
                    Color.clear
                        .frame(width: 140, height: 140)
                        .glassSurface(
                            shadowColor: .blue.opacity(0.3),
                            shadowRadius: 20,
                            shadowY: 0,
                            in: Circle()
                        )
                    
                    Image(systemName: "figure.stand")
                        .font(.system(size: 70, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                
                // 文字
                VStack(spacing: 16) {
                    Text(LocalizationKeys.fullscreenTitle.localized)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // 提醒内容不做国际化：为空则显示固定默认值
                    Text(reminderManager.customMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "站立一下" : reminderManager.customMessage)
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("\(LocalizationKeys.fullscreenRestCountdown.localized)\(reminderManager.formatTimeInterval(reminderManager.restTimeRemaining))")
                        .font(.system(size: 16, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 按钮
                GlassActionButton(
                    icon: "forward.end.fill",
                    label: LocalizationKeys.actionSkipRest.localized,
                    gradient: [.orange, .pink],
                    width: 220
                ) {
                    reminderManager.skipRest()
                }
                .padding(.bottom, 50)
            }
            
        }
    }
}

struct GlassActionButton: View {
    let icon: String
    let label: String
    let gradient: [Color]
    var width: CGFloat = 130
    var height: CGFloat = 90
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: width, height: height)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: gradient[0].opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FullscreenReminderView()
        .environmentObject(ReminderManager())
}
