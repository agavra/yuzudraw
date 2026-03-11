import Testing

@testable import YuzuDraw

struct SelectionToolTests {
    @Test func should_select_shape_on_mouse_down() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let action = tool.mouseDown(
            at: GridPoint(column: 7, row: 4),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        #expect(action == .selectShape(rectangle.id))
    }

    @Test func should_select_shape_on_locked_layer() {
        // given
        let tool = SelectionTool()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        let doc = Document(layers: [
            Layer(name: "Locked", isLocked: true, shapes: [.rectangle(rectangle)])
        ])

        // when
        let action = tool.mouseDown(
            at: GridPoint(column: 7, row: 4),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        #expect(action == .selectShape(rectangle.id))
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
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 7, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 10, row: 6), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.rectangle(let moved)) = action {
            #expect(moved.origin == GridPoint(column: 8, row: 5))
        } else {
            Issue.record("Expected updateShape action with rectangle")
        }
    }

    @Test func should_not_move_shape_on_locked_layer() {
        // given
        let tool = SelectionTool()
        var doc = Document(layers: [Layer(name: "Layer 1", isLocked: true)])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 7, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 10, row: 6), in: doc, activeLayerIndex: 0)

        // then
        #expect(action == .none)
    }

    @Test func should_move_all_selected_shapes_when_dragging_one_selected_shape() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 6)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 15, row: 8),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rect1), toLayerAt: 0)
        doc.addShape(.rectangle(rect2), toLayerAt: 0)
        tool.selectedShapeIDs = [rect1.id, rect2.id]

        // when
        _ = tool.mouseDown(at: GridPoint(column: 8, row: 6), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 11, row: 8),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        if case .updateShapes(let shapes) = action {
            #expect(shapes.count == 2)
            let movedRects = shapes.compactMap { shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape else { return nil }
                return rectangle
            }
            #expect(movedRects.contains { $0.id == rect1.id && $0.origin == GridPoint(column: 8, row: 5) })
            #expect(movedRects.contains { $0.id == rect2.id && $0.origin == GridPoint(column: 18, row: 10) })
        } else {
            Issue.record("Expected updateShapes action with both rectangles")
        }
    }

    @Test func should_preserve_multi_selection_when_mouse_down_on_selected_shape() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 6)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 20, row: 6),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rect1), toLayerAt: 0)
        doc.addShape(.rectangle(rect2), toLayerAt: 0)
        tool.selectedShapeIDs = [rect1.id, rect2.id]

        // when
        let action = tool.mouseDown(
            at: GridPoint(column: 8, row: 6),
            in: doc,
            activeLayerIndex: 0
        )

        // then
        #expect(action == .none)
    }

    @Test func should_narrow_selection_to_clicked_shape_on_click_without_drag() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 6)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 20, row: 6),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rect1), toLayerAt: 0)
        doc.addShape(.rectangle(rect2), toLayerAt: 0)
        tool.selectedShapeIDs = [rect1.id, rect2.id]

        // when - click on rect1 without dragging
        let clickPoint = GridPoint(column: 8, row: 6)
        _ = tool.mouseDown(at: clickPoint, in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: clickPoint, in: doc, activeLayerIndex: 0)

        // then - selection narrows to just rect1
        #expect(action == .selectShape(rect1.id))
    }

    @Test func should_preserve_multi_selection_after_drag() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 6)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 20, row: 8),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rect1), toLayerAt: 0)
        doc.addShape(.rectangle(rect2), toLayerAt: 0)
        tool.selectedShapeIDs = [rect1.id, rect2.id]

        // when - click and drag
        _ = tool.mouseDown(at: GridPoint(column: 8, row: 6), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(to: GridPoint(column: 11, row: 8), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 11, row: 8), in: doc, activeLayerIndex: 0)

        // then - multi-selection is preserved (no narrowing)
        #expect(action == .none)
    }

    @Test func should_resize_rectangle_from_bottom_right_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        tool.selectedShapeIDs = [rectangle.id]

        // when — click at the handle position (maxColumn+1, maxRow+1)
        _ = tool.mouseDown(at: GridPoint(column: 11, row: 7), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 9), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.rectangle(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 7))
        } else {
            Issue.record("Expected updateShape action with resized rectangle")
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
        tool.selectedShapeIDs = [arrow.id]

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

    @Test func should_move_arrow_when_dragging_from_body() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 8, row: 2)
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        let downAction = tool.mouseDown(at: GridPoint(column: 5, row: 2), in: doc, activeLayerIndex: 0)
        let dragAction = tool.mouseDragged(
            to: GridPoint(column: 12, row: 5), in: doc, activeLayerIndex: 0)

        // then
        #expect(downAction == .selectShape(arrow.id))
        if case .updateShape(.arrow(let moved)) = dragAction {
            #expect(moved.start == GridPoint(column: 9, row: 5))
            #expect(moved.end == GridPoint(column: 15, row: 5))
        } else {
            Issue.record("Expected updateShape action with moved arrow")
        }
    }

    @Test func should_snap_arrow_start_handle_to_rectangle_attachment_point() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 10, row: 2)
        )
        let rectangle = RectangleShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        doc.addShape(.arrow(arrow), toLayerAt: 0)
        tool.selectedShapeIDs = [arrow.id]

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 2), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 27, row: 4), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.arrow(let resized)) = action {
            #expect(resized.start == GridPoint(column: 27, row: 4))
            #expect(resized.startAttachment == ArrowAttachment(shapeID: rectangle.id, side: .right))
        } else {
            Issue.record("Expected updateShape action with snapped arrow")
        }
    }

    @Test func should_not_snap_arrow_start_handle_when_more_than_half_cell_from_attachment_point() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 10, row: 2)
        )
        let rectangle = RectangleShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        doc.addShape(.arrow(arrow), toLayerAt: 0)
        tool.selectedShapeIDs = [arrow.id]

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 2), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 26, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.arrow(let resized)) = action {
            #expect(resized.start == GridPoint(column: 26, row: 5))
            #expect(resized.startAttachment == nil)
        } else {
            Issue.record("Expected updateShape action without snapped attachment")
        }
    }

    @Test func should_resize_rectangle_when_drag_starts_on_shifted_bottom_right_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        tool.selectedShapeIDs = [rectangle.id]

        // when
        _ = tool.mouseDown(at: GridPoint(column: 11, row: 7), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 9), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.rectangle(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 7))
        } else {
            Issue.record("Expected updateShape action with resized rectangle")
        }
    }

    @Test func should_resize_rectangle_from_right_midpoint_handle() {
        // given
        let tool = SelectionTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 6, height: 4)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        tool.selectedShapeIDs = [rectangle.id]

        // when
        _ = tool.mouseDown(at: GridPoint(column: 11, row: 5), in: doc, activeLayerIndex: 0)
        let action = tool.mouseDragged(
            to: GridPoint(column: 14, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.rectangle(let resized)) = action {
            #expect(resized.origin == GridPoint(column: 5, row: 3))
            #expect(resized.size == GridSize(width: 10, height: 4))
        } else {
            Issue.record("Expected updateShape action with horizontally resized rectangle")
        }
    }
}
