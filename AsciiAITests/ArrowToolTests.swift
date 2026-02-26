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
            #expect(layerIndex == 0)
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
}
