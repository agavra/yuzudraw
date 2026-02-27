import SwiftUI

struct ColorPickerPopover: View {
    let palette: ColorPalette
    let currentColor: ShapeColor?
    let onColorSelected: (ShapeColor?) -> Void
    let onEditPalette: () -> Void

    @State private var customColor: Color
    @State private var hexText: String

    init(
        palette: ColorPalette,
        currentColor: ShapeColor?,
        onColorSelected: @escaping (ShapeColor?) -> Void,
        onEditPalette: @escaping () -> Void
    ) {
        self.palette = palette
        self.currentColor = currentColor
        self.onColorSelected = onColorSelected
        self.onEditPalette = onEditPalette
        self._customColor = State(initialValue: currentColor?.swiftUIColor ?? .black)
        let hex = currentColor?.hexString ?? "#000000FF"
        self._hexText = State(initialValue: String(hex.dropFirst()))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            paletteGrid
            Divider()
            systemPicker
            Divider()
            HStack {
                Button("No Color") {
                    onColorSelected(nil)
                }
                .font(.caption)
                Spacer()
                Button("Edit Palette...") {
                    onEditPalette()
                }
                .font(.caption)
            }
        }
        .padding(10)
        .frame(width: 200)
    }

    private var paletteGrid: some View {
        let columns = Array(repeating: GridItem(.fixed(20), spacing: 4), count: 8)
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(palette.entries) { entry in
                Button {
                    customColor = entry.color.swiftUIColor
                    hexText = String(entry.color.hexString.dropFirst())
                    onColorSelected(entry.color)
                } label: {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(entry.color.swiftUIColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(
                                    currentColor == entry.color
                                        ? Color.accentColor
                                        : Color.secondary.opacity(0.3),
                                    lineWidth: currentColor == entry.color ? 2 : 1
                                )
                        )
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .help(entry.name)
            }
        }
    }

    private var systemPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            ColorPicker("Custom", selection: $customColor, supportsOpacity: true)
                .font(.caption)
                .onChange(of: customColor) { _, newColor in
                    if let resolved = ShapeColor(nsColor: NSColor(newColor)) {
                        hexText = String(resolved.hexString.dropFirst())
                        onColorSelected(resolved)
                    }
                }
            HStack(spacing: 2) {
                Text("#")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                TextField("RRGGBBAA", text: $hexText)
                    .font(.system(.caption, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        applyHexInput()
                    }
            }
        }
    }

    private func applyHexInput() {
        let cleaned = hexText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let color = ShapeColor(hex: "#\(cleaned)") {
            customColor = color.swiftUIColor
            onColorSelected(color)
        }
    }
}

extension ShapeColor {
    init?(nsColor: NSColor) {
        guard let rgb = nsColor.usingColorSpace(.sRGB) else { return nil }
        self.red = Double(rgb.redComponent)
        self.green = Double(rgb.greenComponent)
        self.blue = Double(rgb.blueComponent)
        self.alpha = Double(rgb.alphaComponent)
    }
}
