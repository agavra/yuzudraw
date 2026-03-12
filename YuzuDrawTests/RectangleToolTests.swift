import Testing

@testable import YuzuDraw

struct RectangleToolTests {
    @Test func should_create_rectangle_on_drag_and_release() {
        // given
        let tool = RectangleTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc)
        _ = tool.mouseDragged(to: GridPoint(column: 10, row: 5), in: doc)
        let action = tool.mouseUp(at: GridPoint(column: 10, row: 5), in: doc)

        // then
        if case .addShape(.rectangle(let rectangle)) = action {
            #expect(rectangle.origin == GridPoint(column: 2, row: 1))
            #expect(rectangle.size == GridSize(width: 9, height: 5))
        } else {
            Issue.record("Expected addShape action with rectangle")
        }
    }

    @Test func should_not_create_rectangle_smaller_than_2x2() {
        // given
        let tool = RectangleTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc)
        let action = tool.mouseUp(at: GridPoint(column: 2, row: 1), in: doc)

        // then
        #expect(action == .none)
    }

    @Test func should_show_preview_during_drag() {
        // given
        let tool = RectangleTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc)
        _ = tool.mouseDragged(to: GridPoint(column: 10, row: 5), in: doc)
        let preview = tool.previewShape()

        // then
        #expect(preview != nil)
        if case .rectangle(let rectangle) = preview {
            #expect(rectangle.origin == GridPoint(column: 2, row: 1))
        }
    }

    @Test func should_clear_preview_after_mouse_up() {
        // given
        let tool = RectangleTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 2, row: 1), in: doc)
        _ = tool.mouseUp(at: GridPoint(column: 10, row: 5), in: doc)
        let preview = tool.previewShape()

        // then
        #expect(preview == nil)
    }

    @Test func should_use_configured_border_style() {
        // given
        let tool = RectangleTool()
        tool.strokeStyle = .double
        let doc = Document()

        // when
        _ = tool.mouseDown(at: GridPoint(column: 0, row: 0), in: doc)
        let action = tool.mouseUp(at: GridPoint(column: 5, row: 3), in: doc)

        // then
        if case .addShape(.rectangle(let rectangle)) = action {
            #expect(rectangle.strokeStyle == .double)
        } else {
            Issue.record("Expected addShape action with rectangle")
        }
    }
}
