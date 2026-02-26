import Foundation

final class SelectionTool: Tool, @unchecked Sendable {
    private static let attachmentSnapRadius: Double = 0.5

    let toolType: ToolType = .select

    private enum Mode {
        case none
        case draggingShape(shapeID: UUID, offset: GridPoint)
        case marquee(start: GridPoint, current: GridPoint)
        case resizingShape(originalShape: AnyShape, handle: ResizeHandle)
    }

    private var mode: Mode = .none
    private var arrowAttachmentPreviewPointsStorage: [GridPoint] = []

    /// Exposed for the canvas overlay to draw the marquee rectangle.
    var marqueeRect: GridRect? {
        guard case .marquee(let start, let current) = mode else { return nil }
        return GridRect.enclosing(from: start, to: current)
    }

    var arrowAttachmentPreviewPoints: [GridPoint] {
        arrowAttachmentPreviewPointsStorage
    }

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int)
        -> ToolAction
    {
        arrowAttachmentPreviewPointsStorage = []

        if let (shape, handle) = resizeHandleHit(at: point, in: document) {
            mode = .resizingShape(originalShape: shape, handle: handle)
            return .selectShape(shape.id)
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
            return .selectShape(shape.id)
        } else {
            mode = .marquee(start: point, current: point)
            return .selectShape(nil)
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

            let movedShape: AnyShape
            switch shape {
            case .box(var box):
                box.origin = newOrigin
                movedShape = .box(box)
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
                return .selectShapes(ids)
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

    private func resizeHandleHit(at point: GridPoint, in document: Document) -> (AnyShape, ResizeHandle)? {
        for layer in document.layers.reversed() {
            guard layer.isVisible, !layer.isLocked else { continue }
            for shape in layer.shapes.reversed() {
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
                arrow.startAttachment = ArrowAttachment(shapeID: snapResult.box.id, side: snapResult.side)
                arrowAttachmentPreviewPointsStorage = ArrowAttachmentSide.allCases.map {
                    snapResult.box.attachmentPoint(for: $0)
                }
            } else {
                arrow.start = clampedPoint
                arrow.startAttachment = nil
                arrowAttachmentPreviewPointsStorage = []
            }
        case .end:
            if let snapResult {
                arrow.end = snapResult.point
                arrow.endAttachment = ArrowAttachment(shapeID: snapResult.box.id, side: snapResult.side)
                arrowAttachmentPreviewPointsStorage = ArrowAttachmentSide.allCases.map {
                    snapResult.box.attachmentPoint(for: $0)
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
    ) -> (box: BoxShape, side: ArrowAttachmentSide, point: GridPoint)? {
        var best: (box: BoxShape, side: ArrowAttachmentSide, point: GridPoint)?
        var bestDistance = Double.greatestFiniteMagnitude

        for layer in document.layers.reversed() {
            guard layer.isVisible else { continue }
            for shape in layer.shapes.reversed() {
                guard shape.id != excludingShapeID else { continue }
                guard case .box(let box) = shape else { continue }
                for side in ArrowAttachmentSide.allCases {
                    let attachPoint = box.attachmentPoint(for: side)
                    let distance = hypot(
                        Double(attachPoint.column - point.column),
                        Double(attachPoint.row - point.row)
                    )
                    guard distance <= Self.attachmentSnapRadius else { continue }
                    if distance < bestDistance {
                        bestDistance = distance
                        best = (box, side, attachPoint)
                    }
                }
            }
        }

        return best
    }
}
