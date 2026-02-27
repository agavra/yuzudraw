import SwiftUI

@MainActor
@Observable
final class EditorViewModel {
    var document: Document
    var canvas: Canvas
    var selectedShapeIDs: Set<UUID> = []
    var activeToolType: ToolType = .select
    var activeLayerIndex: Int = 0
    var expandedItemIDs: Set<UUID> = []
    var isEditingText: Bool = false
    var textEditPoint: GridPoint?
    var textEditContent: String = ""
    var viewportSize: CGSize = .zero
    var hoverGridPoint: GridPoint?

    private var selectionTool = SelectionTool()
    private var boxTool = BoxTool()
    private var arrowTool = ArrowTool()
    private var textTool = TextTool()

    var activeTool: any Tool {
        switch activeToolType {
        case .select: return selectionTool
        case .box: return boxTool
        case .arrow: return arrowTool
        case .text: return textTool
        }
    }

    var arrowAttachmentPreviewPoints: [GridPoint] {
        switch activeToolType {
        case .arrow:
            return arrowTool.attachmentPreviewPoints(in: document)
        case .select:
            return selectionTool.arrowAttachmentPreviewPoints
        case .box, .text:
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
        let action = activeTool.mouseDown(
            at: point, in: document, activeLayerIndex: activeLayerIndex)
        applyAction(action)
    }

    func mouseDragged(to point: GridPoint) {
        let action = activeTool.mouseDragged(
            to: point, in: document, activeLayerIndex: activeLayerIndex)
        applyAction(action)
        rerender()
    }

    func mouseUp(at point: GridPoint) {
        let action = activeTool.mouseUp(
            at: point, in: document, activeLayerIndex: activeLayerIndex)
        applyAction(action)
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
            activeToolType = .select
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
        }
    }

    // MARK: - Text editing

    func commitTextEdit() {
        guard let point = textEditPoint, !textEditContent.isEmpty else {
            cancelTextEdit()
            return
        }
        let textShape = TextShape(origin: point, text: textEditContent)
        document.addShape(.text(textShape), toLayerAt: activeLayerIndex)
        selectedShapeIDs = [textShape.id]
        cancelTextEdit()
        activeToolType = .select
        rerender()
    }

    func cancelTextEdit() {
        isEditingText = false
        textEditPoint = nil
        textEditContent = ""
    }

    // MARK: - Shape property editing

    var selectedShapes: [AnyShape] {
        selectedShapeIDs.compactMap { document.findShape(id: $0) }
    }

    var selectedShape: AnyShape? {
        guard selectedShapeIDs.count == 1, let id = selectedShapeIDs.first else { return nil }
        return document.findShape(id: id)
    }

    func updateSelectedBoxLabel(_ label: String) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.label = label
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxTextHorizontalAlignment(_ alignment: BoxTextHorizontalAlignment) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.textHorizontalAlignment = alignment
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxTextVerticalAlignment(_ alignment: BoxTextVerticalAlignment) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.textVerticalAlignment = alignment
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxHasBorder(_ hasBorder: Bool) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.hasBorder = hasBorder
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxAllowTextOnBorder(_ allow: Bool) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.allowTextOnBorder = allow
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxHasShadow(_ hasShadow: Bool) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.hasShadow = hasShadow
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxShadowStyle(_ style: BoxShadowStyle) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.shadowStyle = style
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxShadowOffsetX(_ value: Int) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.shadowOffsetX = value
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxShadowOffsetY(_ value: Int) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.shadowOffsetY = value
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxTextPadding(
        left: Int? = nil,
        right: Int? = nil,
        top: Int? = nil,
        bottom: Int? = nil
    ) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        if let left {
            box.textPaddingLeft = max(0, left)
        }
        if let right {
            box.textPaddingRight = max(0, right)
        }
        if let top {
            box.textPaddingTop = max(0, top)
        }
        if let bottom {
            box.textPaddingBottom = max(0, bottom)
        }
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxStrokeStyle(_ style: StrokeStyle) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.strokeStyle = style
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxFillMode(_ fillMode: BoxFillMode) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.fillMode = fillMode
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxFillEnabled(_ isEnabled: Bool) {
        updateSelectedBoxFillMode(isEnabled ? .solid : .transparent)
    }

