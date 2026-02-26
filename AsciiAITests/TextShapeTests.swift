import Testing

@testable import AsciiAI

struct TextShapeTests {
    @Test func should_render_single_line_text() {
        // given
        var canvas = Canvas(columns: 20, rows: 5)
        let text = TextShape(
            origin: GridPoint(column: 2, row: 1),
            text: "Hello"
        )

        // when
        text.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 2, row: 1) == "H")
        #expect(canvas.character(atColumn: 6, row: 1) == "o")
    }

    @Test func should_render_multi_line_text() {
        // given
        var canvas = Canvas(columns: 20, rows: 5)
        let text = TextShape(
            origin: GridPoint(column: 0, row: 0),
            text: "Line 1\nLine 2"
        )

        // when
        text.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 0, row: 0) == "L")
        #expect(canvas.character(atColumn: 0, row: 1) == "L")
        #expect(canvas.character(atColumn: 5, row: 1) == "2")
    }

    @Test func should_compute_bounding_rect_for_multiline() {
        // given
        let text = TextShape(
            origin: GridPoint(column: 3, row: 2),
            text: "Short\nLonger line"
        )

        // when
        let rect = text.boundingRect

        // then
        #expect(rect.origin == GridPoint(column: 3, row: 2))
        #expect(rect.size == GridSize(width: 11, height: 2))
    }

    @Test func should_contain_points_inside_bounding_rect() {
        // given
        let text = TextShape(
            origin: GridPoint(column: 5, row: 3),
            text: "Hello"
        )

        // then
        #expect(text.contains(point: GridPoint(column: 5, row: 3)))
        #expect(text.contains(point: GridPoint(column: 9, row: 3)))
        #expect(!text.contains(point: GridPoint(column: 4, row: 3)))
        #expect(!text.contains(point: GridPoint(column: 10, row: 3)))
    }
}
