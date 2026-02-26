import SwiftUI

struct LayerPanel: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            layerList
            Divider()
            bottomButtons
        }
        .frame(minWidth: 180, idealWidth: 200)
    }

    private var header: some View {
        Text("Layers")
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }

    private var layerList: some View {
        List(selection: Binding(
            get: { viewModel.activeLayerIndex },
            set: { viewModel.activeLayerIndex = $0 }
        )) {
            ForEach(Array(viewModel.document.layers.enumerated().reversed()), id: \.element.id) {
                index, layer in
                layerRow(layer: layer, index: index)
                    .tag(index)
            }
        }
        .listStyle(.sidebar)
    }

    private func layerRow(layer: Layer, index: Int) -> some View {
        HStack(spacing: 6) {
            Button {
                viewModel.toggleLayerVisibility(at: index)
            } label: {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundStyle(layer.isVisible ? .primary : .secondary)
            }
            .buttonStyle(.plain)

            Button {
                viewModel.toggleLayerLock(at: index)
            } label: {
                Image(systemName: layer.isLocked ? "lock" : "lock.open")
                    .foregroundStyle(layer.isLocked ? .primary : .secondary)
            }
            .buttonStyle(.plain)

            Text(layer.name)
                .lineLimit(1)

            Spacer()

            // Shape count badge
            if !layer.shapes.isEmpty {
                Text("\(layer.shapes.count)")
                    .font(.caption2)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }

    private var bottomButtons: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.addLayer()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)

            Button {
                viewModel.removeLayer(at: viewModel.activeLayerIndex)
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.plain)
            .disabled(viewModel.document.layers.count <= 1)

            Spacer()
        }
        .padding(8)
    }
}

#Preview {
    LayerPanel(viewModel: EditorViewModel())
}
