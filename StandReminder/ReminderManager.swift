import Foundation
import UserNotifications
import AVFoundation
import AudioToolbox
import SwiftUI
import AppKit

// 支持的语言
enum AppLanguage: String, CaseIterable {
    case system = "system"
    case en = "en"
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    
    var displayName: String {
        switch self {
        case .system: return "System / 跟随系统"
        case .en: return "English"
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        }
    }
}

class ReminderManager: ObservableObject {
    @Published var isActive = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var selectedInterval: TimeInterval = 30 * 60
    @Published var customMessage = "该起来活动一下啦！"
    @Published var activeStartTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @Published var activeEndTime = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    @Published var enableActiveTimeLimit = true
    @Published var enableSound = true
    @Published var reminderHistory: [ReminderRecord] = []
    @Published var customIntervalMinutes: Int = 20
    @Published var useCustomInterval: Bool = false
    @Published var showingFullscreenReminder: Bool = false
    @Published var pendingSnooze: Bool = false
    @Published var selectedLanguage: AppLanguage = .system
    private var fullscreenWindow: NSWindow?

    
    // let fullscreenWindowManager = FullscreenWindowManager()
    private var timer: Timer?
    private var nextReminderTime: Date?

    enum Language: String, CaseIterable {
        case chineseSimplified = "zh-Hans"
        case english = "en"
        case chineseTraditional = "zh-Hant"
        var displayName: String {
            switch self {
            case .english: return LocalizationKeys.languageEnglish.localized
            case .chineseSimplified: return LocalizationKeys.languageChineseSimplified.localized
            case .chineseTraditional: return LocalizationKeys.languageChineseTraditional.localized
            }
        }
    }


    let intervalOptions: [TimeInterval] = [
        15 * 60,  // 15分钟
        20 * 60,  // 20分钟
        40 * 60,  // 40分钟
        120 * 60  // 2小时
    ]
    
    init() {
        print("🔧 ReminderManager 初始化开始")
        loadSettings()
        loadHistory()
        applyLanguage()
        print("✅ ReminderManager 初始化完成")
        print("⏰ 当前间隔: \(useCustomInterval ? customIntervalMinutes : Int(selectedInterval/60)) 分钟")
    }
    
    func startReminder() {
        guard !isActive else { return }
        
        print("🚀 开始提醒...")
        isActive = true
        scheduleNextReminder()
        
        // 记录开始时间
        let record = ReminderRecord(date: Date(), started: true)
        reminderHistory.append(record)
        saveHistory()
    }
    
    func stopReminder() {
        isActive = false
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
        
        // 取消所有待发送的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleNextReminder() {
        let now = Date()
        var nextTime: Date
        
        // 获取当前使用的间隔
        let currentInterval = useCustomInterval ? TimeInterval(customIntervalMinutes * 60) : selectedInterval
        
        // 如果不启用活跃时间限制，直接按间隔设置
        if !enableActiveTimeLimit {
            nextTime = now.addingTimeInterval(currentInterval)
        } else {
            // 启用活跃时间限制的复杂逻辑
            let calendar = Calendar.current
            
            let currentTime = calendar.dateComponents([.hour, .minute], from: now)
            let startTime = calendar.dateComponents([.hour, .minute], from: activeStartTime)
            let endTime = calendar.dateComponents([.hour, .minute], from: activeEndTime)
            
            let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
            let startMinutes = (startTime.hour ?? 0) * 60 + (startTime.minute ?? 0)
            let endMinutes = (endTime.hour ?? 0) * 60 + (endTime.minute ?? 0)
            
            if currentMinutes < startMinutes {
                // 如果在开始时间之前，设置到今天的开始时间
                var components = calendar.dateComponents([.year, .month, .day], from: now)
                components.hour = startTime.hour
                components.minute = startTime.minute
                nextTime = calendar.date(from: components) ?? now.addingTimeInterval(selectedInterval)
            } else if currentMinutes >= endMinutes {
                // 如果在结束时间之后，设置到明天的开始时间
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
                var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
                components.hour = startTime.hour
                components.minute = startTime.minute
                nextTime = calendar.date(from: components) ?? now.addingTimeInterval(selectedInterval)
            } else {
                // 在活跃时间段内，正常设置间隔
                nextTime = now.addingTimeInterval(currentInterval)
                
                // 检查下次提醒时间是否会超出今天的结束时间
                let nextTimeMinutes = calendar.dateComponents([.hour, .minute], from: nextTime)
                let nextMinutes = (nextTimeMinutes.hour ?? 0) * 60 + (nextTimeMinutes.minute ?? 0)
                
                if nextMinutes > endMinutes {
                    // 如果超出了结束时间，调整到明天的开始时间
                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
                    var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
                    components.hour = startTime.hour
                    components.minute = startTime.minute
                    nextTime = calendar.date(from: components) ?? nextTime
                }
            }
        }
        
        nextReminderTime = nextTime
        timeRemaining = nextTime.timeIntervalSince(now)
        
        print("⏰ 下次提醒时间: \(nextTime)")
        print("⏱️ 倒计时: \(formatTimeInterval(timeRemaining))")
        print("🕐 当前时间: \(now)")
        if enableActiveTimeLimit {
            print("⏰ 活跃时间: \(activeStartTime) - \(activeEndTime)")
        } else {
            print("⚡ 活跃时间限制已禁用")
        }
        
        // 安排通知
        scheduleNotification(at: nextTime)
        
        // 重新启动倒计时定时器
        startCountdownTimer()
    }
    
