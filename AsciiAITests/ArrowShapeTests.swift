import Testing

@testable import AsciiAI

struct ArrowShapeTests {
    @Test func should_render_horizontal_arrow() {
        // given
        var canvas = Canvas(columns: 10, rows: 3)
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 8, row: 1)
        )

        // when
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 1, row: 1) == "─")
        #expect(canvas.character(atColumn: 5, row: 1) == "─")
        #expect(canvas.character(atColumn: 8, row: 1) == "▶")
    }

    @Test func should_render_vertical_arrow() {
        // given
        var canvas = Canvas(columns: 5, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 1),
            end: GridPoint(column: 2, row: 6)
        )

        // when
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 2, row: 1) == "│")
        #expect(canvas.character(atColumn: 2, row: 3) == "│")
        #expect(canvas.character(atColumn: 2, row: 6) == "▼")
    }

    @Test func should_render_l_shaped_arrow() {
        // given
        var canvas = Canvas(columns: 10, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 8, row: 6)
        )

        // when
        arrow.render(into: &canvas)

        // then
        // Horizontal segment from (1,1) to (8,1)
        #expect(canvas.character(atColumn: 1, row: 1) == "─")
        #expect(canvas.character(atColumn: 5, row: 1) == "─")
        // Vertical segment from (8,1) to (8,6) with arrowhead
        #expect(canvas.character(atColumn: 8, row: 2) == "│")
        #expect(canvas.character(atColumn: 8, row: 6) == "▼")
    }

    @Test func should_render_arrow_pointing_left() {
        // given
        var canvas = Canvas(columns: 10, rows: 3)
        let arrow = ArrowShape(
            start: GridPoint(column: 8, row: 1),
            end: GridPoint(column: 1, row: 1)
        )

        // when
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 1, row: 1) == "◀")
        #expect(canvas.character(atColumn: 5, row: 1) == "─")
    }

    @Test func should_render_arrow_pointing_up() {
        // given
        var canvas = Canvas(columns: 5, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 6),
            end: GridPoint(column: 2, row: 1)
        )

        // when
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 2, row: 1) == "▲")
        #expect(canvas.character(atColumn: 2, row: 3) == "│")
    }

    @Test func should_generate_no_segments_for_same_point() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 3, row: 3),
            end: GridPoint(column: 3, row: 3)
        )

        // when
        let segments = arrow.pathSegments()

        // then
        #expect(segments.isEmpty)
    }

    @Test func should_contain_points_on_path() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 8, row: 1)
        )

        // then
        #expect(arrow.contains(point: GridPoint(column: 1, row: 1)))
        #expect(arrow.contains(point: GridPoint(column: 5, row: 1)))
        #expect(!arrow.contains(point: GridPoint(column: 5, row: 2)))
    }
}
