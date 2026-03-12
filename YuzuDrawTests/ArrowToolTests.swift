import Testing

@testable import YuzuDraw

struct ArrowToolTests {
    @Test func should_create_arrow_on_click_and_release() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 1, row: 1), in: doc)
        let action = tool.mouseUp(
            at: GridPoint(column: 10, row: 5), in: doc)

        // then
        if case .addShape(.arrow(let arrow)) = action {
            #expect(arrow.start == GridPoint(column: 1, row: 1))
            #expect(arrow.end == GridPoint(column: 10, row: 1))
            #expect(arrow.startAttachment == nil)
            #expect(arrow.endAttachment == nil)
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_attach_arrow_endpoints_to_rectangles() {
        // given
        let tool = ArrowTool()
        var doc = Document()

        let leftRect = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        let rightRect = RectangleShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(leftRect))
        doc.addShape(.rectangle(rightRect))

        // when – click near the right attachment of leftRect and left attachment of rightRect
        _ = tool.mouseDown(at: GridPoint(column: 9, row: 4), in: doc)
        let action = tool.mouseUp(
            at: GridPoint(column: 20, row: 4), in: doc)

        // then
        if case .addShape(.arrow(let arrow)) = action {
            #expect(arrow.start == GridPoint(column: 9, row: 4))
            #expect(arrow.end == GridPoint(column: 20, row: 4))
            #expect(arrow.startAttachment == ArrowAttachment(shapeID: leftRect.id, side: .right))
            #expect(arrow.endAttachment == ArrowAttachment(shapeID: rightRect.id, side: .left))
            #expect(arrow.bendDirection == .horizontalFirst)
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_not_create_zero_length_arrow() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 5, row: 5), in: doc)
        let action = tool.mouseUp(
            at: GridPoint(column: 5, row: 5), in: doc)

        // then
        #expect(action == .none)
    }

    @Test func should_show_preview_during_drag() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 1, row: 1), in: doc)
        _ = tool.mouseDragged(
            to: GridPoint(column: 10, row: 5), in: doc)
        let preview = tool.previewShape()

        // then
        #expect(preview != nil)
    }

    @Test func should_use_clicked_start_terminus_when_drag_begins_on_attachment_point() {
        // given
        let tool = ArrowTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 10, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rectangle))

        // when
        _ = tool.mouseDown(at: GridPoint(column: rectangle.boundingRect.minColumn, row: 4), in: doc)
        let action = tool.mouseUp(at: GridPoint(column: 0, row: 4), in: doc)

        // then
        if case .addShape(.arrow(let arrow)) = action {
            #expect(arrow.start == GridPoint(column: rectangle.boundingRect.minColumn, row: 4))
            #expect(arrow.startAttachment == ArrowAttachment(shapeID: rectangle.id, side: .left))
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_not_snap_start_to_attachment_when_click_is_more_than_half_cell_away() {
        // given
        let tool = ArrowTool()
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 10, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.rectangle(rectangle))

        // when
        _ = tool.mouseDown(at: GridPoint(column: 8, row: 4), in: doc)
        let action = tool.mouseUp(at: GridPoint(column: 0, row: 4), in: doc)

        // then
        if case .addShape(.arrow(let arrow)) = action {
            #expect(arrow.start == GridPoint(column: 8, row: 4))
            #expect(arrow.startAttachment == nil)
        } else {
            Issue.record("Expected addShape action without snapped start attachment")
        }
    }
}
