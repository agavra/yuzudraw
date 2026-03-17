import os
import SwiftUI
import UniformTypeIdentifiers

private let layerPanelLog = OSLog(subsystem: "com.yuzudraw", category: "LayerPanel")

private let indentStep: CGFloat = 14

private struct PanelIconButton: View {
    let systemName: String
    let help: String
    let action: () -> Void

    @State private var isButtonHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.caption2)
                .foregroundStyle(isButtonHovered ? .primary : .secondary)
        }
        .buttonStyle(.plain)
        .onHover { isButtonHovered = $0 }
        .help(help)
    }
}
private let dropMidlineY: CGFloat = 12

private enum DropEdge {
    case before
    case after
}

private enum PanelSelectionItem: Hashable {
    case group(UUID)
    case shape(UUID)
}

private struct PanelSelectionEntry {
    let item: PanelSelectionItem
    let representedShapeIDs: Set<UUID>
}

private func panelRowBackground(isSelected: Bool, isHovered: Bool) -> Color {
    if isSelected {
        return Color.accentColor.opacity(0.22)
    }
    return isHovered ? Color.gray.opacity(0.18) : Color.clear
}

struct LayerPanel: View {
    @Bindable var viewModel: EditorViewModel
    @State private var draggedShapeID: UUID?
    @State private var draggedGroupID: UUID?
    @State private var shapeDropTarget: (id: UUID, edge: DropEdge)?
    @State private var groupDropTarget: UUID?
    @State private var groupReorderTarget: (id: UUID, edge: DropEdge)?
    @State private var ignoreNextRowTap = false
    @State private var selectionAnchorItem: PanelSelectionItem?
    @FocusState private var isPanelFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            objectList
        }
        .frame(minWidth: 160, idealWidth: 200, maxWidth: 260)
        .focusable()
        .focused($isPanelFocused)
        .focusEffectDisabled()
        .onKeyPress(keys: [.delete, .deleteForward]) { press in
            handleDeleteKeyPress(forward: press.key == .deleteForward)
        }
        .onKeyPress(characters: .init(charactersIn: "\u{8}\u{7f}")) { press in
            handleDeleteKeyPress(forward: press.characters == "\u{7f}")
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Objects")
                .font(.headline)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private var selectedSingleShapeID: UUID? {
        guard viewModel.selectedShapeIDs.count == 1 else { return nil }
        return viewModel.selectedShapeIDs.first
    }

    private var visibleSelectionEntries: [PanelSelectionEntry] {
        var entries: [PanelSelectionEntry] = []
        for item in viewModel.document.orderedItems.reversed() {
            appendVisibleEntries(for: item, to: &entries)
        }
        return entries
    }

    private var objectList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.document.orderedItems.reversed()), id: \.id) { item in
                    switch item {
                    case .group(let group):
                        GroupRow(
                            group: group,
                            viewModel: viewModel,
                            ignoreNextRowTap: $ignoreNextRowTap,
                            draggedShapeID: $draggedShapeID,
                            draggedGroupID: $draggedGroupID,
                            shapeDropTarget: $shapeDropTarget,
                            groupDropTarget: $groupDropTarget,
                            groupReorderTarget: $groupReorderTarget,
                            onSelect: { item, representedShapeIDs in
                                applyPanelSelection(
                                    for: item,
                                    representedShapeIDs: representedShapeIDs
                                )
                            },
                            depth: 0
                        )
                    case .shape(let shape):
                        ShapeRow(
                            shape: shape,
                            containingGroupID: nil,
                            viewModel: viewModel,
                            draggedShapeID: $draggedShapeID,
                            draggedGroupID: $draggedGroupID,
                            shapeDropTarget: $shapeDropTarget,
                            onSelect: { item, representedShapeIDs in
                                applyPanelSelection(
                                    for: item,
                                    representedShapeIDs: representedShapeIDs
                                )
                            },
                            depth: 0
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dismissInlineRenameFocus()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                dismissInlineRenameFocus()
            }
        )
        .contextMenu {
            ReorderContextMenu(viewModel: viewModel, shapeID: selectedSingleShapeID)
        }
    }

    private func appendVisibleEntries(
        for item: DocumentItem,
        to entries: inout [PanelSelectionEntry]
    ) {
        switch item {
        case .group(let group):
            entries.append(
                PanelSelectionEntry(
                    item: .group(group.id),
                    representedShapeIDs: Set(group.allShapeIDs)
                )
            )
            guard viewModel.expandedItemIDs.contains(group.id) else { return }
            appendVisibleEntries(for: group, to: &entries)
        case .shape(let shape):
            entries.append(
                PanelSelectionEntry(
                    item: .shape(shape.id),
                    representedShapeIDs: [shape.id]
                )
            )
        }
    }

    private func appendVisibleEntries(
        for group: ShapeGroup,
        to entries: inout [PanelSelectionEntry]
    ) {
        for child in group.children {
            entries.append(
                PanelSelectionEntry(
                    item: .group(child.id),
                    representedShapeIDs: Set(child.allShapeIDs)
                )
            )
            if viewModel.expandedItemIDs.contains(child.id) {
                appendVisibleEntries(for: child, to: &entries)
            }
        }

        let directShapeIDs = Set(group.shapeIDs)
        for shapeID in viewModel.document.shapes.map(\.id).reversed()
        where directShapeIDs.contains(shapeID) {
            entries.append(
                PanelSelectionEntry(
                    item: .shape(shapeID),
                    representedShapeIDs: [shapeID]
                )
            )
        }
    }

    private func applyPanelSelection(
        for item: PanelSelectionItem,
        representedShapeIDs: Set<UUID>
    ) {
        let selectableShapeIDs = Set(representedShapeIDs.filter { viewModel.document.isShapeSelectable($0) })
        guard !selectableShapeIDs.isEmpty else {
            viewModel.selectedShapeIDs = []
            selectionAnchorItem = nil
            return
        }

        let modifiers = NSApp.currentEvent?.modifierFlags ?? []
        let isShift = modifiers.contains(.shift)
        let isCommand = modifiers.contains(.command)

        let nextSelection: Set<UUID>
        if isShift {
            nextSelection = rangeSelectionShapeIDs(
                from: selectionAnchorItem,
                to: item,
                fallback: selectableShapeIDs
            )
        } else if isCommand {
            nextSelection = viewModel.selectedShapeIDs.symmetricDifference(selectableShapeIDs)
        } else {
            nextSelection = selectableShapeIDs
        }

        viewModel.selectedShapeIDs = nextSelection
        selectionAnchorItem = item
        isPanelFocused = true
    }

    private func rangeSelectionShapeIDs(
        from anchor: PanelSelectionItem?,
        to item: PanelSelectionItem,
        fallback: Set<UUID>
    ) -> Set<UUID> {
        guard let anchor else { return fallback }
        let entries = visibleSelectionEntries
        guard let anchorIndex = entries.firstIndex(where: { $0.item == anchor }),
              let targetIndex = entries.firstIndex(where: { $0.item == item })
        else {
            return fallback
        }
        let lower = min(anchorIndex, targetIndex)
        let upper = max(anchorIndex, targetIndex)
        let ids = Set(entries[lower...upper].flatMap(\.representedShapeIDs))
        return Set(ids.filter { viewModel.document.isShapeSelectable($0) })
    }

    private func dismissInlineRenameFocus() {
        NSApp.keyWindow?.makeFirstResponder(nil)
    }

    private func handleDeleteKeyPress(forward: Bool) -> KeyPress.Result {
        let selector =
            forward
            ? #selector(NSResponder.deleteForward(_:))
            : #selector(NSResponder.deleteBackward(_:))
        if NSApp.sendAction(selector, to: nil, from: nil) {
            return .handled
        }
        guard viewModel.canCutSelectedShapes() else { return .ignored }
        viewModel.deleteSelectedShapes()
        return .handled
    }
}

