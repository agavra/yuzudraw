import SwiftUI

@MainActor
@Observable
final class EditorViewModel {
    var document: Document
    var canvas: Canvas
    var selectedShapeID: UUID?
    var activeToolType: ToolType = .select
    var activeBorderStyle: BorderStyle = .single
    var activeLayerIndex: Int = 0
    var isEditingText: Bool = false
    var textEditPoint: GridPoint?
    var textEditContent: String = ""

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
            selectedShapeID = shape.id
            rerender()
        case .selectShape(let id):
            selectedShapeID = id
        case .moveShape(let id, let point):
            // Legacy - handled by updateShape now
            break
        case .beginTextEdit(let point):
            isEditingText = true
            textEditPoint = point
            textEditContent = ""
        case .updateShape(let shape):
            document.updateShape(shape)
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
        selectedShapeID = textShape.id
        cancelTextEdit()
        rerender()
    }

    func cancelTextEdit() {
        isEditingText = false
        textEditPoint = nil
        textEditContent = ""
    }

    // MARK: - Shape property editing

    var selectedShape: AnyShape? {
        guard let id = selectedShapeID else { return nil }
        return document.findShape(id: id)
    }

    func updateSelectedBoxLabel(_ label: String) {
        guard let id = selectedShapeID,
            case .box(var box) = document.findShape(id: id)
        else { return }
        box.label = label
        document.updateShape(.box(box))
        rerender()
    }

    func updateSelectedBoxBorderStyle(_ style: BorderStyle) {
        guard let id = selectedShapeID,
            case .box(var box) = document.findShape(id: id)
        else { return }
        box.borderStyle = style
        document.updateShape(.box(box))
        rerender()
    }

    func updateSelectedBoxOrigin(column: Int, row: Int) {
        guard let id = selectedShapeID,
            case .box(var box) = document.findShape(id: id)
        else { return }
        box.origin = GridPoint(column: column, row: row)
        document.updateShape(.box(box))
        rerender()
    }

    func updateSelectedBoxSize(width: Int, height: Int) {
        guard let id = selectedShapeID,
            case .box(var box) = document.findShape(id: id)
        else { return }
        box.size = GridSize(width: width, height: height)
        document.updateShape(.box(box))
        rerender()
    }

    func updateSelectedArrowLabel(_ label: String) {
        guard let id = selectedShapeID,
            case .arrow(var arrow) = document.findShape(id: id)
        else { return }
        arrow.label = label
        document.updateShape(.arrow(arrow))
        rerender()
    }

    func deleteSelectedShape() {
        guard let id = selectedShapeID else { return }
        document.removeShape(id: id)
        selectedShapeID = nil
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

    // MARK: - Rendering

    func rerender() {
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
}
