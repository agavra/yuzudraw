import Foundation

final class SelectionTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .select

    private var draggedShapeID: UUID?
    private var dragOffset: GridPoint?

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int)
        -> ToolAction
    {
        if let shape = document.hitTest(at: point) {
            draggedShapeID = shape.id
            let rect = shape.boundingRect
            dragOffset = GridPoint(
                column: point.column - rect.origin.column,
                row: point.row - rect.origin.row
            )
            return .selectShape(shape.id)
        } else {
            draggedShapeID = nil
            dragOffset = nil
            return .selectShape(nil)
        }
    }

    func mouseDragged(to point: GridPoint, in document: Document, activeLayerIndex _: Int)
        -> ToolAction
    {
        guard let shapeID = draggedShapeID, let offset = dragOffset else {
            return .none
        }
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
            movedShape = .arrow(arrow)
        case .text(var text):
            text.origin = newOrigin
            movedShape = .text(text)
        }

        return .updateShape(movedShape)
    }

    func mouseUp(at _: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        draggedShapeID = nil
        dragOffset = nil
        return .none
    }

    func cancel() {
        draggedShapeID = nil
        dragOffset = nil
    }

    func previewShape() -> AnyShape? { nil }
}