private struct GroupRow: View {
    let group: ShapeGroup
    @Bindable var viewModel: EditorViewModel
    @Binding var ignoreNextRowTap: Bool
    @Binding var draggedShapeID: UUID?
    @Binding var draggedGroupID: UUID?
    @Binding var shapeDropTarget: (id: UUID, edge: DropEdge)?
    @Binding var groupDropTarget: UUID?
    @Binding var groupReorderTarget: (id: UUID, edge: DropEdge)?
    let onSelect: (PanelSelectionItem, Set<UUID>) -> Void
    let depth: Int
    @State private var isEditingName = false
    @State private var draftName = ""
    @State private var isHovered = false
    @FocusState private var nameFieldFocused: Bool

    private var orderedGroupShapeIDs: [UUID] {
        os_signpost(
            .begin, log: layerPanelLog, name: "orderedGroupShapeIDs",
            "%{public}s members=%d docShapes=%d", group.name, group.shapeIDs.count,
            viewModel.document.shapes.count)
        let memberIDs = Set(group.shapeIDs)
        let result = Array(
            viewModel.document.shapes.map(\.id).filter { memberIDs.contains($0) }.reversed())
        os_signpost(.end, log: layerPanelLog, name: "orderedGroupShapeIDs")
        return result
    }

    private var isSelected: Bool {
        os_signpost(
            .begin, log: layerPanelLog, name: "GroupRow.isSelected", "%{public}s", group.name)
        let groupShapeIDs = Set(group.allShapeIDs)
        let result = !groupShapeIDs.isEmpty
            && groupShapeIDs.isSubset(of: viewModel.selectedShapeIDs)
        os_signpost(.end, log: layerPanelLog, name: "GroupRow.isSelected")
        return result
    }

