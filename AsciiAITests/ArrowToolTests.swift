import Testing

@testable import AsciiAI

struct ArrowToolTests {
    @Test func should_create_arrow_on_click_and_release() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 1, row: 1), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.arrow(let arrow), let layerIndex) = action {
            #expect(arrow.start == GridPoint(column: 1, row: 1))
            #expect(arrow.end == GridPoint(column: 10, row: 5))
            #expect(arrow.startAttachment == nil)
            #expect(arrow.endAttachment == nil)
            #expect(layerIndex == 0)
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_attach_arrow_endpoints_to_boxes() {
        // given
        let tool = ArrowTool()
        var doc = Document()

        let leftBox = BoxShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        let rightBox = BoxShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.box(leftBox), toLayerAt: 0)
        doc.addShape(.box(rightBox), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 5, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 23, row: 4), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.arrow(let arrow), _) = action {
            #expect(arrow.start == GridPoint(column: 9, row: 4))
            #expect(arrow.end == GridPoint(column: 20, row: 4))
            #expect(arrow.startAttachment == ArrowAttachment(shapeID: leftBox.id, side: .right))
            #expect(arrow.endAttachment == ArrowAttachment(shapeID: rightBox.id, side: .left))
            #expect(arrow.bendDirection == .verticalFirst)
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_not_create_zero_length_arrow() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 5, row: 5), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 5, row: 5), in: doc, activeLayerIndex: 0)

        // then
        #expect(action == .none)
    }

    @Test func should_show_preview_during_drag() {
        // given
        let tool = ArrowTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 1, row: 1), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(
            to: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)
        let preview = tool.previewShape()

        // then
        #expect(preview != nil)
    }

    @Test func should_use_clicked_start_terminus_when_drag_begins_on_attachment_point() {
        // given
        let tool = ArrowTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 10, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: box.boundingRect.minColumn, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 0, row: 4), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.arrow(let arrow), _) = action {
            #expect(arrow.start == GridPoint(column: box.boundingRect.minColumn, row: 4))
            #expect(arrow.startAttachment == ArrowAttachment(shapeID: box.id, side: .left))
        } else {
            Issue.record("Expected addShape action with arrow")
        }
    }

    @Test func should_not_snap_start_to_attachment_when_click_is_more_than_half_cell_away() {
        // given
        let tool = ArrowTool()
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 10, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        _ = tool.mouseDown(at: GridPoint(column: 8, row: 4), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 0, row: 4), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.arrow(let arrow), _) = action {
            #expect(arrow.start == GridPoint(column: 8, row: 4))
            #expect(arrow.startAttachment == nil)
        } else {
            Issue.record("Expected addShape action without snapped start attachment")
        }
    }
}
