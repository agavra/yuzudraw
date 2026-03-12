import Foundation

final class TextTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .text

    func mouseDown(at _: GridPoint, in _: Document) -> ToolAction {
        .none
    }

    func mouseDragged(to _: GridPoint, in _: Document) -> ToolAction {
        .none
    }

    func mouseUp(at point: GridPoint, in _: Document) -> ToolAction {
        .beginTextEdit(point)
    }

    func cancel() {}

    func previewShape() -> AnyShape? { nil }
}
