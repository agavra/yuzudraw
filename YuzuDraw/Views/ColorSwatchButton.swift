import SwiftUI

struct ColorSwatchButton: View {
    let label: String
    let color: ShapeColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                colorSwatch(color: color)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct InlineColorRow: View {
    let color: ShapeColor?
    let defaultColor: ShapeColor
    let allowsNone: Bool
    let onColorSelected: (ShapeColor?) -> Void
    let onSwatchTapped: () -> Void

    @State private var hexText: String = ""
    @FocusState private var isHexFieldFocused: Bool

    init(
        color: ShapeColor?,
        defaultColor: ShapeColor = .black,
        allowsNone: Bool = false,
        onColorSelected: @escaping (ShapeColor?) -> Void,
        onSwatchTapped: @escaping () -> Void
    ) {
        self.color = color
        self.defaultColor = defaultColor
        self.allowsNone = allowsNone
        self.onColorSelected = onColorSelected
        self.onSwatchTapped = onSwatchTapped
    }

    private var displayColor: ShapeColor {
        color ?? defaultColor
    }

    private var isNone: Bool {
        allowsNone && color == nil
    }

    var body: some View {
        HStack(spacing: 0) {
            Button {
                onSwatchTapped()
            } label: {
                if isNone {
                    transparentSwatch(size: 14)
                } else {
                    colorSwatch(color: displayColor, size: 14)
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 3)
            .padding(.trailing, 10)
            Text("#")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.tertiary)
            TextField(isNone ? "None" : "------", text: $hexText)
                .font(.system(size: 10, design: .monospaced))
                .textFieldStyle(.plain)
                .frame(width: 84)
                .focused($isHexFieldFocused)
                .onChange(of: hexText) { _, newValue in
                    if newValue.count > 6 {
                        hexText = String(newValue.prefix(6))
                    }
                }
                .onSubmit {
                    applyHex()
                }
                .onChange(of: isHexFieldFocused) { _, focused in
                    if focused {
                        DispatchQueue.main.async {
                            NSApp.keyWindow?.firstResponder?
                                .tryToPerform(#selector(NSText.selectAll(_:)), with: nil)
                        }
                    } else {
                        applyHex()
                    }
                }
                .padding(.trailing, 4)
        }
        .frame(height: 20)
        .fixedSize()
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onAppear { syncHex() }
        .onChange(of: color) { _, _ in syncHex() }
    }

    private func syncHex() {
        if isNone {
            hexText = ""
        } else {
            hexText = String(displayColor.hexString.dropFirst())
        }
    }

    private func applyHex() {
        let cleaned = hexText.trimmingCharacters(in: .whitespacesAndNewlines)
        if allowsNone && cleaned.isEmpty {
            onColorSelected(nil)
            return
        }
        guard !cleaned.isEmpty else { return }
        // Repeat short input to fill 6 characters (e.g. "1" -> "111111", "0a" -> "0a0a0a")
        var expanded = cleaned
        while expanded.count < 6 {
            expanded += cleaned
        }
        expanded = String(expanded.prefix(6))
        if let parsed = ShapeColor(hex: "#\(expanded)") {
            onColorSelected(parsed)
        }
    }
}

struct MixedColorSwatch: View {
    var size: CGFloat = 20

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(NSColor.controlBackgroundColor))

            // Diagonal hatching pattern
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                Path { path in
                    let step: CGFloat = 4
                    var x: CGFloat = -h
                    while x < w + h {
                        path.move(to: CGPoint(x: x, y: h))
                        path.addLine(to: CGPoint(x: x + h, y: 0))
                        x += step
                    }
                }
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))

            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
        }
        .frame(width: size, height: size)
    }
}

private func colorSwatch(color: ShapeColor, size: CGFloat = 20) -> some View {
    RoundedRectangle(cornerRadius: 2)
        .fill(color.swiftUIColor)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
        )
        .frame(width: size, height: size)
}

func transparentSwatch(size: CGFloat = 20) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white)
        Path { path in
            path.move(to: CGPoint(x: 1, y: size - 1))
            path.addLine(to: CGPoint(x: size - 1, y: 1))
        }
        .stroke(Color.red.opacity(0.7), lineWidth: 1.5)
        RoundedRectangle(cornerRadius: 2)
            .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
    }
    .frame(width: size, height: size)
}
