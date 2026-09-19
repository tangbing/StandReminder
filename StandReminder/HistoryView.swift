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
            StandReminderBackground()

            VStack(spacing: 0) {
                HistoryHeader(closeAction: dismiss.callAsFunction)

                Divider()

                ScrollView {
                    VStack(spacing: 18) {
                        Text(.statsToday)
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        GlassStatsView()

                        Picker(LocalizationKeys.historyTimePeriod.localized, selection: $selectedPeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.localizedName).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .accessibilityLabel(LocalizationKeys.historyTimePeriod.localized)

                        GlassRestTrendView(period: selectedPeriod)
                            .environmentObject(reminderManager)

                        GlassHistoryListView(period: selectedPeriod)
                            .environmentObject(reminderManager)
                    }
                    .padding(28)
                }
            }
        }
        .frame(width: 600, height: 620)
        .tint(StandReminderTheme.accent)
        .id(reminderManager.selectedLanguage)
    }
}

private struct HistoryHeader: View {
    let closeAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizationKeys.historyTitle.localized)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Text(LocalizationKeys.historyActivityTrend.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(LocalizationKeys.actionClose.localized, action: closeAction)
                .buttonStyle(.standSecondary)
                .keyboardShortcut(.cancelAction)
        }
        .padding(28)
    }
}

struct GlassStatsView: View {
    @EnvironmentObject var reminderManager: ReminderManager

    private var todayRestSummary: TodayRestSummary {
        TodayRestSummary(records: reminderManager.reminderHistory, calendar: .current, now: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            GlassStatCard(
                value: todayRestSummary.formattedTotalRest,
                label: LocalizationKeys.statsRestTime.localized,
                icon: "figure.walk"
            )

            GlassStatCard(
                value: "\(todayRestSummary.restSessions)",
                label: LocalizationKeys.statsRestSessions.localized,
                icon: "figure.stand"
            )

            GlassStatCard(
                value: todayRestSummary.formattedAverageRest,
                label: LocalizationKeys.statsAvgRest.localized,
                icon: "timer"
            )
        }
    }
}

struct GlassStatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(StandReminderTheme.accent)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 30, height: 30)
                .background(StandReminderTheme.accentSoft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .standSurface(cornerRadius: 16)
        .accessibilityElement(children: .combine)
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
            .filter { $0.responded && $0.date >= startDate }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizationKeys.historyRestRecords.localized)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(filteredRecords.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.06), in: Capsule())
            }

                LazyVStack(spacing: 0) {
                    ForEach(filteredRecords, id: \.id) { record in
                        GlassHistoryRow(record: record)
                        Divider()
                    }

                    if filteredRecords.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "figure.stand")
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(StandReminderTheme.accent)
                            Text(LocalizationKeys.historyNoRecords.localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(.historyEmptyHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 34)
                    }
                }
        }
        .padding(18)
        .standSurface(cornerRadius: 18)
    }
}

struct GlassHistoryRow: View {
    let record: ReminderRecord

    private var iconName: String {
        "figure.stand"
    }

    private var iconColor: Color {
        StandReminderTheme.accent
    }

    private var actionText: String {
        if let seconds = record.restSecondsUsed {
            return "\(LocalizationKeys.historyRested.localized) \(formatMMSS(seconds))"
        }
        return LocalizationKeys.historyRested.localized
    }

    private func formatMMSS(_ totalSeconds: Int) -> String {
        let clamped = max(0, totalSeconds)
        let minutes = clamped / 60
        let seconds = clamped % 60
        return String(format: "%02d:%02d", minutes, seconds)
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

            Text(record.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .accessibilityElement(children: .combine)
    }
}

struct GlassRestTrendView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    let period: HistoryView.TimePeriod

    private var trendPoints: [RestTrendPoint] {
        RestTrendPoint.build(
            period: period,
            records: reminderManager.reminderHistory,
            calendar: .current,
            now: Date()
        )
    }

    private var totalRestSeconds: Int {
        trendPoints.reduce(0) { $0 + $1.restSeconds }
    }

    private var formattedTotalRest: String {
        TodayRestSummary.formatHoursMinutes(seconds: totalRestSeconds)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizationKeys.historyRestTrend.localized)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(formattedTotalRest)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.06), in: Capsule())
            }

            if totalRestSeconds == 0 {
                Text(.historyNoRecords)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                RestTrendBarChart(points: trendPoints, period: period)
                    .frame(height: 120)
            }
        }
        .padding(18)
        .standSurface(cornerRadius: 18)
    }
}

struct RestTrendBarChart: View {
    let points: [RestTrendPoint]
    let period: HistoryView.TimePeriod

