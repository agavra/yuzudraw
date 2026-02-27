import SwiftUI
import UniformTypeIdentifiers

private let indentStep: CGFloat = 14
private let dropMidlineY: CGFloat = 12

private enum DropEdge {
    case before
    case after
}

struct LayerPanel: View {
    @Bindable var viewModel: EditorViewModel
    @State private var draggedLayerID: UUID?
    @State private var draggedShapeID: UUID?
    @State private var layerDropTarget: (id: UUID, edge: DropEdge)?
    @State private var shapeDropTarget: (id: UUID, edge: DropEdge)?
    @State private var explicitlySelectedLayerID: UUID?
    @State private var ignoreNextRowTap = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            layerList
            Divider()
            bottomButtons
        }
        .frame(minWidth: 160, idealWidth: 200, maxWidth: 260)
        .onChange(of: viewModel.selectedShapeIDs) { _, newSelection in
            guard let layerID = explicitlySelectedLayerID,
                let layer = viewModel.document.layers.first(where: { $0.id == layerID })
            else {
                explicitlySelectedLayerID = nil
                return
            }

            let layerSelection = Set(layer.shapes.map(\.id))
            if newSelection != layerSelection {
                explicitlySelectedLayerID = nil
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Layers")
                .font(.headline)

            Spacer()

            Button {
                viewModel.moveSelectedShapeForward()
            } label: {
                Image(systemName: "arrow.up")
            }
            .buttonStyle(.plain)
            .help("Move selected element up")
            .disabled(!canMoveSelectedElementUp)

            Button {
                viewModel.moveSelectedShapeBackward()
            } label: {
                Image(systemName: "arrow.down")
            }
            .buttonStyle(.plain)
            .help("Move selected element down")
            .disabled(!canMoveSelectedElementDown)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private var singleSelectedShapeID: UUID? {
        guard viewModel.selectedShapeIDs.count == 1 else { return nil }
        return viewModel.selectedShapeIDs.first
    }

    private var canMoveSelectedElementUp: Bool {
        guard let shapeID = singleSelectedShapeID else { return false }
        return viewModel.canMoveShapeForward(shapeID)
    }

    private var canMoveSelectedElementDown: Bool {
        guard let shapeID = singleSelectedShapeID else { return false }
        return viewModel.canMoveShapeBackward(shapeID)
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
            HStack(spacing: 2) {
                chevron(isExpanded: viewModel.expandedItemIDs.contains(layer.id)) {
                    ignoreNextRowTap = true
                    viewModel.toggleExpanded(layer.id)
                    DispatchQueue.main.async {
                        ignoreNextRowTap = false
                    }
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
            .background(
                explicitlySelectedLayerID == layer.id
                    ? Color.accentColor.opacity(0.2)
                    : Color.clear
            )
            .cornerRadius(3)
            .onTapGesture {
                guard !ignoreNextRowTap else {
                    ignoreNextRowTap = false
                    return
                }
                viewModel.activeLayerIndex = index
                viewModel.selectedShapeIDs = Set(layer.shapes.map(\.id))
                explicitlySelectedLayerID = layer.id
            }
            .onDrag {
                draggedLayerID = layer.id
                return NSItemProvider(object: "layer:\(layer.id.uuidString)" as NSString)
            }
            .onDrop(
                of: [UTType.text],
                delegate: LayerDropDelegate(
                    targetLayerID: layer.id,
                    draggedLayerID: $draggedLayerID,
                    draggedShapeID: $draggedShapeID,
                    dropTargetLayer: $layerDropTarget,
                    viewModel: viewModel
                )
            )

            if viewModel.expandedItemIDs.contains(layer.id) {
                ForEach(layer.groups) { group in
                    GroupRow(
                        group: group,
                        layer: layer,
                        viewModel: viewModel,
                        ignoreNextRowTap: $ignoreNextRowTap,
                        draggedShapeID: $draggedShapeID,
                        shapeDropTarget: $shapeDropTarget,
                        depth: 1
                    )
                }
                ForEach(Array(layer.ungroupedShapes.reversed())) { shape in
                    ShapeRow(
                        shape: shape,
                        layerID: layer.id,
                        viewModel: viewModel,
                        draggedShapeID: $draggedShapeID,
                        shapeDropTarget: $shapeDropTarget,
                        depth: 1
                    )
                }
            }
        }
        .overlay(alignment: .top) {
            if draggedLayerID != nil, layerDropTarget?.id == layer.id, layerDropTarget?.edge == .before {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
            }
        }
        .overlay(alignment: .bottom) {
            if draggedLayerID != nil, layerDropTarget?.id == layer.id, layerDropTarget?.edge == .after {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
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
    @Binding var ignoreNextRowTap: Bool
    @Binding var draggedShapeID: UUID?
    @Binding var shapeDropTarget: (id: UUID, edge: DropEdge)?
    let depth: Int

    private var orderedGroupShapeIDs: [UUID] {
        let memberIDs = Set(group.shapeIDs)
        return layer.shapes.map(\.id).filter { memberIDs.contains($0) }.reversed()
    }

    private var isSelected: Bool {
        let groupShapeIDs = Set(group.allShapeIDs)
        return !groupShapeIDs.isEmpty && groupShapeIDs.isSubset(of: viewModel.selectedShapeIDs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 2) {
                chevron(isExpanded: viewModel.expandedItemIDs.contains(group.id)) {
                    ignoreNextRowTap = true
                    viewModel.toggleExpanded(group.id)
                    DispatchQueue.main.async {
                        ignoreNextRowTap = false
                    }
                }
                Image(systemName: "folder")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(group.name)
                    .font(.caption)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.leading, CGFloat(depth) * indentStep)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.2)
                    : Color.clear
            )
            .cornerRadius(3)
            .onTapGesture {
                guard !ignoreNextRowTap else {
                    ignoreNextRowTap = false
                    return
                }
                viewModel.selectedShapeIDs = Set(group.allShapeIDs)
                if let layerIndex = viewModel.document.layers.firstIndex(where: { $0.id == layer.id }) {
                    viewModel.activeLayerIndex = layerIndex
                }
            }

            if viewModel.expandedItemIDs.contains(group.id) {
                ForEach(group.children) { child in
                    GroupRow(
                        group: child,
                        layer: layer,
                        viewModel: viewModel,
                        ignoreNextRowTap: $ignoreNextRowTap,
                        draggedShapeID: $draggedShapeID,
                        shapeDropTarget: $shapeDropTarget,
                        depth: depth + 1
                    )
                }
                ForEach(orderedGroupShapeIDs, id: \.self) { shapeID in
                    if let shape = layer.findShape(id: shapeID) {
                        ShapeRow(
                            shape: shape,
                            layerID: layer.id,
                            viewModel: viewModel,
                            draggedShapeID: $draggedShapeID,
                            shapeDropTarget: $shapeDropTarget,
                            depth: depth + 1
                        )
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
    let layerID: UUID
    @Bindable var viewModel: EditorViewModel
    @Binding var draggedShapeID: UUID?
    @Binding var shapeDropTarget: (id: UUID, edge: DropEdge)?
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
        .onDrag {
            draggedShapeID = shape.id
            return NSItemProvider(object: "shape:\(shape.id.uuidString)" as NSString)
        }
        .onDrop(
            of: [UTType.text],
            delegate: ShapeDropDelegate(
                targetShapeID: shape.id,
                layerID: layerID,
                draggedShapeID: $draggedShapeID,
                dropTargetShape: $shapeDropTarget,
                viewModel: viewModel
            )
        )
        .overlay(alignment: .top) {
            if draggedShapeID != nil, shapeDropTarget?.id == shape.id, shapeDropTarget?.edge == .before {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
            }
        }
        .overlay(alignment: .bottom) {
            if draggedShapeID != nil, shapeDropTarget?.id == shape.id, shapeDropTarget?.edge == .after {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
            }
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

private struct LayerDropDelegate: DropDelegate {
    let targetLayerID: UUID
    @Binding var draggedLayerID: UUID?
    @Binding var draggedShapeID: UUID?
    @Binding var dropTargetLayer: (id: UUID, edge: DropEdge)?
    let viewModel: EditorViewModel

    func dropEntered(info: DropInfo) {
        guard draggedLayerID != nil else { return }
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetLayer = (targetLayerID, edge)
    }

    func dropExited(info _: DropInfo) {
        if dropTargetLayer?.id == targetLayerID {
            dropTargetLayer = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard draggedLayerID != nil else { return DropProposal(operation: .move) }
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetLayer = (targetLayerID, edge)
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard draggedLayerID != nil || draggedShapeID != nil else { return false }
        if let draggedLayerID, draggedLayerID != targetLayerID {
            let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
            // Layer rows are shown top->bottom, but model order is bottom->top.
            if edge == .before {
                viewModel.moveLayer(draggedLayerID: draggedLayerID, after: targetLayerID)
            } else {
                viewModel.moveLayer(draggedLayerID: draggedLayerID, before: targetLayerID)
            }
        }
        if let draggedShapeID {
            viewModel.moveShape(draggedShapeID: draggedShapeID, toLayer: targetLayerID)
        }
        draggedLayerID = nil
        draggedShapeID = nil
        dropTargetLayer = nil
        return true
    }
}

private struct ShapeDropDelegate: DropDelegate {
    let targetShapeID: UUID
    let layerID: UUID
    @Binding var draggedShapeID: UUID?
    @Binding var dropTargetShape: (id: UUID, edge: DropEdge)?
    let viewModel: EditorViewModel

    func dropEntered(info: DropInfo) {
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetShape = (targetShapeID, edge)
    }

    func dropExited(info _: DropInfo) {
        if dropTargetShape?.id == targetShapeID {
            dropTargetShape = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetShape = (targetShapeID, edge)
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard draggedShapeID != nil else { return false }
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        if let draggedShapeID, draggedShapeID != targetShapeID {
            // Shape rows are shown top->bottom, but model order is bottom->top.
            if edge == .before {
                viewModel.moveShape(draggedShapeID: draggedShapeID, after: targetShapeID, in: layerID)
            } else {
                viewModel.moveShape(draggedShapeID: draggedShapeID, before: targetShapeID, in: layerID)
            }
        }
        draggedShapeID = nil
        dropTargetShape = nil
        return true
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
