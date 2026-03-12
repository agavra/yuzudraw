import SwiftUI

struct InspectorPanel: View {
    @Bindable var viewModel: EditorViewModel

    // MARK: - Inline rename state
    @State private var isEditingName = false
    @State private var draftName = ""
    @FocusState private var nameFieldFocused: Bool

    // MARK: - Export state
    @State private var isExportSectionExpanded = true
    @State private var exportScale = 1
    @State private var exportBackgroundColor: ShapeColor?
    @State private var exportFormat: ExportFormat = .png

    private enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case svg = "SVG"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.selectedShapes.count > 1 {
                        multiSelectionView
                    } else if let shape = viewModel.selectedShape {
                        shapeProperties(shape)
                    } else if viewModel.activeToolType == .pencil {
                        pencilToolSettings
                    } else {
                        noSelectionView
                    }

                    if viewModel.selectedShapes.count >= 1 {
                        exportSection
                    }
                }
            }
            if viewModel.selectedShapes.count >= 1 {
                Divider()
                bottomToolbar
            }
        }
        .frame(minWidth: 160, idealWidth: 180, maxWidth: 220)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            if viewModel.selectedShapes.count > 1 {
                Image(systemName: "square.on.square")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(viewModel.selectedShapes.count) shapes selected")
                        .font(.headline)
                }
            } else if let shape = viewModel.selectedShape {
                Image(systemName: shapeIcon(for: shape))
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    if isEditingName {
                        TextField("Name", text: $draftName)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color(nsColor: .textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                            .focused($nameFieldFocused)
                            .onSubmit {
                                commitRename(shape)
                            }
                            .onChange(of: nameFieldFocused) { _, isFocused in
                                if !isFocused, isEditingName {
                                    commitRename(shape)
                                }
                            }
                            .onExitCommand {
                                cancelRename(shape)
                            }
                    } else {
                        Text(shape.displayName)
                            .font(.headline)
                            .lineLimit(1)
                            .onTapGesture(count: 2) {
                                beginRename(shape)
                            }
                    }
                    Text(shape.typeName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Inspector")
                    .font(.headline)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Bottom toolbar

    private var bottomToolbar: some View {
        HStack {
            Spacer()
            Button(role: .destructive) {
                viewModel.deleteSelectedShapes()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Delete selected")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Empty state

    @ViewBuilder
    private var multiSelectionView: some View {
        if viewModel.isAllRectanglesSelected {
            multiSelectRectangleProperties
        } else if viewModel.isAllArrowsSelected {
            multiSelectArrowProperties
        } else {
            multiSelectMixedProperties
        }
    }

    // MARK: - Multi-select rectangle properties

    @ViewBuilder
    private var multiSelectRectangleProperties: some View {
        // Text color
        staticSection(label: "Text", icon: "textformat") {
            mixableColorSwatchRow(
                color: viewModel.multiSelectRectTextColor,
                isMixed: viewModel.isMultiSelectRectTextColorMixed,
                target: .multiSelectRectText,
                onColorSelected: { viewModel.updateMultiSelectRectTextColor($0) }
            )
        }

        Divider()

        // Border
        mixableToggleSection(
            label: "Border",
            icon: "paintbrush",
            isEnabled: viewModel.multiSelectRectHasBorder,
            onToggle: { viewModel.updateMultiSelectRectHasBorder($0) }
        ) {
            VStack(alignment: .leading, spacing: 8) {
                mixableColorSwatchRow(
                    color: viewModel.multiSelectRectBorderColor,
                    isMixed: viewModel.isMultiSelectRectBorderColorMixed,
                    target: .multiSelectRectBorder,
                    onColorSelected: { viewModel.updateMultiSelectRectBorderColor($0) }
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text("Style")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    mixableStrokeStylePicker(
                        selected: viewModel.multiSelectRectStrokeStyle,
                        onChange: { viewModel.updateMultiSelectRectStrokeStyle($0) }
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sides")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    multiSelectBorderSidesPicker()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Line")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    mixableBorderLineStylePicker(
                        selected: viewModel.multiSelectRectBorderLineStyle,
                        onChange: { viewModel.updateMultiSelectRectBorderLineStyle($0) }
                    )
                }
                if viewModel.multiSelectRectBorderLineStyle == .dashed {
                    HStack {
                        mixableNumberField("Dash", value: viewModel.multiSelectRectBorderDashLength) { newVal in
                            viewModel.updateMultiSelectRectBorderDashLength(newVal)
                        }
                        mixableNumberField("Gap", value: viewModel.multiSelectRectBorderGapLength) { newVal in
                            viewModel.updateMultiSelectRectBorderGapLength(newVal)
                        }
                    }
                }
                Toggle("Float", isOn: Binding(
                    get: { viewModel.multiSelectRectFloat ?? false },
                    set: { viewModel.updateMultiSelectRectFloat($0) }
                ))
            }
        }

        Divider()

        // Fill
        mixableToggleSection(
            label: "Fill",
            icon: "square.fill",
            isEnabled: viewModel.multiSelectRectFillMode.map { $0.isFilled },
            onToggle: { viewModel.updateMultiSelectRectFillEnabled($0) }
        ) {
            fillModePicker(
                selected: viewModel.multiSelectRectFillMode ?? .opaque,
                onChange: { viewModel.updateMultiSelectRectFillMode($0) }
            )

            if viewModel.multiSelectRectFillMode == .block {
                mixableColorSwatchRow(
                    color: viewModel.multiSelectRectFillColor,
                    isMixed: viewModel.isMultiSelectRectFillColorMixed,
                    target: .multiSelectRectFill,
                    onColorSelected: { viewModel.updateMultiSelectRectFillColor($0) }
                )
                blockCharacterPicker(
                    currentChar: viewModel.multiSelectRectFillCharacter ?? "\u{2588}",
                    onChange: { viewModel.updateMultiSelectRectFillCharacter($0) }
                )
            }

            if viewModel.multiSelectRectFillMode == .character {
                mixableColorSwatchRow(
                    color: viewModel.multiSelectRectFillColor,
                    isMixed: viewModel.isMultiSelectRectFillColorMixed,
                    target: .multiSelectRectFill,
                    onColorSelected: { viewModel.updateMultiSelectRectFillColor($0) }
                )
                HStack {
                    Text("Char")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    TextField("", text: Binding(
                        get: {
                            guard let ch = viewModel.multiSelectRectFillCharacter else { return "" }
                            return ch == " " ? "" : String(ch)
                        },
                        set: { newValue in
                            let char = newValue.first ?? Character(" ")
                            viewModel.updateMultiSelectRectFillCharacter(char)
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 32)
                }
            }
        }

        Divider()

        // Shadow
        mixableToggleSection(
            label: "Shadow",
            icon: "shadow",
            isEnabled: viewModel.multiSelectRectHasShadow,
            onToggle: { viewModel.updateMultiSelectRectHasShadow($0) }
        ) {
            VStack(alignment: .leading, spacing: 6) {
                mixableShadowStylePicker(
                    selected: viewModel.multiSelectRectShadowStyle,
                    onChange: { viewModel.updateMultiSelectRectShadowStyle($0) }
                )
                HStack {
                    mixableNumberField("X", value: viewModel.multiSelectRectShadowOffsetX) { newVal in
                        viewModel.updateMultiSelectRectShadowOffsetX(newVal)
                    }
                    mixableNumberField("Y", value: viewModel.multiSelectRectShadowOffsetY) { newVal in
                        viewModel.updateMultiSelectRectShadowOffsetY(newVal)
                    }
                }
            }
        }
    }

    // MARK: - Multi-select arrow properties

    @ViewBuilder
    private var multiSelectArrowProperties: some View {
        staticSection(label: "Style", icon: "paintbrush") {
            mixableColorSwatchRow(
                color: viewModel.multiSelectArrowStrokeColor,
                isMixed: viewModel.isMultiSelectArrowStrokeColorMixed,
                target: .multiSelectArrowStroke,
                onColorSelected: { viewModel.updateMultiSelectArrowStrokeColor($0) }
            )
            mixableColorSwatchRow(
                color: viewModel.multiSelectArrowLabelColor,
                isMixed: viewModel.isMultiSelectArrowLabelColorMixed,
                target: .multiSelectArrowLabel,
                onColorSelected: { viewModel.updateMultiSelectArrowLabelColor($0) }
            )
            mixableStrokeStylePicker(
                selected: viewModel.multiSelectArrowStrokeStyle,
                onChange: { viewModel.updateMultiSelectArrowStrokeStyle($0) }
            )
            HStack {
                Picker("Start", selection: Binding(
                    get: { viewModel.multiSelectArrowStartHeadStyle ?? .none },
                    set: { viewModel.updateMultiSelectArrowStartHeadStyle($0) }
                )) {
                    ForEach(ArrowHeadStyle.allCases, id: \.self) { style in
                        Text(style.pickerCharacter).tag(style)
                    }
                }
                .pickerStyle(.menu)

                Picker("End", selection: Binding(
                    get: { viewModel.multiSelectArrowEndHeadStyle ?? .none },
                    set: { viewModel.updateMultiSelectArrowEndHeadStyle($0) }
                )) {
                    ForEach(ArrowHeadStyle.allCases, id: \.self) { style in
                        Text(style.pickerCharacter).tag(style)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    // MARK: - Multi-select mixed type properties

    @ViewBuilder
    private var multiSelectMixedProperties: some View {
        if viewModel.hasSelectedRectangles || viewModel.hasSelectedArrows {
            staticSection(label: "Stroke", icon: "paintbrush") {
                mixableColorSwatchRow(
                    color: viewModel.multiSelectCrossBorderStrokeColor,
                    isMixed: viewModel.isMultiSelectCrossBorderStrokeColorMixed,
                    target: .multiSelectBorderStroke,
                    onColorSelected: { viewModel.updateMultiSelectCrossBorderStrokeColor($0) }
                )
                mixableStrokeStylePicker(
                    selected: viewModel.multiSelectCrossStrokeStyle,
                    onChange: { viewModel.updateMultiSelectCrossStrokeStyle($0) }
                )
            }

            Divider()

            staticSection(label: "Text", icon: "textformat") {
                mixableColorSwatchRow(
                    color: viewModel.multiSelectCrossTextLabelColor,
                    isMixed: viewModel.isMultiSelectCrossTextLabelColorMixed,
                    target: .multiSelectText,
                    onColorSelected: { viewModel.updateMultiSelectCrossTextLabelColor($0) }
                )
            }
        }
    }

    private var noSelectionView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cursorarrow.click.2")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Select a shape to inspect")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Export section

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()

            collapsibleSection(
                label: "Export",
                icon: "square.and.arrow.up",
                isExpanded: isExportSectionExpanded,
                onToggle: { isExportSectionExpanded.toggle() }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Picker("", selection: $exportScale) {
                            Text("1x").tag(1)
                            Text("2x").tag(2)
                            Text("3x").tag(3)
                            Text("4x").tag(4)
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .fixedSize()
                        .disabled(exportFormat == .svg)

                        Picker("", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .fixedSize()
                        .onChange(of: exportFormat) {
                            if exportFormat == .svg {
                                exportScale = 1
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Background")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        colorSwatchRow(
                            color: exportBackgroundColor,
                            defaultColor: .white,
                            allowsNone: true,
                            target: .exportBackground,
                            onColorSelected: { exportBackgroundColor = $0 }
                        )
                    }

                    HStack(spacing: 6) {
                        Button {
                            switch exportFormat {
                            case .png:
                                viewModel.exportSelectedShapesAsPNG(
                                    scale: exportScale,
                                    backgroundColor: exportBackgroundColor
                                )
                            case .svg:
                                viewModel.exportSelectedShapesAsSVG(
                                    backgroundColor: exportBackgroundColor
                                )
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button {
                            viewModel.copySelectionAsPlainTextToClipboard()
                        } label: {
                            Label("Copy Text", systemImage: "doc.on.doc")
                                .font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func mixableColorSwatchRow(
        color: ShapeColor?,
        isMixed: Bool,
        target: ColorTarget,
        onColorSelected: @escaping (ShapeColor?) -> Void
    ) -> some View {
        if isMixed {
            HStack(spacing: 0) {
                Button {
                    viewModel.openColorPicker(
                        target: target,
                        currentColor: nil,
                        onColorSelected: onColorSelected
                    )
                } label: {
                    MixedColorSwatch(size: 14)
                }
                .buttonStyle(.plain)
                .padding(.leading, 3)
                .padding(.trailing, 10)
                Text("Mixed")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
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
        } else {
            colorSwatchRow(
                color: color,
                target: target,
                onColorSelected: onColorSelected
            )
        }
    }

    // MARK: - Shape properties

    @ViewBuilder
    private func shapeProperties(_ shape: AnyShape) -> some View {
        switch shape {
        case .rectangle(let rectangle):
            rectangleProperties(rectangle)
        case .arrow(let arrow):
            arrowProperties(arrow)
        case .text(let text):
            textProperties(text)
        case .pencil(let pencil):
            pencilProperties(pencil)
        }
    }

    // MARK: - Rectangle properties

    @ViewBuilder
    private func rectangleProperties(_ rectangle: RectangleShape) -> some View {
        // Position & Size
        staticSection(label: "Position & Size", icon: "arrow.up.left.and.arrow.down.right") {
            HStack {
                numberField("X", value: rectangle.origin.column) { newVal in
                    viewModel.updateSelectedRectangleOrigin(column: newVal, row: rectangle.origin.row)
                }
                numberField("Y", value: rectangle.origin.row) { newVal in
                    viewModel.updateSelectedRectangleOrigin(column: rectangle.origin.column, row: newVal)
                }
            }
            HStack {
                numberField("W", value: rectangle.size.width) { newVal in
                    viewModel.updateSelectedRectangleSize(width: newVal, height: rectangle.size.height)
                }
                numberField("H", value: rectangle.size.height) { newVal in
                    viewModel.updateSelectedRectangleSize(width: rectangle.size.width, height: newVal)
                }
            }
        }

        Divider()

        // Text
        staticSection(label: "Text", icon: "textformat") {
            colorSwatchRow(
                color: rectangle.textColor,
                target: .rectangleText,
                onColorSelected: { viewModel.updateSelectedRectangleTextColor($0) }
            )
            HStack(spacing: 6) {
                    Text("H")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 12)
                    HStack(spacing: 0) {
                        alignmentIconButton(
                            isSelected: rectangle.textHorizontalAlignment == .left,
                            action: {
                                viewModel.updateSelectedRectangleTextHorizontalAlignment(.left)
                            }
                        ) {
                            horizontalAlignmentIcon(.left)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: rectangle.textHorizontalAlignment == .center,
                            action: {
                                viewModel.updateSelectedRectangleTextHorizontalAlignment(.center)
                            }
                        ) {
                            horizontalAlignmentIcon(.center)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: rectangle.textHorizontalAlignment == .right,
                            action: {
                                viewModel.updateSelectedRectangleTextHorizontalAlignment(.right)
                            }
                        ) {
                            horizontalAlignmentIcon(.right)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
                    )
                }

                HStack(spacing: 6) {
                    Text("V")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 12)
                    HStack(spacing: 0) {
                        alignmentIconButton(
                            isSelected: rectangle.textVerticalAlignment == .top,
                            action: {
                                viewModel.updateSelectedRectangleTextVerticalAlignment(.top)
                            }
                        ) {
                            verticalAlignmentIcon(.top)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: rectangle.textVerticalAlignment == .middle,
                            action: {
                                viewModel.updateSelectedRectangleTextVerticalAlignment(.middle)
                            }
                        ) {
                            verticalAlignmentIcon(.middle)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: rectangle.textVerticalAlignment == .bottom,
                            action: {
                                viewModel.updateSelectedRectangleTextVerticalAlignment(.bottom)
                            }
                        ) {
                            verticalAlignmentIcon(.bottom)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
                    )
                }

                Toggle("Allow Text On Border", isOn: Binding(
                    get: { rectangle.allowTextOnBorder },
                    set: { viewModel.updateSelectedRectangleAllowTextOnBorder($0) }
                ))
                .disabled(!rectangle.hasBorder)
        }

        Divider()

        // Padding
        staticSection(label: "Padding", icon: "square.dashed") {
            Grid(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 6) {
                GridRow {
                    numberField("Left", value: rectangle.textPaddingLeft) { newVal in
                        viewModel.updateSelectedRectangleTextPadding(left: newVal)
                    }
                    numberField("Right", value: rectangle.textPaddingRight) { newVal in
                        viewModel.updateSelectedRectangleTextPadding(right: newVal)
                    }
                }
                GridRow {
                    numberField("Top", value: rectangle.textPaddingTop) { newVal in
                        viewModel.updateSelectedRectangleTextPadding(top: newVal)
                    }
                    numberField("Bottom", value: rectangle.textPaddingBottom) { newVal in
                        viewModel.updateSelectedRectangleTextPadding(bottom: newVal)
                    }
                }
            }
        }

        Divider()

        // Border
        toggleSection(
            label: "Border",
            icon: "paintbrush",
            isEnabled: rectangle.hasBorder,
            onToggle: { viewModel.updateSelectedRectangleHasBorder($0) }
        ) {
            VStack(alignment: .leading, spacing: 8) {
                colorSwatchRow(
                    color: rectangle.borderColor,
                    target: .rectangleBorder,
                    onColorSelected: { viewModel.updateSelectedRectangleBorderColor($0) }
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text("Style")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    strokeStylePicker(
                        selected: rectangle.strokeStyle,
                        onChange: { viewModel.updateSelectedRectangleStrokeStyle($0) }
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sides")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    borderSidesPicker(
                        rectangle: rectangle,
                        onToggle: { side, isVisible in
                            viewModel.updateSelectedRectangleBorderSide(side, isVisible: isVisible)
                        }
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Line")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    borderLineStylePicker(
                        selected: rectangle.borderLineStyle,
                        onChange: { viewModel.updateSelectedRectangleBorderLineStyle($0) }
                    )
                }
                if rectangle.borderLineStyle == .dashed {
                    HStack {
                        numberField("Dash", value: rectangle.borderDashLength) { newVal in
                            viewModel.updateSelectedRectangleBorderDashLength(newVal)
                        }
                        numberField("Gap", value: rectangle.borderGapLength) { newVal in
                            viewModel.updateSelectedRectangleBorderGapLength(newVal)
                        }
                    }
                }
                Toggle("Float", isOn: Binding(
                    get: { rectangle.float },
                    set: { viewModel.updateSelectedRectangleFloat($0) }
                ))
            }
        }

        Divider()

        // Fill
        toggleSection(
            label: "Fill",
            icon: "square.fill",
            isEnabled: rectangle.fillMode.isFilled,
            onToggle: { viewModel.updateSelectedRectangleFillEnabled($0) }
        ) {
            fillModePicker(
                selected: rectangle.fillMode,
                onChange: { viewModel.updateSelectedRectangleFillMode($0) }
            )

            if rectangle.fillMode == .block {
                colorSwatchRow(
                    color: rectangle.fillColor,
                    target: .rectangleFill,
                    onColorSelected: { viewModel.updateSelectedRectangleFillColor($0) }
                )
                blockCharacterPicker(
                    currentChar: rectangle.fillCharacter,
                    onChange: { viewModel.updateSelectedRectangleFillCharacter($0) }
                )
            }

            if rectangle.fillMode == .character {
                colorSwatchRow(
                    color: rectangle.fillColor,
                    target: .rectangleFill,
                    onColorSelected: { viewModel.updateSelectedRectangleFillColor($0) }
                )
                HStack {
                    Text("Char")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    TextField("", text: Binding(
                        get: {
                            rectangle.fillCharacter == " " ? "" : String(rectangle.fillCharacter)
                        },
                        set: { newValue in
                            let char = newValue.first ?? Character(" ")
                            viewModel.updateSelectedRectangleFillCharacter(char)
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 32)
                }
            }
        }

        Divider()

        // Shadow
        toggleSection(
            label: "Shadow",
            icon: "shadow",
            isEnabled: rectangle.hasShadow,
            onToggle: { viewModel.updateSelectedRectangleHasShadow($0) }
        ) {
            VStack(alignment: .leading, spacing: 6) {
                shadowStylePicker(
                    selected: rectangle.shadowStyle,
                    onChange: { viewModel.updateSelectedRectangleShadowStyle($0) }
                )

                HStack {
                    numberField("X", value: rectangle.shadowOffsetX) { newVal in
                        viewModel.updateSelectedRectangleShadowOffsetX(newVal)
                    }
                    numberField("Y", value: rectangle.shadowOffsetY) { newVal in
                        viewModel.updateSelectedRectangleShadowOffsetY(newVal)
                    }
                }
            }
        }

    }

    // MARK: - Arrow properties

    @ViewBuilder
    private func arrowProperties(_ arrow: ArrowShape) -> some View {
        // Start & End
        staticSection(label: "Start & End", icon: "arrow.up.left.and.arrow.down.right") {
            HStack {
                numberField("Start X", value: arrow.start.column) { newVal in
                    viewModel.updateSelectedArrowStart(
                        column: newVal, row: arrow.start.row)
                }
                numberField("Start Y", value: arrow.start.row) { newVal in
                    viewModel.updateSelectedArrowStart(
                        column: arrow.start.column, row: newVal)
                }
            }
            HStack {
                numberField("End X", value: arrow.end.column) { newVal in
                    viewModel.updateSelectedArrowEnd(column: newVal, row: arrow.end.row)
                }
                numberField("End Y", value: arrow.end.row) { newVal in
                    viewModel.updateSelectedArrowEnd(
                        column: arrow.end.column, row: newVal)
                }
            }
        }

        Divider()

        // Style
        staticSection(label: "Style", icon: "paintbrush") {
            colorSwatchRow(
                color: arrow.strokeColor,
                target: .arrowStroke,
                onColorSelected: { viewModel.updateSelectedArrowStrokeColor($0) }
            )
            colorSwatchRow(
                color: arrow.labelColor,
                target: .arrowLabel,
                onColorSelected: { viewModel.updateSelectedArrowLabelColor($0) }
            )

            strokeStylePicker(
                selected: arrow.strokeStyle,
                onChange: { viewModel.updateSelectedArrowStrokeStyle($0) }
            )

            HStack {
                Picker("Start", selection: Binding(
                    get: { arrow.startHeadStyle },
                    set: { viewModel.updateSelectedArrowStartHeadStyle($0) }
                )) {
                    ForEach(ArrowHeadStyle.allCases, id: \.self) { style in
                        Text(style.pickerCharacter).tag(style)
                    }
                }
                .pickerStyle(.menu)

                Picker("End", selection: Binding(
                    get: { arrow.endHeadStyle },
                    set: { viewModel.updateSelectedArrowEndHeadStyle($0) }
                )) {
                    ForEach(ArrowHeadStyle.allCases, id: \.self) { style in
                        Text(style.pickerCharacter).tag(style)
                    }
                }
                .pickerStyle(.menu)
            }

            Toggle("Float", isOn: Binding(
                get: { arrow.float },
                set: { viewModel.updateSelectedArrowFloat($0) }
            ))
        }

        // Attachments
        if arrow.startAttachment != nil || arrow.endAttachment != nil {
            Divider()

            staticSection(label: "Attachments", icon: "link") {
                if let attachment = arrow.startAttachment {
                    attachmentRow("Start", attachment: attachment) {
                        viewModel.updateSelectedArrowDetachStart()
                    }
                }
                if let attachment = arrow.endAttachment {
                    attachmentRow("End", attachment: attachment) {
                        viewModel.updateSelectedArrowDetachEnd()
                    }
                }
            }
        }

    }

    @ViewBuilder
    private func attachmentRow(
        _ label: String, attachment: ArrowAttachment, onDetach: @escaping () -> Void
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.medium))
                let shapeName =
                    viewModel.document.findShape(id: attachment.shapeID)?.displayName ?? "Unknown"
                Text("\(shapeName) (\(attachment.side.rawValue))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Detach") {
                onDetach()
            }
            .font(.caption)
        }
    }

    // MARK: - Text properties

    @ViewBuilder
    private func textProperties(_ text: TextShape) -> some View {
        staticSection(label: "Position", icon: "arrow.up.left.and.arrow.down.right") {
            HStack {
                numberField("X", value: text.origin.column) { newVal in
                    viewModel.updateSelectedTextOrigin(column: newVal, row: text.origin.row)
                }
                numberField("Y", value: text.origin.row) { newVal in
                    viewModel.updateSelectedTextOrigin(
                        column: text.origin.column, row: newVal)
                }
            }
            colorSwatchRow(
                color: text.textColor,
                target: .textColor,
                onColorSelected: { viewModel.updateSelectedTextShapeColor($0) }
            )
        }
    }

    // MARK: - Pencil properties

    @ViewBuilder
    private func pencilProperties(_ pencil: PencilShape) -> some View {
        staticSection(label: "Position", icon: "arrow.up.left.and.arrow.down.right") {
            HStack {
                numberField("X", value: pencil.origin.column) { newVal in
                    viewModel.updateSelectedPencilOrigin(column: newVal, row: pencil.origin.row)
                }
                numberField("Y", value: pencil.origin.row) { newVal in
                    viewModel.updateSelectedPencilOrigin(
                        column: pencil.origin.column, row: newVal)
                }
            }
        }

        Divider()

        staticSection(label: "Info", icon: "info.circle") {
            let rect = pencil.boundingRect
            HStack {
                Text("Size")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(rect.size.width) x \(rect.size.height)")
                    .font(.caption.monospaced())
            }
            HStack {
                Text("Cells")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(pencil.cells.count)")
                    .font(.caption.monospaced())
            }
        }

        Divider()

        staticSection(label: "Character", icon: "character.cursor.ibeam") {
            let currentChar = pencil.cells.values.first?.character ?? Character("*")
            let presets: [Character] = ["*", "#", ".", "~", "@", "+", "x", "o"]
            let blockPresets: [Character] = ["\u{2588}", "\u{00B7}", "\u{2591}", "\u{2593}"]

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(32), spacing: 0), count: 4),
                spacing: 0
            ) {
                ForEach(presets + blockPresets, id: \.self) { char in
                    Button {
                        viewModel.updateSelectedPencilCharacter(char)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(
                                    currentChar == char
                                        ? Color.accentColor.opacity(0.16) : Color.clear
                                )
                            Text(String(char))
                                .font(.system(size: 14, design: .monospaced))
                        }
                        .frame(width: 32, height: 24)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
            )

            HStack {
                Text("Custom")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("", text: Binding(
                    get: { String(currentChar) },
                    set: { newValue in
                        if let first = newValue.last {
                            viewModel.updateSelectedPencilCharacter(first)
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 32)
            }
        }

        Divider()

        staticSection(label: "Color", icon: "paintbrush") {
            colorSwatchRow(
                color: pencil.cells.values.first?.color,
                target: .pencilColor,
                onColorSelected: { viewModel.updateSelectedPencilColor($0) }
            )
        }
    }

    // MARK: - Pencil tool settings

    @ViewBuilder
    private var pencilToolSettings: some View {
        staticSection(label: "Character", icon: "character.cursor.ibeam") {
            let presets: [Character] = ["*", "#", ".", "~", "@", "+", "x", "o"]
            let blockPresets: [Character] = ["\u{2588}", "\u{00B7}", "\u{2591}", "\u{2593}"]

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(32), spacing: 0), count: 4),
                spacing: 0
            ) {
                ForEach(presets + blockPresets, id: \.self) { char in
                    Button {
                        viewModel.pencilDrawCharacter = char
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(
                                    viewModel.pencilDrawCharacter == char
                                        ? Color.accentColor.opacity(0.16) : Color.clear
                                )
                            Text(String(char))
                                .font(.system(size: 14, design: .monospaced))
                        }
                        .frame(width: 32, height: 24)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
            )

            HStack {
                Text("Custom")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("", text: Binding(
                    get: { String(viewModel.pencilDrawCharacter) },
                    set: { newValue in
                        if let first = newValue.last {
                            viewModel.pencilDrawCharacter = first
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 32)
            }
        }

        Divider()

        staticSection(label: "Color", icon: "paintbrush") {
            colorSwatchRow(
                color: viewModel.pencilDrawColor,
                target: .pencilToolColor,
                onColorSelected: { viewModel.pencilDrawColor = $0 }
            )
        }
    }

    // MARK: - Helper views

    private func beginRename(_ shape: AnyShape) {
        draftName = shape.displayName
        isEditingName = true
        DispatchQueue.main.async {
            nameFieldFocused = true
        }
    }

    private func commitRename(_ shape: AnyShape) {
        viewModel.renameShapeFromPanel(shape.id, to: draftName)
        isEditingName = false
    }

    private func cancelRename(_ shape: AnyShape) {
        isEditingName = false
        draftName = shape.displayName
    }

    private func shapeIcon(for shape: AnyShape) -> String {
        switch shape {
        case .rectangle: return "rectangle"
        case .arrow: return "arrow.right"
        case .text: return "textformat"
        case .pencil: return "pencil"
        }
    }

    private func numberField(_ label: String, value: Int, onChange: @escaping (Int) -> Void)
        -> some View
    {
        HStack(spacing: 0) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.leading, 4)
                .padding(.trailing, 4)
            TextField(
                label,
                value: Binding(
                    get: { value },
                    set: { onChange($0) }
                ),
                format: .number
            )
            .textFieldStyle(.plain)
            .frame(width: 48)
        }
        .frame(height: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }

    private func strokeGlyphMetrics(for style: StrokeStyle) -> (size: CGFloat, yOffset: CGFloat) {
        switch style {
        case .single: return (16, -4)
        case .double: return (18, -4)
        case .rounded: return (18, -4)
        case .heavy: return (16, -4)
        }
    }

    private func blockCharacterPicker(
        currentChar: Character,
        onChange: @escaping (Character) -> Void
    ) -> some View {
        let blockPresets: [Character] = [
            "\u{2588}", "\u{2593}", "\u{2592}", "\u{2591}",
            "\u{00B7}", "#", ".", "~",
        ]

        return LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(32), spacing: 0), count: 4),
            spacing: 0
        ) {
            ForEach(blockPresets, id: \.self) { char in
                Button {
                    onChange(char)
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(
                                currentChar == char
                                    ? Color.accentColor.opacity(0.16) : Color.clear
                            )
                        Text(String(char))
                            .font(.system(size: 14, design: .monospaced))
                    }
                    .frame(width: 32, height: 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func fillModePicker(
        selected: RectangleFillMode,
        onChange: @escaping (RectangleFillMode) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(RectangleFillMode.filledCases.enumerated()), id: \.element) { index, mode in
                if index > 0 {
                    Divider()
                        .frame(height: 16)
                }
                Button(action: { onChange(mode) }) {
                    ZStack {
                        Rectangle()
                            .fill(selected == mode ? Color.accentColor.opacity(0.16) : Color.clear)
                        Text(mode.label)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func staticSection<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private func collapsibleSection<Content: View>(
        label: String,
        icon: String,
        isExpanded: Bool,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.caption.weight(.semibold))
                Spacer()
                Button {
                    onToggle()
                } label: {
                    Image(systemName: isExpanded ? "minus" : "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                content()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private func toggleSection<Content: View>(
        label: String,
        icon: String,
        isEnabled: Bool,
        onToggle: @escaping (Bool) -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.caption.weight(.semibold))
                Spacer()
                Button {
                    onToggle(!isEnabled)
                } label: {
                    Image(systemName: isEnabled ? "minus" : "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if isEnabled {
                content()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private func mixableToggleSection<Content: View>(
        label: String,
        icon: String,
        isEnabled: Bool?,
        onToggle: @escaping (Bool) -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.caption.weight(.semibold))
                if isEnabled == nil {
                    Text("Mixed")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                Spacer()
                Button {
                    onToggle(!(isEnabled ?? true))
                } label: {
                    Image(systemName: (isEnabled ?? false) ? "minus" : "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if isEnabled ?? false {
                content()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private func mixableNumberField(_ label: String, value: Int?, onChange: @escaping (Int) -> Void)
        -> some View
    {
        HStack(spacing: 0) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.leading, 4)
                .padding(.trailing, 4)
            TextField(
                label,
                text: Binding(
                    get: { value.map { String($0) } ?? "" },
                    set: { newValue in
                        if let intVal = Int(newValue) {
                            onChange(intVal)
                        }
                    }
                ),
                prompt: value == nil ? Text("—") : nil
            )
            .textFieldStyle(.plain)
            .frame(width: 48)
        }
        .frame(height: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }

    private func mixableStrokeStylePicker(
        selected: StrokeStyle?,
        onChange: @escaping (StrokeStyle) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(StrokeStyle.allCases, id: \.self) { style in
                if style != StrokeStyle.allCases.first {
                    Divider()
                        .frame(height: 16)
                }
                alignmentIconButton(
                    isSelected: selected == style,
                    action: { onChange(style) }
                ) {
                    let (size, offset) = strokeGlyphMetrics(for: style)
                    Text(String(style.topLeft))
                        .font(.system(size: size, design: .monospaced))
                        .offset(x: 1, y: offset)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func mixableShadowStylePicker(
        selected: RectangleShadowStyle?,
        onChange: @escaping (RectangleShadowStyle) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(RectangleShadowStyle.allCases, id: \.self) { style in
                if style != RectangleShadowStyle.allCases.first {
                    Divider()
                        .frame(height: 16)
                }
                alignmentIconButton(
                    isSelected: selected == style,
                    action: { onChange(style) }
                ) {
                    Text(String(style.character))
                        .font(.system(size: 14, design: .monospaced))
                        .offset(y: -1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func mixableBorderLineStylePicker(
        selected: RectangleBorderLineStyle?,
        onChange: @escaping (RectangleBorderLineStyle) -> Void
    ) -> some View {
        let cellWidth: CGFloat = 56
        return HStack(spacing: 0) {
            Button(action: { onChange(.solid) }) {
                ZStack {
                    Rectangle()
                        .fill(selected == .solid ? Color.accentColor.opacity(0.16) : Color.clear)
                    Text("Solid")
                        .font(.caption)
                }
                .frame(width: cellWidth, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Divider()
                .frame(height: 16)
            Button(action: { onChange(.dashed) }) {
                ZStack {
                    Rectangle()
                        .fill(selected == .dashed ? Color.accentColor.opacity(0.16) : Color.clear)
                    Text("Dashed")
                        .font(.caption)
                }
                .frame(width: cellWidth, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func multiSelectBorderSidesPicker() -> some View {
        Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                multiSelectBorderSideCell(.top)
                multiSelectBorderSideCell(.right)
            }
            GridRow {
                multiSelectBorderSideCell(.left)
                multiSelectBorderSideCell(.bottom)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
        .fixedSize()
    }

    private func multiSelectBorderSideCell(_ side: RectangleBorderSide) -> some View {
        let uniform = viewModel.multiSelectRectBorderSideUniform(side)
        let isVisible = uniform ?? false
        let isMixed = viewModel.isMultiSelectRectBorderSideMixed(side)
        return Button {
            viewModel.updateMultiSelectRectBorderSide(side, isVisible: !isVisible)
        } label: {
            ZStack {
                Rectangle()
                    .fill(isVisible ? Color.accentColor.opacity(0.16) : Color.clear)
                BorderSideIcon(side: side)
                    .frame(width: 14, height: 14)
                    .opacity(isMixed ? 0.4 : 1.0)
            }
            .frame(width: 32, height: 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: 32, height: 24)
        .contentShape(Rectangle())
    }

    private func shadowStylePicker(
        selected: RectangleShadowStyle, onChange: @escaping (RectangleShadowStyle) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(RectangleShadowStyle.allCases, id: \.self) { style in
                if style != RectangleShadowStyle.allCases.first {
                    Divider()
                        .frame(height: 16)
                }
                alignmentIconButton(
                    isSelected: selected == style,
                    action: { onChange(style) }
                ) {
                    Text(String(style.character))
                        .font(.system(size: 14, design: .monospaced))
                        .offset(y: -1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func strokeStylePicker(
        selected: StrokeStyle, onChange: @escaping (StrokeStyle) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(StrokeStyle.allCases, id: \.self) { style in
                if style != StrokeStyle.allCases.first {
                    Divider()
                        .frame(height: 16)
                }
                alignmentIconButton(
                    isSelected: selected == style,
                    action: { onChange(style) }
                ) {
                    let (size, offset) = strokeGlyphMetrics(for: style)
                    Text(String(style.topLeft))
                        .font(.system(size: size, design: .monospaced))
                        .offset(x: 1, y: offset)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func borderLineStylePicker(
        selected: RectangleBorderLineStyle,
        onChange: @escaping (RectangleBorderLineStyle) -> Void
    ) -> some View {
        let cellWidth: CGFloat = 56
        return HStack(spacing: 0) {
            Button(action: { onChange(.solid) }) {
                ZStack {
                    Rectangle()
                        .fill(selected == .solid ? Color.accentColor.opacity(0.16) : Color.clear)
                    Text("Solid")
                        .font(.caption)
                }
                .frame(width: cellWidth, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Divider()
                .frame(height: 16)
            Button(action: { onChange(.dashed) }) {
                ZStack {
                    Rectangle()
                        .fill(selected == .dashed ? Color.accentColor.opacity(0.16) : Color.clear)
                    Text("Dashed")
                        .font(.caption)
                }
                .frame(width: cellWidth, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }

    private func borderSidesPicker(
        rectangle: RectangleShape,
        onToggle: @escaping (RectangleBorderSide, Bool) -> Void
    ) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                borderSideCell(.top, in: rectangle, onToggle: onToggle)
                borderSideCell(.right, in: rectangle, onToggle: onToggle)
            }
            GridRow {
                borderSideCell(.left, in: rectangle, onToggle: onToggle)
                borderSideCell(.bottom, in: rectangle, onToggle: onToggle)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
        .fixedSize()
    }

    private func borderSideCell(
        _ side: RectangleBorderSide,
        in rectangle: RectangleShape,
        onToggle: @escaping (RectangleBorderSide, Bool) -> Void
    ) -> some View {
        let isVisible = rectangle.visibleBorders.contains(side)
        return alignmentIconButton(
            isSelected: isVisible,
            action: { onToggle(side, !isVisible) }
        ) {
            BorderSideIcon(side: side)
                .frame(width: 14, height: 14)
        }
    }

    private struct BorderSideIcon: View {
        let side: RectangleBorderSide

        var body: some View {
            GeometryReader { geometry in
                let inset: CGFloat = 1.5
                let minX = inset
                let maxX = geometry.size.width - inset
                let minY = inset
                let maxY = geometry.size.height - inset

                Path { path in
                    path.move(to: CGPoint(x: minX, y: minY))
                    path.addLine(to: CGPoint(x: maxX, y: minY))
                }
                .stroke(color(for: .top), style: style(for: .top))

                Path { path in
                    path.move(to: CGPoint(x: minX, y: maxY))
                    path.addLine(to: CGPoint(x: maxX, y: maxY))
                }
                .stroke(color(for: .bottom), style: style(for: .bottom))

                Path { path in
                    path.move(to: CGPoint(x: minX, y: minY))
                    path.addLine(to: CGPoint(x: minX, y: maxY))
                }
                .stroke(color(for: .left), style: style(for: .left))

                Path { path in
                    path.move(to: CGPoint(x: maxX, y: minY))
                    path.addLine(to: CGPoint(x: maxX, y: maxY))
                }
                .stroke(color(for: .right), style: style(for: .right))
            }
        }

        private func style(for candidate: RectangleBorderSide) -> SwiftUI.StrokeStyle {
            if candidate == side {
                return SwiftUI.StrokeStyle(lineWidth: 1.6, lineCap: .round)
            }
            return SwiftUI.StrokeStyle(lineWidth: 0.85, lineCap: .round, dash: [2, 2])
        }

        private func color(for candidate: RectangleBorderSide) -> Color {
            if candidate == side {
                return .primary
            }
            return .secondary.opacity(0.5)
        }
    }

    private func colorSwatchRow(
        color: ShapeColor?,
        defaultColor: ShapeColor = .black,
        allowsNone: Bool = false,
        target: ColorTarget,
        onColorSelected: @escaping (ShapeColor?) -> Void
    ) -> some View {
        InlineColorRow(
            color: color,
            defaultColor: defaultColor,
            allowsNone: allowsNone,
            onColorSelected: onColorSelected,
            onSwatchTapped: {
                viewModel.openColorPicker(
                    target: target,
                    currentColor: color,
                    allowsNone: allowsNone,
                    onColorSelected: onColorSelected
                )
            }
        )
    }

    private func alignmentIconButton<Content: View>(
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.clear)
                content()
            }
            .frame(width: 32, height: 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: 32, height: 24)
        .contentShape(Rectangle())
    }

    private func horizontalAlignmentIcon(_ alignment: RectangleTextHorizontalAlignment) -> some View {
        Image(systemName: horizontalAlignmentSymbol(for: alignment))
            .font(.system(size: 13, weight: .medium))
    }

    private func verticalAlignmentIcon(_ alignment: RectangleTextVerticalAlignment) -> some View {
        Image(systemName: verticalAlignmentSymbol(for: alignment))
            .font(.system(size: 13, weight: .medium))
    }

    private func horizontalAlignmentSymbol(for alignment: RectangleTextHorizontalAlignment) -> String {
        switch alignment {
        case .left:
            return "text.alignleft"
        case .center:
            return "text.aligncenter"
        case .right:
            return "text.alignright"
        }
    }

    private func verticalAlignmentSymbol(for alignment: RectangleTextVerticalAlignment) -> String {
        switch alignment {
        case .top:
            return "align.vertical.top"
        case .middle:
            return "align.vertical.center"
        case .bottom:
            return "align.vertical.bottom"
        }
    }

}

#Preview {
    InspectorPanel(viewModel: {
        let rectangle = RectangleShape(
            origin: GridPoint(column: 4, row: 2),
            size: GridSize(width: 20, height: 10),
            label: "My Rectangle"
        )
        var document = Document()
        document.addShape(.rectangle(rectangle))
        let vm = EditorViewModel(document: document)
        vm.selectedShapeIDs = [rectangle.id]
        return vm
    }())
    .frame(height: 700)
}