    private var selectedSingleShapeID: UUID? {
        guard viewModel.selectedShapeIDs.count == 1 else { return nil }
        return viewModel.selectedShapeIDs.first
    }

    private var isHidden: Bool {
        viewModel.isGroupHiddenInPanel(group.id)
    }

    private var isLocked: Bool {
        viewModel.isGroupLockedInPanel(group.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let _ = os_signpost(
                .event, log: layerPanelLog, name: "GroupRow.body", "%{public}s depth=%d",
                group.name, depth)
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
                if isEditingName {
                    TextField("Group name", text: $draftName)
                        .textFieldStyle(.plain)
                        .font(.caption)
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
                            commitRename()
                        }
                        .onChange(of: nameFieldFocused) { _, isFocused in
                            if !isFocused, isEditingName {
                                commitRename()
                            }
                        }
                        .onExitCommand {
                            cancelRename()
                        }
                } else {
                    Text(group.name)
                        .font(.caption)
                        .lineLimit(1)
                        .opacity(isHidden ? 0.55 : 1)
                }
                Spacer(minLength: 0)
                if isHovered || isHidden || isLocked {
                    HStack(spacing: 6) {
                        if isHovered || isHidden {
                            PanelIconButton(
                                systemName: isHidden ? "eye.slash" : "eye",
                                help: isHidden ? "Show group" : "Hide group"
                            ) {
                                viewModel.toggleGroupHiddenFromPanel(group.id)
                            }
                        }
                        if isHovered || isLocked {
                            PanelIconButton(
                                systemName: isLocked ? "lock" : "lock.open",
                                help: isLocked ? "Unlock group" : "Lock group"
                            ) {
                                viewModel.toggleGroupLockedFromPanel(group.id)
                            }
                        }
                    }
                    .padding(.trailing, 4)
                }
            }
            .padding(.leading, CGFloat(depth) * indentStep)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                panelRowBackground(isSelected: isSelected, isHovered: isHovered)
            )
            .cornerRadius(3)
            .onHover { isHovered = $0 }
            .onTapGesture {
                if isEditingName {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    return
                }
                guard !isHidden, !isLocked else { return }
                guard !ignoreNextRowTap else {
                    ignoreNextRowTap = false
                    return
                }
                let groupIDs = Set(group.allShapeIDs)
                viewModel.enteredGroupID = nil
                onSelect(.group(group.id), groupIDs)
            }
            .onTapGesture(count: 2) {
                guard !isHidden, !isLocked else { return }
                beginRename()
            }
            .onDrag {
                draggedGroupID = group.id
                return NSItemProvider(object: "group:\(group.id.uuidString)" as NSString)
            }
            .onDrop(
                of: [UTType.text],
                delegate: GroupDropDelegate(
                    targetGroupID: group.id,
                    draggedShapeID: $draggedShapeID,
                    draggedGroupID: $draggedGroupID,
                    groupDropTarget: $groupDropTarget,
                    groupReorderTarget: $groupReorderTarget,
                    viewModel: viewModel
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .opacity(groupDropTarget == group.id ? 1 : 0)
            )
            .overlay(alignment: .top) {
                if draggedGroupID != nil, groupReorderTarget?.id == group.id,
                    groupReorderTarget?.edge == .before
                {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 2)
                }
            }
            .overlay(alignment: .bottom) {
                if draggedGroupID != nil, groupReorderTarget?.id == group.id,
                    groupReorderTarget?.edge == .after
                {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 2)
                }
            }
            .contextMenu {
                Button("Ungroup") {
                    // Select all shapes in this group, then ungroup
                    let groupIDs = Set(group.allShapeIDs)
                    viewModel.selectedShapeIDs = groupIDs
                    viewModel.ungroupSelectedShapes()
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                .disabled(isHidden || isLocked)

                Divider()

                Button("Rename") {
                    beginRename()
                }
                .disabled(isHidden || isLocked)

                Divider()

                GroupReorderContextMenu(viewModel: viewModel, groupID: group.id)
            }

            let isGroupExpanded = viewModel.expandedItemIDs.contains(group.id)
            Group {
                ForEach(group.children) { child in
                    GroupRow(
                        group: child,
                        viewModel: viewModel,
                        ignoreNextRowTap: $ignoreNextRowTap,
                        draggedShapeID: $draggedShapeID,
                        draggedGroupID: $draggedGroupID,
                        shapeDropTarget: $shapeDropTarget,
                        groupDropTarget: $groupDropTarget,
                        groupReorderTarget: $groupReorderTarget,
                        onSelect: onSelect,
                        depth: depth + 1
                    )
                }
                ForEach(orderedGroupShapeIDs, id: \.self) { shapeID in
                    if let shape = viewModel.document.findShape(id: shapeID) {
                        ShapeRow(
                            shape: shape,
                            containingGroupID: group.id,
                            viewModel: viewModel,
                            draggedShapeID: $draggedShapeID,
                            draggedGroupID: $draggedGroupID,
                            shapeDropTarget: $shapeDropTarget,
                            onSelect: onSelect,
                            depth: depth + 1
                        )
                    }
                }
            }
            .frame(maxHeight: isGroupExpanded ? .infinity : 0)
            .clipped()
            .opacity(isGroupExpanded ? 1 : 0)
        }
    }

    private func beginRename() {
        draftName = group.name
        isEditingName = true
        DispatchQueue.main.async {
            nameFieldFocused = true
        }
    }

    private func commitRename() {
        viewModel.renameGroupFromPanel(group.id, to: draftName)
        isEditingName = false
    }

    private func cancelRename() {
        isEditingName = false
        draftName = group.name
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
        .contentShape(Rectangle())
        .frame(width: 20, height: 20)
    }
}

