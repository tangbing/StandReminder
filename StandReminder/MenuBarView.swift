import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 状态显示
            HStack(spacing: 8) {
                Circle()
                    .fill(reminderManager.isActive ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                    .shadow(color: reminderManager.isActive ? .green.opacity(0.5) : .orange.opacity(0.5), radius: 3)
                
                Text(reminderManager.isActive ? 
                     LocalizationKeys.statusActive.localized :
                     LocalizationKeys.statusPaused.localized)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(cornerRadius: 10, shadow: false)
            
            // 倒计时
            if reminderManager.isActive {
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizationKeys.timerNextReminder.localized)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(reminderManager.formatTimeInterval(reminderManager.timeRemaining))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .glassBackground(cornerRadius: 10, shadow: false)
            }
            
            Divider().padding(.vertical, 2)
            
            // 控制按钮
            VStack(spacing: 6) {
                MenuButton(
                    icon: reminderManager.isActive ? "stop.fill" : "play.fill",
                    label: reminderManager.isActive ? 
                        LocalizationKeys.actionStopReminder.localized :
                        LocalizationKeys.actionStartReminder.localized,
                    color: reminderManager.isActive ? .red : .green
                ) {
                    if reminderManager.isActive {
                        reminderManager.stopReminder()
                    } else {
                        reminderManager.startReminder()
                    }
                }
                
                if reminderManager.isActive {
                    Menu {
                        Button("5\(LocalizationKeys.timeMinutes.localized)") { reminderManager.snoozeReminder(minutes: 5) }
                        Button("10\(LocalizationKeys.timeMinutes.localized)") { reminderManager.snoozeReminder(minutes: 10) }
                        Button("15\(LocalizationKeys.timeMinutes.localized)") { reminderManager.snoozeReminder(minutes: 15) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.orange)
                                .frame(width: 16)
                            Text(LocalizationKeys.menuSnooze.localized)
                                .font(.system(size: 13, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            
            Divider().padding(.vertical, 2)
            
            // 今日统计
            let stats = reminderManager.getTodayStats()
            HStack(spacing: 12) {
                MiniStatView(value: "\(stats.reminders)", label: LocalizationKeys.statsReminders.localized, color: .blue)
                MiniStatView(value: "\(stats.responses)", label: LocalizationKeys.statsResponses.localized, color: .green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassBackground(cornerRadius: 10, shadow: false)
            
            Divider().padding(.vertical, 2)
            
            // 菜单项
            VStack(spacing: 4) {
                MenuButton(icon: "macwindow", label: LocalizationKeys.menuOpenMain.localized, color: .blue) {
                    openWindow(id: "main")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApp.setActivationPolicy(.regular)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                
                MenuButton(icon: "power", label: LocalizationKeys.actionQuit.localized, color: .red) {
                    NSApplication.shared.terminate(nil)
                }
            }
            
            Divider().padding(.vertical, 2)
            
            // 开发者工具：导出图标
            Button(action: {
                openWindow(id: "icon-generator")
                NSApp.activate(ignoringOtherApps: true)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 12))
                    Text("Generate App Icon")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(12)
        .frame(width: 240)
        .id(reminderManager.selectedLanguage)
    }
}

struct MenuButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                    .frame(width: 16)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MiniStatView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(ReminderManager())
}
