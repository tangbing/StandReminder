import SwiftUI
import UserNotifications
import AVFoundation

@main
struct StandReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var reminderManager = ReminderManager()
    
    var body: some Scene {
        // 使用 WindowGroup 但设置为不自动显示
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(reminderManager)
                .onAppear {
                    print("🚀 StandReminderApp - ContentView 即将显示")
                    requestNotificationPermission()
                    // 设置快捷键管理器
                    KeyboardShortcutManager.shared.setReminderManager(reminderManager)
                    print("⚙️ 快捷键管理器已设置")
                    
                    // 将 reminderManager 传递给 AppDelegate
                    appDelegate.reminderManager = reminderManager
                }
        }
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("打开主界面") {
                    // 使用 openWindow 而不是 AppDelegate
                    // openWindow(id: "main")
                }
                .keyboardShortcut("m", modifiers: [.command])
            }
        }
        
        MenuBarExtra(content: {
            MenuBarView()
                .environmentObject(reminderManager)
                .id(reminderManager.selectedLanguage) // 强制刷新内容视图
        }, label: {
            // 建立对 selectedLanguage 的依赖，确保语言变更时 Label 重绘
            let _ = reminderManager.selectedLanguage
            let title = LocalizationKeys.appTitle.localized
            Label(title, systemImage: "figure.stand")
                .environment(\.locale, .current)
        })
        .menuBarExtraStyle(.window)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知权限已授权")
            } else {
                print("❌ 通知权限被拒绝")
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var reminderManager: ReminderManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置应用为菜单栏应用
        NSApp.setActivationPolicy(.accessory)
        print("🚀 AppDelegate 初始化完成")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("🔄 应用重新打开，hasVisibleWindows: \(flag)")
        if !flag {
            // 如果没有可见窗口，激活应用并显示主窗口
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("🪟 最后一个窗口关闭")
        // 关闭最后一个窗口时不退出应用，而是返回菜单栏模式
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}
