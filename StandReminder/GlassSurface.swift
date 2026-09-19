import SwiftUI

enum StandReminderTheme {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
            return NSColor(srgbRed: 0.55, green: 0.84, blue: 0.74, alpha: 1)
        }
        return NSColor(srgbRed: 0.06, green: 0.43, blue: 0.41, alpha: 1)
    })
    static let buttonFill = Color(red: 0.06, green: 0.43, blue: 0.41)
    static let accentSoft = accent.opacity(0.10)
    static let lime = Color(red: 0.75, green: 0.95, blue: 0.65)
    static let deepTeal = Color(red: 0.025, green: 0.25, blue: 0.24)
    static let success = accent
    static let warning = Color(red: 0.70, green: 0.43, blue: 0.16)
    static let destructive = Color(red: 0.76, green: 0.24, blue: 0.27)
    static let heroGradient = LinearGradient(
        colors: [Color(red: 0.075, green: 0.45, blue: 0.43), deepTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct StandReminderBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        (colorScheme == .dark
            ? Color(red: 0.065, green: 0.10, blue: 0.095)
            : Color(red: 0.955, green: 0.97, blue: 0.96))
            .ignoresSafeArea()
    }
}

/// The same upright figure and upward gesture as the app icon.
struct StandBrandMark: View {
    var size: CGFloat = 44

    var body: some View {
        HStack(alignment: .center, spacing: size * 0.06) {
            Image(systemName: "figure.stand")
                .font(.system(size: size * 0.58, weight: .medium))
                .foregroundStyle(.white)
            Image(systemName: "arrow.up")
                .font(.system(size: size * 0.32, weight: .bold))
                .foregroundStyle(StandReminderTheme.lime)
        }
        .frame(width: size, height: size)
        .background(StandReminderTheme.heroGradient,
                    in: RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        .accessibilityHidden(true)
    }
}

enum GlassSurfaceProminence {
    case regular
    case prominent
}

extension View {
    func standSurface(cornerRadius: CGFloat = 18, shadow: Bool = false) -> some View {
        modifier(StandSurfaceModifier(cornerRadius: cornerRadius, showsShadow: shadow))
    }

    @ViewBuilder
    func glassSurface<S: Shape>(
        prominence: GlassSurfaceProminence = .regular,
        tint: Color? = nil,
        interactive: Bool = false,
        shadow: Bool = true,
        shadowColor: Color = Color.black.opacity(0.08),
        shadowRadius: CGFloat = 8,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 4,
        in shape: S
    ) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            var style: GlassEffectStyle = (prominence == .regular) ? .regular : .prominent
            if let tint {
                style = style.tint(tint)
            }
            if interactive {
                style = style.interactive()
            }

            self
                .glassEffect(style, in: shape)
        } else {
            self
                .background(
                    Group {
                        if shadow {
                            shape
                                .fill(.ultraThinMaterial)
                                .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
                        } else {
                            shape.fill(.ultraThinMaterial)
                        }
                    }
                )
        }
        #else
        self
            .background(
                Group {
                    if shadow {
                        shape
                            .fill(.ultraThinMaterial)
                            .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
                    } else {
                        shape.fill(.ultraThinMaterial)
                    }
                }
            )
        #endif
    }
    
    func glassBackground(cornerRadius: CGFloat = 16, interactive: Bool = false, shadow: Bool = true) -> some View {
        glassSurface(interactive: interactive, shadow: shadow, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func glassCapsule(interactive: Bool = false, shadow: Bool = false) -> some View {
        glassSurface(interactive: interactive, shadow: shadow, in: Capsule())
    }
    
    func glassCircle(interactive: Bool = false, shadow: Bool = true) -> some View {
        glassSurface(interactive: interactive, shadow: shadow, in: Circle())
    }
}

private struct StandSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat
    let showsShadow: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .background(Color(nsColor: .controlBackgroundColor), in: shape)
            .overlay {
                shape.strokeBorder(
                    Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04),
                    lineWidth: 1
                )
            }
            .shadow(
                color: showsShadow ? Color.black.opacity(colorScheme == .dark ? 0.18 : 0.07) : .clear,
                radius: 16,
                y: 8
            )
    }
}

struct StandPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let tint: Color
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(tint, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .opacity(!isEnabled ? 0.45 : configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == StandPrimaryButtonStyle {
    static func standPrimary(tint: Color = StandReminderTheme.buttonFill, foreground: Color = .white) -> StandPrimaryButtonStyle {
        StandPrimaryButtonStyle(tint: tint, foreground: foreground)
    }
}

struct StandSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Color.primary.opacity(configuration.isPressed ? 0.10 : 0.055))
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .opacity(isEnabled ? 1 : 0.45)
    }
}

extension ButtonStyle where Self == StandSecondaryButtonStyle {
    static var standSecondary: StandSecondaryButtonStyle { StandSecondaryButtonStyle() }
}
