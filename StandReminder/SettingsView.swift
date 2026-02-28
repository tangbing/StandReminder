import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempInterval: TimeInterval
    @State private var tempMessage: String
    @State private var tempStartTime: Date
    @State private var tempEndTime: Date
    @State private var tempEnableSound: Bool
    @State private var tempEnableActiveTimeLimit: Bool
    @State private var tempCustomIntervalMinutes: Int
    @State private var tempUseCustomInterval: Bool
    @State private var tempRestDurationMinutes: Int
    @State private var tempLanguage: AppLanguage
    
    init() {
        _tempInterval = State(initialValue: 20 * 60)
        _tempMessage = State(initialValue: "站立一下")
        _tempStartTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date())
        _tempEndTime = State(initialValue: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date())
        _tempEnableSound = State(initialValue: true)
        _tempEnableActiveTimeLimit = State(initialValue: false)
        _tempCustomIntervalMinutes = State(initialValue: 20)
        _tempUseCustomInterval = State(initialValue: false)
        _tempRestDurationMinutes = State(initialValue: 15)
        _tempLanguage = State(initialValue: .system)
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [.purple.opacity(0.12), .blue.opacity(0.08), .cyan.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 标题栏
                HStack {
                    Text(LocalizationKeys.settingsTitle.localized)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(LocalizationKeys.actionCancel.localized) {
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        
                        Button(action: {
                            saveSettings()
                            dismiss()
                        }) {
                            Text(LocalizationKeys.actionSave.localized)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing),
                                    in: Capsule()
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // 设置内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 提醒间隔
                        GlassSettingSection(
                            title: LocalizationKeys.settingsReminderInterval.localized,
                            icon: "clock",
                            color: .blue
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(LocalizationKeys.settingsCustomInterval.localized, isOn: $tempUseCustomInterval)
                                    .toggleStyle(.switch)
                                    .tint(.blue)
                                
                                if tempUseCustomInterval {
                                    HStack(spacing: 8) {
                                        TextField("20", value: $tempCustomIntervalMinutes, formatter: NumberFormatter())
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 80)
                                        Text(LocalizationKeys.timeMinutesFull.localized)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Picker(selection: $tempInterval) {
                                        ForEach(reminderManager.intervalOptions, id: \.self) { interval in
                                            Text(reminderManager.formatIntervalOption(interval)).tag(interval)
                                        }
                                    } label: {
                                        Text(LocalizationKeys.settingsSelectInterval.localized)
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                }
                                
                                Divider().opacity(0.6)
                                
                                HStack(spacing: 8) {
                                    Text(LocalizationKeys.settingsRestTime.localized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(tempRestDurationMinutes) \(LocalizationKeys.timeMinutesFull.localized)")
                                        .font(.subheadline)
                                        .monospacedDigit()
                                    
                                    Stepper("", value: $tempRestDurationMinutes, in: 1...120, step: 1)
                                        .labelsHidden()
                                }
                            }
                        }
                    
                        // 活跃时间段
                        GlassSettingSection(
                            title: LocalizationKeys.settingsActiveHours.localized,
                            icon: "calendar.badge.clock",
                            color: .purple
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(LocalizationKeys.settingsTimeLimit.localized, isOn: $tempEnableActiveTimeLimit)
                                    .toggleStyle(.switch)
                                    .tint(.purple)
                                
                                if tempEnableActiveTimeLimit {
                                    VStack(spacing: 10) {
                                        DatePicker(LocalizationKeys.settingsStart.localized, selection: $tempStartTime, displayedComponents: .hourAndMinute)
                                        DatePicker(LocalizationKeys.settingsEnd.localized, selection: $tempEndTime, displayedComponents: .hourAndMinute)
                                    }
                                    
                                    Text(LocalizationKeys.settingsTimeLimitDescription.localized)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    
                        // 提醒内容
                        GlassSettingSection(
                            title: LocalizationKeys.settingsReminderMessage.localized,
                            icon: "text.bubble",
                            color: .cyan
                        ) {
                            TextField(LocalizationKeys.settingsEnterReminderText.localized, text: $tempMessage, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(2...4)
                        }
                        
                        // 声音设置
                        GlassSettingSection(
                            title: LocalizationKeys.settingsSound.localized,
                            icon: "speaker.wave.2",
                            color: .orange
                        ) {
                            Toggle(LocalizationKeys.settingsPlaySound.localized, isOn: $tempEnableSound)
                                .toggleStyle(.switch)
                                .tint(.orange)
                        }
                        
                        // 语言设置
                        GlassSettingSection(
                            title: LocalizationKeys.settingsLanguage.localized,
                            icon: "globe",
                            color: .indigo
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Picker(selection: Binding(
                                    get: { reminderManager.selectedLanguage },
                                    set: { newValue in
                                        reminderManager.setLanguage(newValue)
                                    }
                                )) {
                                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                } label: {
                                    Text(LocalizationKeys.settingsInterfaceLanguage.localized)
                                }
                                .pickerStyle(.menu)
                                
                                Text(LocalizationKeys.languageRestartHint.localized)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        // .id(languageChangedId) - Moved to root view
                        
                        // 快捷键
                        GlassSettingSection(
                            title: LocalizationKeys.settingsKeyboardShortcuts.localized,
                            icon: "command",
                            color: .green
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                GlassShortcutRow(keys: "⌘S", description: LocalizationKeys.settingsShortcutStartStop.localized)
                                GlassShortcutRow(keys: "⌘P", description: LocalizationKeys.settingsShortcutPauseResume.localized)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
        .frame(width: 420, height: 580)
        .id(reminderManager.selectedLanguage) // 语言变化时刷新整个视图
        .onAppear { loadCurrentSettings() }
    }
    
    private func loadCurrentSettings() {
        tempInterval = reminderManager.selectedInterval
        // 显示为原样字符串
        tempMessage = reminderManager.customMessage
        tempStartTime = reminderManager.activeStartTime
        tempEndTime = reminderManager.activeEndTime
        tempEnableSound = reminderManager.enableSound
        tempEnableActiveTimeLimit = reminderManager.enableActiveTimeLimit
        tempCustomIntervalMinutes = reminderManager.customIntervalMinutes
        tempUseCustomInterval = reminderManager.useCustomInterval
        tempRestDurationMinutes = reminderManager.restDurationMinutes
        tempLanguage = reminderManager.selectedLanguage
    }
    
    private func saveSettings() {
        reminderManager.selectedInterval = tempInterval
        // 提醒内容不做国际化：直接存储用户输入；若为空则存固定默认值
        let trimmed = tempMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        reminderManager.customMessage = trimmed.isEmpty ? "站立一下" : trimmed
        reminderManager.activeStartTime = tempStartTime
        reminderManager.activeEndTime = tempEndTime
        reminderManager.enableSound = tempEnableSound
        reminderManager.enableActiveTimeLimit = tempEnableActiveTimeLimit
        reminderManager.customIntervalMinutes = tempCustomIntervalMinutes
        reminderManager.useCustomInterval = tempUseCustomInterval
        reminderManager.restDurationMinutes = tempRestDurationMinutes
        reminderManager.selectedLanguage = tempLanguage
        reminderManager.applyLanguage()
        reminderManager.persistSettingsAndRescheduleIfNeeded()
    }
}

struct GlassSettingSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            content
                .padding(.leading, 28)
        }
        .padding(14)
        .glassBackground(cornerRadius: 16)
    }
}

struct GlassShortcutRow: View {
    let keys: String
    let description: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glassSurface(shadow: false, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ReminderManager())
}
