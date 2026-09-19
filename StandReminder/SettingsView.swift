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
    @State private var hasLoadedSettings = false
    @State private var selectedTab: SettingsTab = .rhythm

    private enum SettingsTab: String, CaseIterable {
        case rhythm, reminder, general

        var title: String {
            switch self {
            case .rhythm: return LocalizationKeys.settingsRhythm.localized
            case .reminder: return LocalizationKeys.settingsReminder.localized
            case .general: return LocalizationKeys.settingsGeneral.localized
            }
        }
    }

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
            StandReminderBackground()

            VStack(spacing: 0) {
                SettingsHeader(
                    cancelAction: dismiss.callAsFunction,
                    saveAction: saveAndDismiss
                )

                Picker(LocalizationKeys.settingsTitle.localized, selection: $selectedTab) {
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel(LocalizationKeys.settingsTitle.localized)
                .padding(.horizontal, 28)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 18) {
                        switch selectedTab {
                        case .rhythm:
                            intervalSection
                            activeHoursSection
                        case .reminder:
                            messageSection
                            soundSection
                        case .general:
                            languageSection
                            shortcutSection
                        }
                    }
                    .padding(28)
                }
            }
        }
        .frame(width: 600, height: 600)
        .tint(StandReminderTheme.accent)
        .id(reminderManager.selectedLanguage)
        .onAppear(perform: loadCurrentSettings)
    }

    private var intervalChoices: [TimeInterval] {
        let additionalIntervals: [TimeInterval] = [30 * 60, 60 * 60, tempInterval]
        return Array(Set(reminderManager.intervalOptions + additionalIntervals)).sorted()
    }

    private var intervalSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsReminderInterval.localized,
            icon: "clock"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $tempUseCustomInterval) {
                    HStack {
                        Text(.settingsCustomInterval)
                        Spacer()
                    }
                }
                    .toggleStyle(.switch)
                    .tint(StandReminderTheme.accent)

                if tempUseCustomInterval {
                    LabeledContent(LocalizationKeys.settingsSelectInterval.localized) {
                        HStack(spacing: 8) {
                            TextField("20", value: $tempCustomIntervalMinutes, formatter: Self.numberFormatter)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 78)
                            Text(LocalizationKeys.timeMinutesFull.localized)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Picker(LocalizationKeys.settingsSelectInterval.localized, selection: $tempInterval) {
                        ForEach(intervalChoices, id: \.self) { interval in
                            Text(reminderManager.formatIntervalOption(interval)).tag(interval)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                HStack {
                    Text(LocalizationKeys.settingsRestTime.localized)
                    Spacer()
                    Text("\(tempRestDurationMinutes) \(LocalizationKeys.timeMinutesFull.localized)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Stepper(
                        LocalizationKeys.settingsRestTime.localized,
                        value: $tempRestDurationMinutes,
                        in: 1...120
                    )
                    .labelsHidden()
                    .accessibilityLabel(LocalizationKeys.settingsRestTime.localized)
                    .accessibilityValue("\(tempRestDurationMinutes) \(LocalizationKeys.timeMinutesFull.localized)")
                }
            }
        }
    }

    private var activeHoursSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsActiveHours.localized,
            icon: "calendar.badge.clock"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $tempEnableActiveTimeLimit) {
                    HStack {
                        Text(.settingsTimeLimit)
                        Spacer()
                    }
                }
                    .toggleStyle(.switch)
                    .tint(StandReminderTheme.accent)

                if tempEnableActiveTimeLimit {
                    VStack(spacing: 10) {
                        DatePicker(
                            LocalizationKeys.settingsStart.localized,
                            selection: $tempStartTime,
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            LocalizationKeys.settingsEnd.localized,
                            selection: $tempEndTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Text(LocalizationKeys.settingsTimeLimitDescription.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var messageSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsReminderMessage.localized,
            icon: "text.bubble"
        ) {
            TextField(
                LocalizationKeys.settingsEnterReminderText.localized,
                text: $tempMessage,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(2...4)
        }
    }

    private var soundSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsSound.localized,
            icon: "speaker.wave.2"
        ) {
            Toggle(isOn: $tempEnableSound) {
                HStack {
                    Text(.settingsPlaySound)
                    Spacer()
                }
            }
                .toggleStyle(.switch)
                .tint(StandReminderTheme.accent)
        }
    }

    private var languageSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsLanguage.localized,
            icon: "globe"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Picker(
                    LocalizationKeys.settingsInterfaceLanguage.localized,
                    selection: Binding(
                        get: { tempLanguage },
                        set: updateLanguage
                    )
                ) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)

                Text(LocalizationKeys.languageRestartHint.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var shortcutSection: some View {
        SettingSection(
            title: LocalizationKeys.settingsKeyboardShortcuts.localized,
            icon: "command"
        ) {
            VStack(spacing: 10) {
                ShortcutRow(
                    keys: "⌘S",
                    description: LocalizationKeys.settingsShortcutStartStop.localized
                )
                ShortcutRow(
                    keys: "⌘M",
                    description: LocalizationKeys.menuOpenMain.localized
                )
            }
        }
    }

    private func updateLanguage(_ language: AppLanguage) {
        tempLanguage = language
        reminderManager.setLanguage(language)
    }

    private func loadCurrentSettings() {
        guard !hasLoadedSettings else { return }
        hasLoadedSettings = true
        tempInterval = reminderManager.selectedInterval
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

    private func saveAndDismiss() {
        reminderManager.selectedInterval = tempInterval

        let trimmedMessage = tempMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        reminderManager.customMessage = trimmedMessage.isEmpty ? "站立一下" : tempMessage
        reminderManager.activeStartTime = tempStartTime
        reminderManager.activeEndTime = tempEndTime
        reminderManager.enableSound = tempEnableSound
        reminderManager.enableActiveTimeLimit = tempEnableActiveTimeLimit
        reminderManager.customIntervalMinutes = max(1, tempCustomIntervalMinutes)
        reminderManager.useCustomInterval = tempUseCustomInterval
        reminderManager.restDurationMinutes = tempRestDurationMinutes
        reminderManager.setLanguage(tempLanguage)
        reminderManager.applyLanguage()
        reminderManager.persistSettingsAndRescheduleIfNeeded()
        dismiss()
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        return formatter
    }()
}

private struct SettingsHeader: View {
    let cancelAction: () -> Void
    let saveAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizationKeys.settingsTitle.localized)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Text(LocalizationKeys.settingsSubtitle.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(LocalizationKeys.actionCancel.localized, action: cancelAction)
                .buttonStyle(.standSecondary)
                .keyboardShortcut(.cancelAction)

            Button(LocalizationKeys.actionSave.localized, action: saveAction)
                .buttonStyle(.standPrimary())
                .frame(width: 92)
                .keyboardShortcut(.defaultAction)
        }
        .padding(28)
    }
}

private struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(StandReminderTheme.accent)
                    .frame(width: 30, height: 30)
                    .background(StandReminderTheme.accentSoft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .standSurface(cornerRadius: 18)
    }
}

private struct ShortcutRow: View {
    let keys: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Text(keys)
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .frame(width: 42, height: 26)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ReminderManager())
}
