import SwiftUI

struct ContentView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var showingSettings = false
    @State private var showingHistory = false

    var body: some View {
        ZStack {
            StandReminderBackground()

            VStack(spacing: 24) {
                header
                ReminderTimerPanel()
                ReminderControls()
                todaySummary
            }
            .padding(32)
        }
        .frame(width: 600, height: 680)
        .tint(StandReminderTheme.accent)
        .id(reminderManager.selectedLanguage)
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(reminderManager)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView().environmentObject(reminderManager)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            StandBrandMark()
            VStack(alignment: .leading, spacing: 4) {
                Text(.appTitle)
                    .font(.system(size: 20, weight: .semibold))
                Text(.appSubtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Label(LocalizationKeys.quickActionSettings.localized, systemImage: "slider.horizontal.3")
            }
            .buttonStyle(.standSecondary)
            .keyboardShortcut(",", modifiers: .command)
        }
    }

    private var todaySummary: some View {
        let summary = TodayRestSummary(records: reminderManager.reminderHistory, calendar: .current, now: Date())
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(.statsToday)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button {
                    showingHistory = true
                } label: {
                    HStack(spacing: 5) {
                        Text(.quickActionHistory)
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(StandReminderTheme.accent)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 24) {
                DashboardMetric(value: "\(summary.restSessions)", label: LocalizationKeys.statsRestSessions.localized)
                Divider().frame(height: 36)
                DashboardMetric(value: summary.formattedTotalRest, label: LocalizationKeys.statsRestTime.localized)
                Spacer(minLength: 0)
                Image(systemName: "figure.stand")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(StandReminderTheme.accent.opacity(0.55))
                    .accessibilityHidden(true)
            }
        }
        .padding(20)
        .standSurface()
    }
}

/// Shared by the main window and the menu bar, including the rest phase.
struct ReminderTimerPanel: View {
    @EnvironmentObject var reminderManager: ReminderManager
    var compact = false

    private var isResting: Bool { reminderManager.showingFullscreenReminder }

    private var timerLabel: String {
        if isResting { return LocalizationKeys.fullscreenRestCountdown.localized }
        return (reminderManager.isActive ? LocalizationKeys.timerNextReminder : .timerReady).localized
    }

    private var timerValue: String {
        let interval = reminderManager.useCustomInterval
            ? TimeInterval(reminderManager.customIntervalMinutes * 60)
            : reminderManager.selectedInterval
        return reminderManager.formatTimeInterval(
            isResting ? reminderManager.restTimeRemaining
                : reminderManager.isActive ? reminderManager.timeRemaining : interval
        )
    }

    private var subtitle: String {
        if isResting { return LocalizationKeys.dashboardRestHint.localized }
        return (reminderManager.isActive ? LocalizationKeys.dashboardActiveHint : .dashboardIdleHint).localized
    }

    var body: some View {
        VStack(spacing: compact ? 18 : 24) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(reminderManager.isActive ? StandReminderTheme.lime : Color.white.opacity(0.5))
                        .frame(width: 6, height: 6)
                    Text((isResting ? LocalizationKeys.statusResting
                          : reminderManager.isActive ? .statusEnabled : .statusPaused).localized)
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer()
                Image(systemName: isResting ? "figure.stand" : "arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(StandReminderTheme.lime)
                    .accessibilityHidden(true)
            }

            VStack(spacing: compact ? 6 : 8) {
                Text(timerLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))
                Text(timerValue)
                    .font(.system(size: compact ? 52 : 78, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if !compact {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            HStack(spacing: 16) {
                Label(intervalText, systemImage: "clock")
                Spacer(minLength: 0)
                Label("\(reminderManager.restDurationMinutes) \(LocalizationKeys.timeMinutesFull.localized)",
                      systemImage: "figure.stand")
                    .accessibilityLabel("\(LocalizationKeys.settingsRestTime.localized) \(reminderManager.restDurationMinutes) \(LocalizationKeys.timeMinutesFull.localized)")
            }
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.top, compact ? 12 : 18)
            .overlay(alignment: .top) {
                Rectangle().fill(.white.opacity(0.16)).frame(height: 1)
            }
        }
        .foregroundStyle(.white)
        .padding(compact ? 20 : 28)
        .background(StandReminderTheme.heroGradient,
                    in: RoundedRectangle(cornerRadius: compact ? 18 : 24, style: .continuous))
    }

    private var intervalText: String {
        let minutes = reminderManager.useCustomInterval
            ? reminderManager.customIntervalMinutes
            : Int(reminderManager.selectedInterval / 60)
        return String(format: LocalizationKeys.timerEveryMinutes.localized, minutes)
    }
}

struct ReminderControls: View {
    @EnvironmentObject var reminderManager: ReminderManager
    var compact = false

    private var primaryTitle: String {
        if reminderManager.showingFullscreenReminder { return LocalizationKeys.actionSkipRest.localized }
        return (reminderManager.isActive ? LocalizationKeys.actionPauseReminder : .actionStartReminder).localized
    }

    var body: some View {
        VStack(spacing: 10) {
            Button(action: performPrimaryAction) {
                Label(primaryTitle, systemImage: reminderManager.showingFullscreenReminder
                      ? "forward.end.fill" : reminderManager.isActive ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.standPrimary())
            .keyboardShortcut("s", modifiers: .command)

            if reminderManager.isActive && !reminderManager.showingFullscreenReminder {
                Menu {
                    ForEach([5, 10, 15], id: \.self) { minutes in
                        Button(String(format: LocalizationKeys.actionDelayMinutes.localized, minutes)) {
                            reminderManager.snoozeReminder(minutes: minutes)
                        }
                    }
                } label: {
                    Label(LocalizationKeys.menuDelay.localized, systemImage: "clock.arrow.circlepath")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                }
                .menuStyle(.borderlessButton)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: compact ? 170 : 190)
            } else {
                Text((reminderManager.showingFullscreenReminder
                      ? LocalizationKeys.dashboardRestHint : .dashboardStartHint).localized)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(height: 24)
            }
        }
    }

    private func performPrimaryAction() {
        if reminderManager.showingFullscreenReminder {
            reminderManager.skipRest()
        } else if reminderManager.isActive {
            reminderManager.stopReminder()
        } else {
            reminderManager.startReminder()
        }
    }
}

private struct DashboardMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.system(size: 25, weight: .medium, design: .rounded))
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView().environmentObject(ReminderManager())
}
