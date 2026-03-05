import SwiftUI

enum ColorTarget: Hashable {
    case rectangleBorder
    case rectangleFill
    case rectangleText
    case arrowStroke
    case arrowLabel
    case textColor
    case pencilColor
    case pencilToolColor
    case layerFill
    case layerBorder
    case layerText
    case exportBackground
    case multiSelectRectBorder
    case multiSelectRectFill
    case multiSelectRectText
    case multiSelectArrowStroke
    case multiSelectArrowLabel
    case multiSelectBorderStroke
    case multiSelectText
}

@MainActor
@Observable
final class EditorViewModel {
    private struct ShapeClipboardPayload: Codable, Sendable {
        var shapes: [AnyShape]
    }

    private static let shapeClipboardType = NSPasteboard.PasteboardType("com.yuzudraw.shapes+json")
    private static let pasteOffset = GridPoint(column: 2, row: 1)

    var document: Document
    var canvas: Canvas
    var selectedShapeIDs: Set<UUID> = [] {
        didSet {
            clearSelectedLayerIfNeeded()
        }
    }
    var selectedLayerID: UUID?
    var activeToolType: ToolType = .select {
        didSet {
            if activeToolType != oldValue {
                enteredGroupID = nil
            }
        }
    }
    var activeLayerIndex: Int = 0
    var expandedItemIDs: Set<UUID> = []
    var isEditingText: Bool = false
    var textEditPoint: GridPoint?
    var textEditContent: String = ""
    var textEditShapeID: UUID?
    var viewportSize: CGSize = .zero
    var hoverGridPoint: GridPoint?
    var isOptionKeyPressed: Bool = false
    var isShiftKeyPressed: Bool = false
    var enteredGroupID: UUID?

    // MARK: - Undo/Redo
    private var undoStack: [Document] = []
    private var redoStack: [Document] = []
    private var isInDragOperation = false
    private static let maxUndoLevels = 50

