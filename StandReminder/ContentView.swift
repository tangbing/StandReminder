import SwiftUI

struct ContentView: View {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInitialized = true
            }
        }
    }
    
    private var loadingView: some View {
        ZStack {
            GradientBackground()
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text(.timerInitializing)
                    .font(.headline)
                    .padding(.top)
            }
        }
        .frame(width: 420, height: 520)
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeaderView()
                    .environmentObject(reminderManager)
                
                TimerView()
                    .environmentObject(reminderManager)
                
                ControlButtonsView()
                    .environmentObject(reminderManager)
                
                QuickActionsView(showingSettings: $showingSettings, showingHistory: $showingHistory)
                    .environmentObject(reminderManager)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .frame(width: 420)
        .frame(minHeight: 500, maxHeight: 700)
        .background(GradientBackground())
        .id(reminderManager.selectedLanguage)
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

// MARK: - 兼容性背景视图
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.15),
                Color.purple.opacity(0.1),
                Color.cyan.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct HeaderView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Color.clear
                    .frame(width: 80, height: 80)
                    .glassSurface(
                        shadowColor: .blue.opacity(0.2),
                        shadowRadius: 10,
                        shadowY: 0,
                        in: Circle()
                    )
                
                Image(systemName: "figure.stand")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(.appTitle)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(.appSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct TimerView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 16) {
            // 状态指示器
            HStack(spacing: 8) {
                Circle()
                    .fill(reminderManager.isActive ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                    .shadow(color: reminderManager.isActive ? .green.opacity(0.5) : .orange.opacity(0.5), radius: 4)
                
                Text(reminderManager.isActive ? 
                     LocalizationKeys.statusEnabled.localized :
                     LocalizationKeys.statusDisabled.localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .glassCapsule()
            
            // 倒计时
            if reminderManager.isActive {
                VStack(spacing: 10) {
                    Text(.timerNextReminder)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(1.5)
                    
                    Text(reminderManager.formatTimeInterval(reminderManager.timeRemaining))
                        .font(.system(size: 52, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassBackground(cornerRadius: 24)
            }
            
            // 间隔设置
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.cyan)
                Text(.timerInterval)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(reminderManager.useCustomInterval ? 
                     "\(reminderManager.customIntervalMinutes)\(LocalizationKeys.timeMinutes.localized)" :
                     reminderManager.formatIntervalOption(reminderManager.selectedInterval))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct ControlButtonsView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 12) {
            // 主按钮
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if reminderManager.isActive {
                        reminderManager.stopReminder()
                    } else {
                        reminderManager.startReminder()
                    }
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: reminderManager.isActive ? "stop.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(reminderManager.isActive ? 
                         LocalizationKeys.actionStopReminder.localized :
                         LocalizationKeys.actionStartReminder.localized)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: reminderManager.isActive ? 
                            [.red, .pink] : [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .shadow(color: (reminderManager.isActive ? Color.red : Color.blue).opacity(0.4), radius: 12, x: 0, y: 6)
            
            // 小憩按钮
            if reminderManager.isActive {
                HStack(spacing: 8) {
                    ForEach([5, 10, 15], id: \.self) { minutes in
                        Button(action: {
                            reminderManager.snoozeReminder(minutes: minutes)
                        }) {
                            Text("\(minutes)\(LocalizationKeys.timeMinutes.localized)")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .foregroundStyle(.orange)
                                .glassSurface(
                                    interactive: true,
                                    shadow: false,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: reminderManager.isActive)
    }
}

struct QuickActionsView: View {
    @Binding var showingSettings: Bool
    @Binding var showingHistory: Bool
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        VStack(spacing: 14) {
            // 今日统计
            let stats = reminderManager.getTodayStats()
            HStack(spacing: 0) {
                StatCard(value: "\(stats.reminders)", label: LocalizationKeys.statsReminders.localized, color: .blue)
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)
                
                StatCard(value: "\(stats.responses)", label: LocalizationKeys.statsResponses.localized, color: .green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .glassBackground(cornerRadius: 20)
            
            // 操作按钮
            HStack(spacing: 10) {
                ActionButton(icon: "gearshape.fill", label: LocalizationKeys.quickActionSettings.localized, color: .blue) {
                    showingSettings = true
                }
                
                ActionButton(icon: "chart.bar.fill", label: LocalizationKeys.quickActionHistory.localized, color: .green) {
                    showingHistory = true
                }
                
                ActionButton(icon: "power", label: LocalizationKeys.actionQuit.localized, color: .red) {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.caption)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .glassSurface(
                interactive: true,
                shadow: false,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderManager())
}
