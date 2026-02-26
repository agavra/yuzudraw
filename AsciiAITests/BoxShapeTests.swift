import Testing

@testable import AsciiAI

struct BoxShapeTests {
    @Test func should_render_single_border_box() {
        // given
        var canvas = Canvas(columns: 12, rows: 5)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 12, height: 5),
            borderStyle: .single
        )

        // when
        box.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "┌──────────┐")
        #expect(lines[1] == "│          │")
        #expect(lines[4] == "└──────────┘")
    }

    @Test func should_render_double_border_box() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            borderStyle: .double
        )

        // when
        box.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "╔════╗")
        #expect(lines[1] == "║    ║")
        #expect(lines[2] == "╚════╝")
    }

    @Test func should_render_box_with_centered_label() {
        // given
        var canvas = Canvas(columns: 12, rows: 5)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 12, height: 5),
            borderStyle: .single,
            label: "Server"
        )

        // when
        box.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[2] == "│  Server  │")
    }

    @Test func should_truncate_long_label() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            borderStyle: .single,
            label: "VeryLongLabel"
        )

        // when
        box.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[1] == "│Very│")
    }

    @Test func should_not_render_box_smaller_than_2x2() {
        // given
        var canvas = Canvas(columns: 5, rows: 5)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 1, height: 1)
        )

        // when
        box.render(into: &canvas)

        // then - canvas should be all spaces
        #expect(canvas.character(atColumn: 0, row: 0) == " ")
    }

    @Test func should_contain_points_inside_bounding_rect() {
        // given
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4)
        )

        // then
        #expect(box.contains(point: GridPoint(column: 5, row: 3)))
        #expect(box.contains(point: GridPoint(column: 14, row: 6)))
        #expect(!box.contains(point: GridPoint(column: 4, row: 3)))
    }

    @Test func should_render_rounded_border_box() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            borderStyle: .rounded
        )

        // when
        box.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "╭────╮")
        #expect(lines[2] == "╰────╯")
    }
}
