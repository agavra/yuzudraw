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

    @Test func should_resize_box_from_bottom_right_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 10, row: 6), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 9), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.box(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 7))
        } else {
            Issue.record("Expected updateShape action with resized box")
        }
    }

    @Test func should_resize_arrow_by_dragging_end_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 8, row: 2)
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 8, row: 2), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 12, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.arrow(let resized)) = action {
            #expect(resized.start == GridPoint(column: 2, row: 2))
            #expect(resized.end == GridPoint(column: 12, row: 5))
        } else {
            Issue.record("Expected updateShape action with resized arrow")
        }
    }

    @Test func should_resize_box_when_drag_starts_on_shifted_bottom_right_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 11, row: 7), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 9), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.box(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 7))
        } else {
            Issue.record("Expected updateShape action with resized box")
        }
    }

    @Test func should_resize_box_from_right_midpoint_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 11, row: 5), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.box(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 4))
        } else {
            Issue.record("Expected updateShape action with horizontally resized box")
        }
    }
}