private struct ShapeRow: View {
    let shape: AnyShape
    let containingGroupID: UUID?
    @Bindable var viewModel: EditorViewModel
    @Binding var draggedShapeID: UUID?
    @Binding var draggedGroupID: UUID?
    @Binding var shapeDropTarget: (id: UUID, edge: DropEdge)?
    let onSelect: (PanelSelectionItem, Set<UUID>) -> Void
    let depth: Int
    @State private var isEditingName = false
    @State private var draftName = ""
    @State private var isHovered = false
    @FocusState private var nameFieldFocused: Bool

    private var isHidden: Bool {
        viewModel.isShapeHiddenInPanel(shape.id)
    }

    private var isLocked: Bool {
        viewModel.isShapeLockedInPanel(shape.id)
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: shapeTypeIcon)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 12)
            if isEditingName {
                TextField("Item name", text: $draftName)
                    .textFieldStyle(.plain)
                    .font(.caption)
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
                        commitRename()
                    }
                    .onChange(of: nameFieldFocused) { _, isFocused in
                        if !isFocused, isEditingName {
                            commitRename()
                        }
                    }
                    .onExitCommand {
                        cancelRename()
                    }
            } else {
                Text(shape.displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .opacity(isHidden ? 0.55 : 1)
            }
            Spacer()
            if isHovered || isHidden || isLocked {
                HStack(spacing: 6) {
                    if isHovered || isHidden {
                        PanelIconButton(
                            systemName: isHidden ? "eye.slash" : "eye",
                            help: isHidden ? "Show item" : "Hide item"
                        ) {
                            viewModel.toggleShapeHiddenFromPanel(shape.id)
                        }
                    }
                    if isHovered || isLocked {
                        PanelIconButton(
                            systemName: isLocked ? "lock" : "lock.open",
                            help: isLocked ? "Unlock item" : "Lock item"
                        ) {
                            viewModel.toggleShapeLockedFromPanel(shape.id)
                        }
                    }
                }
                .padding(.trailing, 4)
            }
        }
        .padding(.leading, CGFloat(depth) * indentStep + 12)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(
            panelRowBackground(
                isSelected: viewModel.selectedShapeIDs.contains(shape.id),
                isHovered: isHovered
            )
        )
        .cornerRadius(3)
        .onHover { isHovered = $0 }
        .onTapGesture {
            if isEditingName {
                NSApp.keyWindow?.makeFirstResponder(nil)
                return
            }
            guard !isHidden, !isLocked else { return }
            // If the shape is inside a group, set enteredGroupID to the innermost containing group
            if let rootGroup = viewModel.document.findRootGroup(containingShape: shape.id) {
                let ancestry = viewModel.document.findGroupAncestry(containingShape: shape.id)
                // Set to the innermost group that directly contains this shape
                if let innermostGroup = ancestry.last(where: { $0.shapeIDs.contains(shape.id) }) {
                    viewModel.enteredGroupID = innermostGroup.id
                } else {
                    viewModel.enteredGroupID = rootGroup.id
                }
            } else {
                viewModel.enteredGroupID = nil
            }
            onSelect(.shape(shape.id), [shape.id])
        }
        .onTapGesture(count: 2) {
            guard !isHidden, !isLocked else { return }
            beginRename()
        }
        .onDrag {
            draggedShapeID = shape.id
            return NSItemProvider(object: "shape:\(shape.id.uuidString)" as NSString)
        }
        .onDrop(
            of: [UTType.text],
            delegate: ShapeDropDelegate(
                targetShapeID: shape.id,
                targetGroupID: containingGroupID,
                draggedShapeID: $draggedShapeID,
                draggedGroupID: $draggedGroupID,
                dropTargetShape: $shapeDropTarget,
                viewModel: viewModel
            )
        )
        .contextMenu {
            ReorderContextMenu(viewModel: viewModel, shapeID: shape.id)
        }
        .overlay(alignment: .top) {
            if (draggedShapeID != nil || draggedGroupID != nil),
                shapeDropTarget?.id == shape.id, shapeDropTarget?.edge == .before
            {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
            }
        }
        .overlay(alignment: .bottom) {
            if (draggedShapeID != nil || draggedGroupID != nil),
                shapeDropTarget?.id == shape.id, shapeDropTarget?.edge == .after
            {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 2)
            }
        }
    }

    private func beginRename() {
        draftName = shape.displayName
        isEditingName = true
        DispatchQueue.main.async {
            nameFieldFocused = true
        }
    }

    private func commitRename() {
        viewModel.renameShapeFromPanel(shape.id, to: draftName)
        isEditingName = false
    }

    private func cancelRename() {
        isEditingName = false
        draftName = shape.displayName
    }

    private var shapeTypeIcon: String {
        switch shape {
        case .rectangle: return "rectangle"
        case .arrow: return "arrow.right"
        case .text: return "textformat"
        case .pencil: return "pencil"
        }
    }
}

