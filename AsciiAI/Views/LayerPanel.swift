import SwiftUI

private let indentStep: CGFloat = 14

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
        .frame(minWidth: 160, idealWidth: 200, maxWidth: 260)
    }

    private var header: some View {
        Text("Layers")
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }

    private var layerList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.document.layers.enumerated().reversed()), id: \.element.id) {
                    index, layer in
                    layerSection(layer: layer, index: index)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private func layerSection(layer: Layer, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Layer header row
            HStack(spacing: 2) {
                chevron(isExpanded: viewModel.expandedItemIDs.contains(layer.id)) {
                    viewModel.toggleExpanded(layer.id)
                }

                Button {
                    viewModel.toggleLayerVisibility(at: index)
                } label: {
                    Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                        .font(.caption2)
                        .foregroundStyle(layer.isVisible ? .primary : .secondary)
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.toggleLayerLock(at: index)
                } label: {
                    Image(systemName: layer.isLocked ? "lock" : "lock.open")
                        .font(.caption2)
                        .foregroundStyle(layer.isLocked ? .primary : .secondary)
                }
                .buttonStyle(.plain)

                Text(layer.name)
                    .font(.caption)
                    .lineLimit(1)
                    .fontWeight(index == viewModel.activeLayerIndex ? .semibold : .regular)

                Spacer()

                if !layer.shapes.isEmpty {
                    Text("\(layer.shapes.count)")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .background(.quaternary)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.activeLayerIndex = index
            }

            // Expanded children
            if viewModel.expandedItemIDs.contains(layer.id) {
                ForEach(layer.groups) { group in
                    GroupRow(group: group, layer: layer, viewModel: viewModel, depth: 1)
                }
                ForEach(layer.ungroupedShapes) { shape in
                    ShapeRow(shape: shape, viewModel: viewModel, depth: 1)
                }
            }
        }
    }

    private func chevron(isExpanded: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .frame(width: 12, height: 12)
        }
        .buttonStyle(.plain)
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

private struct GroupRow: View {
    let group: ShapeGroup
    let layer: Layer
    @Bindable var viewModel: EditorViewModel
    let depth: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 2) {
                chevron(isExpanded: viewModel.expandedItemIDs.contains(group.id)) {
                    viewModel.toggleExpanded(group.id)
                }
                Image(systemName: "folder")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(group.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.leading, CGFloat(depth) * indentStep)
            .padding(.vertical, 2)

            if viewModel.expandedItemIDs.contains(group.id) {
                ForEach(group.children) { child in
                    GroupRow(
                        group: child, layer: layer, viewModel: viewModel, depth: depth + 1)
                }
                ForEach(group.shapeIDs, id: \.self) { shapeID in
                    if let shape = layer.findShape(id: shapeID) {
                        ShapeRow(shape: shape, viewModel: viewModel, depth: depth + 1)
                    }
                }
            }
        }
    }

    private func chevron(isExpanded: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .frame(width: 12, height: 12)
        }
        .buttonStyle(.plain)
    }
}

private struct ShapeRow: View {
    let shape: AnyShape
    @Bindable var viewModel: EditorViewModel
    let depth: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: shapeTypeIcon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 12)
            Text(shape.displayName)
                .font(.caption)
                .lineLimit(1)
            Spacer()
        }
        .padding(.leading, CGFloat(depth) * indentStep + 12)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background(
            viewModel.selectedShapeIDs.contains(shape.id)
                ? Color.accentColor.opacity(0.2)
                : Color.clear
        )
        .cornerRadius(3)
        .onTapGesture {
            viewModel.selectShapeFromPanel(shape.id)
        }
    }

    private var shapeTypeIcon: String {
        switch shape {
        case .box: return "rectangle"
        case .arrow: return "arrow.right"
        case .text: return "textformat"
        }
    }
}

#Preview {
    let vm = EditorViewModel()
    let box1 = BoxShape(
        origin: GridPoint(column: 5, row: 3),
        size: GridSize(width: 20, height: 5),
        label: "Server"
    )
    let box2 = BoxShape(
        origin: GridPoint(column: 30, row: 3),
        size: GridSize(width: 15, height: 4),
        label: "Database"
    )
    let arrow = ArrowShape(
        start: GridPoint(column: 25, row: 5),
        end: GridPoint(column: 30, row: 5),
        label: "SQL"
    )
    let text = TextShape(
        origin: GridPoint(column: 5, row: 10),
        text: "Notes here"
    )
    vm.document.addShape(.box(box1), toLayerAt: 0)
    vm.document.addShape(.box(box2), toLayerAt: 0)
    vm.document.addShape(.arrow(arrow), toLayerAt: 0)
    vm.document.addShape(.text(text), toLayerAt: 0)
    vm.document.layers[0].groups.append(
        ShapeGroup(name: "Backend", shapeIDs: [box1.id, box2.id])
    )
    vm.expandedItemIDs.insert(vm.document.layers[0].id)
    vm.selectedShapeIDs = [box1.id]

    return LayerPanel(viewModel: vm)
        .frame(height: 300)
}
