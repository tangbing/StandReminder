import SwiftUI

struct FullscreenReminderView: View {
    @EnvironmentObject var reminderManager: ReminderManager

    private var reminderMessage: String {
        let trimmedMessage = reminderManager.customMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedMessage.isEmpty ? "站立一下" : reminderManager.customMessage
    }

    var body: some View {
        ZStack {
            StandReminderTheme.heroGradient.ignoresSafeArea()

            VStack(spacing: 32) {
                HStack(spacing: 14) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 76, weight: .light))
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(StandReminderTheme.lime)
                }
                .accessibilityHidden(true)

                VStack(spacing: 14) {
                    Text(.fullscreenTitle)
                        .font(.system(size: 40, weight: .medium))
                    Text(reminderMessage)
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                    Text(.fullscreenHint)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.70))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    Text(reminderManager.formatTimeInterval(reminderManager.restTimeRemaining))
                        .font(.system(size: 68, weight: .light, design: .rounded))
                        .monospacedDigit()
                    Text(.fullscreenRestCountdown)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .accessibilityElement(children: .combine)

                Button(action: reminderManager.skipRest) {
                    Label(LocalizationKeys.actionSkipRest.localized, systemImage: "arrow.right")
                }
                .buttonStyle(.standPrimary(
                    tint: StandReminderTheme.lime,
                    foreground: StandReminderTheme.deepTeal
                ))
                .frame(width: 220)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .foregroundStyle(.white)
            .frame(maxWidth: 700)
            .padding(48)
        }
        .id(reminderManager.selectedLanguage)
    }
}

#Preview {
    FullscreenReminderView().environmentObject(ReminderManager())
}
