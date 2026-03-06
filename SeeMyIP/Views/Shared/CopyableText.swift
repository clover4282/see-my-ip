import AppKit
import SwiftUI

private struct InteractiveButtonHoverKey: EnvironmentKey {
    static let defaultValue = false
}

private struct InteractiveButtonPressedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var interactiveButtonIsHovering: Bool {
        get { self[InteractiveButtonHoverKey.self] }
        set { self[InteractiveButtonHoverKey.self] = newValue }
    }

    var interactiveButtonIsPressed: Bool {
        get { self[InteractiveButtonPressedKey.self] }
        set { self[InteractiveButtonPressedKey.self] = newValue }
    }
}

struct CopyableText: View {
    let text: String
    let font: Font
    let onCopy: (String) -> Void
    @State private var isCopied = false

    init(_ text: String, font: Font = .system(.body, design: .monospaced), onCopy: @escaping (String) -> Void) {
        self.text = text
        self.font = font
        self.onCopy = onCopy
    }

    var body: some View {
        Button {
            onCopy(text)
            withAnimation {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isCopied = false
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(text)
                    .font(font)
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(isCopied ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.caption)
            }
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

struct InteractiveButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 8
    var pressedFill: Color = Color.primary.opacity(0.06)

    func makeBody(configuration: Configuration) -> some View {
        InteractiveButtonBody(
            configuration: configuration,
            cornerRadius: cornerRadius,
            pressedFill: pressedFill
        )
    }
}

private struct InteractiveButtonBody: View {
    let configuration: ButtonStyle.Configuration
    let cornerRadius: CGFloat
    let pressedFill: Color

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    @State private var cursorActive = false

    var body: some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .environment(\.interactiveButtonIsHovering, isEnabled && isHovering)
            .environment(\.interactiveButtonIsPressed, isEnabled && configuration.isPressed)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(pressedBackgroundFill)
                    .allowsHitTesting(false)
            }
            .opacity(configuration.isPressed && isEnabled ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.14), value: isHovering)
            .animation(.easeInOut(duration: 0.14), value: configuration.isPressed)
            .onHover { hovering in
                updateHoverState(hovering)
            }
            .onDisappear {
                updateHoverState(false)
            }
    }

    private var pressedBackgroundFill: Color {
        guard isEnabled else { return .clear }
        if configuration.isPressed { return pressedFill }
        return .clear
    }

    private func updateHoverState(_ hovering: Bool) {
        guard isEnabled else {
            if cursorActive {
                NSCursor.pop()
                cursorActive = false
            }
            isHovering = false
            return
        }

        if hovering && !cursorActive {
            NSCursor.pointingHand.push()
            cursorActive = true
        } else if !hovering && cursorActive {
            NSCursor.pop()
            cursorActive = false
        }

        isHovering = hovering
    }
}

private struct InteractiveControlHoverModifier: ViewModifier {
    let cornerRadius: CGFloat
    let enabled: Bool
    let baseTint: Color
    let hoverTint: Color

    @State private var isHovering = false
    @State private var cursorActive = false

    func body(content: Content) -> some View {
        content
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .foregroundStyle(enabled && isHovering ? hoverTint : baseTint)
            .animation(.easeInOut(duration: 0.14), value: isHovering)
            .onHover { hovering in
                updateHoverState(hovering)
            }
            .onDisappear {
                updateHoverState(false)
            }
    }

    private func updateHoverState(_ hovering: Bool) {
        guard enabled else {
            if cursorActive {
                NSCursor.pop()
                cursorActive = false
            }
            isHovering = false
            return
        }

        if hovering && !cursorActive {
            NSCursor.pointingHand.push()
            cursorActive = true
        } else if !hovering && cursorActive {
            NSCursor.pop()
            cursorActive = false
        }

        isHovering = hovering
    }
}

private struct InteractiveForegroundModifier: ViewModifier {
    let idle: Color
    let hover: Color
    let pressed: Color?

    @Environment(\.interactiveButtonIsHovering) private var isHovering
    @Environment(\.interactiveButtonIsPressed) private var isPressed

    func body(content: Content) -> some View {
        content
            .foregroundStyle(resolvedColor)
            .animation(.easeInOut(duration: 0.14), value: isHovering)
            .animation(.easeInOut(duration: 0.14), value: isPressed)
    }

    private var resolvedColor: Color {
        if isPressed, let pressed {
            return pressed
        }
        if isHovering {
            return hover
        }
        return idle
    }
}

extension View {
    func interactiveControlHover(
        cornerRadius: CGFloat = 8,
        enabled: Bool = true,
        baseTint: Color = .primary,
        hoverTint: Color = .accentColor
    ) -> some View {
        modifier(
            InteractiveControlHoverModifier(
                cornerRadius: cornerRadius,
                enabled: enabled,
                baseTint: baseTint,
                hoverTint: hoverTint
            )
        )
    }

    func interactiveForeground(
        idle: Color = .primary,
        hover: Color = .accentColor,
        pressed: Color? = nil
    ) -> some View {
        modifier(
            InteractiveForegroundModifier(
                idle: idle,
                hover: hover,
                pressed: pressed
            )
        )
    }
}