    func recordSnapshot() {
        guard !isInDragOperation else { return }
        if undoStack.last == document { return }
        undoStack.append(document)
        if undoStack.count > Self.maxUndoLevels { undoStack.removeFirst() }
        redoStack.removeAll()
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(document)
        document = previous
        selectedShapeIDs = []
        enteredGroupID = nil
        rerender()
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(document)
        document = next
        selectedShapeIDs = []
        enteredGroupID = nil
        rerender()
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Color picker state
    var activeColorTarget: ColorTarget?
    var colorPickerCurrentColor: ShapeColor?
    var colorPickerAllowsNone: Bool = false
    var colorPickerOnColorSelected: ((ShapeColor?) -> Void)?

    func openColorPicker(
        target: ColorTarget,
        currentColor: ShapeColor?,
        allowsNone: Bool = false,
        onColorSelected: @escaping (ShapeColor?) -> Void
    ) {
        if activeColorTarget == target {
            closeColorPicker()
            return
        }
        activeColorTarget = target
        colorPickerCurrentColor = currentColor
        colorPickerAllowsNone = allowsNone
        colorPickerOnColorSelected = onColorSelected
    }

    func closeColorPicker() {
        activeColorTarget = nil
        colorPickerCurrentColor = nil
        colorPickerAllowsNone = false
        colorPickerOnColorSelected = nil
    }

    private var selectionTool = SelectionTool()
    private var rectangleTool = RectangleTool()
    private var arrowTool = ArrowTool()
    private var textTool = TextTool()
    private var pencilTool = PencilTool()
    private var lastPastedPayloadData: Data?
    private var consecutivePasteCount = 0

    var activeTool: any Tool {
        switch activeToolType {
        case .select: return selectionTool
        case .rectangle: return rectangleTool
        case .arrow: return arrowTool
        case .text: return textTool
        case .pencil: return pencilTool
        }
    }

    var arrowAttachmentPreviewPoints: [GridPoint] {
        switch activeToolType {
        case .arrow:
            return arrowTool.attachmentPreviewPoints(near: hoverGridPoint, in: document)
        case .select:
            return selectionTool.arrowAttachmentPreviewPoints
        case .rectangle, .text, .pencil:
            return []
        }
    }

    var isHoveringArrowAttachmentPoint: Bool {
        hoveredArrowAttachmentPoint != nil
    }

    var hoveredArrowAttachmentPoint: GridPoint? {
        guard activeToolType == .arrow, let hoverGridPoint else { return nil }
        return arrowAttachmentPreviewPoints.min { lhs, rhs in
            let lhsDistance = hypot(
                Double(lhs.column - hoverGridPoint.column),
                Double(lhs.row - hoverGridPoint.row)
            )
            let rhsDistance = hypot(
                Double(rhs.column - hoverGridPoint.column),
                Double(rhs.row - hoverGridPoint.row)
            )
            return lhsDistance < rhsDistance
        }.flatMap { previewPoint in
            let distance = hypot(
                Double(previewPoint.column - hoverGridPoint.column),
                Double(previewPoint.row - hoverGridPoint.row)
            ) <= 1.5
            return distance ? previewPoint : nil
        }
    }

    init(document: Document = Document()) {
        self.document = document
        self.canvas = Canvas(size: document.canvasSize)
        expandedItemIDs = Set(document.layers.map(\.id))
        rerender()
    }

    // MARK: - Mouse events

    func mouseDown(at point: GridPoint) {
        if activeColorTarget != nil {
            closeColorPicker()
        }
        if isEditingText {
            commitTextEdit()
        }
        arrowTool.suppressAttachment = isOptionKeyPressed
        selectionTool.selectedShapeIDs = selectedShapeIDs
        selectionTool.isShiftKeyPressed = isShiftKeyPressed

        // When pencil tool is active and a pencil shape is selected, append to it
        if activeToolType == .pencil {
            if let selectedID = selectedShapeIDs.first,
                selectedShapeIDs.count == 1,
                let shape = document.findShape(id: selectedID),
                case .pencil = shape
            {
                pencilTool.targetShapeID = selectedID
            } else {
                pencilTool.targetShapeID = nil
            }
        }

        recordSnapshot()
        isInDragOperation = true

        let action = activeTool.mouseDown(
            at: point, in: document, activeLayerIndex: activeLayerIndex)

        if activeToolType == .select {
            applyGroupAwareAction(action)
        } else {
            applyAction(action)
        }
    }

    func handleDoubleClick(at point: GridPoint) {
        guard let shape = document.hitTest(at: point) else { return }

        // Don't allow editing shapes on locked layers
        guard let layerIndex = document.layerIndex(containingShape: shape.id),
              !document.layers[layerIndex].isLocked
        else { return }

        let layer = document.layers[layerIndex]

        // Group handling: if shape is in a group, double-click enters the group
        if let rootGroup = layer.findRootGroup(containingShape: shape.id) {
            if enteredGroupID == nil {
                // Not entered yet — enter the root group, select the shape (or sub-group)
                enteredGroupID = rootGroup.id
                let resolved = resolveGroupSelection(forShapeID: shape.id)
                selectedShapeIDs = resolved.shapeIDs
                // If resolved to a single shape, start text editing
                if resolved.groupID == nil {
                    startTextEditForShape(shape)
                }
                return
            }

            // Already entered — check if we can drill deeper
            let ancestry = layer.findGroupAncestry(containingShape: shape.id)
            if let enteredIndex = ancestry.firstIndex(where: { $0.id == enteredGroupID }) {
                let enteredGroup = ancestry[enteredIndex]
                if let childGroup = enteredGroup.childGroup(containingShape: shape.id) {
                    // Drill into sub-group
                    enteredGroupID = childGroup.id
                    let resolved = resolveGroupSelection(forShapeID: shape.id)
                    selectedShapeIDs = resolved.shapeIDs
                    if resolved.groupID == nil {
                        startTextEditForShape(shape)
                    }
                    return
                }
            }
        }

        // At individual shape level (or ungrouped) — start text editing
        startTextEditForShape(shape)
    }

    private func startTextEditForShape(_ shape: AnyShape) {
        let editPoint: GridPoint
        let content: String

        switch shape {
        case .text(let text):
            editPoint = text.origin
            content = text.text
        case .rectangle(let rectangle):
            editPoint = rectangle.labelEditPoint
            content = rectangle.label
        case .arrow(let arrow):
            editPoint = arrow.labelEditPoint
            content = arrow.label
        case .pencil:
            return
        }

        isEditingText = true
        textEditShapeID = shape.id
        textEditPoint = editPoint
        textEditContent = content
        selectedShapeIDs = [shape.id]
    }

    func mouseDragged(to point: GridPoint) {
        arrowTool.suppressAttachment = isOptionKeyPressed
        if activeToolType == .arrow {
            hoverGridPoint = point
        }
        let action = activeTool.mouseDragged(
            to: point, in: document, activeLayerIndex: activeLayerIndex)
        applyAction(action)
        rerender()
    }

    func mouseUp(at point: GridPoint) {
        arrowTool.suppressAttachment = isOptionKeyPressed
        selectionTool.isShiftKeyPressed = isShiftKeyPressed
        let action = activeTool.mouseUp(
            at: point, in: document, activeLayerIndex: activeLayerIndex)

        if activeToolType == .select {
            applyGroupAwareAction(action)
        } else {
            applyAction(action)
        }

        isInDragOperation = false
        // Pop the undo snapshot if the drag didn't actually change the document
        if undoStack.last == document {
            undoStack.removeLast()
        }
    }

    func updateHoverGridPoint(_ point: GridPoint?) {
        hoverGridPoint = point
    }

    // MARK: - Grid coordinate conversion

    func gridPoint(from location: CGPoint, charSize: CGSize) -> GridPoint {
        GridPoint(
            column: max(0, Int(location.x / charSize.width)),
            row: max(0, Int(location.y / charSize.height))
        )
    }

    // MARK: - Tool actions

    private func applyAction(_ action: ToolAction) {
        switch action {
        case .none:
            break
        case .addShape(let shape, let layerIndex):
            document.addShape(shape, toLayerAt: layerIndex)
            selectedShapeIDs = [shape.id]
            if case .pencil = shape {
                // Stay in pencil mode so the user can keep drawing
            } else {
                activeToolType = .select
            }
            rerender()
        case .selectShape(let id):
            selectedShapeIDs = id.map { [$0] } ?? []
        case .selectShapes(let ids):
            selectedShapeIDs = ids
        case .moveShape(_, _):
            // Legacy - handled by updateShape now
            break
        case .beginTextEdit(let point):
            isEditingText = true
            textEditPoint = point
            textEditContent = ""
        case .updateShape(let shape):
            updateShapeAndAttachments(shape)
            rerender()
        case .updateShapes(let shapes):
            for shape in shapes {
                updateShapeAndAttachments(shape)
            }
            rerender()
        case .addShapeToSelection(let id):
            selectedShapeIDs.insert(id)
        case .removeShapeFromSelection(let id):
            selectedShapeIDs.remove(id)
        case .addShapesToSelection(let ids):
            selectedShapeIDs.formUnion(ids)
        }
    }

    // MARK: - Group-aware selection

    private func activeLayer() -> Layer? {
        guard document.layers.indices.contains(activeLayerIndex) else { return nil }
        return document.layers[activeLayerIndex]
    }

    func resolveGroupSelection(forShapeID shapeID: UUID) -> (shapeIDs: Set<UUID>, groupID: UUID?) {
        guard let layer = activeLayer() else {
            return ([shapeID], nil)
        }
        guard let rootGroup = layer.findRootGroup(containingShape: shapeID) else {
            return ([shapeID], nil)
        }
        guard let enteredGroupID else {
            return (rootGroup.allShapeIDs, rootGroup.id)
        }

        // Walk the ancestry to find the entered group, then resolve within it
        let ancestry = layer.findGroupAncestry(containingShape: shapeID)
        guard let enteredIndex = ancestry.firstIndex(where: { $0.id == enteredGroupID }) else {
            // Shape is not inside the entered group — select the root group
            return (rootGroup.allShapeIDs, rootGroup.id)
        }

        let enteredGroup = ancestry[enteredIndex]
        if let childGroup = enteredGroup.childGroup(containingShape: shapeID) {
            return (childGroup.allShapeIDs, childGroup.id)
        }
        return ([shapeID], nil)
    }

    private func isGroupSelected() -> ShapeGroup? {
        guard !selectedShapeIDs.isEmpty, let layer = activeLayer() else { return nil }
        for group in layer.groups {
            let groupIDs = group.allShapeIDs
            if !groupIDs.isEmpty, groupIDs == selectedShapeIDs {
                return group
            }
        }
        // Also check nested groups
        return findSelectedGroupRecursive(in: layer.groups)
    }

    private func findSelectedGroupRecursive(in groups: [ShapeGroup]) -> ShapeGroup? {
        for group in groups {
            let groupIDs = group.allShapeIDs
            if !groupIDs.isEmpty, groupIDs == selectedShapeIDs {
                return group
            }
            if let found = findSelectedGroupRecursive(in: group.children) {
                return found
            }
        }
        return nil
    }

    private func applyGroupAwareAction(_ action: ToolAction) {
        switch action {
        case .selectShape(nil):
            // Click on empty canvas: exit group, deselect
            enteredGroupID = nil
            applyAction(action)

        case .selectShape(let id?):
            guard let layer = activeLayer(),
                  let rootGroup = layer.findRootGroup(containingShape: id)
            else {
                // Ungrouped shape — clear group state, select normally
                enteredGroupID = nil
                applyAction(action)
                return
            }

            if enteredGroupID != nil, isAncestor(groupID: enteredGroupID!, of: id, in: layer) {
                // Already inside entered group — check if current selection matches a sub-group
                if let selectedSubGroup = findSelectedSubGroup(within: enteredGroupID!, in: layer),
                   selectedSubGroup.containsShape(id) {
                    // Selection matches a sub-group and we clicked inside it — drill into it
                    enteredGroupID = selectedSubGroup.id
                    let resolved = resolveGroupSelection(forShapeID: id)
                    selectedShapeIDs = resolved.shapeIDs
                } else {
                    // Resolve within the entered group
                    let resolved = resolveGroupSelection(forShapeID: id)
                    selectedShapeIDs = resolved.shapeIDs
                }
            } else if let currentGroup = isGroupSelected(), currentGroup.id == rootGroup.id || isAncestor(group: currentGroup, of: id, in: layer) {
                // Group (or ancestor) is already selected — enter group, select inner target
                enteredGroupID = currentGroup.id
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs = resolved.shapeIDs
            } else {
                // Group not selected — select entire root group
                enteredGroupID = nil
                selectedShapeIDs = rootGroup.allShapeIDs
            }

        case .addShapeToSelection(let id):
            guard let layer = activeLayer(),
                  let rootGroup = layer.findRootGroup(containingShape: id)
            else {
                applyAction(action)
                return
            }
            if enteredGroupID != nil {
                // Inside entered group, shift+click adds individual shape or sub-group
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs.formUnion(resolved.shapeIDs)
            } else {
                selectedShapeIDs.formUnion(rootGroup.allShapeIDs)
            }

        case .removeShapeFromSelection(let id):
            guard let layer = activeLayer(),
                  let rootGroup = layer.findRootGroup(containingShape: id)
            else {
                applyAction(action)
                return
            }
            if enteredGroupID != nil {
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs.subtract(resolved.shapeIDs)
            } else {
                selectedShapeIDs.subtract(rootGroup.allShapeIDs)
            }

        default:
            // For all other actions (updateShape, updateShapes, addShapesToSelection, etc.)
            applyAction(action)
        }
    }

    private func isAncestor(group: ShapeGroup, of shapeID: UUID, in layer: Layer) -> Bool {
        let ancestry = layer.findGroupAncestry(containingShape: shapeID)
        return ancestry.contains { $0.id == group.id }
    }

    private func findSelectedSubGroup(within parentGroupID: UUID, in layer: Layer) -> ShapeGroup? {
        guard !selectedShapeIDs.isEmpty else { return nil }
        // Find the parent group, then check if selection matches any of its child groups
        func findGroup(id: UUID, in groups: [ShapeGroup]) -> ShapeGroup? {
            for group in groups {
                if group.id == id { return group }
                if let found = findGroup(id: id, in: group.children) { return found }
            }
            return nil
        }
        guard let parentGroup = findGroup(id: parentGroupID, in: layer.groups) else { return nil }
        for child in parentGroup.children {
            if child.allShapeIDs == selectedShapeIDs {
                return child
            }
        }
        return nil
    }

    private func isAncestor(groupID: UUID, of shapeID: UUID, in layer: Layer) -> Bool {
        let ancestry = layer.findGroupAncestry(containingShape: shapeID)
        return ancestry.contains { $0.id == groupID }
    }

    var selectedGroupBoundingRect: GridRect? {
        guard enteredGroupID == nil, !selectedShapeIDs.isEmpty else { return nil }
        guard let layer = activeLayer() else { return nil }

        // Check if the selection matches a group's allShapeIDs
        let matchesGroup = layer.groups.contains { group in
            let ids = group.allShapeIDs
            return !ids.isEmpty && ids == selectedShapeIDs
        } || findSelectedGroupRecursive(in: layer.groups) != nil

        guard matchesGroup else { return nil }

        let shapes = selectedShapeIDs.compactMap { document.findShape(id: $0) }
        guard !shapes.isEmpty else { return nil }

        var minCol = Int.max
        var minRow = Int.max
        var maxCol = Int.min
        var maxRow = Int.min
        for shape in shapes {
            let rect = shape.boundingRect
            minCol = min(minCol, rect.minColumn)
            minRow = min(minRow, rect.minRow)
            maxCol = max(maxCol, rect.maxColumn)
            maxRow = max(maxRow, rect.maxRow)
        }

        return GridRect(
            origin: GridPoint(column: minCol, row: minRow),
            size: GridSize(width: maxCol - minCol + 1, height: maxRow - minRow + 1)
        )
    }

    func handleEscape() -> Bool {
        if let enteredGroupID {
            // Exit entered group and re-select the group as a whole
            if let layer = activeLayer() {
                let ancestry = findGroupContaining(groupID: enteredGroupID, in: layer.groups)
                if let parentGroup = ancestry {
                    // Re-select the parent group
                    selectedShapeIDs = parentGroup.allShapeIDs
                    self.enteredGroupID = nil
                } else {
                    // enteredGroupID is a root group — find it and select it
                    if let group = layer.groups.first(where: { $0.id == enteredGroupID }) {
                        selectedShapeIDs = group.allShapeIDs
                    }
                    self.enteredGroupID = nil
                }
            } else {
                self.enteredGroupID = nil
                selectedShapeIDs = []
            }
            return true
        } else if !selectedShapeIDs.isEmpty {
            selectedShapeIDs = []
            return true
        }
        return false
    }

    private func findGroupContaining(groupID: UUID, in groups: [ShapeGroup]) -> ShapeGroup? {
        for group in groups {
            if group.children.contains(where: { $0.id == groupID }) {
                return group
            }
            if let found = findGroupContaining(groupID: groupID, in: group.children) {
                return found
            }
        }
        return nil
    }

    // MARK: - Text editing

    func commitTextEdit() {
        recordSnapshot()
        guard let point = textEditPoint else {
            cancelTextEdit()
            return
        }

        if let shapeID = textEditShapeID {
            // Editing an existing shape's text
            guard let shape = document.findShape(id: shapeID) else {
                cancelTextEdit()
                return
            }
            switch shape {
            case .text(var text):
                if textEditContent.isEmpty {
                    // Empty text → delete the shape
                    document.removeShape(id: shapeID)
                    selectedShapeIDs = []
                } else {
                    text.text = textEditContent
                    document.updateShape(.text(text))
                }
            case .rectangle(var rectangle):
                rectangle.label = textEditContent
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.label = textEditContent
                document.updateShape(.arrow(arrow))
            case .pencil:
                break
            }
        } else {
            // Creating a new TextShape via TextTool
            guard !textEditContent.isEmpty else {
                cancelTextEdit()
                return
            }
            let textShape = TextShape(origin: point, text: textEditContent)
            document.addShape(.text(textShape), toLayerAt: activeLayerIndex)
            selectedShapeIDs = [textShape.id]
            activeToolType = .select
        }

        cancelTextEdit()
        rerender()
    }

    func cancelTextEdit() {
        isEditingText = false
        textEditPoint = nil
        textEditContent = ""
        textEditShapeID = nil
    }

    // MARK: - Shape property editing

    var selectedShapes: [AnyShape] {
        selectedShapeIDs.compactMap { document.findShape(id: $0) }
    }

    var selectedShape: AnyShape? {
        guard selectedShapeIDs.count == 1, let id = selectedShapeIDs.first else { return nil }
        return document.findShape(id: id)
    }

    var selectedLayer: Layer? {
        guard let id = selectedLayerID else { return nil }
        return document.layers.first { $0.id == id }
    }

    private func clearSelectedLayerIfNeeded() {
        guard let layerID = selectedLayerID,
            let layer = document.layers.first(where: { $0.id == layerID })
        else {
            selectedLayerID = nil
            return
        }
        let layerShapeIDs = Set(layer.shapes.map(\.id))
        if selectedShapeIDs != layerShapeIDs {
            selectedLayerID = nil
        }
    }

    // MARK: - Layer aggregate colors

    var hasLayerFillShapes: Bool {
        selectedLayer?.shapes.contains { if case .rectangle = $0 { return true }; return false } ?? false
    }

    var hasLayerBorderShapes: Bool {
        selectedLayer?.shapes.contains {
            if case .rectangle = $0 { return true }
            if case .arrow = $0 { return true }
            return false
        } ?? false
    }

    var hasLayerTextShapes: Bool {
        selectedLayer?.shapes.isEmpty == false
    }

    var documentColors: [ShapeColor] {
        var seen = Set<ShapeColor>()
        var result: [ShapeColor] = []
        for color in [ShapeColor.black, .white] {
            seen.insert(color)
            result.append(color)
        }
        for layer in document.layers {
            for shape in layer.shapes {
                for color in shape.colors {
                    if seen.insert(color).inserted {
                        result.append(color)
                    }
                }
            }
        }
        return result
    }

    var layerFillColor: ShapeColor? {
        guard let layer = selectedLayer else { return nil }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            if case .rectangle(let rectangle) = shape { return rectangle.fillColor }
            return nil
        }
        guard let first = colors.first else { return nil }
        return colors.allSatisfy({ $0 == first }) ? first : nil
    }

