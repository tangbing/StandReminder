import SwiftUI

// 安全的 ContentView 实现
struct SafeContentView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var isInitialized = false
    
    var body: some View {
        Group {
            if isInitialized {
                mainContent
            } else {
                loadingView
            }
        }
        .onAppear {
            // 延迟初始化，确保环境对象已经绑定
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInitialized = true
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text(LocalizationKeys.timerInitializing.localized)
                .font(.headline)
                .padding(.top)
        }
        .frame(width: 400, height: 500)
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            SafeHeaderView()
                .environmentObject(reminderManager)
            
            SafeTimerView()
                .environmentObject(reminderManager)
            
            SafeControlButtonsView()
                .environmentObject(reminderManager)
            
            SafeQuickActionsView(showingSettings: $showingSettings, showingHistory: $showingHistory)
                .environmentObject(reminderManager)

            Spacer()
        }
        .padding(30)
        .frame(width: 400, height: 500)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(reminderManager)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(reminderManager)
        }
    }
}

// 安全的 HeaderView
struct SafeHeaderView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.stand")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(safeLanguageText())
                .font(.title)
                .fontWeight(.bold)
            
            Text(safeSubtitleText())
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func safeLanguageText() -> String {
        return LocalizationKeys.appTitle.localized
    }
    
    private func safeSubtitleText() -> String {
        return LocalizationKeys.appSubtitle.localized
    }
}

// 安全的 TimerView
struct SafeTimerView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 15) {
            // 当前状态
            HStack {
                Image(systemName: reminderManager.isActive ? "play.circle.fill" : "pause.circle.fill")
                    .foregroundColor(reminderManager.isActive ? .green : .orange)
                
                Text(safeStatusText())
                    .font(.headline)
            }
            
            // 倒计时显示
            if reminderManager.isActive {
                VStack(spacing: 8) {
                    Text(safeNextReminderText())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reminderManager.formatTimeInterval(reminderManager.timeRemaining))
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
            
            // 当前设置显示
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(safeIntervalLabelText())
                    .foregroundColor(.secondary)
                Text(reminderManager.formatIntervalOption(reminderManager.selectedInterval))
                    .fontWeight(.medium)
            }
            .font(.caption)
        }
    }
    
    private func safeStatusText() -> String {
        if reminderManager.isActive {
            return LocalizationKeys.statusEnabled.localized
        } else {
            return LocalizationKeys.statusDisabled.localized
        }
    }
    
    private func safeNextReminderText() -> String {
        return LocalizationKeys.timerNextReminder.localized
    }
    
    private func safeIntervalLabelText() -> String {
        return LocalizationKeys.timerInterval.localized
    }
}

// 安全的 ControlButtonsView
struct SafeControlButtonsView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 15) {
            // 主控制按钮
            Button(action: {
                if reminderManager.isActive {
                    reminderManager.stopReminder()
                } else {
                    reminderManager.startReminder()
                }
            }) {
                HStack {
                    Image(systemName: reminderManager.isActive ? "stop.fill" : "play.fill")
                    Text(safeMainButtonText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(reminderManager.isActive ? Color.red : Color.blue)
                )
                .foregroundColor(.white)
                .font(.headline)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 小憩按钮
            if reminderManager.isActive {
                HStack(spacing: 10) {
                    ForEach([5, 10, 15], id: \.self) { minutes in
                        Button(action: {
                            reminderManager.snoozeReminder(minutes: minutes)
                        }) {
                            Text(safeSnoozeText(minutes: minutes))
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.2))
                                )
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func safeMainButtonText() -> String {
        if reminderManager.isActive {
            return LocalizationKeys.actionStopReminder.localized
        } else {
            return LocalizationKeys.actionStartReminder.localized
        }
    }
    
    private func safeSnoozeText(minutes: Int) -> String {
        return "\(minutes)\(LocalizationKeys.timeMinutes.localized)"
    }
}

// 安全的 QuickActionsView
struct SafeQuickActionsView: View {
    @Binding var showingSettings: Bool
    @Binding var showingHistory: Bool
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 15) {
            // 今日统计
            todayStatsView
            
            // 操作按钮
            actionButtonsView
        }
    }
    
    private var todayStatsView: some View {
        let stats = reminderManager.getTodayStats()
        return VStack(spacing: 5) {
            Text(safeTodayStatsText())
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(stats.reminders)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(safeRemindersText())
                        .font(.caption2)
                }
                
                VStack {
                    Text("\(stats.responses)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text(safeResponsesText())
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.1))
        )
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 15) {
            Button(action: {
                showingSettings = true
            }) {
                VStack {
                    Image(systemName: "gear")
                    Text(safeSettingsText())
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                showingHistory = true
            }) {
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text(safeHistoryText())
                        .font(.caption)
                }
                .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                VStack {
                    Image(systemName: "xmark.circle")
                    Text(safeQuitText())
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func safeTodayStatsText() -> String {
        return LocalizationKeys.statsToday.localized
    }
    
    private func safeRemindersText() -> String {
        return LocalizationKeys.statsReminders.localized
    }
    
    private func safeResponsesText() -> String {
        return LocalizationKeys.statsResponses.localized
    }
    
    private func safeSettingsText() -> String {
        return LocalizationKeys.quickActionSettings.localized
    }
    
    private func safeHistoryText() -> String {
        return LocalizationKeys.quickActionHistory.localized
    }
    
    private func safeQuitText() -> String {
        return LocalizationKeys.actionQuit.localized
    }
}

#Preview {
    SafeContentView()
        .environmentObject(ReminderManager())
}