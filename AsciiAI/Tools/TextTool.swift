import Foundation

final class TextTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .text

    func mouseDown(at _: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        .none
    }

    func mouseDragged(to _: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        .none
    }

    func mouseUp(at point: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        .beginTextEdit(point)
    }

    func cancel() {}

    func previewShape() -> AnyShape? { nil }
}
