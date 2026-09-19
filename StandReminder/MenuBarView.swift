import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 9) {
                StandBrandMark(size: 30)
                Text(.appTitle)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Menu {
                    Button(LocalizationKeys.quickActionSettings.localized) { showWindow("settings") }
                    Button(LocalizationKeys.quickActionHistory.localized) { showWindow("history") }
                    Divider()
                    Button(LocalizationKeys.actionQuit.localized) { NSApp.terminate(nil) }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .accessibilityLabel(LocalizationKeys.menuMore.localized)
                .help(LocalizationKeys.menuMore.localized)
            }

            ReminderTimerPanel(compact: true)
            ReminderControls(compact: true)

            Button { showWindow("main") } label: {
                HStack {
                    Text(.menuOpenMain)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 320)
        .background { StandReminderBackground() }
        .tint(StandReminderTheme.accent)
        .id(reminderManager.selectedLanguage)
    }

    private func showWindow(_ id: String) {
        openWindow(id: id)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

#Preview {
    MenuBarView().environmentObject(ReminderManager())
}
