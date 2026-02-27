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

struct InlineColorRow<Popover: View>: View {
    let color: ShapeColor?
    let defaultColor: ShapeColor
    let onColorSelected: (ShapeColor?) -> Void
    @Binding var isPopoverPresented: Bool
    @ViewBuilder let popover: () -> Popover

    @State private var hexText: String = ""

    init(
        color: ShapeColor?,
        defaultColor: ShapeColor = .black,
        onColorSelected: @escaping (ShapeColor?) -> Void,
        isPopoverPresented: Binding<Bool>,
        @ViewBuilder popover: @escaping () -> Popover
    ) {
        self.color = color
        self.defaultColor = defaultColor
        self.onColorSelected = onColorSelected
        self._isPopoverPresented = isPopoverPresented
        self.popover = popover
    }

    private var displayColor: ShapeColor {
        color ?? defaultColor
    }

    var body: some View {
        HStack(spacing: 0) {
            Button {
                isPopoverPresented.toggle()
            } label: {
                colorSwatch(color: displayColor, size: 14)
            }
            .buttonStyle(.plain)
            .padding(.leading, 3)
            .padding(.trailing, 10)
            .popover(isPresented: $isPopoverPresented) {
                popover()
            }
            Text("#")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.tertiary)
            TextField("------", text: $hexText)
                .font(.system(size: 10, design: .monospaced))
                .textFieldStyle(.plain)
                .frame(width: 84)
                .onSubmit {
                    applyHex()
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
        hexText = String(displayColor.hexString.dropFirst())
    }

    private func applyHex() {
        let cleaned = hexText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsed = ShapeColor(hex: "#\(cleaned)") {
            onColorSelected(parsed)
        }
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
