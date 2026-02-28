import Foundation
import Cocoa

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private var reminderManager: ReminderManager?
    
    private init() {
        // 简化实现，移除全局监听以避免权限问题
    }
    
    func setReminderManager(_ manager: ReminderManager) {
        self.reminderManager = manager
    }
    
    // 这些方法可以被应用内的按钮调用
    func toggleReminder() {
        Task { @MainActor [weak self] in
            guard let reminderManager = self?.reminderManager else { return }
            if reminderManager.isActive {
                reminderManager.stopReminder()
            } else {
                reminderManager.startReminder()
            }
        }
    }
    
    func pauseResumeReminder() {
        Task { @MainActor [weak self] in
            guard let reminderManager = self?.reminderManager else { return }
            if reminderManager.isActive {
                reminderManager.stopReminder()
            } else {
                reminderManager.startReminder()
            }
        }
    }
}
