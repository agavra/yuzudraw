import Foundation

final class RectangleTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .rectangle

    private var startPoint: GridPoint?
    private var currentPoint: GridPoint?
    var strokeStyle: StrokeStyle = .single

    func mouseDown(at point: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        startPoint = point
        currentPoint = point
        return .none
    }

    func mouseDragged(to point: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        currentPoint = point
        return .none
    }

    func mouseUp(at point: GridPoint, in _: Document, activeLayerIndex: Int) -> ToolAction {
        guard let start = startPoint else { return .none }
        currentPoint = point

        let rect = GridRect.enclosing(from: start, to: point)

        // Minimum 2x2 rectangle
        guard rect.size.width >= 2, rect.size.height >= 2 else {
            cancel()
            return .none
        }

        let rectangle = RectangleShape(
            origin: rect.origin,
            size: rect.size,
            strokeStyle: strokeStyle
        )

        cancel()
        return .addShape(.rectangle(rectangle), layerIndex: activeLayerIndex)
    }

    func cancel() {
        startPoint = nil
        currentPoint = nil
    }

    func previewShape() -> AnyShape? {
        guard let start = startPoint, let current = currentPoint else { return nil }
        let rect = GridRect.enclosing(from: start, to: current)
        guard rect.size.width >= 2, rect.size.height >= 2 else { return nil }
        return .rectangle(
            RectangleShape(
                origin: rect.origin,
                size: rect.size,
                strokeStyle: strokeStyle
            ))
    }
}
