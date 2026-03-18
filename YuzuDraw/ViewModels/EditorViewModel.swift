import os
import SwiftUI

private let layerPanelLog = OSLog(subsystem: "com.yuzudraw", category: "LayerPanel")

enum ColorTarget: Hashable {
    case rectangleBorder
    case rectangleFill
    case rectangleText
    case arrowStroke
    case arrowLabel
    case textColor
    case pencilColor
    case pencilToolColor
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
        var sourceGroupID: UUID?
        /// When a whole group is copied, stores the group structure so paste can recreate it as a sibling.
        var copiedGroupStructure: ShapeGroup?
    }

    private static let shapeClipboardType = NSPasteboard.PasteboardType("com.yuzudraw.shapes")
    private static let pasteOffset = GridPoint(column: 2, row: 1)
    private let clipboardClient: ClipboardClient

    var document: Document
    var canvas: Canvas
    var selectedShapeIDs: Set<UUID> = []
    var activeToolType: ToolType = .select {
        didSet {
            if activeToolType != oldValue {
                enteredGroupID = nil
            }
        }
    }
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

    func replaceDocument(_ newDocument: Document) {
        undoStack.removeAll()
        redoStack.removeAll()
        document = newDocument
        selectedShapeIDs = []
        enteredGroupID = nil
        rerender()
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func beginColorPickerDrag() {
        recordSnapshot()
        isInDragOperation = true
    }

    func endColorPickerDrag() {
        isInDragOperation = false
        if undoStack.last == document {
            undoStack.removeLast()
        }
    }

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
        case .hand: return selectionTool
        case .rectangle: return rectangleTool
        case .arrow: return arrowTool
        case .text: return textTool
        case .pencil: return pencilTool
        }
    }

    var arrowAttachmentPreviewPoints: [GridPoint] {
        if isOptionKeyPressed { return [] }
        switch activeToolType {
        case .arrow:
            return arrowTool.attachmentPreviewPoints(near: hoverGridPoint, in: document)
        case .select:
            return selectionTool.arrowAttachmentPreviewPoints
        case .hand, .rectangle, .text, .pencil:
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

    init(
        document: Document = Document(),
        clipboardClient: ClipboardClient = SystemClipboardClient()
    ) {
        self.document = document
        self.clipboardClient = clipboardClient
        self.canvas = Canvas(size: document.canvasSize)
        expandedItemIDs = []
        rerender()
    }

    // MARK: - Mouse events

    func mouseDown(at point: GridPoint) {
        sanitizeSelectionAndEnteredGroup()
        if activeColorTarget != nil {
            closeColorPicker()
        }
        if isEditingText {
            commitTextEdit()
        }
        let optionDown = NSEvent.modifierFlags.contains(.option)
        isOptionKeyPressed = optionDown
        arrowTool.suppressAttachment = optionDown
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

        let action = activeTool.mouseDown(at: point, in: document)

        if activeToolType == .select {
            applyGroupAwareAction(action)
        } else {
            applyAction(action)
        }
    }

    func handleDoubleClick(at point: GridPoint) {
        guard let shape = document.hitTest(at: point) else { return }

        // Group handling: if shape is in a group, double-click enters the group
        if let rootGroup = document.findRootGroup(containingShape: shape.id) {
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
            let ancestry = document.findGroupAncestry(containingShape: shape.id)
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
        let optionDown = NSEvent.modifierFlags.contains(.option)
        isOptionKeyPressed = optionDown
        arrowTool.suppressAttachment = optionDown
        if activeToolType == .arrow {
            hoverGridPoint = point
        }
        let action = activeTool.mouseDragged(to: point, in: document)
        applyAction(action)
        rerender()
    }

    func mouseUp(at point: GridPoint) {
        let optionDown = NSEvent.modifierFlags.contains(.option)
        isOptionKeyPressed = optionDown
        arrowTool.suppressAttachment = optionDown
        selectionTool.isShiftKeyPressed = isShiftKeyPressed
        let action = activeTool.mouseUp(at: point, in: document)

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
        // Force a view update so non-observed tool state (e.g. marquee rect)
        // is picked up by SwiftUI.
        rerender()
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
        case .addShape(let shape):
            document.addShape(shape)
            selectedShapeIDs = [shape.id]
            if case .pencil = shape {
                // Stay in pencil mode so the user can keep drawing
            } else {
                activeToolType = .select
            }
            rerender()
        case .selectShape(let id):
            if let id, document.isShapeSelectable(id) {
                selectedShapeIDs = [id]
            } else {
                selectedShapeIDs = []
            }
        case .selectShapes(let ids):
            selectedShapeIDs = Set(ids.filter { document.isShapeSelectable($0) })
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
            guard document.isShapeSelectable(id) else { break }
            selectedShapeIDs.insert(id)
        case .removeShapeFromSelection(let id):
            selectedShapeIDs.remove(id)
        case .addShapesToSelection(let ids):
            selectedShapeIDs.formUnion(ids.filter { document.isShapeSelectable($0) })
        }
    }

    // MARK: - Group-aware selection

    func resolveGroupSelection(forShapeID shapeID: UUID) -> (shapeIDs: Set<UUID>, groupID: UUID?) {
        guard document.isShapeSelectable(shapeID) else {
            return ([], nil)
        }
        guard let rootGroup = document.findRootGroup(containingShape: shapeID) else {
            return ([shapeID], nil)
        }
        guard let enteredGroupID else {
            return (rootGroup.allShapeIDs, rootGroup.id)
        }

        // Walk the ancestry to find the entered group, then resolve within it
        let ancestry = document.findGroupAncestry(containingShape: shapeID)
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
        guard !selectedShapeIDs.isEmpty else { return nil }
        for group in document.groups {
            let groupIDs = group.allShapeIDs
            if !groupIDs.isEmpty, groupIDs == selectedShapeIDs {
                return group
            }
        }
        // Also check nested groups
        return findSelectedGroupRecursive(in: document.groups)
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
            guard let rootGroup = document.findRootGroup(containingShape: id)
            else {
                // Ungrouped shape — clear group state, select normally
                enteredGroupID = nil
                applyAction(action)
                return
            }

            if enteredGroupID != nil, isAncestor(groupID: enteredGroupID!, of: id) {
                // Already inside entered group — check if current selection matches a sub-group
                if let selectedSubGroup = findSelectedSubGroup(within: enteredGroupID!),
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
            } else if let currentGroup = isGroupSelected(), currentGroup.id == rootGroup.id || isAncestor(group: currentGroup, of: id) {
                // Group (or ancestor) is already selected — enter group, select inner target
                enteredGroupID = currentGroup.id
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs = resolved.shapeIDs
            } else {
                // Group not selected — select entire root group
                enteredGroupID = nil
                selectedShapeIDs = Set(rootGroup.allShapeIDs.filter { document.isShapeSelectable($0) })
            }

        case .addShapeToSelection(let id):
            guard let rootGroup = document.findRootGroup(containingShape: id)
            else {
                applyAction(action)
                return
            }
            if enteredGroupID != nil {
                // Inside entered group, shift+click adds individual shape or sub-group
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs.formUnion(resolved.shapeIDs)
            } else {
                selectedShapeIDs.formUnion(rootGroup.allShapeIDs.filter { document.isShapeSelectable($0) })
            }

        case .removeShapeFromSelection(let id):
            guard let rootGroup = document.findRootGroup(containingShape: id)
            else {
                applyAction(action)
                return
            }
            if enteredGroupID != nil {
                let resolved = resolveGroupSelection(forShapeID: id)
                selectedShapeIDs.subtract(resolved.shapeIDs)
            } else {
                selectedShapeIDs.subtract(rootGroup.allShapeIDs.filter { document.isShapeSelectable($0) })
            }

        default:
            // For all other actions (updateShape, updateShapes, addShapesToSelection, etc.)
            applyAction(action)
        }
    }

    private func isAncestor(group: ShapeGroup, of shapeID: UUID) -> Bool {
        let ancestry = document.findGroupAncestry(containingShape: shapeID)
        return ancestry.contains { $0.id == group.id }
    }

    private func findSelectedSubGroup(within parentGroupID: UUID) -> ShapeGroup? {
        guard !selectedShapeIDs.isEmpty else { return nil }
        // Find the parent group, then check if selection matches any of its child groups
        guard let parentGroup = document.findGroupByID(parentGroupID) else { return nil }
        for child in parentGroup.children {
            if child.allShapeIDs == selectedShapeIDs {
                return child
            }
        }
        return nil
    }

    private func isAncestor(groupID: UUID, of shapeID: UUID) -> Bool {
        let ancestry = document.findGroupAncestry(containingShape: shapeID)
        return ancestry.contains { $0.id == groupID }
    }

    var selectedGroupBoundingRect: GridRect? {
        guard enteredGroupID == nil, !selectedShapeIDs.isEmpty else { return nil }

        // Check if the selection matches a group's allShapeIDs
        let matchesGroup = document.groups.contains { group in
            let ids = group.allShapeIDs
            return !ids.isEmpty && ids == selectedShapeIDs
        } || findSelectedGroupRecursive(in: document.groups) != nil

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
            let ancestry = findGroupContaining(groupID: enteredGroupID, in: document.groups)
            if let parentGroup = ancestry {
                // Re-select the parent group
                selectedShapeIDs = Set(parentGroup.allShapeIDs.filter { document.isShapeSelectable($0) })
                self.enteredGroupID = nil
            } else {
                // enteredGroupID is a root group — find it and select it
                if let group = document.groups.first(where: { $0.id == enteredGroupID }) {
                    selectedShapeIDs = Set(group.allShapeIDs.filter { document.isShapeSelectable($0) })
                }
                self.enteredGroupID = nil
            }
            return true
        } else if !selectedShapeIDs.isEmpty {
            selectedShapeIDs = []
            return true
        } else if activeToolType != .select {
            activeToolType = .select
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
            document.addShape(.text(textShape))
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
        selectedShapeIDs.compactMap { id in
            guard document.isShapeSelectable(id) else { return nil }
            return document.findShape(id: id)
        }
    }

    var selectedShape: AnyShape? {
        guard selectedShapeIDs.count == 1, let id = selectedShapeIDs.first else { return nil }
        guard document.isShapeSelectable(id) else { return nil }
        return document.findShape(id: id)
    }

    var documentColors: [ShapeColor] {
        var seen = Set<ShapeColor>()
        var result: [ShapeColor] = []
        for color in [ShapeColor.black, .white] {
            seen.insert(color)
            result.append(color)
        }
        for shape in document.shapes {
            for color in shape.colors {
                if seen.insert(color).inserted {
                    result.append(color)
                }
            }
        }
        return result
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

    var multiSelectRectFloat: Bool? { uniformValue(selectedRectangles.map(\.float)) }

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

    func updateMultiSelectRectFloat(_ float: Bool) {
        recordSnapshot()
        for shape in selectedShapes {
            if case .rectangle(var rectangle) = shape {
                rectangle.float = float
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
                switch fillMode {
                case .none:
                    break
                case .opaque:
                    rectangle.fillCharacter = " "
                case .block:
                    if !Self.blockCharacters.contains(rectangle.fillCharacter) {
                        rectangle.fillCharacter = "\u{2588}"
                    }
                case .character:
                    if rectangle.fillCharacter == " " {
                        rectangle.fillCharacter = "*"
                    }
                }
                updateShapeAndAttachments(.rectangle(rectangle))
            }
        }
        rerender()
    }

    func updateMultiSelectRectFillEnabled(_ isEnabled: Bool) {
        updateMultiSelectRectFillMode(isEnabled ? .opaque : .none)
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

    func updateSelectedRectangleFloat(_ float: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .rectangle(var rectangle) = shape
        else { return }
        rectangle.float = float
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
        switch fillMode {
        case .none:
            break
        case .opaque:
            rectangle.fillCharacter = " "
        case .block:
            if !Self.blockCharacters.contains(rectangle.fillCharacter) {
                rectangle.fillCharacter = "\u{2588}"
            }
        case .character:
            if rectangle.fillCharacter == " " {
                rectangle.fillCharacter = "*"
            }
        }
        updateShapeAndAttachments(.rectangle(rectangle))
        rerender()
    }

    static let blockCharacters: Set<Character> = [
        "\u{2588}", "\u{2593}", "\u{2592}", "\u{2591}",
        "\u{00B7}", "#", ".", "~",
    ]

    func updateSelectedRectangleFillEnabled(_ isEnabled: Bool) {
        updateSelectedRectangleFillMode(isEnabled ? .opaque : .none)
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

    func updateSelectedArrowFloat(_ float: Bool) {
        recordSnapshot()
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.float = float
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

    // MARK: - Clipboard and export

    func canCopySelectedShapes() -> Bool {
        !isEditingText && !selectedShapesInDocumentOrder().isEmpty
    }

    func canCopySelectionAsPlainText() -> Bool {
        !isEditingText && (document.hasContent || !selectedShapesInDocumentOrder().isEmpty)
    }

    func canCopySelectionAsDSL() -> Bool {
        !isEditingText && !selectedShapesInDocumentOrder().isEmpty
    }

    func canCopySelectionAsPNG() -> Bool {
        !isEditingText && !selectedShapesInDocumentOrder().isEmpty
    }

    func canPasteShapesFromClipboard() -> Bool {
        guard !isEditingText,
            let payloadData = clipboardPayloadData(from: clipboardClient)
        else { return false }
        return decodeShapeClipboardPayload(from: payloadData) != nil
    }

    func copySelectedShapesToClipboard() {
        guard let payloadData = selectedShapesClipboardPayloadData() else { return }
        if let plainText = selectionOrCanvasPlainText() {
            clipboardClient.writeItem(
                data: payloadData, dataType: Self.shapeClipboardType,
                string: plainText, stringType: .string
            )
        } else {
            clipboardClient.clearContents()
            clipboardClient.setData(payloadData, forType: Self.shapeClipboardType)
        }
        lastPastedPayloadData = nil
        consecutivePasteCount = 0
    }

    @discardableResult
    func pasteShapesFromClipboard() -> Bool {
        guard let payloadData = clipboardPayloadData(from: clipboardClient) else { return false }
        return pasteShapes(fromClipboardPayloadData: payloadData)
    }

    @discardableResult
    func pasteShapes(fromClipboardPayloadData payloadData: Data) -> Bool {
        guard !isEditingText,
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
        var pastedShapeIDsInOrder: [UUID] = []

        for shape in payload.shapes {
            guard let newID = idMap[shape.id] else { continue }
            let remappedShape = remappedShapeForClipboardPaste(shape, newID: newID, idMap: idMap)
            let translated = translatedShape(remappedShape, dx: dx, dy: dy)
            document.addShape(translated)
            pastedShapeIDs.insert(translated.id)
            pastedShapeIDsInOrder.append(translated.id)
        }

        if let copiedGroup = payload.copiedGroupStructure {
            // Whole group was copied — recreate group structure as a sibling
            let newGroup = copiedGroup.remappingIDs(idMap)
            _ = document.insertSiblingGroup(newGroup, nextTo: copiedGroup.id)
            document.consolidateGroup(newGroup.id)
        } else if let sourceGroupID = payload.sourceGroupID {
            _ = document.appendShapesToGroup(ids: pastedShapeIDsInOrder, groupID: sourceGroupID)
        }

        selectedShapeIDs = pastedShapeIDs
        activeToolType = .select
        rerender()
        return true
    }

    func selectedShapesClipboardPayloadData() -> Data? {
        let shapes = selectedShapesInDocumentOrder()
        guard !shapes.isEmpty else { return nil }
        let (sourceGroupID, copiedGroupStructure) = selectedShapesSourceGroupInfo()
        let payload = ShapeClipboardPayload(
            shapes: shapes,
            sourceGroupID: sourceGroupID,
            copiedGroupStructure: copiedGroupStructure
        )
        let encoder = JSONEncoder()
        return try? encoder.encode(payload)
    }

    private func selectedShapesSourceGroupInfo() -> (sourceGroupID: UUID?, copiedGroupStructure: ShapeGroup?) {
        let selectedIDs = selectedShapeIDs

        if let selectedGroupID = topMostSelectedGroupID(selectedIDs: selectedIDs),
           let group = document.findGroupByID(selectedGroupID),
           group.allShapeIDs == selectedIDs {
            // Entire group is selected — store its structure so paste creates a sibling group
            let parentID = document.parentGroupID(of: selectedGroupID)
            return (parentID, group)
        }

        // Partial selection within a group — use the existing "paste into same group" behavior
        if let selectedGroupID = topMostSelectedGroupID(selectedIDs: selectedIDs) {
            return (selectedGroupID, nil)
        }

        let orderedShapes = selectedShapesInDocumentOrder()
        guard let firstShapeID = orderedShapes.first?.id else { return (nil, nil) }
        let groupID = document.findGroupAncestry(containingShape: firstShapeID).last?.id
        return (groupID, nil)
    }

    private func topMostSelectedGroupID(selectedIDs: Set<UUID>) -> UUID? {
        func visit(_ groups: [ShapeGroup]) -> UUID? {
            for group in groups {
                let memberIDs = group.allShapeIDs
                if !memberIDs.isEmpty, memberIDs.isSubset(of: selectedIDs) {
                    return group.id
                }
                if let found = visit(group.children) {
                    return found
                }
            }
            return nil
        }
        return visit(document.groups)
    }

    func copySelectionAsPlainTextToClipboard() {
        guard let dsl = selectionDSL() else { return }
        clipboardClient.clearContents()
        clipboardClient.setString(dsl, forType: .string)
    }

    func copySelectionAsDSLToClipboard() {
        guard let dsl = selectionDSL() else { return }
        clipboardClient.clearContents()
        clipboardClient.setString(dsl, forType: .string)
    }

    func copySelectionAsPNGToClipboard(scale: Int = 1, backgroundColor: ShapeColor? = nil) {
        guard
            let canvas = selectedShapesExportCanvas(),
            let data = pngData(from: canvas, scale: scale, backgroundColor: backgroundColor)
        else { return }

        clipboardClient.clearContents()
        clipboardClient.setData(data, forType: .png)
    }

    func selectionOrCanvasPlainText() -> String? {
        let selectedShapes = selectedShapesInDocumentOrder()
        if !selectedShapes.isEmpty {
            return plainText(for: selectedShapes)
        }
        guard document.hasContent else { return nil }
        return canvas.render()
    }

    func selectionDSL() -> String? {
        let selectedIDs = Set(selectedShapesInDocumentOrder().map(\.id))
        guard !selectedIDs.isEmpty else { return nil }

        let selectionDocument = Document(
            shapes: selectedShapesInDocumentOrder(),
            groups: selectedGroups(from: document.groups, selectedIDs: selectedIDs),
            canvasSize: document.canvasSize,
            palette: document.palette
        )
        return DSLSerializer.serialize(selectionDocument)
    }

    private func selectedShapesInDocumentOrder() -> [AnyShape] {
        document.shapes.filter {
            selectedShapeIDs.contains($0.id) && document.isShapeSelectable($0.id)
        }
    }

    private func selectedGroups(from groups: [ShapeGroup], selectedIDs: Set<UUID>) -> [ShapeGroup] {
        groups.compactMap { selectedGroup(from: $0, selectedIDs: selectedIDs) }
    }

    private func selectedGroup(from group: ShapeGroup, selectedIDs: Set<UUID>) -> ShapeGroup? {
        let selectedChildren = selectedGroups(from: group.children, selectedIDs: selectedIDs)
        let selectedShapeIDs = group.shapeIDs.filter { selectedIDs.contains($0) }

        guard !selectedShapeIDs.isEmpty || !selectedChildren.isEmpty else { return nil }

        return ShapeGroup(
            id: group.id,
            name: group.name,
            shapeIDs: selectedShapeIDs,
            children: selectedChildren
        )
    }

    private func selectedShapesExportCanvas() -> Canvas? {
        let shapes = selectedShapesInDocumentOrder()
        guard !shapes.isEmpty else { return nil }

        let first = shapes[0].renderBoundingRect
        let bounds = shapes.dropFirst().reduce(first) { result, shape in
            let rect = shape.renderBoundingRect
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
        return exportCanvas
    }

    private func clipboardPayloadData(from clipboard: ClipboardClient) -> Data? {
        if let data = clipboard.data(forType: Self.shapeClipboardType) {
            return data
        }
        if let string = clipboard.string(forType: .string) {
            return string.data(using: .utf8)
        }
        return nil
    }

    private func decodeShapeClipboardPayload(from data: Data) -> ShapeClipboardPayload? {
        if let payload = try? JSONDecoder().decode(ShapeClipboardPayload.self, from: data) {
            return payload
        }
        guard let dslString = String(data: data, encoding: .utf8) else { return nil }
        return shapeClipboardPayload(fromDSL: dslString)
    }

    private func shapeClipboardPayload(fromDSL dsl: String) -> ShapeClipboardPayload? {
        guard let document = try? DSLParser.parse(dsl), !document.shapes.isEmpty else { return nil }
        let copiedGroupStructure: ShapeGroup?
        if document.groups.count == 1 {
            copiedGroupStructure = document.groups.first
        } else {
            copiedGroupStructure = nil
        }
        return ShapeClipboardPayload(
            shapes: document.shapes,
            sourceGroupID: nil,
            copiedGroupStructure: copiedGroupStructure
        )
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

        let first = shapes[0].renderBoundingRect
        let bounds = shapes.dropFirst().reduce(first) { result, shape in
            let rect = shape.renderBoundingRect
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

    func exportSelectedShapesAsPNG(scale: Int, backgroundColor: ShapeColor?) {
        guard let canvas = selectedShapesExportCanvas(),
            let pngData = pngData(from: canvas, scale: scale, backgroundColor: backgroundColor)
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "png")!]

        let defaultName: String
        if let group = isGroupSelected() {
            defaultName = "\(group.name).png"
        } else {
            defaultName = "Selection.png"
        }
        panel.nameFieldStringValue = defaultName

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try pngData.write(to: url)
        } catch {
            print("Failed to export PNG: \(error)")
        }
    }

    func exportSelectedShapesAsSVG(backgroundColor: ShapeColor?) {
        guard let canvas = selectedShapesExportCanvas(),
            let data = svgData(from: canvas, backgroundColor: backgroundColor)
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "svg")!]

        let defaultName: String
        if let group = isGroupSelected() {
            defaultName = "\(group.name).svg"
        } else {
            defaultName = "Selection.svg"
        }
        panel.nameFieldStringValue = defaultName

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try data.write(to: url)
        } catch {
            print("Failed to export SVG: \(error)")
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
            guard document.isShapeSelectable(id) else { continue }
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
            guard document.isShapeSelectable(id) else { continue }
            guard let shape = document.findShape(id: id) else { continue }
            let movedShape = translatedForSelectionMove(shape: shape, dx: dx, dy: dy)
            updateShapeAndAttachments(movedShape)
        }
        rerender()
    }

    func moveSelectedShapeForward() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard performGroupAwareMove(shapeID: shapeID, action: .forward) else { return }
        rerender()
    }

    func moveSelectedShapeBackward() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard performGroupAwareMove(shapeID: shapeID, action: .backward) else { return }
        rerender()
    }

    func moveSelectedShapeToFront() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard performGroupAwareMove(shapeID: shapeID, action: .toFront) else { return }
        rerender()
    }

    func moveSelectedShapeToBack() {
        recordSnapshot()
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard performGroupAwareMove(shapeID: shapeID, action: .toBack) else { return }
        rerender()
    }

    func moveShapeForward(_ shapeID: UUID) {
        recordSnapshot()
        guard performGroupAwareMove(shapeID: shapeID, action: .forward) else { return }
        rerender()
    }

    func moveShapeBackward(_ shapeID: UUID) {
        recordSnapshot()
        guard performGroupAwareMove(shapeID: shapeID, action: .backward) else { return }
        rerender()
    }

    func moveShapeToFront(_ shapeID: UUID) {
        recordSnapshot()
        guard performGroupAwareMove(shapeID: shapeID, action: .toFront) else { return }
        rerender()
    }

    func moveShapeToBack(_ shapeID: UUID) {
        recordSnapshot()
        guard performGroupAwareMove(shapeID: shapeID, action: .toBack) else { return }
        rerender()
    }

    func canMoveShapeForward(_ shapeID: UUID) -> Bool {
        canPerformGroupAwareMove(shapeID: shapeID, forward: true)
    }

    func canMoveShapeBackward(_ shapeID: UUID) -> Bool {
        canPerformGroupAwareMove(shapeID: shapeID, forward: false)
    }

    func canMoveSelectedShapeForward() -> Bool {
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return false }
        return canPerformGroupAwareMove(shapeID: shapeID, forward: true)
    }

    func canMoveSelectedShapeBackward() -> Bool {
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return false }
        return canPerformGroupAwareMove(shapeID: shapeID, forward: false)
    }

    // MARK: - Group z-order

    func moveGroupForward(_ groupID: UUID) {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        guard document.moveGroupForward(groupID: groupID) else { return }
        rerender()
    }

    func moveGroupBackward(_ groupID: UUID) {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        guard document.moveGroupBackward(groupID: groupID) else { return }
        rerender()
    }

    func moveGroupToFront(_ groupID: UUID) {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        guard document.moveGroupToFront(groupID: groupID) else { return }
        rerender()
    }

    func moveGroupToBack(_ groupID: UUID) {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        guard document.moveGroupToBack(groupID: groupID) else { return }
        rerender()
    }

    func canMoveGroupForward(_ groupID: UUID) -> Bool {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return false }
        return document.canMoveGroupForward(groupID: groupID)
    }

    func canMoveGroupBackward(_ groupID: UUID) -> Bool {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return false }
        return document.canMoveGroupBackward(groupID: groupID)
    }

    // MARK: - Group-aware move helpers

    private enum ZOrderAction {
        case forward, backward, toFront, toBack
    }

    private func performGroupAwareMove(shapeID: UUID, action: ZOrderAction) -> Bool {
        guard document.isShapeSelectable(shapeID) else { return false }
        if let rootGroup = document.findRootGroup(containingShape: shapeID) {
            guard !document.isGroupLockedEffectively(rootGroup.id),
                  !document.isGroupHiddenEffectively(rootGroup.id)
            else { return false }
            if enteredGroupID != nil {
                // Move within the group
                switch action {
                case .forward:
                    return document.moveShapeWithinGroup(
                        id: shapeID, forward: true, groupID: rootGroup.id)
                case .backward:
                    return document.moveShapeWithinGroup(
                        id: shapeID, forward: false, groupID: rootGroup.id)
                case .toFront:
                    var moved = false
                    while document.moveShapeWithinGroup(
                        id: shapeID, forward: true, groupID: rootGroup.id)
                    {
                        moved = true
                    }
                    return moved
                case .toBack:
                    var moved = false
                    while document.moveShapeWithinGroup(
                        id: shapeID, forward: false, groupID: rootGroup.id)
                    {
                        moved = true
                    }
                    return moved
                }
            } else {
                // Move the whole group
                switch action {
                case .forward:
                    return document.moveGroupForward(groupID: rootGroup.id)
                case .backward:
                    return document.moveGroupBackward(groupID: rootGroup.id)
                case .toFront:
                    return document.moveGroupToFront(groupID: rootGroup.id)
                case .toBack:
                    return document.moveGroupToBack(groupID: rootGroup.id)
                }
            }
        } else {
            // Ungrouped shape — existing behavior
            switch action {
            case .forward: return document.moveShapeForward(id: shapeID)
            case .backward: return document.moveShapeBackward(id: shapeID)
            case .toFront: return document.moveShapeToFront(id: shapeID)
            case .toBack: return document.moveShapeToBack(id: shapeID)
            }
        }
    }

    private func canPerformGroupAwareMove(shapeID: UUID, forward: Bool) -> Bool {
        guard document.isShapeSelectable(shapeID) else { return false }
        if let rootGroup = document.findRootGroup(containingShape: shapeID) {
            guard !document.isGroupLockedEffectively(rootGroup.id),
                  !document.isGroupHiddenEffectively(rootGroup.id)
            else { return false }
            if enteredGroupID != nil {
                return document.canMoveShapeWithinGroup(
                    id: shapeID, forward: forward, groupID: rootGroup.id)
            } else {
                if forward {
                    return document.canMoveGroupForward(groupID: rootGroup.id)
                } else {
                    return document.canMoveGroupBackward(groupID: rootGroup.id)
                }
            }
        } else {
            if forward {
                return document.canMoveShapeForward(id: shapeID)
            } else {
                return document.canMoveShapeBackward(id: shapeID)
            }
        }
    }

    func canGroupSelectedShapes() -> Bool {
        guard !selectedShapeIDs.isEmpty else { return false }

        for shapeID in selectedShapeIDs {
            guard document.findShape(id: shapeID) != nil,
                  document.isShapeSelectable(shapeID)
            else { return false }
        }

        return true
    }

    func groupSelectedShapes() {
        enteredGroupID = nil
        recordSnapshot()
        guard canGroupSelectedShapes() else { return }

        let selectedIDs = selectedShapeIDs

        // Ensure shapes belong to one group only by removing them from existing groups first.
        document.removeShapesFromGroups(ids: selectedIDs)

        let orderedShapeIDs = document.shapes.map(\.id).filter { selectedIDs.contains($0) }
        guard !orderedShapeIDs.isEmpty else { return }

        let group = ShapeGroup(name: nextGroupName(), shapeIDs: orderedShapeIDs)
        document.groups.append(group)
        document.consolidateGroup(group.id)
        expandedItemIDs.insert(group.id)
        rerender()
    }

    func canUngroupSelectedShapes() -> Bool {
        guard !selectedShapeIDs.isEmpty else { return false }
        for group in document.groups {
            if !group.allShapeIDs.isDisjoint(with: selectedShapeIDs) {
                return true
            }
        }
        return false
    }

    func ungroupSelectedShapes() {
        enteredGroupID = nil
        recordSnapshot()
        guard !selectedShapeIDs.isEmpty else { return }
        document.groups = ungroupedGroups(document.groups, selectedIDs: selectedShapeIDs)
        document.pruneOrphanedVisibilityAndLockState()
        sanitizeSelectionAndEnteredGroup()
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
        guard !isEditingText else { return false }
        return !shapeIDsForSelectAll().isEmpty
    }

    func selectAllShapes() {
        guard !isEditingText else { return }
        let shapeIDs = shapeIDsForSelectAll()
        guard !shapeIDs.isEmpty else { return }
        selectedShapeIDs = shapeIDs
        activeToolType = .select
    }

    private func shapeIDsForSelectAll() -> Set<UUID> {
        if let selectedGroup = isGroupSelected() {
            return Set(selectedGroup.allShapeIDs.filter { document.isShapeSelectable($0) })
        }

        if let groupID = innermostGroupIDForCurrentSelection(),
           let group = document.findGroupByID(groupID) {
            return Set(group.allShapeIDs.filter { document.isShapeSelectable($0) })
        }

        return Set(document.shapes.map(\.id).filter { document.isShapeSelectable($0) })
    }

    private func innermostGroupIDForCurrentSelection() -> UUID? {
        guard !selectedShapeIDs.isEmpty else { return nil }

        var innermostGroupID: UUID?

        for shapeID in selectedShapeIDs {
            guard let currentGroupID = document.findGroupAncestry(containingShape: shapeID).last?.id else {
                return nil
            }

            if let innermostGroupID, innermostGroupID != currentGroupID {
                return nil
            }
            innermostGroupID = currentGroupID
        }

        return innermostGroupID
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
            !payload.shapes.isEmpty
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
            document.addShape(translated)
            duplicatedIDs.insert(translated.id)
        }

        selectedShapeIDs = duplicatedIDs
        activeToolType = .select
        rerender()
    }

    func moveShape(draggedShapeID: UUID, before targetShapeID: UUID) {
        guard document.isShapeSelectable(draggedShapeID),
              document.isShapeSelectable(targetShapeID)
        else { return }
        recordSnapshot()
        guard document.moveShape(id: draggedShapeID, before: targetShapeID) else { return }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, after targetShapeID: UUID) {
        guard document.isShapeSelectable(draggedShapeID),
              document.isShapeSelectable(targetShapeID)
        else { return }
        recordSnapshot()
        guard document.moveShape(id: draggedShapeID, after: targetShapeID) else { return }
        rerender()
    }

    func moveGroup(draggedGroupID: UUID, beforeShape targetShapeID: UUID) {
        guard !document.isGroupLockedEffectively(draggedGroupID),
              !document.isGroupHiddenEffectively(draggedGroupID),
              document.isShapeSelectable(targetShapeID)
        else { return }
        recordSnapshot()
        guard document.moveGroup(groupID: draggedGroupID, beforeShape: targetShapeID)
        else { return }
        rerender()
    }

    func moveGroup(draggedGroupID: UUID, afterShape targetShapeID: UUID) {
        guard !document.isGroupLockedEffectively(draggedGroupID),
              !document.isGroupHiddenEffectively(draggedGroupID),
              document.isShapeSelectable(targetShapeID)
        else { return }
        recordSnapshot()
        guard document.moveGroup(groupID: draggedGroupID, afterShape: targetShapeID)
        else { return }
        rerender()
    }

    func moveGroup(draggedGroupID: UUID, beforeGroup targetGroupID: UUID) {
        guard !document.isGroupLockedEffectively(draggedGroupID),
              !document.isGroupHiddenEffectively(draggedGroupID),
              !document.isGroupLockedEffectively(targetGroupID),
              !document.isGroupHiddenEffectively(targetGroupID)
        else { return }
        recordSnapshot()
        guard document.moveGroup(groupID: draggedGroupID, beforeGroup: targetGroupID)
        else { return }
        rerender()
    }

    func moveGroup(draggedGroupID: UUID, afterGroup targetGroupID: UUID) {
        guard !document.isGroupLockedEffectively(draggedGroupID),
              !document.isGroupHiddenEffectively(draggedGroupID),
              !document.isGroupLockedEffectively(targetGroupID),
              !document.isGroupHiddenEffectively(targetGroupID)
        else { return }
        recordSnapshot()
        guard document.moveGroup(groupID: draggedGroupID, afterGroup: targetGroupID)
        else { return }
        rerender()
    }

    func moveShapeToGroup(shapeID: UUID, groupID: UUID) {
        guard document.findShape(id: shapeID) != nil,
              document.isShapeSelectable(shapeID),
              !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        document.removeShapesFromGroups(ids: [shapeID])
        _ = document.appendShapesToGroup(ids: [shapeID], groupID: groupID)
        document.consolidateGroup(groupID)
        rerender()
    }

    func removeShapeFromGroup(shapeID: UUID) {
        guard document.findRootGroup(containingShape: shapeID) != nil,
              document.isShapeSelectable(shapeID)
        else { return }
        recordSnapshot()
        document.removeShapesFromGroups(ids: [shapeID])
        rerender()
    }

    func toggleExpanded(_ itemID: UUID) {
        os_signpost(.begin, log: layerPanelLog, name: "toggleExpanded")
        if expandedItemIDs.contains(itemID) {
            expandedItemIDs.remove(itemID)
        } else {
            expandedItemIDs.insert(itemID)
        }
        os_signpost(.end, log: layerPanelLog, name: "toggleExpanded")
    }

    func selectShapeFromPanel(_ shapeID: UUID, extending: Bool = false) {
        guard document.isShapeSelectable(shapeID) else { return }
        if extending {
            if selectedShapeIDs.contains(shapeID) {
                selectedShapeIDs.remove(shapeID)
            } else {
                selectedShapeIDs.insert(shapeID)
            }
        } else {
            selectedShapeIDs = [shapeID]
        }
    }

    func renameShapeFromPanel(_ shapeID: UUID, to newName: String) {
        guard document.isShapeSelectable(shapeID) else { return }
        recordSnapshot()
        guard let shapeIndex = document.shapes.firstIndex(where: { $0.id == shapeID }) else {
            return
        }
        document.shapes[shapeIndex] = document.shapes[shapeIndex].renamedForPanel(newName)
    }

    func renameGroupFromPanel(_ groupID: UUID, to newName: String) {
        guard !document.isGroupLockedEffectively(groupID),
              !document.isGroupHiddenEffectively(groupID)
        else { return }
        recordSnapshot()
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        _ = document.renameGroup(id: groupID, to: trimmed)
    }

    func isShapeHiddenInPanel(_ shapeID: UUID) -> Bool {
        document.hiddenShapeIDs.contains(shapeID)
    }

    func isShapeLockedInPanel(_ shapeID: UUID) -> Bool {
        document.lockedShapeIDs.contains(shapeID)
    }

    func isGroupHiddenInPanel(_ groupID: UUID) -> Bool {
        document.hiddenGroupIDs.contains(groupID)
    }

    func isGroupLockedInPanel(_ groupID: UUID) -> Bool {
        document.lockedGroupIDs.contains(groupID)
    }

    func toggleShapeHiddenFromPanel(_ shapeID: UUID) {
        guard document.findShape(id: shapeID) != nil else { return }
        recordSnapshot()
        let shouldHide = !document.hiddenShapeIDs.contains(shapeID)
        document.setShapeHidden(shapeID, isHidden: shouldHide)
        sanitizeSelectionAndEnteredGroup()
        rerender()
    }

    func toggleShapeLockedFromPanel(_ shapeID: UUID) {
        guard document.findShape(id: shapeID) != nil else { return }
        recordSnapshot()
        let shouldLock = !document.lockedShapeIDs.contains(shapeID)
        document.setShapeLocked(shapeID, isLocked: shouldLock)
        sanitizeSelectionAndEnteredGroup()
        rerender()
    }

    func toggleGroupHiddenFromPanel(_ groupID: UUID) {
        guard document.findGroupByID(groupID) != nil else { return }
        recordSnapshot()
        let shouldHide = !document.hiddenGroupIDs.contains(groupID)
        document.setGroupHidden(groupID, isHidden: shouldHide)
        sanitizeSelectionAndEnteredGroup()
        rerender()
    }

    func toggleGroupLockedFromPanel(_ groupID: UUID) {
        guard document.findGroupByID(groupID) != nil else { return }
        recordSnapshot()
        let shouldLock = !document.lockedGroupIDs.contains(groupID)
        document.setGroupLocked(groupID, isLocked: shouldLock)
        sanitizeSelectionAndEnteredGroup()
        rerender()
    }

    private func sanitizeSelectionAndEnteredGroup() {
        selectedShapeIDs = Set(selectedShapeIDs.filter { document.isShapeSelectable($0) })

        if let enteredGroupID,
           document.isGroupHiddenEffectively(enteredGroupID)
                || document.isGroupLockedEffectively(enteredGroupID)
        {
            self.enteredGroupID = nil
        }
    }

    private func nextGroupName() -> String {
        let existingNames = Set(document.groups.map(\.name))
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
        for shapeIndex in document.shapes.indices {
            guard case .arrow(var arrow) = document.shapes[shapeIndex] else {
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
                document.shapes[shapeIndex] = .arrow(arrow)
            }
        }
    }

    private func rerouteAttachedArrows(for shapeID: UUID) {
        for shapeIndex in document.shapes.indices {
            guard case .arrow(var arrow) = document.shapes[shapeIndex] else {
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

            document.shapes[shapeIndex] = .arrow(arrow)
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
}