    private func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = LocalizationKeys.notificationTitle.localized
        content.body = customMessage.isEmpty ? LocalizationKeys.notificationBody.localized : customMessage
        content.categoryIdentifier = "STAND_REMINDER"
        
        if enableSound {
            // 系统通知声音（若用户允许）
            content.sound = .default
        }
        
        let timeInterval = date.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知安排失败: \(error)")
            }
        }
    }
    
    private func startCountdownTimer() {
        timer?.invalidate()
        print("⏲️ 启动倒计时定时器")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    // 每30秒打印一次调试信息
                    if Int(self.timeRemaining) % 30 == 0 {
                        print("⏰ 剩余时间: \(self.formatTimeInterval(self.timeRemaining))")
                    }
                } else {
                    self.handleReminderTriggered()
                }
            }
        }
    }
    
    private func handleReminderTriggered() {
        print("🔔 提醒触发 - 显示全屏提醒")
        
        // 播放即时声音（不依赖通知中心）
        if enableSound {
            NSSound.beep()
        }
        
        // 记录提醒触发
        let record = ReminderRecord(date: Date(), started: false, triggered: true)
        reminderHistory.append(record)
        saveHistory()
        
        // 显示全屏提醒
        DispatchQueue.main.async {
            self.showingFullscreenReminder = true
            // self.fullscreenWindowManager.showFullscreenReminder(reminderManager: self)
            // 临时使用简单的窗口显示
            self.showSimpleFullscreenReminder()
        }
        
        // 停止当前计时器，等待用户操作后再重置
        timer?.invalidate()
    }
    
    private func showSimpleFullscreenReminder() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame // 不包含菜单栏和 Dock
        // 计算菜单栏高度（visibleFrame 顶部比 screenFrame 顶部低的那部分）
        let menuBarHeight = screenFrame.maxY - visibleFrame.maxY
        // 仅排除菜单栏区域，覆盖其下方全部（包括 Dock）
        let overlayFrame = NSRect(x: screenFrame.minX, y: screenFrame.minY, width: screenFrame.width, height: screenFrame.height - menuBarHeight)
        
        // 如果已有全屏窗口，先关闭
        fullscreenWindow?.close()
        
        let window = NSPanel(
            contentRect: overlayFrame,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        window.isFloatingPanel = true
        window.hidesOnDeactivate = false
        window.level = .floating
        window.backgroundColor = NSColor.white
        window.isOpaque = true
        window.hasShadow = false
        window.isMovable = false
        window.canHide = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        fullscreenWindow = window
        
        let contentView = FullscreenReminderView { [weak self] in
            self?.dismissFullscreenReminder()
        }
        .environmentObject(self)
        
        window.contentView = NSHostingView(rootView: contentView)
        window.orderFrontRegardless() // 非模态显示，不抢占焦点
        // 不调用 makeKeyAndOrderFront 与 NSApp.activate，保持父窗口可交互
    }
    
    private func dismissFullscreenReminder() {
        showingFullscreenReminder = false
        fullscreenWindow?.close()
        fullscreenWindow = nil
        // 根据状态决定是否重置倒计时
        if isActive {
            if pendingSnooze {
                // 小憩已安排，清除标记不再重置
                pendingSnooze = false
            } else {
                // 正常关闭或已站立，重新安排下次提醒
                scheduleNextReminder()
            }
        }
        // 重新激活 accessory 模式，避免界面卡住
        NSApp.setActivationPolicy(.accessory)
    }
    
    func snoozeReminder(minutes: Int) {
        print("😴 小憩 \(minutes) 分钟")
        let snoozeTime = TimeInterval(minutes * 60)
        
        // 在当前剩余时间基础上添加小憩时间
        let newTimeRemaining = timeRemaining + snoozeTime
        let newTime = Date().addingTimeInterval(newTimeRemaining)
        
        nextReminderTime = newTime
        timeRemaining = newTimeRemaining
        
        print("⏰ 剩余时间: \(formatTimeInterval(timeRemaining))")
        print("🔔 下次提醒时间: \(DateFormatter.localizedString(from: newTime, dateStyle: .none, timeStyle: .medium))")
        
        // 取消当前通知并安排新的
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduleNotification(at: newTime)
        
        // 重新启动倒计时定时器
        startCountdownTimer()
    }
    
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatIntervalOption(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return String(format: "%d%@", hours, LocalizationKeys.timeHours.localized)
            } else {
                return String(format: "%d%@ %d%@", hours, LocalizationKeys.timeHours.localized, remainingMinutes, LocalizationKeys.timeMinutes.localized)
            }
        } else {
            return String(format: "%d%@", minutes, LocalizationKeys.timeMinutes.localized)
        }
    }
    
    // MARK: - Settings Persistence
    private func saveSettings() {
        UserDefaults.standard.set(selectedInterval, forKey: "selectedInterval")
        UserDefaults.standard.set(customMessage, forKey: "customMessage")
        UserDefaults.standard.set(activeStartTime, forKey: "activeStartTime")
        UserDefaults.standard.set(activeEndTime, forKey: "activeEndTime")
        UserDefaults.standard.set(enableActiveTimeLimit, forKey: "enableActiveTimeLimit")
        UserDefaults.standard.set(enableSound, forKey: "enableSound")
        UserDefaults.standard.set(customIntervalMinutes, forKey: "customIntervalMinutes")
        UserDefaults.standard.set(useCustomInterval, forKey: "useCustomInterval")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguageCode")
    }
    
    private func loadSettings() {
        selectedInterval = UserDefaults.standard.object(forKey: "selectedInterval") as? TimeInterval ?? 30 * 60
        customMessage = UserDefaults.standard.string(forKey: "customMessage") ?? LocalizationKeys.fullscreenDefaultMessage.localized
        
        // 安全地创建默认时间
        activeStartTime = UserDefaults.standard.object(forKey: "activeStartTime") as? Date ?? {
            var calendar = Calendar.current
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        
        activeEndTime = UserDefaults.standard.object(forKey: "activeEndTime") as? Date ?? {
            var calendar = Calendar.current
            var components = DateComponents()
            components.hour = 18
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        
        enableSound = UserDefaults.standard.object(forKey: "enableSound") as? Bool ?? true
        enableActiveTimeLimit = UserDefaults.standard.object(forKey: "enableActiveTimeLimit") as? Bool ?? false // 默认禁用时间限制
        
        customIntervalMinutes = UserDefaults.standard.object(forKey: "customIntervalMinutes") as? Int ?? 20
        useCustomInterval = UserDefaults.standard.object(forKey: "useCustomInterval") as? Bool ?? false
        
        if let langStr = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let lang = AppLanguage(rawValue: langStr) {
            selectedLanguage = lang
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
        
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        
        // 触发 objectWillChange 强制刷新所有绑定此 manager 的视图
        objectWillChange.send()
    }
    
    // 提供给外部调用的方法，用于保存历史记录
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(reminderHistory) {
            UserDefaults.standard.set(encoded, forKey: "reminderHistory")
        }
    }
    
    func updateSettings() {
        saveSettings()
        
        // 如果提醒正在运行，重新安排
        if isActive {
            stopReminder()
            startReminder()
        }
    }

    func applyLanguage() {
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguageCode")
        print("🌐 当前界面语言: \(selectedLanguage.rawValue)")
        objectWillChange.send()
    }
    
    // MARK: - History Management
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "reminderHistory"),
           let decoded = try? JSONDecoder().decode([ReminderRecord].self, from: data) {
            reminderHistory = decoded
        }
    }
    
    func getTodayStats() -> (reminders: Int, responses: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let todayRecords = reminderHistory.filter { record in
            record.date >= today && record.date < tomorrow
        }
        
        let reminders = todayRecords.filter { $0.triggered }.count
        let responses = todayRecords.filter { $0.responded }.count
        
        return (reminders, responses)
    }
}

struct ReminderRecord: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let started: Bool
    let triggered: Bool
    let responded: Bool
    
    init(date: Date, started: Bool = false, triggered: Bool = false, responded: Bool = false) {
        self.date = date
        self.started = started
        self.triggered = triggered
        self.responded = responded
    }
}
