import SwiftUI
import AppKit

// 纯菜单样式的状态栏内容：无标题栏、无三色按钮
struct MenuBarMenuView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            // 状态展示（非交互）
            Label(
                reminderManager.isActive ? LocalizationKeys.statusActive.localized
                                         : LocalizationKeys.statusPaused.localized,
                systemImage: reminderManager.isActive ? "bolt.fill" : "pause.circle"
            )
            .disabled(true)

            if reminderManager.isActive {
                Label("\(LocalizationKeys.timerNextReminder.localized): " + reminderManager.formatTimeInterval(reminderManager.timeRemaining), systemImage: "clock")
                    .disabled(true)
            }

            Divider()

            // 开始/停止
            Button(action: {
                if reminderManager.isActive { reminderManager.stopReminder() }
                else { reminderManager.startReminder() }
            }) {
                Label(reminderManager.isActive ? LocalizationKeys.actionStopReminder.localized
                                               : LocalizationKeys.actionStartReminder.localized,
                      systemImage: reminderManager.isActive ? "stop.fill" : "play.fill")
            }

            // 小憩菜单
            if reminderManager.isActive {
                Menu(content: {
                    Button(action: { reminderManager.snoozeReminder(minutes: 5) }) {
                        Label("5\(LocalizationKeys.timeMinutes.localized)", systemImage: "5.circle")
                    }
                    Button(action: { reminderManager.snoozeReminder(minutes: 10) }) {
                        Label("10\(LocalizationKeys.timeMinutes.localized)", systemImage: "10.circle")
                    }
                    Button(action: { reminderManager.snoozeReminder(minutes: 15) }) {
                        Label("15\(LocalizationKeys.timeMinutes.localized)", systemImage: "15.circle")
                    }
                }, label: {
                    Label(LocalizationKeys.menuSnooze.localized, systemImage: "moon.zzz.fill")
                })
            }

            Divider()

            // 打开主界面
            Button(action: {
                openWindow(id: "main")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }) {
                Label(LocalizationKeys.menuOpenMain.localized, systemImage: "macwindow")
            }

            // 退出
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label(LocalizationKeys.actionQuit.localized, systemImage: "power")
            }
        }
        .labelStyle(.titleAndIcon)
    }
}

#if DEBUG
struct MenuBarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarMenuView()
            .environmentObject(ReminderManager())
    }
}
#endif
