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
            TextField("Text", text: Binding(
                get: { box.label },
                set: { viewModel.updateSelectedBoxLabel($0) }
            ))
            .textFieldStyle(.roundedBorder)

            Picker("Horizontal", selection: Binding(
                get: { box.textHorizontalAlignment },
                set: { viewModel.updateSelectedBoxTextHorizontalAlignment($0) }
            )) {
                ForEach(BoxTextHorizontalAlignment.allCases, id: \.self) { alignment in
                    Text(alignment.rawValue.capitalized).tag(alignment)
                }
            }
            .pickerStyle(.menu)

            Picker("Vertical", selection: Binding(
                get: { box.textVerticalAlignment },
                set: { viewModel.updateSelectedBoxTextVerticalAlignment($0) }
            )) {
                ForEach(BoxTextVerticalAlignment.allCases, id: \.self) { alignment in
                    Text(alignment.rawValue.capitalized).tag(alignment)
                }
            }
            .pickerStyle(.menu)

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
            propertyRow("Start", value: "\(arrow.start.column), \(arrow.start.row)")
            propertyRow("End", value: "\(arrow.end.column), \(arrow.end.row)")

            sectionHeader("Label")
            TextField("Label", text: Binding(
                get: { arrow.label },
                set: { viewModel.updateSelectedArrowLabel($0) }
            ))
            .textFieldStyle(.roundedBorder)

            Picker("Stroke", selection: Binding(
                get: { arrow.strokeStyle },
                set: { viewModel.updateSelectedArrowStrokeStyle($0) }
            )) {
                ForEach(StrokeStyle.allCases, id: \.self) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder
    private func textProperties(_ text: TextShape) -> some View {
        Group {
            propertyRow(
                "Position", value: "\(text.origin.column), \(text.origin.row)")
            propertyRow("Content", value: text.text)
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

}

#Preview {
    InspectorPanel(viewModel: EditorViewModel())
}