private struct ReorderContextMenu: View {
    let viewModel: EditorViewModel
    let shapeID: UUID?

    private var canMoveBack: Bool {
        guard let shapeID else { return false }
        return viewModel.canMoveShapeBackward(shapeID)
    }

    private var canMoveFront: Bool {
        guard let shapeID else { return false }
        return viewModel.canMoveShapeForward(shapeID)
    }

    var body: some View {
        Button("Bring to Front") {
            guard let shapeID else { return }
            viewModel.moveShapeToFront(shapeID)
        }
        .keyboardShortcut("]", modifiers: [])
        .disabled(!canMoveFront)

        Button("Send to Back") {
            guard let shapeID else { return }
            viewModel.moveShapeToBack(shapeID)
        }
        .keyboardShortcut("[", modifiers: [])
        .disabled(!canMoveBack)

        Divider()

        Button("Bring Forward") {
            guard let shapeID else { return }
            viewModel.moveShapeForward(shapeID)
        }
        .keyboardShortcut("]", modifiers: .command)
        .disabled(!canMoveFront)

        Button("Send Backward") {
            guard let shapeID else { return }
            viewModel.moveShapeBackward(shapeID)
        }
        .keyboardShortcut("[", modifiers: .command)
        .disabled(!canMoveBack)
    }
}