    private var maxMinutes: Double {
        let maxValue = points.map { $0.restMinutes }.max() ?? 0
        return max(1, maxValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let availableHeight = max(1, proxy.size.height)
                HStack(alignment: .bottom, spacing: period == .month ? 2 : 6) {
                    ForEach(points) { point in
                        let ratio = point.restMinutes / maxMinutes
                        let barHeight = max(2, availableHeight * ratio)
                        Capsule(style: .continuous)
                            .fill(StandReminderTheme.accent.opacity(point.restSeconds > 0 ? 0.88 : 0.12))
                            .frame(height: barHeight)
                            .accessibilityElement()
                            .accessibilityLabel(point.accessibilityLabel(period: period))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }

            HStack {
                Text(points.first?.xAxisLabel(period: period) ?? "")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(points.last?.xAxisLabel(period: period) ?? "")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(LocalizationKeys.historyRestTrend.localized)
    }
}

struct TodayRestSummary {
    let totalRestSeconds: Int
    let restSessions: Int

    init(records: [ReminderRecord], calendar: Calendar, now: Date) {
        let startOfDay = calendar.startOfDay(for: now)
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            self.totalRestSeconds = 0
            self.restSessions = 0
            return
        }

        let todayRestRecords = records.filter { record in
            record.responded && record.date >= startOfDay && record.date < startOfTomorrow
        }

        self.restSessions = todayRestRecords.count
        self.totalRestSeconds = todayRestRecords.compactMap(\.restSecondsUsed).reduce(0, +)
    }

    var formattedTotalRest: String {
        Self.formatHoursMinutes(seconds: totalRestSeconds)
    }

    var formattedAverageRest: String {
        guard restSessions > 0 else { return "00:00" }
        let averageSeconds = max(0, totalRestSeconds / restSessions)
        return Self.formatMMSS(seconds: averageSeconds)
    }

    static func formatMMSS(seconds totalSeconds: Int) -> String {
        let clamped = max(0, totalSeconds)
        let minutes = clamped / 60
        let seconds = clamped % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func formatHoursMinutes(seconds totalSeconds: Int) -> String {
        let clamped = max(0, totalSeconds)
        let totalMinutes = clamped / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)\(LocalizationKeys.timeHours.localized) \(minutes)\(LocalizationKeys.timeMinutes.localized)"
        }
        return "\(totalMinutes)\(LocalizationKeys.timeMinutes.localized)"
    }
}

struct RestTrendPoint: Identifiable {
    let id: String
    let date: Date
    let restSeconds: Int

    var restMinutes: Double {
        Double(restSeconds) / 60.0
    }

    func xAxisLabel(period: HistoryView.TimePeriod) -> String {
        switch period {
        case .week:
            return Self.weekdayFormatter.string(from: date)
        case .month:
            return Self.monthDayFormatter.string(from: date)
        case .year:
            return Self.monthFormatter.string(from: date)
        }
    }

    func accessibilityLabel(period: HistoryView.TimePeriod) -> String {
        let label = xAxisLabel(period: period)
        let minutesString = String(format: "%.0f", restMinutes)
        return "\(label): \(minutesString)\(LocalizationKeys.timeMinutesFull.localized)"
    }

    static func build(period: HistoryView.TimePeriod, records: [ReminderRecord], calendar: Calendar, now: Date) -> [RestTrendPoint] {
        switch period {
        case .week:
            return buildDaily(days: 7, records: records, calendar: calendar, now: now)
        case .month:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return buildDaily(from: startDate, to: now, records: records, calendar: calendar)
        case .year:
            return buildMonthly(months: 12, records: records, calendar: calendar, now: now)
        }
    }

    private static func buildDaily(days: Int, records: [ReminderRecord], calendar: Calendar, now: Date) -> [RestTrendPoint] {
        let clampedDays = max(1, days)
        let endDate = calendar.startOfDay(for: now)
        let startDate = calendar.date(byAdding: .day, value: -(clampedDays - 1), to: endDate) ?? endDate
        return buildDaily(from: startDate, to: endDate, records: records, calendar: calendar)
    }

    private static func buildDaily(from startDate: Date, to endDate: Date, records: [ReminderRecord], calendar: Calendar) -> [RestTrendPoint] {
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        var points: [RestTrendPoint] = []
        var currentDay = startDay

        while currentDay <= endDay {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }

            let restSeconds = records
                .filter { record in
                    record.responded && record.date >= currentDay && record.date < nextDay
                }
                .compactMap(\.restSecondsUsed)
                .reduce(0, +)

            let id = String(Int(currentDay.timeIntervalSince1970))
            points.append(RestTrendPoint(id: id, date: currentDay, restSeconds: restSeconds))
            currentDay = nextDay
        }

        return points
    }

    private static func buildMonthly(months: Int, records: [ReminderRecord], calendar: Calendar, now: Date) -> [RestTrendPoint] {
        let clampedMonths = max(1, months)
        guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }

        var points: [RestTrendPoint] = []
        for offset in stride(from: clampedMonths - 1, through: 0, by: -1) {
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: startOfCurrentMonth) else { continue }
            guard let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }

            let restSeconds = records
                .filter { record in
                    record.responded && record.date >= monthStart && record.date < nextMonthStart
                }
                .compactMap(\.restSecondsUsed)
                .reduce(0, +)

            let id = String(Int(monthStart.timeIntervalSince1970))
            points.append(RestTrendPoint(id: id, date: monthStart, restSeconds: restSeconds))
        }

        return points
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }()
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
