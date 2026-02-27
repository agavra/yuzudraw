import SwiftUI

enum PaletteTab: Int, CaseIterable {
    case defaults
    case custom
    case page

    var label: String {
        switch self {
        case .defaults: "Default"
        case .custom: "Custom"
        case .page: "Page"
        }
    }

}

struct ColorPickerPopover: View {
    let customPalette: ColorPalette
    let pageColors: [ShapeColor]
    let currentColor: ShapeColor?
    let allowsNone: Bool
    let onColorSelected: (ShapeColor?) -> Void
    let onDismiss: () -> Void
    let onAddToPalette: (ShapeColor) -> Void
    let onRemoveFromPalette: (UUID) -> Void

    @State private var hue: Double
    @State private var saturation: Double
    @State private var brightness: Double
    @State private var hexText: String
    @State private var selectedTab: PaletteTab = .page

    init(
        customPalette: ColorPalette,
        pageColors: [ShapeColor],
        currentColor: ShapeColor?,
        allowsNone: Bool = false,
        onColorSelected: @escaping (ShapeColor?) -> Void,
        onDismiss: @escaping () -> Void,
        onAddToPalette: @escaping (ShapeColor) -> Void,
        onRemoveFromPalette: @escaping (UUID) -> Void
    ) {
        self.customPalette = customPalette
        self.pageColors = pageColors
        self.currentColor = currentColor
        self.allowsNone = allowsNone
        self.onColorSelected = onColorSelected
        self.onDismiss = onDismiss
        self.onAddToPalette = onAddToPalette
        self.onRemoveFromPalette = onRemoveFromPalette

        let color = currentColor ?? .black
        let hsb = color.hsbComponents
        self._hue = State(initialValue: hsb.hue)
        self._saturation = State(initialValue: hsb.saturation)
        self._brightness = State(initialValue: hsb.brightness)
        self._hexText = State(initialValue: String(color.hexString.dropFirst()))
    }