private struct GroupReorderContextMenu: View {
    let viewModel: EditorViewModel
    let groupID: UUID

    private var canMoveBack: Bool {
        viewModel.canMoveGroupBackward(groupID)
    }

    private var canMoveFront: Bool {
        viewModel.canMoveGroupForward(groupID)
    }

    var body: some View {
        Button("Bring to Front") {
            viewModel.moveGroupToFront(groupID)
        }
        .disabled(!canMoveFront)

        Button("Send to Back") {
            viewModel.moveGroupToBack(groupID)
        }
        .disabled(!canMoveBack)

        Divider()

        Button("Bring Forward") {
            viewModel.moveGroupForward(groupID)
        }
        .disabled(!canMoveFront)

        Button("Send Backward") {
            viewModel.moveGroupBackward(groupID)
        }
        .disabled(!canMoveBack)
    }
}

private struct ShapeDropDelegate: DropDelegate {
    let targetShapeID: UUID
    let targetGroupID: UUID?
    @Binding var draggedShapeID: UUID?
    @Binding var draggedGroupID: UUID?
    @Binding var dropTargetShape: (id: UUID, edge: DropEdge)?
    let viewModel: EditorViewModel

    func dropEntered(info: DropInfo) {
        guard draggedShapeID != nil || draggedGroupID != nil else { return }
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetShape = (targetShapeID, edge)
    }

