import Testing

@testable import YuzuDraw

struct BoxToolTests {
    @Test func should_create_box_on_drag_and_release() {
        // given
        let tool = BoxTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(to: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.box(let box), let layerIndex) = action {
            #expect(box.origin == GridPoint(column: 2, row: 1))
            #expect(box.size == GridSize(width: 9, height: 5))
            #expect(layerIndex == 0)
        } else {
            Issue.record("Expected addShape action with box")
        }
    }

    @Test func should_not_create_box_smaller_than_2x2() {
        // given
        let tool = BoxTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 2, row: 1), in: doc, activeLayerIndex: 0)

        // then
        #expect(action == .none)
    }

    @Test func should_show_preview_during_drag() {
        // given
        let tool = BoxTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(to: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)
        let preview = tool.previewShape()

        // then
        #expect(preview != nil)
        if case .box(let box) = preview {
            #expect(box.origin == GridPoint(column: 2, row: 1))
        }
    }

    @Test func should_clear_preview_after_mouse_up() {
        // given
        let tool = BoxTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc, activeLayerIndex: 0)
        _ = tool.mouseUp(at: GridPoint(column: 10, row: 5), in: doc, activeLayerIndex: 0)
        let preview = tool.previewShape()

        // then
        #expect(preview == nil)
    }

    @Test func should_use_configured_border_style() {
        // given
        let tool = BoxTool()
        tool.strokeStyle = .double
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 0, row: 0), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.box(let box), _) = action {
            #expect(box.strokeStyle == .double)
        } else {
            Issue.record("Expected addShape action with box")
        }
    }
}