    private var activeColor: ShapeColor {
        ShapeColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            saturationBrightnessSquare
            hueSlider
            hexAndEyedropperRow
            Divider()
            paletteTabs
            paletteContent
        }
        .padding(8)
    }

    // MARK: - Saturation-Brightness Square

    private var saturationBrightnessSquare: some View {
        GeometryReader { geo in
            let size = geo.size.width
            ZStack {
                Color(hue: hue, saturation: 1, brightness: 1)

                LinearGradient(
                    colors: [.white, .white.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(activeColor.swiftUIColor)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .overlay(Circle().stroke(.black.opacity(0.2), lineWidth: 1).padding(-1))
                    .frame(width: 12, height: 12)
                    .position(
                        x: saturation * size,
                        y: (1 - brightness) * size
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        saturation = min(max(value.location.x / size, 0), 1)
                        brightness = 1 - min(max(value.location.y / size, 0), 1)
                        syncHexAndEmit()
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Hue Slider

    private var hueSlider: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(hue: 0, saturation: 1, brightness: 1), location: 0),
                                .init(color: Color(hue: 1.0 / 6, saturation: 1, brightness: 1), location: 1.0 / 6),
                                .init(color: Color(hue: 2.0 / 6, saturation: 1, brightness: 1), location: 2.0 / 6),
                                .init(color: Color(hue: 3.0 / 6, saturation: 1, brightness: 1), location: 3.0 / 6),
                                .init(color: Color(hue: 4.0 / 6, saturation: 1, brightness: 1), location: 4.0 / 6),
                                .init(color: Color(hue: 5.0 / 6, saturation: 1, brightness: 1), location: 5.0 / 6),
                                .init(color: Color(hue: 1, saturation: 1, brightness: 1), location: 1),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Circle()
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .overlay(Circle().stroke(.black.opacity(0.2), lineWidth: 1).padding(-1))
                    .frame(width: 14, height: 14)
                    .position(x: hue * width, y: 6)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = min(max(value.location.x / width, 0), 1)
                        syncHexAndEmit()
                    }
            )
        }
        .frame(height: 12)
    }

    // MARK: - Hex + Eyedropper Row

    private var hexAndEyedropperRow: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(activeColor.swiftUIColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .frame(width: 22, height: 22)

            HStack(spacing: 2) {
                Text("#")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                TextField("RRGGBB", text: $hexText)
                    .font(.system(.caption2, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        applyHexInput()
                    }
            }

            Button {
                sampleColor()
            } label: {
                Image(systemName: "eyedropper")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderless)
            .help("Pick a color from screen")
        }
    }

    // MARK: - Palette Tabs

    private var paletteTabs: some View {
        HStack(spacing: 0) {
            ForEach(PaletteTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.label)
                        .font(.system(size: 10))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == tab
                                ? Color.accentColor.opacity(0.15)
                                : Color.clear
                        )
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Palette Content

    private var paletteContent: some View {
        Group {
            switch selectedTab {
            case .defaults:
                colorGrid(colors: ColorPalette.default.entries.map(\.color))
            case .custom:
                customPaletteContent
            case .page:
                if pageColors.isEmpty {
                    Text("No colors on this page")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                } else {
                    colorGrid(colors: pageColors)
                }
            }
        }
        .frame(height: 80, alignment: .top)
    }

    private func colorGrid(colors: [ShapeColor]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(16), spacing: 3), count: 10)
        return LazyVGrid(columns: columns, spacing: 3) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                Button {
                    applyColor(color)
                } label: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.swiftUIColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(
                                    currentColor == color
                                        ? Color.accentColor
                                        : Color.secondary.opacity(0.3),
                                    lineWidth: currentColor == color ? 2 : 1
                                )
                        )
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.plain)
                .help(color.hexString)
            }
            if allowsNone {
                Button {
                    onColorSelected(nil)
                } label: {
                    transparentSwatch(size: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(
                                    currentColor == nil
                                        ? Color.accentColor
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                }
                .buttonStyle(.plain)
                .help("No Color")
            }
        }
    }

    private var customPaletteContent: some View {
        let columns = Array(repeating: GridItem(.fixed(16), spacing: 3), count: 10)
        return VStack(spacing: 4) {
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(customPalette.entries) { entry in
                    Button {
                        applyColor(entry.color)
                    } label: {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(entry.color.swiftUIColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(
                                        currentColor == entry.color
                                            ? Color.accentColor
                                            : Color.secondary.opacity(0.3),
                                        lineWidth: currentColor == entry.color ? 2 : 1
                                    )
                            )
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .help(entry.name)
                    .contextMenu {
                        Button("Remove", role: .destructive) {
                            onRemoveFromPalette(entry.id)
                        }
                    }
                }
                if allowsNone {
                    Button {
                        onColorSelected(nil)
                    } label: {
                        transparentSwatch(size: 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(
                                        currentColor == nil
                                            ? Color.accentColor
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .help("No Color")
                }
            }
            Button {
                onAddToPalette(activeColor)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.system(size: 8))
                    Text("Add Current Color")
                }
            }
            .font(.caption2)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Actions

    private func applyColor(_ color: ShapeColor) {
        let hsb = color.hsbComponents
        hue = hsb.hue
        saturation = hsb.saturation
        brightness = hsb.brightness
        hexText = String(color.hexString.dropFirst())
        onColorSelected(color)
    }

    private func syncHexAndEmit() {
        let color = activeColor
        hexText = String(color.hexString.dropFirst())
        onColorSelected(color)
    }

    private func applyHexInput() {
        let cleaned = hexText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let color = ShapeColor(hex: "#\(cleaned)") {
            applyColor(color)
        }
    }

    private func sampleColor() {
        let sampler = NSColorSampler()
        sampler.show { nsColor in
            MainActor.assumeIsolated {
                if let nsColor, let color = ShapeColor(nsColor: nsColor) {
                    applyColor(color)
                }
            }
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
