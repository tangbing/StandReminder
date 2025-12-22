import SwiftUI

struct FullscreenReminderView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    let onDismiss: () -> Void
    
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
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .shadow(color: .blue.opacity(0.3), radius: 20)
                    
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
                        .foregroundColor(.white)
                    
                    Text(reminderManager.customMessage)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 按钮
                HStack(spacing: 20) {
                    GlassActionButton(
                        icon: "checkmark.circle.fill",
                        label: LocalizationKeys.actionDone.localized,
                        gradient: [.green, .cyan]
                    ) {
                        markAsResponded()
                        onDismiss()
                    }
                    
                    GlassActionButton(
                        icon: "moon.zzz.fill",
                        label: LocalizationKeys.actionSnooze5Min.localized,
                        gradient: [.orange, .yellow]
                    ) {
                        reminderManager.pendingSnooze = true
                        reminderManager.snoozeReminder(minutes: 5)
                        onDismiss()
                    }
                }
                .padding(.bottom, 50)
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding(28)
                }
                Spacer()
            }
        }
    }
    
    private func markAsResponded() {
        let record = ReminderRecord(date: Date(), responded: true)
        reminderManager.reminderHistory.append(record)
        reminderManager.saveHistory()
    }
}

struct GlassActionButton: View {
    let icon: String
    let label: String
    let gradient: [Color]
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
            .foregroundColor(.white)
            .frame(width: 130, height: 90)
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
    FullscreenReminderView(onDismiss: {})
        .environmentObject(ReminderManager())
}
