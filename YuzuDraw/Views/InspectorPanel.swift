import SwiftUI

struct InspectorPanel: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.selectedShapes.count > 1 {
                        Divider()
                        multiSelectionView
                    } else if let shape = viewModel.selectedShape {
                        Divider()
                        shapeProperties(shape)
                    } else {
                        noSelectionView
                    }
                }
                .padding(12)
            }
        }
        .frame(minWidth: 160, idealWidth: 180, maxWidth: 220)
    }

    private var header: some View {
        Text("Properties")
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }

    private var multiSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(viewModel.selectedShapes.count) shapes selected")
                .foregroundStyle(.secondary)

            Button("Delete All", role: .destructive) {
                viewModel.deleteSelectedShapes()
            }
        }
    }

    private var noSelectionView: some View {
        Text("No selection")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }

    @ViewBuilder
    private func shapeProperties(_ shape: AnyShape) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            propertyRow("Type", value: shape.typeName)
            Divider()

            switch shape {
            case .box(let box):
                boxProperties(box)
            case .arrow(let arrow):
                arrowProperties(arrow)
            case .text(let text):
                textProperties(text)
            }

            Divider()

            Button("Delete", role: .destructive) {
                viewModel.deleteSelectedShapes()
            }
        }
    }

    @ViewBuilder
    private func boxProperties(_ box: BoxShape) -> some View {
        Group {
            sectionHeader("Position")
            HStack {
                numberField("X", value: box.origin.column) { newVal in
                    viewModel.updateSelectedBoxOrigin(column: newVal, row: box.origin.row)
                }
                numberField("Y", value: box.origin.row) { newVal in
                    viewModel.updateSelectedBoxOrigin(column: box.origin.column, row: newVal)
                }
            }

            sectionHeader("Size")
            HStack {
                numberField("W", value: box.size.width) { newVal in
                    viewModel.updateSelectedBoxSize(width: newVal, height: box.size.height)
                }
                numberField("H", value: box.size.height) { newVal in
                    viewModel.updateSelectedBoxSize(width: box.size.width, height: newVal)
                }
            }
            Divider()

            sectionHeader("Text")
            VStack(alignment: .leading, spacing: 6) {
                Text("Horizontal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 0) {
                    alignmentIconButton(
                        isSelected: box.textHorizontalAlignment == .left,
                        action: { viewModel.updateSelectedBoxTextHorizontalAlignment(.left) }
                    ) {
                        horizontalAlignmentIcon(.left)
                    }
                    Divider()
                        .frame(height: 16)
                    alignmentIconButton(
                        isSelected: box.textHorizontalAlignment == .center,
                        action: { viewModel.updateSelectedBoxTextHorizontalAlignment(.center) }
                    ) {
                        horizontalAlignmentIcon(.center)
                    }
                    Divider()
                        .frame(height: 16)
                    alignmentIconButton(
                        isSelected: box.textHorizontalAlignment == .right,
                        action: { viewModel.updateSelectedBoxTextHorizontalAlignment(.right) }
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

            VStack(alignment: .leading, spacing: 6) {
                Text("Vertical")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 0) {
                    alignmentIconButton(
                        isSelected: box.textVerticalAlignment == .top,
                        action: { viewModel.updateSelectedBoxTextVerticalAlignment(.top) }
                    ) {
                        verticalAlignmentIcon(.top)
                    }
                    Divider()
                        .frame(height: 16)
                    alignmentIconButton(
                        isSelected: box.textVerticalAlignment == .middle,
                        action: { viewModel.updateSelectedBoxTextVerticalAlignment(.middle) }
                    ) {
                        verticalAlignmentIcon(.middle)
                    }
                    Divider()
                        .frame(height: 16)
                    alignmentIconButton(
                        isSelected: box.textVerticalAlignment == .bottom,
                        action: { viewModel.updateSelectedBoxTextVerticalAlignment(.bottom) }
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

            HStack {
                numberField("Pad L", value: box.textPaddingLeft) { newVal in
                    viewModel.updateSelectedBoxTextPadding(left: newVal)
                }
                numberField("Pad R", value: box.textPaddingRight) { newVal in
                    viewModel.updateSelectedBoxTextPadding(right: newVal)
                }
            }

            HStack {
                numberField("Pad T", value: box.textPaddingTop) { newVal in
                    viewModel.updateSelectedBoxTextPadding(top: newVal)
                }
                numberField("Pad B", value: box.textPaddingBottom) { newVal in
                    viewModel.updateSelectedBoxTextPadding(bottom: newVal)
                }
            }
            Divider()

            sectionHeader("Style")
            Toggle("Border", isOn: Binding(
                get: { box.hasBorder },
                set: { viewModel.updateSelectedBoxHasBorder($0) }
            ))

            if box.hasBorder {
                Picker("Border Style", selection: Binding(
                    get: { box.strokeStyle },
                    set: { viewModel.updateSelectedBoxStrokeStyle($0) }
                )) {
                    ForEach(StrokeStyle.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
                .pickerStyle(.menu)
            }

            HStack {
                Toggle("Fill", isOn: Binding(
                    get: { box.fillMode == .solid },
                    set: { viewModel.updateSelectedBoxFillEnabled($0) }
                ))

                if box.fillMode == .solid {
                    Text("Char")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    TextField("", text: Binding(
                        get: { box.fillCharacter == " " ? "" : String(box.fillCharacter) },
                        set: { newValue in
                            let char = newValue.first ?? Character(" ")
                            viewModel.updateSelectedBoxFillCharacter(char)
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 24)
                }
            }

            Toggle("Enable Shadow", isOn: Binding(
                get: { box.hasShadow },
                set: { viewModel.updateSelectedBoxHasShadow($0) }
            ))

            if box.hasShadow {
                Picker("Style", selection: Binding(
                    get: { box.shadowStyle },
                    set: { viewModel.updateSelectedBoxShadowStyle($0) }
                )) {
                    ForEach(BoxShadowStyle.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
                .pickerStyle(.menu)

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

    @ViewBuilder
    private func arrowProperties(_ arrow: ArrowShape) -> some View {
        Group {
            sectionHeader("Position")
            HStack {
                numberField("Start X", value: arrow.start.column) { newVal in
                    viewModel.updateSelectedArrowStart(column: newVal, row: arrow.start.row)
                }
                numberField("Start Y", value: arrow.start.row) { newVal in
                    viewModel.updateSelectedArrowStart(column: arrow.start.column, row: newVal)
                }
            }
            HStack {
                numberField("End X", value: arrow.end.column) { newVal in
                    viewModel.updateSelectedArrowEnd(column: newVal, row: arrow.end.row)
                }
                numberField("End Y", value: arrow.end.row) { newVal in
                    viewModel.updateSelectedArrowEnd(column: arrow.end.column, row: newVal)
                }
            }
            Divider()

            sectionHeader("Style")
            Picker("Stroke", selection: Binding(
                get: { arrow.strokeStyle },
                set: { viewModel.updateSelectedArrowStrokeStyle($0) }
            )) {
                ForEach(StrokeStyle.allCases, id: \.self) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(.menu)

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

            if arrow.startAttachment != nil || arrow.endAttachment != nil {
                Divider()
                sectionHeader("Attachments")

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
    private func attachmentRow(_ label: String, attachment: ArrowAttachment, onDetach: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.medium))
                let shapeName = viewModel.document.findShape(id: attachment.shapeID)?.displayName ?? "Unknown"
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

    @ViewBuilder
    private func textProperties(_ text: TextShape) -> some View {
        Group {
            sectionHeader("Position")
            HStack {
                numberField("X", value: text.origin.column) { newVal in
                    viewModel.updateSelectedTextOrigin(column: newVal, row: text.origin.row)
                }
                numberField("Y", value: text.origin.row) { newVal in
                    viewModel.updateSelectedTextOrigin(column: text.origin.column, row: newVal)
                }
            }
        }
    }

    // MARK: - Helper views

    private func propertyRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
        }
        .font(.callout)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.black)
            .textCase(.uppercase)
    }

    private func numberField(_ label: String, value: Int, onChange: @escaping (Int) -> Void)
        -> some View
    {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
            TextField(
                label,
                value: Binding(
                    get: { value },
                    set: { onChange($0) }
                ),
                format: .number
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 50)
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
    InspectorPanel(viewModel: EditorViewModel())
}
