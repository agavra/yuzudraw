import SwiftUI

struct InspectorPanel: View {
    @Bindable var viewModel: EditorViewModel

    // MARK: - Section expansion state


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
                    Text(shape.displayName)
                        .font(.headline)
                        .lineLimit(1)
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
            strokeStylePicker(
                selected: box.strokeStyle,
                onChange: { viewModel.updateSelectedBoxStrokeStyle($0) }
            )
        }

        Divider()

        // Fill
        toggleSection(
            label: "Fill",
            icon: "square.fill",
            isEnabled: box.fillMode == .solid,
            onToggle: { viewModel.updateSelectedBoxFillEnabled($0) }
        ) {
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
        }
    }

    // MARK: - Helper views

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
        .padding(.vertical, 10)
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
        .padding(.vertical, 10)
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