    var isLayerFillColorMixed: Bool {
        guard let layer = selectedLayer else { return false }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            if case .rectangle(let rectangle) = shape { return rectangle.fillColor }
            return nil
        }
        guard colors.count > 1 else { return false }
        return !colors.allSatisfy { $0 == colors[0] }
    }

    var layerBorderColor: ShapeColor? {
        guard let layer = selectedLayer else { return nil }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            switch shape {
            case .rectangle(let rectangle): return rectangle.borderColor
            case .arrow(let arrow): return arrow.strokeColor
            case .text, .pencil: return nil
            }
        }
        guard let first = colors.first else { return nil }
        return colors.allSatisfy({ $0 == first }) ? first : nil
    }

    var isLayerBorderColorMixed: Bool {
        guard let layer = selectedLayer else { return false }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            switch shape {
            case .rectangle(let rectangle): return rectangle.borderColor
            case .arrow(let arrow): return arrow.strokeColor
            case .text, .pencil: return nil
            }
        }
        guard colors.count > 1 else { return false }
        return !colors.allSatisfy { $0 == colors[0] }
    }

    var layerTextColor: ShapeColor? {
        guard let layer = selectedLayer else { return nil }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            switch shape {
            case .rectangle(let rectangle): return rectangle.textColor
            case .arrow(let arrow): return arrow.labelColor
            case .text(let text): return text.textColor
            case .pencil: return nil
            }
        }
        guard let first = colors.first else { return nil }
        return colors.allSatisfy({ $0 == first }) ? first : nil
    }

    var isLayerTextColorMixed: Bool {
        guard let layer = selectedLayer else { return false }
        let colors = layer.shapes.compactMap { shape -> ShapeColor? in
            switch shape {
            case .rectangle(let rectangle): return rectangle.textColor
            case .arrow(let arrow): return arrow.labelColor
            case .text(let text): return text.textColor
            case .pencil: return nil
            }
        }
        guard colors.count > 1 else { return false }
        return !colors.allSatisfy { $0 == colors[0] }
    }

    func updateLayerFillColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let layer = selectedLayer else { return }
        for shape in layer.shapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.fillColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateLayerBorderColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let layer = selectedLayer else { return }
        for shape in layer.shapes {
            switch shape {
            case .rectangle(var rectangle):
                rectangle.borderColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.strokeColor = color
                document.updateShape(.arrow(arrow))
            case .text, .pencil:
                break
            }
        }
        rerender()
    }

    func updateLayerTextColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let layer = selectedLayer else { return }
        for shape in layer.shapes {
            switch shape {
            case .rectangle(var rectangle):
                rectangle.textColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.labelColor = color
                document.updateShape(.arrow(arrow))
            case .text(var text):
                text.textColor = color
                document.updateShape(.text(text))
            case .pencil:
                break
            }
        }
        rerender()
    }

    // MARK: - Multi-selection helpers

    private func uniformValue<T: Equatable>(_ values: [T]) -> T? {
        guard let first = values.first else { return nil }
        return values.allSatisfy({ $0 == first }) ? first : nil
    }

    private func uniformOptionalValue<T: Equatable>(_ values: [T?]) -> T? {
        guard let first = values.first else { return nil }
        return values.allSatisfy({ $0 == first }) ? first : nil
    }

    private func isMixed<T: Equatable>(_ values: [T]) -> Bool {
        guard values.count > 1 else { return false }
        return !values.allSatisfy { $0 == values[0] }
    }

    var selectedRectangles: [RectangleShape] {
        selectedShapes.compactMap { if case .rectangle(let r) = $0 { return r }; return nil }
    }

    var selectedArrows: [ArrowShape] {
        selectedShapes.compactMap { if case .arrow(let a) = $0 { return a }; return nil }
    }

    var isAllRectanglesSelected: Bool {
        selectedShapes.count > 1 && selectedShapes.allSatisfy { if case .rectangle = $0 { return true }; return false }
    }

    var isAllArrowsSelected: Bool {
        selectedShapes.count > 1 && selectedShapes.allSatisfy { if case .arrow = $0 { return true }; return false }
    }

    var hasSelectedRectangles: Bool {
        selectedShapes.contains { if case .rectangle = $0 { return true }; return false }
    }

    var hasSelectedArrows: Bool {
        selectedShapes.contains { if case .arrow = $0 { return true }; return false }
    }

    // MARK: - Multi-selection rectangle computed properties

    var multiSelectRectHasBorder: Bool? { uniformValue(selectedRectangles.map(\.hasBorder)) }
    var isMultiSelectRectHasBorderMixed: Bool { isMixed(selectedRectangles.map(\.hasBorder)) }

    var multiSelectRectBorderColor: ShapeColor? { uniformOptionalValue(selectedRectangles.map(\.borderColor)) }
    var isMultiSelectRectBorderColorMixed: Bool { isMixed(selectedRectangles.map(\.borderColor)) }

    var multiSelectRectStrokeStyle: StrokeStyle? { uniformValue(selectedRectangles.map(\.strokeStyle)) }
    var isMultiSelectRectStrokeStyleMixed: Bool { isMixed(selectedRectangles.map(\.strokeStyle)) }

    var multiSelectRectBorderLineStyle: RectangleBorderLineStyle? { uniformValue(selectedRectangles.map(\.borderLineStyle)) }
    var isMultiSelectRectBorderLineStyleMixed: Bool { isMixed(selectedRectangles.map(\.borderLineStyle)) }

    var multiSelectRectBorderDashLength: Int? { uniformValue(selectedRectangles.map(\.borderDashLength)) }
    var isMultiSelectRectBorderDashLengthMixed: Bool { isMixed(selectedRectangles.map(\.borderDashLength)) }

    var multiSelectRectBorderGapLength: Int? { uniformValue(selectedRectangles.map(\.borderGapLength)) }
    var isMultiSelectRectBorderGapLengthMixed: Bool { isMixed(selectedRectangles.map(\.borderGapLength)) }

    var multiSelectRectVisibleBorders: Set<RectangleBorderSide>? { uniformValue(selectedRectangles.map(\.visibleBorders)) }
    var isMultiSelectRectVisibleBordersMixed: Bool { isMixed(selectedRectangles.map(\.visibleBorders)) }

    func multiSelectRectBorderSideUniform(_ side: RectangleBorderSide) -> Bool? {
        uniformValue(selectedRectangles.map { $0.visibleBorders.contains(side) })
    }

    func isMultiSelectRectBorderSideMixed(_ side: RectangleBorderSide) -> Bool {
        isMixed(selectedRectangles.map { $0.visibleBorders.contains(side) })
    }

    var multiSelectRectFillMode: RectangleFillMode? { uniformValue(selectedRectangles.map(\.fillMode)) }
    var isMultiSelectRectFillModeMixed: Bool { isMixed(selectedRectangles.map(\.fillMode)) }

    var multiSelectRectFillColor: ShapeColor? { uniformOptionalValue(selectedRectangles.map(\.fillColor)) }
    var isMultiSelectRectFillColorMixed: Bool { isMixed(selectedRectangles.map(\.fillColor)) }

    var multiSelectRectFillCharacter: Character? { uniformValue(selectedRectangles.map(\.fillCharacter)) }
    var isMultiSelectRectFillCharacterMixed: Bool { isMixed(selectedRectangles.map(\.fillCharacter)) }

    var multiSelectRectHasShadow: Bool? { uniformValue(selectedRectangles.map(\.hasShadow)) }
    var isMultiSelectRectHasShadowMixed: Bool { isMixed(selectedRectangles.map(\.hasShadow)) }

    var multiSelectRectShadowStyle: RectangleShadowStyle? { uniformValue(selectedRectangles.map(\.shadowStyle)) }
    var isMultiSelectRectShadowStyleMixed: Bool { isMixed(selectedRectangles.map(\.shadowStyle)) }

    var multiSelectRectShadowOffsetX: Int? { uniformValue(selectedRectangles.map(\.shadowOffsetX)) }
    var isMultiSelectRectShadowOffsetXMixed: Bool { isMixed(selectedRectangles.map(\.shadowOffsetX)) }

    var multiSelectRectShadowOffsetY: Int? { uniformValue(selectedRectangles.map(\.shadowOffsetY)) }
    var isMultiSelectRectShadowOffsetYMixed: Bool { isMixed(selectedRectangles.map(\.shadowOffsetY)) }

    var multiSelectRectTextColor: ShapeColor? { uniformOptionalValue(selectedRectangles.map(\.textColor)) }
    var isMultiSelectRectTextColorMixed: Bool { isMixed(selectedRectangles.map(\.textColor)) }

    // MARK: - Multi-selection arrow computed properties

    var multiSelectArrowStrokeColor: ShapeColor? { uniformOptionalValue(selectedArrows.map(\.strokeColor)) }
    var isMultiSelectArrowStrokeColorMixed: Bool { isMixed(selectedArrows.map(\.strokeColor)) }

    var multiSelectArrowLabelColor: ShapeColor? { uniformOptionalValue(selectedArrows.map(\.labelColor)) }
    var isMultiSelectArrowLabelColorMixed: Bool { isMixed(selectedArrows.map(\.labelColor)) }

    var multiSelectArrowStrokeStyle: StrokeStyle? { uniformValue(selectedArrows.map(\.strokeStyle)) }
    var isMultiSelectArrowStrokeStyleMixed: Bool { isMixed(selectedArrows.map(\.strokeStyle)) }

    var multiSelectArrowStartHeadStyle: ArrowHeadStyle? { uniformValue(selectedArrows.map(\.startHeadStyle)) }
    var isMultiSelectArrowStartHeadStyleMixed: Bool { isMixed(selectedArrows.map(\.startHeadStyle)) }

    var multiSelectArrowEndHeadStyle: ArrowHeadStyle? { uniformValue(selectedArrows.map(\.endHeadStyle)) }
    var isMultiSelectArrowEndHeadStyleMixed: Bool { isMixed(selectedArrows.map(\.endHeadStyle)) }

    // MARK: - Multi-selection cross-type computed properties

    var multiSelectCrossStrokeStyle: StrokeStyle? {
        let styles: [StrokeStyle] = selectedShapes.compactMap { shape in
            switch shape {
            case .rectangle(let r): return r.strokeStyle
            case .arrow(let a): return a.strokeStyle
            case .text, .pencil: return nil
            }
        }
        return uniformValue(styles)
    }

    var isMultiSelectCrossStrokeStyleMixed: Bool {
        let styles: [StrokeStyle] = selectedShapes.compactMap { shape in
            switch shape {
            case .rectangle(let r): return r.strokeStyle
            case .arrow(let a): return a.strokeStyle
            case .text, .pencil: return nil
            }
        }
        return isMixed(styles)
    }

    var multiSelectCrossBorderStrokeColor: ShapeColor? {
        let colors: [ShapeColor?] = selectedShapes.compactMap { (shape: AnyShape) -> ShapeColor?? in
            switch shape {
            case .rectangle(let r): return r.borderColor
            case .arrow(let a): return a.strokeColor
            case .text, .pencil: return nil
            }
        }
        return uniformOptionalValue(colors)
    }

    var isMultiSelectCrossBorderStrokeColorMixed: Bool {
        let colors: [ShapeColor?] = selectedShapes.compactMap { (shape: AnyShape) -> ShapeColor?? in
            switch shape {
            case .rectangle(let r): return r.borderColor
            case .arrow(let a): return a.strokeColor
            case .text, .pencil: return nil
            }
        }
        return isMixed(colors)
    }

    var multiSelectCrossTextLabelColor: ShapeColor? {
        let colors: [ShapeColor?] = selectedShapes.compactMap { (shape: AnyShape) -> ShapeColor?? in
            switch shape {
            case .rectangle(let r): return r.textColor
            case .arrow(let a): return a.labelColor
            case .text(let t): return t.textColor
            case .pencil: return nil
            }
        }
        return uniformOptionalValue(colors)
    }

    var isMultiSelectCrossTextLabelColorMixed: Bool {
        let colors: [ShapeColor?] = selectedShapes.compactMap { (shape: AnyShape) -> ShapeColor?? in
            switch shape {
            case .rectangle(let r): return r.textColor
            case .arrow(let a): return a.labelColor
            case .text(let t): return t.textColor
            case .pencil: return nil
            }
        }
        return isMixed(colors)
    }

    // MARK: - Multi-selection batch update methods

    func updateMultiSelectRectHasBorder(_ hasBorder: Bool) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.hasBorder = hasBorder
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectBorderColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.borderColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectStrokeStyle(_ style: StrokeStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.strokeStyle = style
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectBorderLineStyle(_ lineStyle: RectangleBorderLineStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.borderLineStyle = lineStyle
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectBorderDashLength(_ value: Int) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.borderDashLength = max(1, value)
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectBorderGapLength(_ value: Int) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.borderGapLength = max(0, value)
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectBorderSide(_ side: RectangleBorderSide, isVisible: Bool) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                if isVisible {
                    rectangle.visibleBorders.insert(side)
                } else {
                    rectangle.visibleBorders.remove(side)
                }
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectFillMode(_ fillMode: RectangleFillMode) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.fillMode = fillMode
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectFillEnabled(_ isEnabled: Bool) {
        updateMultiSelectRectFillMode(isEnabled ? .solid : .transparent)
    }

    func updateMultiSelectRectFillColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.fillColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectFillCharacter(_ fillCharacter: Character) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.fillCharacter = fillCharacter
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectHasShadow(_ hasShadow: Bool) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.hasShadow = hasShadow
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectShadowStyle(_ style: RectangleShadowStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.shadowStyle = style
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectShadowOffsetX(_ value: Int) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.shadowOffsetX = value
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectShadowOffsetY(_ value: Int) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.shadowOffsetY = value
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectTextColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.textColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectArrowStrokeColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .arrow(var arrow) = shape {
                arrow.strokeColor = color
                document.updateShape(.arrow(arrow))
            }
        }
        rerender()
    }

    func updateMultiSelectArrowLabelColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .arrow(var arrow) = shape {
                arrow.labelColor = color
                document.updateShape(.arrow(arrow))
            }
        }
        rerender()
    }

    func updateMultiSelectArrowStrokeStyle(_ style: StrokeStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .arrow(var arrow) = shape {
                arrow.strokeStyle = style
                document.updateShape(.arrow(arrow))
            }
        }
        rerender()
    }

    func updateMultiSelectArrowStartHeadStyle(_ style: ArrowHeadStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .arrow(var arrow) = shape {
                arrow.startHeadStyle = style
                document.updateShape(.arrow(arrow))
            }
        }
        rerender()
    }

    func updateMultiSelectArrowEndHeadStyle(_ style: ArrowHeadStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .arrow(var arrow) = shape {
                arrow.endHeadStyle = style
                document.updateShape(.arrow(arrow))
            }
        }
        rerender()
    }

    func updateMultiSelectCrossStrokeStyle(_ style: StrokeStyle) {
        recordSnapshot()
        for shape in selectedShapes {
            switch shape {
            case .rectangle(var rectangle):
                rectangle.strokeStyle = style
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.strokeStyle = style
                document.updateShape(.arrow(arrow))
            case .text, .pencil:
                break
            }
        }
        rerender()
    }

    func updateMultiSelectCrossBorderStrokeColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            switch shape {
            case .rectangle(var rectangle):
                rectangle.borderColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.strokeColor = color
                document.updateShape(.arrow(arrow))
            case .text, .pencil:
                break
            }
        }
        rerender()
    }

    func updateMultiSelectCrossTextLabelColor(_ color: ShapeColor?) {
        recordSnapshot()
        for shape in selectedShapes {
            switch shape {
            case .rectangle(var rectangle):
                rectangle.textColor = color
                updateShapeAndAttachments(.rectangle(rectangle))
            case .arrow(var arrow):
                arrow.labelColor = color
                document.updateShape(.arrow(arrow))
            case .text(var text):
                text.textColor = color
                document.updateShape(.text(text))
            case .pencil:
                break
            }
        }
        rerender()
    }

    func updateSelectedRectangleLabel(_ label: String) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.label = label
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleTextHorizontalAlignment(_ alignment: RectangleTextHorizontalAlignment) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.textHorizontalAlignment = alignment
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleTextVerticalAlignment(_ alignment: RectangleTextVerticalAlignment) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.textVerticalAlignment = alignment
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleHasBorder(_ hasBorder: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.hasBorder = hasBorder
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleBorderSide(_ side: RectangleBorderSide, isVisible: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        if isVisible {
            rectangle.visibleBorders.insert(side)
        } else {
            rectangle.visibleBorders.remove(side)
        }
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleBorderLineStyle(_ lineStyle: RectangleBorderLineStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.borderLineStyle = lineStyle
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleBorderDashLength(_ value: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.borderDashLength = max(1, value)
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleBorderGapLength(_ value: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.borderGapLength = max(0, value)
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleAllowTextOnBorder(_ allow: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.allowTextOnBorder = allow
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleHasShadow(_ hasShadow: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.hasShadow = hasShadow
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleShadowStyle(_ style: RectangleShadowStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.shadowStyle = style
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleShadowOffsetX(_ value: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.shadowOffsetX = value
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleShadowOffsetY(_ value: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.shadowOffsetY = value
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleTextPadding(
        left: Int? = nil,
        right: Int? = nil,
        top: Int? = nil,
        bottom: Int? = nil
    ) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        if let left {
            rectangle.textPaddingLeft = max(0, left)
        }
        if let right {
            rectangle.textPaddingRight = max(0, right)
        }
        if let top {
            rectangle.textPaddingTop = max(0, top)
        }
        if let bottom {
            rectangle.textPaddingBottom = max(0, bottom)
        }
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleStrokeStyle(_ style: StrokeStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.strokeStyle = style
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleFillMode(_ fillMode: RectangleFillMode) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.fillMode = fillMode
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleFillEnabled(_ isEnabled: Bool) {
        updateSelectedRectangleFillMode(isEnabled ? .solid : .transparent)
    }

    func updateSelectedRectangleFillCharacter(_ fillCharacter: Character) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.fillCharacter = fillCharacter
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleOrigin(column: Int, row: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.origin = GridPoint(column: column, row: row)
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleSize(width: Int, height: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.size = GridSize(width: width, height: height)
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedArrowLabel(_ label: String) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.label = label
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowStrokeStyle(_ style: StrokeStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.strokeStyle = style
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowStart(column: Int, row: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.start = GridPoint(column: column, row: row)
        arrow.startAttachment = nil
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowEnd(column: Int, row: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.end = GridPoint(column: column, row: row)
        arrow.endAttachment = nil
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowStartHeadStyle(_ style: ArrowHeadStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.startHeadStyle = style
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowEndHeadStyle(_ style: ArrowHeadStyle) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.endHeadStyle = style
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowDetachStart() {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.startAttachment = nil
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowDetachEnd() {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.endAttachment = nil
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedTextOrigin(column: Int, row: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .text(var text) = shape
        else { return }
        text.origin = GridPoint(column: column, row: row)
        document.updateShape(.text(text))
        rerender()
    }

    func updateSelectedTextContent(_ content: String) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .text(var text) = shape
        else { return }
        text.text = content
        document.updateShape(.text(text))
        rerender()
    }

    // MARK: - Pencil tool properties

    var pencilDrawCharacter: Character = "*" {
        didSet { pencilTool.drawCharacter = pencilDrawCharacter }
    }

    var pencilDrawColor: ShapeColor? {
        didSet { pencilTool.drawColor = pencilDrawColor }
    }

    func updateSelectedPencilOrigin(column: Int, row: Int) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .pencil(var pencil) = shape
        else { return }
        pencil.origin = GridPoint(column: column, row: row)
        document.updateShape(.pencil(pencil))
        rerender()
    }

    func updateSelectedPencilCharacter(_ character: Character) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .pencil(var pencil) = shape
        else { return }
        for key in pencil.cells.keys {
            pencil.cells[key]?.character = character
        }
        document.updateShape(.pencil(pencil))
        rerender()
    }

    func updateSelectedPencilColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .pencil(var pencil) = shape
        else { return }
        for key in pencil.cells.keys {
            pencil.cells[key]?.color = color
        }
        document.updateShape(.pencil(pencil))
        rerender()
    }

    // MARK: - Color editing

    func updateSelectedRectangleBorderColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.borderColor = color
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleFillColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.fillColor = color
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedRectangleTextColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.textColor = color
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    func updateSelectedArrowStrokeColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.strokeColor = color
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowLabelColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.labelColor = color
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedTextShapeColor(_ color: ShapeColor?) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .text(var text) = shape
        else { return }
        text.textColor = color
        document.updateShape(.text(text))
        rerender()
    }

    // MARK: - Palette editing

    func addPaletteColor(name: String, color: ShapeColor) {
        recordSnapshot()
        document.palette.entries.append(ColorPaletteEntry(name: name, color: color))
    }

    func updatePaletteColor(id: UUID, name: String? = nil, color: ShapeColor? = nil) {
        recordSnapshot()
        guard let index = document.palette.entries.firstIndex(where: { $0.id == id }) else { return }
        if let name { document.palette.entries[index].name = name }
        if let color { document.palette.entries[index].color = color }
    }

    func removePaletteColor(id: UUID) {
        recordSnapshot()
        document.palette.entries.removeAll { $0.id == id }
    }

    // MARK: - Layer export

    func canCopySelectedShapes() -> Bool {
        !isEditingText && !selectedShapesInDocumentOrder().isEmpty
    }

    func canCopySelectionAsPlainText() -> Bool {
        !isEditingText && (document.hasContent || !selectedShapesInDocumentOrder().isEmpty)
    }

    func canPasteShapesFromClipboard() -> Bool {
        guard !isEditingText,
            document.layers.indices.contains(activeLayerIndex),
            !document.layers[activeLayerIndex].isLocked,
            let payloadData = clipboardPayloadData(from: NSPasteboard.general)
        else { return false }
        return decodeShapeClipboardPayload(from: payloadData) != nil
    }

    func copySelectedShapesToClipboard() {
        guard let payloadData = selectedShapesClipboardPayloadData() else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(payloadData, forType: Self.shapeClipboardType)
        if let payloadString = String(data: payloadData, encoding: .utf8) {
            pasteboard.setString(payloadString, forType: .string)
        }
        lastPastedPayloadData = nil
        consecutivePasteCount = 0
    }

    @discardableResult
    func pasteShapesFromClipboard() -> Bool {
        guard let payloadData = clipboardPayloadData(from: NSPasteboard.general) else { return false }
        return pasteShapes(fromClipboardPayloadData: payloadData)
    }

    @discardableResult
    func pasteShapes(fromClipboardPayloadData payloadData: Data) -> Bool {
        guard !isEditingText,
            document.layers.indices.contains(activeLayerIndex),
            !document.layers[activeLayerIndex].isLocked,
            let payload = decodeShapeClipboardPayload(from: payloadData),
            !payload.shapes.isEmpty
        else { return false }

        if lastPastedPayloadData == payloadData {
            consecutivePasteCount += 1
        } else {
            lastPastedPayloadData = payloadData
            consecutivePasteCount = 1
        }

        let dx = Self.pasteOffset.column * consecutivePasteCount
        let dy = Self.pasteOffset.row * consecutivePasteCount

        recordSnapshot()

        let idMap = Dictionary(uniqueKeysWithValues: payload.shapes.map { ($0.id, UUID()) })
        var pastedShapeIDs: Set<UUID> = []

        for shape in payload.shapes {
            guard let newID = idMap[shape.id] else { continue }
            let remappedShape = remappedShapeForClipboardPaste(shape, newID: newID, idMap: idMap)
            let translated = translatedShape(remappedShape, dx: dx, dy: dy)
            document.addShape(translated, toLayerAt: activeLayerIndex)
            pastedShapeIDs.insert(translated.id)
        }

        selectedShapeIDs = pastedShapeIDs
        activeToolType = .select
        rerender()
        return true
    }

    func selectedShapesClipboardPayloadData() -> Data? {
        let shapes = selectedShapesInDocumentOrder()
        guard !shapes.isEmpty else { return nil }
        let payload = ShapeClipboardPayload(shapes: shapes)
        let encoder = JSONEncoder()
        return try? encoder.encode(payload)
    }

    func copySelectionAsPlainTextToClipboard() {
        guard let text = selectionOrCanvasPlainText() else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func selectionOrCanvasPlainText() -> String? {
        let selectedShapes = selectedShapesInDocumentOrder()
        if !selectedShapes.isEmpty {
            return plainText(for: selectedShapes)
        }
        guard document.hasContent else { return nil }
        return canvas.render()
    }

    func copySelectedLayerAsTextToClipboard() {
        guard let text = selectedLayerPlainText() else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func selectedLayerPlainText() -> String? {
        guard let canvas = selectedLayerExportCanvas() else { return nil }
        return canvas.render()
    }

    private func selectedShapesInDocumentOrder() -> [AnyShape] {
        var ordered: [AnyShape] = []
        for layer in document.layers {
            for shape in layer.shapes where selectedShapeIDs.contains(shape.id) {
                ordered.append(shape)
            }
        }
        return ordered
    }

    private func clipboardPayloadData(from pasteboard: NSPasteboard) -> Data? {
        if let data = pasteboard.data(forType: Self.shapeClipboardType) {
            return data
        }
        if let string = pasteboard.string(forType: .string) {
            return string.data(using: .utf8)
        }
        return nil
    }

    private func decodeShapeClipboardPayload(from data: Data) -> ShapeClipboardPayload? {
        try? JSONDecoder().decode(ShapeClipboardPayload.self, from: data)
    }

    private func remappedShapeForClipboardPaste(
        _ shape: AnyShape,
        newID: UUID,
        idMap: [UUID: UUID]
    ) -> AnyShape {
        switch shape {
        case .rectangle(let rectangle):
            return .rectangle(
                RectangleShape(
                    id: newID,
                    name: rectangle.name,
                    origin: rectangle.origin,
                    size: rectangle.size,
                    strokeStyle: rectangle.strokeStyle,
                    hasBorder: rectangle.hasBorder,
                    visibleBorders: rectangle.visibleBorders,
                    borderLineStyle: rectangle.borderLineStyle,
                    borderDashLength: rectangle.borderDashLength,
                    borderGapLength: rectangle.borderGapLength,
                    fillMode: rectangle.fillMode,
                    fillCharacter: rectangle.fillCharacter,
                    label: rectangle.label,
                    textHorizontalAlignment: rectangle.textHorizontalAlignment,
                    textVerticalAlignment: rectangle.textVerticalAlignment,
                    allowTextOnBorder: rectangle.allowTextOnBorder,
                    textPaddingLeft: rectangle.textPaddingLeft,
                    textPaddingRight: rectangle.textPaddingRight,
                    textPaddingTop: rectangle.textPaddingTop,
                    textPaddingBottom: rectangle.textPaddingBottom,
                    hasShadow: rectangle.hasShadow,
                    shadowStyle: rectangle.shadowStyle,
                    shadowOffsetX: rectangle.shadowOffsetX,
                    shadowOffsetY: rectangle.shadowOffsetY,
                    borderColor: rectangle.borderColor,
                    fillColor: rectangle.fillColor,
                    textColor: rectangle.textColor
                )
            )
        case .arrow(let arrow):
            var startAttachment = arrow.startAttachment
            var endAttachment = arrow.endAttachment

            if let attachment = startAttachment {
                if let remappedShapeID = idMap[attachment.shapeID] {
                    startAttachment = ArrowAttachment(shapeID: remappedShapeID, side: attachment.side)
                } else {
                    startAttachment = nil
                }
            }

            if let attachment = endAttachment {
                if let remappedShapeID = idMap[attachment.shapeID] {
                    endAttachment = ArrowAttachment(shapeID: remappedShapeID, side: attachment.side)
                } else {
                    endAttachment = nil
                }
            }

            return .arrow(
                ArrowShape(
                    id: newID,
                    name: arrow.name,
                    start: arrow.start,
                    end: arrow.end,
                    label: arrow.label,
                    strokeStyle: arrow.strokeStyle,
                    bendDirection: arrow.bendDirection,
                    startAttachment: startAttachment,
                    endAttachment: endAttachment,
                    startHeadStyle: arrow.startHeadStyle,
                    endHeadStyle: arrow.endHeadStyle,
                    strokeColor: arrow.strokeColor,
                    labelColor: arrow.labelColor
                )
            )
        case .text(let text):
            return .text(
                TextShape(
                    id: newID,
                    name: text.name,
                    origin: text.origin,
                    text: text.text,
                    textColor: text.textColor
                )
            )
        case .pencil(let pencil):
            return .pencil(
                PencilShape(
                    id: newID,
                    name: pencil.name,
                    origin: pencil.origin,
                    cells: pencil.cells
                )
            )
        }
    }

    private func plainText(for shapes: [AnyShape]) -> String? {
        guard !shapes.isEmpty else { return nil }

        let first = shapes[0].boundingRect
        let bounds = shapes.dropFirst().reduce(first) { result, shape in
            let rect = shape.boundingRect
            let minColumn = min(result.minColumn, rect.minColumn)
            let minRow = min(result.minRow, rect.minRow)
            let maxColumn = max(result.maxColumn, rect.maxColumn)
            let maxRow = max(result.maxRow, rect.maxRow)
            return GridRect(
                origin: GridPoint(column: minColumn, row: minRow),
                size: GridSize(width: maxColumn - minColumn + 1, height: maxRow - minRow + 1)
            )
        }

        var exportCanvas = Canvas(columns: bounds.size.width, rows: bounds.size.height)
        for shape in shapes {
            translatedShape(shape, dx: -bounds.origin.column, dy: -bounds.origin.row)
                .render(into: &exportCanvas)
        }
        return exportCanvas.render()
    }

    func exportSelectedLayerAsPNG(scale: Int, backgroundColor: ShapeColor?) {
        guard let layer = selectedLayer,
            let canvas = selectedLayerExportCanvas(),
            let pngData = pngData(from: canvas, scale: scale, backgroundColor: backgroundColor)
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "png")!]
        panel.nameFieldStringValue = "\(layer.name).png"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try pngData.write(to: url)
        } catch {
            print("Failed to export layer PNG: \(error)")
        }
    }

    private func selectedLayerExportCanvas() -> Canvas? {
        guard let layer = selectedLayer, !layer.shapes.isEmpty else { return nil }
        let bounds = layerBounds(for: layer)

        var canvas = Canvas(columns: bounds.size.width, rows: bounds.size.height)
        for shape in layer.shapes {
            translatedShape(shape, dx: -bounds.origin.column, dy: -bounds.origin.row)
                .render(into: &canvas)
        }
        return canvas
    }

    private func layerBounds(for layer: Layer) -> GridRect {
        let first = layer.shapes[0].boundingRect
        return layer.shapes.dropFirst().reduce(first) { result, shape in
            let rect = shape.boundingRect
            let minColumn = min(result.minColumn, rect.minColumn)
            let minRow = min(result.minRow, rect.minRow)
            let maxColumn = max(result.maxColumn, rect.maxColumn)
            let maxRow = max(result.maxRow, rect.maxRow)
            return GridRect(
                origin: GridPoint(column: minColumn, row: minRow),
                size: GridSize(width: maxColumn - minColumn + 1, height: maxRow - minRow + 1)
            )
        }
    }

    private func translatedShape(_ shape: AnyShape, dx: Int, dy: Int) -> AnyShape {
        switch shape {
        case .rectangle(var rectangle):
            rectangle.origin = GridPoint(column: rectangle.origin.column + dx, row: rectangle.origin.row + dy)
            return .rectangle(rectangle)
        case .arrow(var arrow):
            arrow.start = GridPoint(column: arrow.start.column + dx, row: arrow.start.row + dy)
            arrow.end = GridPoint(column: arrow.end.column + dx, row: arrow.end.row + dy)
            return .arrow(arrow)
        case .text(var text):
            text.origin = GridPoint(column: text.origin.column + dx, row: text.origin.row + dy)
            return .text(text)
        case .pencil(var pencil):
            pencil.origin = GridPoint(
                column: pencil.origin.column + dx,
                row: pencil.origin.row + dy
            )
            return .pencil(pencil)
        }
    }

    private func pngData(from canvas: Canvas, scale: Int, backgroundColor: ShapeColor?) -> Data? {
        let exportScale = min(max(scale, 1), 4)
        let font = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        let charSize = ("M" as NSString).size(withAttributes: [.font: font])
        let baseWidth = max(1, Int(ceil(CGFloat(canvas.columns) * charSize.width)))
        let baseHeight = max(1, Int(ceil(CGFloat(canvas.rows) * charSize.height)))
        let width = baseWidth * exportScale
        let height = baseHeight * exportScale

        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }

        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        (backgroundColor?.nsColor ?? .clear).setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()

        context.cgContext.scaleBy(x: CGFloat(exportScale), y: CGFloat(exportScale))

        for row in 0..<canvas.rows {
            for column in 0..<canvas.columns {
                guard let cell = canvas.cell(atColumn: column, row: row) else { continue }
                let x = CGFloat(column) * charSize.width
                let y = CGFloat(canvas.rows - row - 1) * charSize.height
                let cellRect = NSRect(x: x, y: y, width: charSize.width, height: charSize.height)

                if let background = cell.backgroundColor {
                    background.nsColor.setFill()
                    cellRect.fill()
                }

                guard cell.character != " " else { continue }
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: (cell.foregroundColor ?? .black).nsColor,
                ]
                NSString(string: String(cell.character)).draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
            }
        }

        NSGraphicsContext.restoreGraphicsState()
        return bitmap.representation(using: .png, properties: [:])
    }

    func exportSelectedLayerAsSVG(backgroundColor: ShapeColor?) {
        guard let layer = selectedLayer,
            let canvas = selectedLayerExportCanvas(),
            let data = svgData(from: canvas, backgroundColor: backgroundColor)
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "svg")!]
        panel.nameFieldStringValue = "\(layer.name).svg"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try data.write(to: url)
        } catch {
            print("Failed to export layer SVG: \(error)")
        }
    }

    private func svgData(from canvas: Canvas, backgroundColor: ShapeColor?) -> Data? {
        let font = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        let charSize = ("M" as NSString).size(withAttributes: [.font: font])
        let cellWidth = charSize.width
        let cellHeight = charSize.height
        let width = CGFloat(canvas.columns) * cellWidth
        let height = CGFloat(canvas.rows) * cellHeight
        let fontSize = 16.0

        var svg = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        svg += "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\(Int(ceil(width)))\" height=\"\(Int(ceil(height)))\">\n"

        if let bg = backgroundColor {
            svg += "  <rect width=\"100%\" height=\"100%\" fill=\"\(bg.svgColorString)\"/>\n"
        }

        // Background color rects
        var bgRects = ""
        for row in 0..<canvas.rows {
            for column in 0..<canvas.columns {
                guard let cell = canvas.cell(atColumn: column, row: row),
                    let background = cell.backgroundColor
                else { continue }
                let x = CGFloat(column) * cellWidth
                let y = CGFloat(row) * cellHeight
                bgRects +=
                    "    <rect x=\"\(Int(x))\" y=\"\(Int(y))\" width=\"\(Int(ceil(cellWidth)))\" height=\"\(Int(ceil(cellHeight)))\" fill=\"\(background.svgColorString)\"/>\n"
            }
        }
        if !bgRects.isEmpty {
            svg += "  <g>\n\(bgRects)  </g>\n"
        }

        // Foreground text
        var texts = ""
        for row in 0..<canvas.rows {
            for column in 0..<canvas.columns {
                guard let cell = canvas.cell(atColumn: column, row: row),
                    cell.character != " "
                else { continue }
                let x = CGFloat(column) * cellWidth
                let y = CGFloat(row) * cellHeight + cellHeight * 0.8
                let color = (cell.foregroundColor ?? .black).svgColorString
                let escaped = svgEscape(String(cell.character))
                texts +=
                    "    <text x=\"\(Int(x))\" y=\"\(Int(y))\" fill=\"\(color)\" font-family=\"monospace\" font-size=\"\(fontSize)\">\(escaped)</text>\n"
            }
        }
        if !texts.isEmpty {
            svg += "  <g>\n\(texts)  </g>\n"
        }

        svg += "</svg>\n"
        return svg.data(using: .utf8)
    }

    private func svgEscape(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    func deleteSelectedShapes() {
        recordSnapshot()
        for id in selectedShapeIDs {
            detachArrows(referencing: id)
            document.removeShape(id: id)
        }
        selectedShapeIDs = []
        enteredGroupID = nil
        rerender()
    }

    func moveSelectedShapes(dx: Int, dy: Int) {
        recordSnapshot()
        for id in selectedShapeIDs {
            guard let layerIndex = document.layerIndex(containingShape: id),
                !document.layers[layerIndex].isLocked,
                let shape = document.findShape(id: id)
            else { continue }

            let movedShape = translatedForSelectionMove(shape: shape, dx: dx, dy: dy)
            updateShapeAndAttachments(movedShape)
        }
        rerender()
    }

    // MARK: - Layer management

    func addLayer() {
        recordSnapshot()
        let name = "Layer \(document.layers.count + 1)"
        document.addLayer(name: name)
        activeLayerIndex = document.layers.count - 1
        expandedItemIDs.insert(document.layers[activeLayerIndex].id)
    }

    func removeLayer(at index: Int) {
        recordSnapshot()
        document.removeLayer(at: index)
        if activeLayerIndex >= document.layers.count {
            activeLayerIndex = document.layers.count - 1
        }
        rerender()
    }

    func toggleLayerVisibility(at index: Int) {
        recordSnapshot()
        guard document.layers.indices.contains(index) else { return }
        document.layers[index].isVisible.toggle()
        rerender()
    }

    func toggleLayerLock(at index: Int) {
        recordSnapshot()
        guard document.layers.indices.contains(index) else { return }
        document.layers[index].isLocked.toggle()
    }

    func moveActiveLayerUp() {
        recordSnapshot()
        guard document.moveLayerUp(at: activeLayerIndex) else { return }
        activeLayerIndex += 1
        rerender()
    }

    func moveActiveLayerDown() {
        recordSnapshot()
        guard document.moveLayerDown(at: activeLayerIndex) else { return }
        activeLayerIndex -= 1
        rerender()
    }

    func canMoveActiveLayerUp() -> Bool {
        activeLayerIndex < document.layers.count - 1
    }

    func canMoveActiveLayerDown() -> Bool {
        activeLayerIndex > 0
    }

    func moveSelectedShapeForward() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeForward(id: shapeID) else { return }
        rerender()
    }

    func moveSelectedShapeBackward() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeBackward(id: shapeID) else { return }
        rerender()
    }

    func moveSelectedShapeToFront() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeToFront(id: shapeID) else { return }
        rerender()
    }

    func moveSelectedShapeToBack() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeToBack(id: shapeID) else { return }
        rerender()
    }

    func moveShapeForward(_ shapeID: UUID) {
        recordSnapshot()
        guard document.moveShapeForward(id: shapeID) else { return }
        rerender()
    }

    func moveShapeBackward(_ shapeID: UUID) {
        recordSnapshot()
        guard document.moveShapeBackward(id: shapeID) else { return }
        rerender()
    }

    func moveShapeToFront(_ shapeID: UUID) {
        recordSnapshot()
        guard document.moveShapeToFront(id: shapeID) else { return }
        rerender()
    }

    func moveShapeToBack(_ shapeID: UUID) {
        recordSnapshot()
        guard document.moveShapeToBack(id: shapeID) else { return }
        rerender()
    }

    func canMoveShapeForward(_ shapeID: UUID) -> Bool {
        document.canMoveShapeForward(id: shapeID)
    }

    func canMoveShapeBackward(_ shapeID: UUID) -> Bool {
        document.canMoveShapeBackward(id: shapeID)
    }

    func canMoveSelectedShapeForward() -> Bool {
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return false }
        return document.canMoveShapeForward(id: shapeID)
    }

    func canMoveSelectedShapeBackward() -> Bool {
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return false }
        return document.canMoveShapeBackward(id: shapeID)
    }

    func canGroupSelectedShapes() -> Bool {
        guard selectedShapeIDs.count > 1 else { return false }

        var selectedLayerIndex: Int?
        for shapeID in selectedShapeIDs {
            guard let layerIndex = document.layerIndex(containingShape: shapeID),
                !document.layers[layerIndex].isLocked
            else { return false }

            if let selectedLayerIndex {
                guard selectedLayerIndex == layerIndex else { return false }
            } else {
                selectedLayerIndex = layerIndex
            }
        }

        return true
    }

    func groupSelectedShapes() {
        enteredGroupID = nil
        recordSnapshot()
        guard canGroupSelectedShapes(),
            let firstSelectedShapeID = selectedShapeIDs.first,
            let layerIndex = document.layerIndex(containingShape: firstSelectedShapeID)
        else { return }

        var layer = document.layers[layerIndex]
        let selectedIDs = selectedShapeIDs

        // Ensure shapes belong to one group only by removing them from existing groups first.
        layer.removeShapesFromGroups(ids: selectedIDs)

        let orderedShapeIDs = layer.shapes.map(\.id).filter { selectedIDs.contains($0) }
        guard orderedShapeIDs.count > 1 else { return }

        let group = ShapeGroup(name: nextGroupName(in: layer), shapeIDs: orderedShapeIDs)
        layer.groups.append(group)
        document.layers[layerIndex] = layer
        expandedItemIDs.insert(layer.id)
        expandedItemIDs.insert(group.id)
        rerender()
    }

    func canUngroupSelectedShapes() -> Bool {
        guard !selectedShapeIDs.isEmpty else { return false }
        for shapeID in selectedShapeIDs {
            guard let layerIndex = document.layerIndex(containingShape: shapeID),
                !document.layers[layerIndex].isLocked
            else { return false }
            let layer = document.layers[layerIndex]
            for group in layer.groups {
                if !group.allShapeIDs.isDisjoint(with: selectedShapeIDs) {
                    return true
                }
            }
        }
        return false
    }

    func ungroupSelectedShapes() {
        enteredGroupID = nil
        recordSnapshot()
        guard !selectedShapeIDs.isEmpty else { return }

        var layerIndicesProcessed = Set<Int>()
        for shapeID in selectedShapeIDs {
            guard let layerIndex = document.layerIndex(containingShape: shapeID) else { continue }
            layerIndicesProcessed.insert(layerIndex)
        }

        for layerIndex in layerIndicesProcessed {
            guard !document.layers[layerIndex].isLocked else { continue }
            var layer = document.layers[layerIndex]
            layer.groups = ungroupedGroups(layer.groups, selectedIDs: selectedShapeIDs)
            document.layers[layerIndex] = layer
        }
        rerender()
    }

    private func ungroupedGroups(
        _ groups: [ShapeGroup],
        selectedIDs: Set<UUID>
    ) -> [ShapeGroup] {
        var result: [ShapeGroup] = []
        for var group in groups {
            group.children = ungroupedGroups(group.children, selectedIDs: selectedIDs)
            if !group.allShapeIDs.isDisjoint(with: selectedIDs) {
                // Promote children to siblings; drop this group entirely
                result.append(contentsOf: group.children)
            } else {
                result.append(group)
            }
        }
        return result
    }

    func canSelectAllShapes() -> Bool {
        guard !isEditingText,
            document.layers.indices.contains(activeLayerIndex)
        else { return false }
        return !document.layers[activeLayerIndex].shapes.isEmpty
    }

    func selectAllShapes() {
        guard canSelectAllShapes() else { return }
        let layer = document.layers[activeLayerIndex]
        selectedShapeIDs = Set(layer.shapes.map(\.id))
        activeToolType = .select
    }

    func canCutSelectedShapes() -> Bool {
        !isEditingText && !selectedShapeIDs.isEmpty
    }

    func cutSelectedShapes() {
        copySelectedShapesToClipboard()
        deleteSelectedShapes()
    }

    func canDuplicateSelectedShapes() -> Bool {
        !isEditingText && !selectedShapeIDs.isEmpty
    }

    func duplicateSelectedShapes() {
        guard let payloadData = selectedShapesClipboardPayloadData(),
            let payload = decodeShapeClipboardPayload(from: payloadData),
            !payload.shapes.isEmpty,
            document.layers.indices.contains(activeLayerIndex),
            !document.layers[activeLayerIndex].isLocked
        else { return }

        recordSnapshot()

        let idMap = Dictionary(uniqueKeysWithValues: payload.shapes.map { ($0.id, UUID()) })
        var duplicatedIDs: Set<UUID> = []

        for shape in payload.shapes {
            guard let newID = idMap[shape.id] else { continue }
            let remapped = remappedShapeForClipboardPaste(shape, newID: newID, idMap: idMap)
            let translated = translatedShape(
                remapped,
                dx: Self.pasteOffset.column,
                dy: Self.pasteOffset.row
            )
            document.addShape(translated, toLayerAt: activeLayerIndex)
            duplicatedIDs.insert(translated.id)
        }

        selectedShapeIDs = duplicatedIDs
        activeToolType = .select
        rerender()
    }

    func moveLayer(draggedLayerID: UUID, before targetLayerID: UUID) {
        recordSnapshot()
        let activeLayerID =
            document.layers.indices.contains(activeLayerIndex)
            ? document.layers[activeLayerIndex].id
            : nil
        guard document.moveLayer(id: draggedLayerID, before: targetLayerID) else { return }
        if let activeLayerID,
            let newActive = document.layers.firstIndex(where: { $0.id == activeLayerID })
        {
            activeLayerIndex = newActive
        }
        rerender()
    }

    func moveLayer(draggedLayerID: UUID, after targetLayerID: UUID) {
        recordSnapshot()
        let activeLayerID =
            document.layers.indices.contains(activeLayerIndex)
            ? document.layers[activeLayerIndex].id
            : nil
        guard document.moveLayer(id: draggedLayerID, after: targetLayerID) else { return }
        if let activeLayerID,
            let newActive = document.layers.firstIndex(where: { $0.id == activeLayerID })
        {
            activeLayerIndex = newActive
        }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, before targetShapeID: UUID, in layerID: UUID) {
        recordSnapshot()
        guard document.moveShape(id: draggedShapeID, before: targetShapeID, in: layerID) else { return }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, after targetShapeID: UUID, in layerID: UUID) {
        recordSnapshot()
        guard document.moveShape(id: draggedShapeID, after: targetShapeID, in: layerID) else { return }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, toLayer targetLayerID: UUID) {
        recordSnapshot()
        guard document.moveShape(id: draggedShapeID, toLayer: targetLayerID) else { return }
        if let newLayerIndex = document.layerIndex(containingShape: draggedShapeID) {
            activeLayerIndex = newLayerIndex
        }
        rerender()
    }

    func toggleExpanded(_ itemID: UUID) {
        if expandedItemIDs.contains(itemID) {
            expandedItemIDs.remove(itemID)
        } else {
            expandedItemIDs.insert(itemID)
        }
    }

    func selectShapeFromPanel(_ shapeID: UUID, extending: Bool = false) {
        if extending {
            if selectedShapeIDs.contains(shapeID) {
                selectedShapeIDs.remove(shapeID)
            } else {
                selectedShapeIDs.insert(shapeID)
            }
        } else {
            selectedShapeIDs = [shapeID]
        }
        for (index, layer) in document.layers.enumerated() {
            if layer.findShape(id: shapeID) != nil {
                activeLayerIndex = index
                break
            }
        }
    }

    func renameShapeFromPanel(_ shapeID: UUID, to newName: String) {
        recordSnapshot()
        for layerIndex in document.layers.indices {
            guard let shapeIndex = document.layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID }) else {
                continue
            }
            document.layers[layerIndex].shapes[shapeIndex] = document.layers[layerIndex].shapes[shapeIndex]
                .renamedForPanel(newName)
            return
        }
    }

    func renameGroupFromPanel(_ groupID: UUID, to newName: String) {
        recordSnapshot()
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        for layerIndex in document.layers.indices {
            if document.layers[layerIndex].renameGroup(id: groupID, to: trimmed) {
                return
            }
        }
    }

    private func nextGroupName(in layer: Layer) -> String {
        let existingNames = Set(layer.groups.map(\.name))
        var index = 1
        while existingNames.contains("Group \(index)") {
            index += 1
        }
        return "Group \(index)"
    }

    // MARK: - Canvas auto-grow

    func expandCanvasForScrollIfNeeded(
        visibleMaxColumn: Int,
        visibleMaxRow: Int,
        deltaX: CGFloat,
        deltaY: CGFloat
    ) {
        let edgeThresholdColumns = 5
        let edgeThresholdRows = 3
        let growthColumns = 20
        let growthRows = 10
        let padding = 10

        var newWidth = document.canvasSize.width
        var newHeight = document.canvasSize.height
        var minimumWidth = Canvas.defaultColumns
        var minimumHeight = Canvas.defaultRows

        if let bbox = document.boundingBox() {
            minimumWidth = max(minimumWidth, bbox.maxColumn + 1 + padding)
            minimumHeight = max(minimumHeight, bbox.maxRow + 1 + padding)
        }

        if deltaX > 0, visibleMaxColumn >= (document.canvasSize.width - edgeThresholdColumns) {
            newWidth += growthColumns
        } else if deltaX < 0, newWidth > minimumWidth {
            let shrinkLimit = max(minimumWidth, visibleMaxColumn + edgeThresholdColumns)
            if (newWidth - shrinkLimit) >= growthColumns {
                newWidth = max(minimumWidth, newWidth - growthColumns)
            }
        }

        if deltaY > 0, visibleMaxRow >= (document.canvasSize.height - edgeThresholdRows) {
            newHeight += growthRows
        } else if deltaY < 0, newHeight > minimumHeight {
            let shrinkLimit = max(minimumHeight, visibleMaxRow + edgeThresholdRows)
            if (newHeight - shrinkLimit) >= growthRows {
                newHeight = max(minimumHeight, newHeight - growthRows)
            }
        }

        let newSize = GridSize(width: newWidth, height: newHeight)
        guard newSize != document.canvasSize else { return }
        document.canvasSize = newSize
        rerender()
    }

    func expandCanvasIfNeeded() {
        let padding = 10
        var requiredWidth = max(Canvas.defaultColumns, document.canvasSize.width)
        var requiredHeight = max(Canvas.defaultRows, document.canvasSize.height)

        // Expand to fit all shapes with padding
        if let bbox = document.boundingBox() {
            requiredWidth = max(requiredWidth, bbox.maxColumn + 1 + padding)
            requiredHeight = max(requiredHeight, bbox.maxRow + 1 + padding)
        }

        // Expand to fill viewport (using charSize estimate for conversion)
        if viewportSize.width > 0 && viewportSize.height > 0 {
            let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            let charSize = ("M" as NSString).size(withAttributes: [.font: font])
            let viewportCols = Int(ceil(viewportSize.width / charSize.width))
            let viewportRows = Int(ceil(viewportSize.height / charSize.height))
            requiredWidth = max(requiredWidth, viewportCols)
            requiredHeight = max(requiredHeight, viewportRows)
        }

        let newSize = GridSize(width: requiredWidth, height: requiredHeight)
        if newSize != document.canvasSize {
            document.canvasSize = newSize
        }
    }

    // MARK: - Rendering

    func rerender() {
        expandCanvasIfNeeded()
        canvas = Canvas(size: document.canvasSize)

        // Render document shapes
        document.render(into: &canvas)

        // Render tool preview on top
        if let preview = activeTool.previewShape() {
            preview.render(into: &canvas)
        }
    }

    // MARK: - Arrow attachments

    private func updateShapeAndAttachments(_ shape: AnyShape) {
        document.updateShape(shape)

        if case .rectangle(let rectangle) = shape {
            rerouteAttachedArrows(for: rectangle.id)
        }
    }

    private func detachArrows(referencing shapeID: UUID) {
        for layerIndex in document.layers.indices {
            for shapeIndex in document.layers[layerIndex].shapes.indices {
                guard case .arrow(var arrow) = document.layers[layerIndex].shapes[shapeIndex] else {
                    continue
                }

                var mutated = false
                if arrow.startAttachment?.shapeID == shapeID {
                    arrow.startAttachment = nil
                    mutated = true
                }
                if arrow.endAttachment?.shapeID == shapeID {
                    arrow.endAttachment = nil
                    mutated = true
                }
                if mutated {
                    document.layers[layerIndex].shapes[shapeIndex] = .arrow(arrow)
                }
            }
        }
    }

    private func rerouteAttachedArrows(for shapeID: UUID) {
        for layerIndex in document.layers.indices {
            for shapeIndex in document.layers[layerIndex].shapes.indices {
                guard case .arrow(var arrow) = document.layers[layerIndex].shapes[shapeIndex] else {
                    continue
                }

                let referencesShape =
                    arrow.startAttachment?.shapeID == shapeID
                    || arrow.endAttachment?.shapeID == shapeID
                guard referencesShape else { continue }

                let startResolved = resolveAttachment(arrow.startAttachment)
                let endResolved = resolveAttachment(arrow.endAttachment)

                if let startResolved {
                    arrow.start = startResolved.point
                } else if arrow.startAttachment != nil {
                    arrow.startAttachment = nil
                }

                if let endResolved {
                    arrow.end = endResolved.point
                } else if arrow.endAttachment != nil {
                    arrow.endAttachment = nil
                }

                arrow.bendDirection = ArrowRouter.bendDirection(
                    start: arrow.start,
                    end: arrow.end,
                    startSide: startResolved?.side ?? arrow.startAttachment?.side,
                    endSide: endResolved?.side ?? arrow.endAttachment?.side
                )

                document.layers[layerIndex].shapes[shapeIndex] = .arrow(arrow)
            }
        }
    }

    private func resolveAttachment(_ attachment: ArrowAttachment?) -> (point: GridPoint, side: ArrowAttachmentSide)? {
        guard let attachment else { return nil }
        guard let shape = document.findShape(id: attachment.shapeID),
            case .rectangle(let rectangle) = shape
        else {
            return nil
        }

        return (rectangle.attachmentPoint(for: attachment.side), attachment.side)
    }

    private func translatedForSelectionMove(shape: AnyShape, dx: Int, dy: Int) -> AnyShape {
        switch shape {
        case .rectangle(var rectangle):
            rectangle.origin = GridPoint(
                column: rectangle.origin.column + dx,
                row: rectangle.origin.row + dy
            )
            return .rectangle(rectangle)
        case .arrow(var arrow):
            arrow.start = GridPoint(
                column: arrow.start.column + dx,
                row: arrow.start.row + dy
            )
            arrow.end = GridPoint(
                column: arrow.end.column + dx,
                row: arrow.end.row + dy
            )

            // Preserve only attachments to shapes that are currently selected and moving.
            if let attachment = arrow.startAttachment,
                !selectedShapeIDs.contains(attachment.shapeID)
            {
                arrow.startAttachment = nil
            }
            if let attachment = arrow.endAttachment,
                !selectedShapeIDs.contains(attachment.shapeID)
            {
                arrow.endAttachment = nil
            }

            return .arrow(arrow)
        case .text(var text):
            text.origin = GridPoint(
                column: text.origin.column + dx,
                row: text.origin.row + dy
            )
            return .text(text)
        case .pencil(var pencil):
            pencil.origin = GridPoint(
                column: pencil.origin.column + dx,
                row: pencil.origin.row + dy
            )
            return .pencil(pencil)
        }
    }
}
