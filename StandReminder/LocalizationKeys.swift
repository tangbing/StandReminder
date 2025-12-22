import Foundation

/// Centralized localization keys to avoid hardcoded strings throughout the codebase.
/// Usage: LocalizedStringKey.appTitle.localized or Text(LocalizedStringKey.appTitle.key)
enum LocalizationKeys: String {
    // MARK: - App Title
    case appTitle = "app.title"
    case appSubtitle = "app.subtitle"
    
    // MARK: - Status
    case statusActive = "status.active"
    case statusPaused = "status.paused"
    case statusEnabled = "status.enabled"
    case statusDisabled = "status.disabled"
    
    // MARK: - Timer
    case timerNextReminder = "timer.next_reminder"
    case timerInterval = "timer.interval"
    case timerInitializing = "timer.initializing"
    
    // MARK: - Actions
    case actionStartReminder = "action.start_reminder"
    case actionStopReminder = "action.stop_reminder"
    case actionDone = "action.done"
    case actionSnooze5Min = "action.snooze_5min"
    case actionSave = "action.save"
    case actionCancel = "action.cancel"
    case actionClose = "action.close"
    case actionQuit = "action.quit"
    
    // MARK: - Time Units
    case timeMinutes = "time.minutes"
    case timeMinutesFull = "time.minutes_full"
    case timeHours = "time.hours"
    
    // MARK: - Quick Actions
    case quickActionSettings = "quick_action.settings"
    case quickActionHistory = "quick_action.history"
    
    // MARK: - Statistics
    case statsToday = "stats.today"
    case statsReminders = "stats.reminders"
    case statsResponses = "stats.responses"
    case statsResponseRate = "stats.response_rate"
    
    // MARK: - Settings
    case settingsTitle = "settings.title"
    case settingsLanguage = "settings.language"
    case settingsInterfaceLanguage = "settings.interface_language"
    case settingsReminderInterval = "settings.reminder_interval"
    case settingsCustomInterval = "settings.custom_interval"
    case settingsSelectInterval = "settings.select_interval"
    case settingsActiveHours = "settings.active_hours"
    case settingsTimeLimit = "settings.time_limit"
    case settingsStart = "settings.start"
    case settingsEnd = "settings.end"
    case settingsTimeLimitDescription = "settings.time_limit_description"
    case settingsReminderMessage = "settings.reminder_message"
    case settingsEnterReminderText = "settings.enter_reminder_text"
    case settingsSound = "settings.sound"
    case settingsPlaySound = "settings.play_sound"
    case settingsKeyboardShortcuts = "settings.keyboard_shortcuts"
    case settingsShortcutStartStop = "settings.shortcut_start_stop"
    case settingsShortcutPauseResume = "settings.shortcut_pause_resume"
    
    // MARK: - History
    case historyTitle = "history.title"
    case historyThisWeek = "history.this_week"
    case historyThisMonth = "history.this_month"
    case historyThisYear = "history.this_year"
    case historyTimePeriod = "history.time_period"
    case historyRecentActivity = "history.recent_activity"
    case historyDetailedRecords = "history.detailed_records"
    case historyActivityTrend = "history.activity_trend"
    
    // MARK: - History Actions
    case historyStarted = "history.started"
    case historyTriggered = "history.triggered"
    case historyStopped = "history.stopped"
    case historyStartedReminder = "history.started_reminder"
    case historyTriggeredReminder = "history.triggered_reminder"
    case historyRespondedReminder = "history.responded_reminder"
    case historyOtherAction = "history.other_action"
    
    // MARK: - Fullscreen Reminder
    case fullscreenTitle = "fullscreen.title"
    case fullscreenDefaultMessage = "fullscreen.default_message"
    
    // MARK: - Language Names
    case languageEnglish = "language.english"
    case languageChineseSimplified = "language.chinese_simplified"
    case languageChineseTraditional = "language.chinese_traditional"
    case languageSystem = "language.system"
    case languageRestartHint = "language.restart_hint"
    
    // MARK: - Menu Bar
    case menuOpenMain = "menu.open_main"
    case menuSnooze = "menu.snooze"
    
    // MARK: - Notifications
    case notificationTitle = "notification.title"
    case notificationBody = "notification.body"
    
    var localized: String {
        let selected = UserDefaults.standard.string(forKey: "selectedLanguage")
        // print("🌐 Localization Debug - Key: \(self.rawValue), Selected Language: \(String(describing: selected))")
        
        if let lang = selected, lang != "system" {
            // Define search paths based on the selected language
            var searchLangs: [String] = [lang]
            
            // Add fallbacks for Traditional Chinese
            if lang == "zh-Hant" {
                searchLangs.append(contentsOf: ["zh_Hant", "zh-TW", "zh_TW", "zh-HK", "zh_HK"])
            } 
            // Add fallbacks for Simplified Chinese
            else if lang == "zh-Hans" {
                searchLangs.append(contentsOf: ["zh_Hans", "zh-CN", "zh_CN"])
            }
            
            // Try each language code
            for searchLang in searchLangs {
                if let path = Bundle.main.path(forResource: searchLang, ofType: "lproj"),
                   let bundle = Bundle(path: path) {
                    return NSLocalizedString(self.rawValue, tableName: nil, bundle: bundle, value: self.rawValue, comment: "")
                }
            }
            
            // Try replacing hyphen with underscore as a general fallback
            let altLang = lang.replacingOccurrences(of: "-", with: "_")
            if let path = Bundle.main.path(forResource: altLang, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                print("⚠️ Localization Warning - Found bundle with underscore: \(altLang)")
                return NSLocalizedString(self.rawValue, tableName: nil, bundle: bundle, value: self.rawValue, comment: "")
            }
            
            // Robust Discovery: List all available lproj bundles to debug
            if let urls = Bundle.main.urls(forResourcesWithExtension: "lproj", subdirectory: nil) {
                let availableBundles = urls.map { $0.deletingPathExtension().lastPathComponent }
                print("❌ Localization Error - Could not find bundle for language: \(lang). Checked: \(searchLangs)")
                print("📂 Available bundles in app: \(availableBundles)")
                
                // Fuzzy match attempt
                for available in availableBundles {
                    // Check if available bundle contains the language code (case insensitive)
                    if available.lowercased().contains(lang.lowercased().replacingOccurrences(of: "-", with: "")) ||
                       available.lowercased().contains(lang.lowercased().replacingOccurrences(of: "_", with: "")) {
                        print("🔄 Fuzzy match found: \(available) for \(lang)")
                        if let path = Bundle.main.path(forResource: available, ofType: "lproj"),
                           let bundle = Bundle(path: path) {
                            return NSLocalizedString(self.rawValue, tableName: nil, bundle: bundle, value: self.rawValue, comment: "")
                        }
                    }
                }
            } else {
                print("❌ Localization Error - No lproj bundles found in main bundle!")
            }
        }
        
        // Fallback to system default
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    /// Returns the raw key value for use with SwiftUI Text() initializer
    var key: String {
        self.rawValue
    }
}

// MARK: - Convenience Extension for SwiftUI
import SwiftUI

extension Text {
    init(_ key: LocalizationKeys) {
        self.init(key.localized)
    }
}
