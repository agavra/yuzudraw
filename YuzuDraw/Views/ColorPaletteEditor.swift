import SwiftUI

struct ColorPaletteEditor: View {
    @Bindable var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            paletteList
            Divider()
            footer
        }
        .frame(width: 320, height: 400)
    }

    private var header: some View {
        HStack {
            Text("Edit Palette")
                .font(.headline)
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
        .padding(12)
    }

    private var paletteList: some View {
        List {
            ForEach(viewModel.document.palette.entries) { entry in
                HStack(spacing: 8) {
                    ColorPicker(
                        "",
                        selection: Binding(
                            get: { entry.color.swiftUIColor },
                            set: { newColor in
                                if let shapeColor = ShapeColor(nsColor: NSColor(newColor)) {
                                    viewModel.updatePaletteColor(id: entry.id, color: shapeColor)
                                }
                            }
                        ),
                        supportsOpacity: true
                    )
                    .labelsHidden()
                    .frame(width: 30)

                    TextField(
                        "Name",
                        text: Binding(
                            get: { entry.name },
                            set: { viewModel.updatePaletteColor(id: entry.id, name: $0) }
                        )
                    )
                    .textFieldStyle(.plain)

                    Spacer()

                    Button {
                        viewModel.removePaletteColor(id: entry.id)
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
            .onMove { source, destination in
                viewModel.document.palette.entries.move(
                    fromOffsets: source, toOffset: destination)
            }
        }
    }

    private var footer: some View {
        HStack {
            Button("Add Color") {
                viewModel.addPaletteColor(name: "New Color", color: .gray)
            }
            .font(.caption)
            Spacer()
            Button("Reset to Default") {
                viewModel.document.palette = .default
            }
            .font(.caption)
        }
        .padding(12)
    }
}
