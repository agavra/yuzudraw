import Testing

@testable import AsciiAI

struct SelectionToolTests {
    @Test func should_select_shape_on_mouse_down() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        let action = tool.mouseDown(
            at: GridPoint(column: 7, row: 4),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        #expect(action == .selectShape(box.id))
    }

    @Test func should_deselect_when_clicking_empty_area() {
        // given
        let tool = SelectionTool()
        let doc = Document()

        // when
        let action = tool.mouseDown(
            at: GridPoint(column: 0, row: 0),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        #expect(action == .selectShape(nil))
    }

    @Test func should_move_shape_on_drag() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 7, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 10, row: 6), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.box(let moved)) = action {
            #expect(moved.origin == GridPoint(column: 8, row: 5))
        } else {
            Issue.record("Expected updateShape action with box")
        }
    }

    @Test func should_not_move_shape_on_locked_layer() {
        // given
        let tool = SelectionTool()
        var doc = Document(layers: [Layer(name: "Layer 1", isLocked: true)])
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 7, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 10, row: 6), in: doc, activeLayerIndex: 0)

        // then
        #expect(action == .none)
    }
}
