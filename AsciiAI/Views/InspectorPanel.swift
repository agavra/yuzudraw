import SwiftUI

struct InspectorPanel: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    borderStyleSection
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

            sectionHeader("Style")
            Picker("Border", selection: Binding(
                get: { box.borderStyle },
                set: { viewModel.updateSelectedBoxBorderStyle($0) }
            )) {
                ForEach(BorderStyle.allCases, id: \.self) { style in
                    Text(style.rawValue.capitalized).tag(style)
                }
            }
            .pickerStyle(.menu)

            sectionHeader("Label")
            TextField("Label", text: Binding(
                get: { box.label },
                set: { viewModel.updateSelectedBoxLabel($0) }
            ))
            .textFieldStyle(.roundedBorder)
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

    // MARK: - Border style

    private var borderStyleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            sectionHeader("Stroke")
            Picker("Stroke", selection: Binding(
                get: { viewModel.activeBorderStyle },
                set: { viewModel.setBorderStyle($0) }
            )) {
                Text("Single ─│┌┐").tag(BorderStyle.single)
                Text("Double ═║╔╗").tag(BorderStyle.double)
                Text("Rounded ─│╭╮").tag(BorderStyle.rounded)
                Text("Heavy ━┃┏┓").tag(BorderStyle.heavy)
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
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
            .font(.caption)
            .foregroundStyle(.secondary)
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
