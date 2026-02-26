import Foundation

final class BoxTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .box

    private var startPoint: GridPoint?
    private var currentPoint: GridPoint?
    var borderStyle: BorderStyle = .single

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

        // Minimum 2x2 box
        guard rect.size.width >= 2, rect.size.height >= 2 else {
            cancel()
            return .none
        }

        let box = BoxShape(
            origin: rect.origin,
            size: rect.size,
            borderStyle: borderStyle
        )

        cancel()
        return .addShape(.box(box), layerIndex: activeLayerIndex)
    }

    func cancel() {
        startPoint = nil
        currentPoint = nil
    }

    func previewShape() -> AnyShape? {
        guard let start = startPoint, let current = currentPoint else { return nil }
        let rect = GridRect.enclosing(from: start, to: current)
        guard rect.size.width >= 2, rect.size.height >= 2 else { return nil }
        return .box(
            BoxShape(
                origin: rect.origin,
                size: rect.size,
                borderStyle: borderStyle
            ))
    }
}
