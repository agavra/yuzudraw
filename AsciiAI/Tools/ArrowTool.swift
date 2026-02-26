import Foundation

final class ArrowTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .arrow

    private var startPoint: GridPoint?
    private var currentPoint: GridPoint?

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

        // Don't create zero-length arrows
        guard start != point else {
            cancel()
            return .none
        }

        let arrow = ArrowShape(start: start, end: point)

        cancel()
        return .addShape(.arrow(arrow), layerIndex: activeLayerIndex)
    }

    func cancel() {
        startPoint = nil
        currentPoint = nil
    }

    func previewShape() -> AnyShape? {
        guard let start = startPoint, let current = currentPoint, start != current else {
            return nil
        }
        return .arrow(ArrowShape(start: start, end: current))
    }
}
