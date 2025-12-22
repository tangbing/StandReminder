import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: TimePeriod = .week
    
    enum TimePeriod: String, CaseIterable {
        case week, month, year
        
        var localizedName: String {
            switch self {
            case .week: return LocalizationKeys.historyThisWeek.localized
            case .month: return LocalizationKeys.historyThisMonth.localized
            case .year: return LocalizationKeys.historyThisYear.localized
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [.green.opacity(0.12), .cyan.opacity(0.08), .blue.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 标题栏
                HStack {
                    Text(LocalizationKeys.historyTitle.localized)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text(LocalizationKeys.actionClose.localized)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing),
                                in: Capsule()
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                // 内容
                ScrollView {
                    VStack(spacing: 16) {
                        // 时间段选择
                        Picker("", selection: $selectedPeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.localizedName).tag(period)
                            }

                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        
                        // 统计卡片
                        GlassStatsView()
                            .environmentObject(reminderManager)
                        
                        // 历史列表
                        GlassHistoryListView(period: selectedPeriod)
                            .environmentObject(reminderManager)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .frame(width: 420, height: 580)
    }
}

struct GlassStatsView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    
    private var responseRate: String {
        let stats = reminderManager.getTodayStats()
        guard stats.reminders > 0 else { return "0%" }
        return String(format: "%.0f%%", Double(stats.responses) / Double(stats.reminders) * 100)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            GlassStatCard(
                value: "\(reminderManager.getTodayStats().reminders)",
                label: LocalizationKeys.statsReminders.localized,
                icon: "bell.fill",
                color: .blue
            )
            
            GlassStatCard(
                value: "\(reminderManager.getTodayStats().responses)",
                label: LocalizationKeys.statsResponses.localized,
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            GlassStatCard(
                value: responseRate,
                label: LocalizationKeys.statsResponseRate.localized,
                icon: "chart.bar.fill",
                color: .orange
            )
        }
        .padding(.horizontal, 20)
    }
}

struct GlassStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

struct GlassHistoryListView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    let period: HistoryView.TimePeriod
    
    private var filteredRecords: [ReminderRecord] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date = {
            switch period {
            case .week: return calendar.date(byAdding: .day, value: -7, to: now) ?? now
            case .month: return calendar.date(byAdding: .month, value: -1, to: now) ?? now
            case .year: return calendar.date(byAdding: .year, value: -1, to: now) ?? now
            }
        }()
        
        return reminderManager.reminderHistory
            .filter { $0.date >= startDate }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizationKeys.historyRecentActivity.localized)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(filteredRecords.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.ultraThinMaterial))
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredRecords.prefix(15), id: \.id) { record in
                        GlassHistoryRow(record: record)
                    }
                    
                    if filteredRecords.isEmpty {
                        Text("暂无记录")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 30)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 280)
        }
    }
}

struct GlassHistoryRow: View {
    let record: ReminderRecord
    
    private var iconName: String {
        if record.started { return "play.circle.fill" }
        if record.triggered { return "bell.badge.fill" }
        return "stop.circle.fill"
    }
    
    private var iconColor: Color {
        if record.started { return .green }
        if record.triggered { return .blue }
        return .red
    }
    
    private var actionText: String {
        if record.started { return LocalizationKeys.historyStarted.localized }
        if record.triggered { return LocalizationKeys.historyTriggered.localized }
        return LocalizationKeys.historyStopped.localized
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.system(size: 14))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 20)
            
            Text(actionText)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(DateFormatter.timeFormatter.string(from: record.date))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    HistoryView()
        .environmentObject(ReminderManager())
}