    func updateSelectedBoxFillCharacter(_ fillCharacter: Character) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.fillCharacter = fillCharacter
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxOrigin(column: Int, row: Int) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.origin = GridPoint(column: column, row: row)
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedBoxSize(width: Int, height: Int) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.size = GridSize(width: width, height: height)
        updateShapeAndAttachments(.box(box))
        rerender()
    }

    func updateSelectedArrowLabel(_ label: String) {
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.label = label
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func updateSelectedArrowStrokeStyle(_ style: StrokeStyle) {
        guard let shape = selectedShape,
            case .arrow(var arrow) = shape
        else { return }
        arrow.strokeStyle = style
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func deleteSelectedShapes() {
        for id in selectedShapeIDs {
            detachArrows(referencing: id)
            document.removeShape(id: id)
        }
        selectedShapeIDs = []
        rerender()
    }

    func moveSelectedShapes(dx: Int, dy: Int) {
        for id in selectedShapeIDs {
            guard let layerIndex = document.layerIndex(containingShape: id),
                !document.layers[layerIndex].isLocked,
                let shape = document.findShape(id: id)
            else { continue }

            let movedShape: AnyShape
            switch shape {
            case .box(var box):
                box.origin = GridPoint(
                    column: box.origin.column + dx,
                    row: box.origin.row + dy
                )
                movedShape = .box(box)
            case .arrow(var arrow):
                arrow.start = GridPoint(
                    column: arrow.start.column + dx,
                    row: arrow.start.row + dy
                )
                arrow.end = GridPoint(
                    column: arrow.end.column + dx,
                    row: arrow.end.row + dy
                )
                arrow.startAttachment = nil
                arrow.endAttachment = nil
                movedShape = .arrow(arrow)
            case .text(var text):
                text.origin = GridPoint(
                    column: text.origin.column + dx,
                    row: text.origin.row + dy
                )
                movedShape = .text(text)
            }
            updateShapeAndAttachments(movedShape)
        }
        rerender()
    }

    // MARK: - Layer management

    func addLayer() {
        let name = "Layer \(document.layers.count + 1)"
        document.addLayer(name: name)
        activeLayerIndex = document.layers.count - 1
        expandedItemIDs.insert(document.layers[activeLayerIndex].id)
    }

    func removeLayer(at index: Int) {
        document.removeLayer(at: index)
        if activeLayerIndex >= document.layers.count {
            activeLayerIndex = document.layers.count - 1
        }
        rerender()
    }

    func toggleLayerVisibility(at index: Int) {
        guard document.layers.indices.contains(index) else { return }
        document.layers[index].isVisible.toggle()
        rerender()
    }

    func toggleLayerLock(at index: Int) {
        guard document.layers.indices.contains(index) else { return }
        document.layers[index].isLocked.toggle()
    }

    func moveActiveLayerUp() {
        guard document.moveLayerUp(at: activeLayerIndex) else { return }
        activeLayerIndex += 1
        rerender()
    }

    func moveActiveLayerDown() {
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
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeForward(id: shapeID) else { return }
        rerender()
    }

    func moveSelectedShapeBackward() {
        guard selectedShapeIDs.count == 1, let shapeID = selectedShapeIDs.first else { return }
        guard document.moveShapeBackward(id: shapeID) else { return }
        rerender()
    }

    func canMoveShapeForward(_ shapeID: UUID) -> Bool {
        document.canMoveShapeForward(id: shapeID)
    }

    func canMoveShapeBackward(_ shapeID: UUID) -> Bool {
        document.canMoveShapeBackward(id: shapeID)
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

    func moveLayer(draggedLayerID: UUID, before targetLayerID: UUID) {
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
        guard document.moveShape(id: draggedShapeID, before: targetShapeID, in: layerID) else { return }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, after targetShapeID: UUID, in layerID: UUID) {
        guard document.moveShape(id: draggedShapeID, after: targetShapeID, in: layerID) else { return }
        rerender()
    }

    func moveShape(draggedShapeID: UUID, toLayer targetLayerID: UUID) {
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

    func selectShapeFromPanel(_ shapeID: UUID) {
        selectedShapeIDs = [shapeID]
        for (index, layer) in document.layers.enumerated() {
            if layer.findShape(id: shapeID) != nil {
                activeLayerIndex = index
                break
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

    func expandCanvasIfNeeded() {
        let padding = 10
        var requiredWidth = Canvas.defaultColumns
        var requiredHeight = Canvas.defaultRows

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

        if case .box(let box) = shape {
            rerouteAttachedArrows(for: box.id)
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
            case .box(let box) = shape
        else {
            return nil
        }

        return (box.attachmentPoint(for: attachment.side), attachment.side)
    }
}
