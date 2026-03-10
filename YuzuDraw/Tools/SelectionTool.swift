import Foundation

final class SelectionTool: Tool, @unchecked Sendable {
    private static let attachmentSnapRadius: Double = 0.5

    let toolType: ToolType = .select

    /// Set by the view model before mouseDown so the tool can do bounding-rect
    /// hit testing on already-selected pencil shapes.
    var selectedShapeIDs: Set<UUID> = []

    /// Set by the view model before mouse events so the tool can handle
    /// additive (shift+click) selection.
    var isShiftKeyPressed: Bool = false

    private enum Mode {
        case none
        case draggingShape(shapeID: UUID, offset: GridPoint)
        case marquee(start: GridPoint, current: GridPoint)
        case resizingShape(originalShape: AnyShape, handle: ResizeHandle)
    }

    private var mode: Mode = .none
    private var didDragMove = false
    private var arrowAttachmentPreviewPointsStorage: [GridPoint] = []

    /// Exposed for the canvas overlay to draw the marquee rectangle.
    var marqueeRect: GridRect? {
        guard case .marquee(let start, let current) = mode else { return nil }
        let rect = GridRect.enclosing(from: start, to: current)
        guard rect.size.width > 1 || rect.size.height > 1 else { return nil }
        return rect
    }

