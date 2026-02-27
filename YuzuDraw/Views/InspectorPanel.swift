import SwiftUI

struct InspectorPanel: View {
    @Bindable var viewModel: EditorViewModel

    // MARK: - Inline rename state
    @State private var isEditingName = false
    @State private var draftName = ""
    @FocusState private var nameFieldFocused: Bool

    // MARK: - Color popover state
    @State private var activeColorTarget: ColorTarget?
    @State private var showPaletteEditor = false

    private enum ColorTarget: Hashable {
        case boxBorder
        case boxFill
        case boxText
        case arrowStroke
        case arrowLabel
        case textColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.selectedShapes.count > 1 {
                        multiSelectionView
                            .padding(12)
                    } else if let shape = viewModel.selectedShape {
                        shapeProperties(shape)
                    } else {
                        noSelectionView
                    }
                }
            }
            if viewModel.selectedShapes.count >= 1 {
                Divider()
                bottomToolbar
            }
        }
        .frame(minWidth: 160, idealWidth: 180, maxWidth: 220)
        .sheet(isPresented: $showPaletteEditor) {
            ColorPaletteEditor(viewModel: viewModel)
        }
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

    private var multiSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(viewModel.selectedShapes.count) shapes selected")
                .foregroundStyle(.secondary)
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

    // MARK: - Shape properties

    @ViewBuilder
    private func shapeProperties(_ shape: AnyShape) -> some View {
        switch shape {
        case .box(let box):
            boxProperties(box)
        case .arrow(let arrow):
            arrowProperties(arrow)
        case .text(let text):
            textProperties(text)
        }
    }

    // MARK: - Box properties

    @ViewBuilder
    private func boxProperties(_ box: BoxShape) -> some View {
        // Position & Size
        staticSection(label: "Position & Size", icon: "arrow.up.left.and.arrow.down.right") {
            HStack {
                numberField("X", value: box.origin.column) { newVal in
                    viewModel.updateSelectedBoxOrigin(column: newVal, row: box.origin.row)
                }
                numberField("Y", value: box.origin.row) { newVal in
                    viewModel.updateSelectedBoxOrigin(column: box.origin.column, row: newVal)
                }
            }
            HStack {
                numberField("W", value: box.size.width) { newVal in
                    viewModel.updateSelectedBoxSize(width: newVal, height: box.size.height)
                }
                numberField("H", value: box.size.height) { newVal in
                    viewModel.updateSelectedBoxSize(width: box.size.width, height: newVal)
                }
            }
        }

        Divider()

        // Text
        staticSection(label: "Text", icon: "textformat") {
            colorSwatchRow(
                color: box.textColor,
                target: .boxText,
                onColorSelected: { viewModel.updateSelectedBoxTextColor($0) }
            )
            HStack(spacing: 6) {
                    Text("H")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 12)
                    HStack(spacing: 0) {
                        alignmentIconButton(
                            isSelected: box.textHorizontalAlignment == .left,
                            action: {
                                viewModel.updateSelectedBoxTextHorizontalAlignment(.left)
                            }
                        ) {
                            horizontalAlignmentIcon(.left)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: box.textHorizontalAlignment == .center,
                            action: {
                                viewModel.updateSelectedBoxTextHorizontalAlignment(.center)
                            }
                        ) {
                            horizontalAlignmentIcon(.center)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: box.textHorizontalAlignment == .right,
                            action: {
                                viewModel.updateSelectedBoxTextHorizontalAlignment(.right)
                            }
                        ) {
                            horizontalAlignmentIcon(.right)
                        }
                    }
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
                            isSelected: box.textVerticalAlignment == .top,
                            action: {
                                viewModel.updateSelectedBoxTextVerticalAlignment(.top)
                            }
                        ) {
                            verticalAlignmentIcon(.top)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: box.textVerticalAlignment == .middle,
                            action: {
                                viewModel.updateSelectedBoxTextVerticalAlignment(.middle)
                            }
                        ) {
                            verticalAlignmentIcon(.middle)
                        }
                        Divider()
                            .frame(height: 16)
                        alignmentIconButton(
                            isSelected: box.textVerticalAlignment == .bottom,
                            action: {
                                viewModel.updateSelectedBoxTextVerticalAlignment(.bottom)
                            }
                        ) {
                            verticalAlignmentIcon(.bottom)
                        }
                    }
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
                    get: { box.allowTextOnBorder },
                    set: { viewModel.updateSelectedBoxAllowTextOnBorder($0) }
                ))
                .disabled(!box.hasBorder)
        }

        Divider()

        // Padding
        staticSection(label: "Padding", icon: "square.dashed") {
            Grid(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 6) {
                GridRow {
                    numberField("Left", value: box.textPaddingLeft) { newVal in
                        viewModel.updateSelectedBoxTextPadding(left: newVal)
                    }
                    numberField("Right", value: box.textPaddingRight) { newVal in
                        viewModel.updateSelectedBoxTextPadding(right: newVal)
                    }
                }
                GridRow {
                    numberField("Top", value: box.textPaddingTop) { newVal in
                        viewModel.updateSelectedBoxTextPadding(top: newVal)
                    }
                    numberField("Bottom", value: box.textPaddingBottom) { newVal in
                        viewModel.updateSelectedBoxTextPadding(bottom: newVal)
                    }
                }
            }
        }

        Divider()

        // Border
        toggleSection(
            label: "Border",
            icon: "paintbrush",
            isEnabled: box.hasBorder,
            onToggle: { viewModel.updateSelectedBoxHasBorder($0) }
        ) {
            VStack(alignment: .leading, spacing: 8) {
                colorSwatchRow(
                    color: box.borderColor,
                    target: .boxBorder,
                    onColorSelected: { viewModel.updateSelectedBoxBorderColor($0) }
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text("Style")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    strokeStylePicker(
                        selected: box.strokeStyle,
                        onChange: { viewModel.updateSelectedBoxStrokeStyle($0) }
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sides")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    borderSidesPicker(
                        box: box,
                        onToggle: { side, isVisible in
                            viewModel.updateSelectedBoxBorderSide(side, isVisible: isVisible)
                        }
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Line")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    borderLineStylePicker(
                        selected: box.borderLineStyle,
                        onChange: { viewModel.updateSelectedBoxBorderLineStyle($0) }
                    )
                }
                if box.borderLineStyle == .dashed {
                    HStack {
                        numberField("Dash", value: box.borderDashLength) { newVal in
                            viewModel.updateSelectedBoxBorderDashLength(newVal)
                        }
                        numberField("Gap", value: box.borderGapLength) { newVal in
                            viewModel.updateSelectedBoxBorderGapLength(newVal)
                        }
                    }
                }
            }
        }

        Divider()

        // Fill
        toggleSection(
            label: "Fill",
            icon: "square.fill",
            isEnabled: box.fillMode == .solid,
            onToggle: { viewModel.updateSelectedBoxFillEnabled($0) }
        ) {
            colorSwatchRow(
                color: box.fillColor,
                target: .boxFill,
                onColorSelected: { viewModel.updateSelectedBoxFillColor($0) }
            )
            HStack {
                Text("Char")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("", text: Binding(
                    get: {
                        box.fillCharacter == " " ? "" : String(box.fillCharacter)
                    },
                    set: { newValue in
                        let char = newValue.first ?? Character(" ")
                        viewModel.updateSelectedBoxFillCharacter(char)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 24)
            }
        }

        Divider()

        // Shadow
        toggleSection(
            label: "Shadow",
            icon: "shadow",
            isEnabled: box.hasShadow,
            onToggle: { viewModel.updateSelectedBoxHasShadow($0) }
        ) {
            VStack(alignment: .leading, spacing: 6) {
                shadowStylePicker(
                    selected: box.shadowStyle,
                    onChange: { viewModel.updateSelectedBoxShadowStyle($0) }
                )

                HStack {
                    numberField("X", value: box.shadowOffsetX) { newVal in
                        viewModel.updateSelectedBoxShadowOffsetX(newVal)
                    }
                    numberField("Y", value: box.shadowOffsetY) { newVal in
                        viewModel.updateSelectedBoxShadowOffsetY(newVal)
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
        case .box: return "rectangle"
        case .arrow: return "arrow.right"
        case .text: return "textformat"
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

    private func shadowStylePicker(
        selected: BoxShadowStyle, onChange: @escaping (BoxShadowStyle) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(BoxShadowStyle.allCases, id: \.self) { style in
                if style != BoxShadowStyle.allCases.first {
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
        selected: BoxBorderLineStyle,
        onChange: @escaping (BoxBorderLineStyle) -> Void
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
        box: BoxShape,
        onToggle: @escaping (BoxBorderSide, Bool) -> Void
    ) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                borderSideCell(.top, in: box, onToggle: onToggle)
                borderSideCell(.right, in: box, onToggle: onToggle)
            }
            GridRow {
                borderSideCell(.left, in: box, onToggle: onToggle)
                borderSideCell(.bottom, in: box, onToggle: onToggle)
            }
        }
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
        _ side: BoxBorderSide,
        in box: BoxShape,
        onToggle: @escaping (BoxBorderSide, Bool) -> Void
    ) -> some View {
        let isVisible = box.visibleBorders.contains(side)
        return alignmentIconButton(
            isSelected: isVisible,
            action: { onToggle(side, !isVisible) }
        ) {
            BorderSideIcon(side: side)
                .frame(width: 14, height: 14)
        }
    }

    private struct BorderSideIcon: View {
        let side: BoxBorderSide

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

        private func style(for candidate: BoxBorderSide) -> SwiftUI.StrokeStyle {
            if candidate == side {
                return SwiftUI.StrokeStyle(lineWidth: 1.6, lineCap: .round)
            }
            return SwiftUI.StrokeStyle(lineWidth: 0.85, lineCap: .round, dash: [2, 2])
        }

        private func color(for candidate: BoxBorderSide) -> Color {
            if candidate == side {
                return .primary
            }
            return .secondary.opacity(0.5)
        }
    }

    private func colorSwatchRow(
        color: ShapeColor?,
        defaultColor: ShapeColor = .black,
        target: ColorTarget,
        onColorSelected: @escaping (ShapeColor?) -> Void
    ) -> some View {
        InlineColorRow(
            color: color,
            defaultColor: defaultColor,
            onColorSelected: onColorSelected,
            isPopoverPresented: Binding(
                get: { activeColorTarget == target },
                set: { newValue in
                    activeColorTarget = newValue ? target : nil
                }
            )
        ) {
            ColorPickerPopover(
                palette: viewModel.document.palette,
                currentColor: color,
                onColorSelected: { newColor in
                    onColorSelected(newColor)
                    activeColorTarget = nil
                },
                onEditPalette: {
                    activeColorTarget = nil
                    showPaletteEditor = true
                }
            )
        }
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

    private func horizontalAlignmentIcon(_ alignment: BoxTextHorizontalAlignment) -> some View {
        Image(systemName: horizontalAlignmentSymbol(for: alignment))
            .font(.system(size: 13, weight: .medium))
    }

    private func verticalAlignmentIcon(_ alignment: BoxTextVerticalAlignment) -> some View {
        Image(systemName: verticalAlignmentSymbol(for: alignment))
            .font(.system(size: 13, weight: .medium))
    }

    private func horizontalAlignmentSymbol(for alignment: BoxTextHorizontalAlignment) -> String {
        switch alignment {
        case .left:
            return "text.alignleft"
        case .center:
            return "text.aligncenter"
        case .right:
            return "text.alignright"
        }
    }

    private func verticalAlignmentSymbol(for alignment: BoxTextVerticalAlignment) -> String {
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
    let box = BoxShape(
        origin: GridPoint(column: 4, row: 2),
        size: GridSize(width: 20, height: 10),
        label: "My Box"
    )
    var document = Document()
    document.addShape(.box(box), toLayerAt: 0)
    let vm = EditorViewModel(document: document)
    vm.selectedShapeIDs = [box.id]
    return InspectorPanel(viewModel: vm)
        .frame(height: 700)
}
