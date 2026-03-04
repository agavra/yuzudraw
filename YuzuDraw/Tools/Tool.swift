import Foundation

enum ToolType: String, CaseIterable, Sendable {
    case select
    case box
    case arrow
    case text
    case pencil
}

enum ToolAction: Equatable, Sendable {
    case none
    case addShape(AnyShape, layerIndex: Int)
    case selectShape(UUID?)
    case moveShape(UUID, to: GridPoint)
    case beginTextEdit(GridPoint)
    case updateShape(AnyShape)
    case updateShapes([AnyShape])
    case selectShapes(Set<UUID>)
}

protocol Tool: AnyObject, Sendable {
    var toolType: ToolType { get }
    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex: Int)
        -> ToolAction
    func mouseDragged(to point: GridPoint, in document: Document, activeLayerIndex: Int)
        -> ToolAction
    func mouseUp(at point: GridPoint, in document: Document, activeLayerIndex: Int) -> ToolAction
    func cancel()
    func previewShape() -> AnyShape?
}

extension Tool {
    func previewShape() -> AnyShape? { nil }
    func cancel() {}
}
