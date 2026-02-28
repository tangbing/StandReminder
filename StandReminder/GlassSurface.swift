import SwiftUI

enum GlassSurfaceProminence {
    case regular
    case prominent
}

extension View {
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

