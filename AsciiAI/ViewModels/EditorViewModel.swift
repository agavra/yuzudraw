import SwiftUI

@MainActor
@Observable
final class EditorViewModel {
    var document: Document
    var canvas: Canvas
    var selectedShapeIDs: Set<UUID> = []
    var activeToolType: ToolType = .select
    var activeBorderStyle: BorderStyle = .single
    var activeLayerIndex: Int = 0
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

    func updateSelectedBoxBorderStyle(_ style: BorderStyle) {
        guard let shape = selectedShape,
            case .box(var box) = shape
        else { return }
        box.borderStyle = style
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

    func deleteSelectedShapes() {
        for id in selectedShapeIDs {
            detachArrows(referencing: id)
            document.removeShape(id: id)
        }
        selectedShapeIDs = []
        rerender()
    }

    // MARK: - Layer management

    func addLayer() {
        let name = "Layer \(document.layers.count + 1)"
        document.addLayer(name: name)
        activeLayerIndex = document.layers.count - 1
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

    // MARK: - Border style sync

    func setBorderStyle(_ style: BorderStyle) {
        activeBorderStyle = style
        boxTool.borderStyle = style
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