    func dropExited(info _: DropInfo) {
        if dropTargetShape?.id == targetShapeID {
            dropTargetShape = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard draggedShapeID != nil || draggedGroupID != nil else {
            return DropProposal(operation: .move)
        }
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
        dropTargetShape = (targetShapeID, edge)
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after

        // Handle group-on-shape reordering
        if let draggedGroupID {
            // Shape rows are shown top->bottom, but model order is bottom->top.
            if edge == .before {
                viewModel.moveGroup(
                    draggedGroupID: draggedGroupID, afterShape: targetShapeID)
            } else {
                viewModel.moveGroup(
                    draggedGroupID: draggedGroupID, beforeShape: targetShapeID)
            }
            self.draggedGroupID = nil
            dropTargetShape = nil
            return true
        }

        guard draggedShapeID != nil else { return false }
        if let draggedShapeID, draggedShapeID != targetShapeID {
            // Shape rows are shown top->bottom, but model order is bottom->top.
            if edge == .before {
                viewModel.moveShape(draggedShapeID: draggedShapeID, after: targetShapeID)
            } else {
                viewModel.moveShape(draggedShapeID: draggedShapeID, before: targetShapeID)
            }
            // Update group membership to match drop target's context
            if let targetGroupID {
                viewModel.moveShapeToGroup(shapeID: draggedShapeID, groupID: targetGroupID)
            } else {
                viewModel.removeShapeFromGroup(shapeID: draggedShapeID)
            }
        }
        draggedShapeID = nil
        dropTargetShape = nil
        return true
    }
}

private struct GroupDropDelegate: DropDelegate {
    let targetGroupID: UUID
    @Binding var draggedShapeID: UUID?
    @Binding var draggedGroupID: UUID?
    @Binding var groupDropTarget: UUID?
    @Binding var groupReorderTarget: (id: UUID, edge: DropEdge)?
    let viewModel: EditorViewModel

    func dropEntered(info: DropInfo) {
        if draggedGroupID != nil {
            let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
            groupReorderTarget = (targetGroupID, edge)
        } else {
            groupDropTarget = targetGroupID
        }
    }

    func dropExited(info _: DropInfo) {
        if groupDropTarget == targetGroupID {
            groupDropTarget = nil
        }
        if groupReorderTarget?.id == targetGroupID {
            groupReorderTarget = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        if draggedGroupID != nil {
            let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
            groupReorderTarget = (targetGroupID, edge)
        } else {
            groupDropTarget = targetGroupID
        }
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        // Handle group-on-group reordering
        if let draggedGroupID, draggedGroupID != targetGroupID {
            let edge: DropEdge = info.location.y < dropMidlineY ? .before : .after
            // Group rows are shown top->bottom, but model order is bottom->top.
            if edge == .before {
                viewModel.moveGroup(
                    draggedGroupID: draggedGroupID, afterGroup: targetGroupID)
            } else {
                viewModel.moveGroup(
                    draggedGroupID: draggedGroupID, beforeGroup: targetGroupID)
            }
            self.draggedGroupID = nil
            groupReorderTarget = nil
            return true
        }

        // Handle shape-into-group
        guard let draggedShapeID else { return false }
        // Don't drop a shape that's already a direct member of this group
        if let group = viewModel.document.groups.first(where: { $0.id == targetGroupID }),
            group.shapeIDs.contains(draggedShapeID)
        {
            self.draggedShapeID = nil
            groupDropTarget = nil
            return false
        }
        viewModel.moveShapeToGroup(shapeID: draggedShapeID, groupID: targetGroupID)
        self.draggedShapeID = nil
        groupDropTarget = nil
        return true
    }
}

#Preview {
    let vm = EditorViewModel()
    let rect1 = RectangleShape(
        origin: GridPoint(column: 5, row: 3),
        size: GridSize(width: 20, height: 5),
        label: "Server"
    )
    let rect2 = RectangleShape(
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
    vm.document = Document(
        shapes: [.rectangle(rect1), .rectangle(rect2), .arrow(arrow), .text(text)],
        groups: [ShapeGroup(name: "Backend", shapeIDs: [rect1.id, rect2.id])]
    )
    vm.selectedShapeIDs = [rect1.id]

    return LayerPanel(viewModel: vm)
        .frame(height: 300)
}