    var arrowAttachmentPreviewPoints: [GridPoint] {
        arrowAttachmentPreviewPointsStorage
    }

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int)
        -> ToolAction
    {
        arrowAttachmentPreviewPointsStorage = []
        didDragMove = false

        if selectedShapeIDs.count <= 1,
            let (shape, handle) = resizeHandleHit(at: point, in: document)
        {
            mode = .resizingShape(originalShape: shape, handle: handle)
            return .selectShape(shape.id)
        }

        // For selected pencil shapes, hit-test against the bounding rect
        // so the user can drag from any point within it.
        if let pencilShape = selectedPencilShapeInBounds(at: point, in: document) {
            let rect = pencilShape.boundingRect
            mode = .draggingShape(
                shapeID: pencilShape.id,
                offset: GridPoint(
                    column: point.column - rect.origin.column,
                    row: point.row - rect.origin.row
                )
            )
            if isShiftKeyPressed {
                if selectedShapeIDs.contains(pencilShape.id) {
                    return .none  // Will toggle off on mouseUp if no drag
                }
                return .addShapeToSelection(pencilShape.id)
            }
            if selectedShapeIDs.count > 1, selectedShapeIDs.contains(pencilShape.id) {
                return .none
            }
            return .selectShape(pencilShape.id)
        }

        if let shape = document.hitTest(at: point) {
            let rect = shape.boundingRect
            mode = .draggingShape(
                shapeID: shape.id,
                offset: GridPoint(
                    column: point.column - rect.origin.column,
                    row: point.row - rect.origin.row
                )
            )
            if isShiftKeyPressed {
                if selectedShapeIDs.contains(shape.id) {
                    return .none  // Will toggle off on mouseUp if no drag
                }
                return .addShapeToSelection(shape.id)
            }
            if selectedShapeIDs.count > 1, selectedShapeIDs.contains(shape.id) {
                return .none
            }
            return .selectShape(shape.id)
        } else {
            mode = .marquee(start: point, current: point)
            return isShiftKeyPressed ? .none : .selectShape(nil)
        }
    }

    func mouseDragged(to point: GridPoint, in document: Document, activeLayerIndex _: Int)
        -> ToolAction
    {
        switch mode {
        case .none:
            arrowAttachmentPreviewPointsStorage = []
            return .none

        case .draggingShape(let shapeID, let offset):
            guard let shape = document.findShape(id: shapeID) else {
                return .none
            }
            guard let layerIndex = document.layerIndex(containingShape: shapeID),
                !document.layers[layerIndex].isLocked
            else {
                return .none
            }

            let newOrigin = GridPoint(
                column: max(0, point.column - offset.column),
                row: max(0, point.row - offset.row)
            )

            if selectedShapeIDs.count > 1, selectedShapeIDs.contains(shapeID) {
                let updates = movedSelectedShapes(
                    draggingShape: shape,
                    toOrigin: newOrigin,
                    in: document
                )
                if !updates.isEmpty { didDragMove = true }
                return updates.isEmpty ? .none : .updateShapes(updates)
            }

            let currentOrigin = shape.boundingRect.origin
            guard newOrigin != currentOrigin else { return .none }
            didDragMove = true
            let movedShape: AnyShape
            switch shape {
            case .rectangle(var rectangle):
                rectangle.origin = newOrigin
                movedShape = .rectangle(rectangle)
            case .arrow(var arrow):
                let dx = newOrigin.column - arrow.boundingRect.origin.column
                let dy = newOrigin.row - arrow.boundingRect.origin.row
                arrow.start = GridPoint(
                    column: arrow.start.column + dx, row: arrow.start.row + dy)
                arrow.end = GridPoint(column: arrow.end.column + dx, row: arrow.end.row + dy)
                arrow.startAttachment = nil
                arrow.endAttachment = nil
                movedShape = .arrow(arrow)
            case .text(var text):
                text.origin = newOrigin
                movedShape = .text(text)
            case .pencil(var pencil):
                pencil.origin = newOrigin
                movedShape = .pencil(pencil)
            }

            return .updateShape(movedShape)

        case .marquee(let start, _):
            mode = .marquee(start: start, current: point)
            arrowAttachmentPreviewPointsStorage = []
            return .none

        case .resizingShape(let originalShape, let handle):
            guard let layerIndex = document.layerIndex(containingShape: originalShape.id),
                !document.layers[layerIndex].isLocked
            else {
                return .none
            }

            guard case .arrow(let arrow) = originalShape, handle == .start || handle == .end else {
                arrowAttachmentPreviewPointsStorage = []
                return .updateShape(originalShape.resized(using: handle, to: point))
            }

            let resized = resizeArrow(
                arrow,
                using: handle,
                to: point,
                in: document
            )
            return .updateShape(.arrow(resized))
        }
    }

    private func movedSelectedShapes(
        draggingShape: AnyShape,
        toOrigin newOrigin: GridPoint,
        in document: Document
    ) -> [AnyShape] {
        var movableShapes: [AnyShape] = []
        for layer in document.layers {
            guard !layer.isLocked else { continue }
            for shape in layer.shapes where selectedShapeIDs.contains(shape.id) {
                movableShapes.append(shape)
            }
        }

        guard !movableShapes.isEmpty else { return [] }

        let draggedOrigin = draggingShape.boundingRect.origin
        var dx = newOrigin.column - draggedOrigin.column
        var dy = newOrigin.row - draggedOrigin.row

        let minColumn = movableShapes.map { $0.boundingRect.origin.column }.min() ?? 0
        let minRow = movableShapes.map { $0.boundingRect.origin.row }.min() ?? 0
        dx = max(-minColumn, dx)
        dy = max(-minRow, dy)

        if dx == 0, dy == 0 { return [] }

        return movableShapes.map { translateShape($0, dx: dx, dy: dy) }
    }

    private func translateShape(_ shape: AnyShape, dx: Int, dy: Int) -> AnyShape {
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

            // Preserve only attachments to shapes that are moving as part of this drag.
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

    func mouseUp(at point: GridPoint, in document: Document, activeLayerIndex _: Int) -> ToolAction
    {
        switch mode {
        case .marquee(let start, _):
            let rect = GridRect.enclosing(from: start, to: point)
            mode = .none
            arrowAttachmentPreviewPointsStorage = []
            // Only do marquee selection if the user actually dragged
            if rect.size.width > 1 || rect.size.height > 1 {
                let shapes = document.shapesInRect(rect, excludingLockedLayers: true)
                let ids = Set(shapes.map(\.id))
                return isShiftKeyPressed ? .addShapesToSelection(ids) : .selectShapes(ids)
            }
            return .none

        case .draggingShape(let shapeID, _):
            mode = .none
            arrowAttachmentPreviewPointsStorage = []
            if !didDragMove {
                // Shift+click without drag on selected shape: deselect it.
                if isShiftKeyPressed, selectedShapeIDs.contains(shapeID) {
                    return .removeShapeFromSelection(shapeID)
                }
                // Click without drag on a multi-selected shape: narrow to just that shape.
                if selectedShapeIDs.count > 1, selectedShapeIDs.contains(shapeID) {
                    return .selectShape(shapeID)
                }
            }
            return .none

        default:
            mode = .none
            arrowAttachmentPreviewPointsStorage = []
            return .none
        }
    }

    func cancel() {
        mode = .none
        arrowAttachmentPreviewPointsStorage = []
    }

    func previewShape() -> AnyShape? { nil }

    private func selectedPencilShapeInBounds(at point: GridPoint, in document: Document) -> AnyShape? {
        for id in selectedShapeIDs {
            guard let shape = document.findShape(id: id),
                case .pencil = shape,
                shape.boundingRect.contains(point)
            else { continue }
            return shape
        }
        return nil
    }

    private func resizeHandleHit(at point: GridPoint, in document: Document) -> (AnyShape, ResizeHandle)? {
        guard !selectedShapeIDs.isEmpty else { return nil }
        for layer in document.layers.reversed() {
            guard layer.isVisible, !layer.isLocked else { continue }
            for shape in layer.shapes.reversed() {
                guard selectedShapeIDs.contains(shape.id) else { continue }
                if let handle = shape.resizeHandle(at: point) {
                    return (shape, handle)
                }
            }
        }
        return nil
    }

    private func resizeArrow(
        _ original: ArrowShape,
        using handle: ResizeHandle,
        to point: GridPoint,
        in document: Document
    ) -> ArrowShape {
        var arrow = original
        let clampedPoint = GridPoint(
            column: max(0, point.column),
            row: max(0, point.row)
        )

        let snapResult = snappedAttachment(
            near: clampedPoint,
            in: document,
            excludingShapeID: arrow.id
        )

        switch handle {
        case .start:
            if let snapResult {
                arrow.start = snapResult.point
                arrow.startAttachment = ArrowAttachment(shapeID: snapResult.rectangle.id, side: snapResult.side)
                arrowAttachmentPreviewPointsStorage = ArrowAttachmentSide.allCases.map {
                    snapResult.rectangle.attachmentPoint(for: $0)
                }
            } else {
                arrow.start = clampedPoint
                arrow.startAttachment = nil
                arrowAttachmentPreviewPointsStorage = []
            }
        case .end:
            if let snapResult {
                arrow.end = snapResult.point
                arrow.endAttachment = ArrowAttachment(shapeID: snapResult.rectangle.id, side: snapResult.side)
                arrowAttachmentPreviewPointsStorage = ArrowAttachmentSide.allCases.map {
                    snapResult.rectangle.attachmentPoint(for: $0)
                }
            } else {
                arrow.end = clampedPoint
                arrow.endAttachment = nil
                arrowAttachmentPreviewPointsStorage = []
            }
        case .topLeft, .top, .topRight, .right, .bottomLeft, .bottom, .bottomRight, .left:
            break
        }

        arrow.bendDirection = ArrowRouter.bendDirection(
            start: arrow.start,
            end: arrow.end,
            startSide: arrow.startAttachment?.side,
            endSide: arrow.endAttachment?.side
        )

        return arrow
    }

    private func snappedAttachment(
        near point: GridPoint,
        in document: Document,
        excludingShapeID: UUID
    ) -> (rectangle: RectangleShape, side: ArrowAttachmentSide, point: GridPoint)? {
        var best: (rectangle: RectangleShape, side: ArrowAttachmentSide, point: GridPoint)?
        var bestDistance = Double.greatestFiniteMagnitude

        for layer in document.layers.reversed() {
            guard layer.isVisible else { continue }
            for shape in layer.shapes.reversed() {
                guard shape.id != excludingShapeID else { continue }
                guard case .rectangle(let rectangle) = shape else { continue }
                for side in ArrowAttachmentSide.allCases {
                    let attachPoint = rectangle.attachmentPoint(for: side)
                    let distance = hypot(
                        Double(attachPoint.column - point.column),
                        Double(attachPoint.row - point.row)
                    )
                    guard distance <= Self.attachmentSnapRadius else { continue }
                    if distance < bestDistance {
                        bestDistance = distance
                        best = (rectangle, side, attachPoint)
                    }
                }
            }
        }

        return best
    }
}
