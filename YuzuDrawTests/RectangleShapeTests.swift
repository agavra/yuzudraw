import Testing

@testable import YuzuDraw

struct RectangleShapeTests {
    @Test func should_render_single_border_rectangle() {
        // given
        var canvas = Canvas(columns: 12, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 12, height: 5),
            strokeStyle: .single
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "┌──────────┐")
        #expect(lines[1] == "│          │")
        #expect(lines[4] == "└──────────┘")
    }

    @Test func should_render_double_border_rectangle() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .double
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "╔════╗")
        #expect(lines[1] == "║    ║")
        #expect(lines[2] == "╚════╝")
    }

    @Test func should_render_rectangle_with_centered_label() {
        // given
        var canvas = Canvas(columns: 12, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 12, height: 5),
            strokeStyle: .single,
            label: "Server"
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[2] == "│  Server  │")
    }

    @Test func should_truncate_long_label() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single,
            label: "VeryLongLabel"
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[1] == "│Very│")
    }

    @Test func should_not_render_rectangle_smaller_than_2x2() {
        // given
        var canvas = Canvas(columns: 5, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 1, height: 1)
        )

        // when
        rectangle.render(into: &canvas)

        // then - canvas should be all spaces
        #expect(canvas.character(atColumn: 0, row: 0) == " ")
    }

    @Test func should_contain_points_inside_bounding_rect() {
        // given
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4)
        )

        // then
        #expect(rectangle.contains(point: GridPoint(column: 5, row: 3)))
        #expect(rectangle.contains(point: GridPoint(column: 14, row: 6)))
        #expect(!rectangle.contains(point: GridPoint(column: 4, row: 3)))
    }

    @Test func should_render_rounded_border_rectangle() {
        // given
        var canvas = Canvas(columns: 6, rows: 3)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .rounded
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "╭────╮")
        #expect(lines[2] == "╰────╯")
    }

    @Test func should_render_only_selected_border_sides() {
        // given
        var canvas = Canvas(columns: 6, rows: 4)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            visibleBorders: [.top, .left]
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "┌─────")
        #expect(lines[1] == "│     ")
        #expect(lines[2] == "│     ")
        #expect(lines[3] == "│     ")
    }

    @Test func should_render_dashed_rectangle_border_with_configured_pattern() {
        // given
        var canvas = Canvas(columns: 8, rows: 4)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 8, height: 4),
            borderLineStyle: .dashed,
            borderDashLength: 1,
            borderGapLength: 1
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "┌─ ─ ─ ┐")
        #expect(lines[1] == "│      │")
        #expect(lines[3] == "└─ ─ ─ ┘")
    }

    @Test func should_render_solid_fill_inside_rectangle() {
        // given
        var canvas = Canvas(columns: 7, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 7, height: 5),
            strokeStyle: .single,
            fillMode: .solid,
            fillCharacter: "."
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[1] == "│.....│")
        #expect(lines[3] == "│.....│")
    }

    @Test func should_render_text_with_right_bottom_alignment() {
        // given
        var canvas = Canvas(columns: 10, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            label: "Hi",
            textHorizontalAlignment: .right,
            textVerticalAlignment: .bottom
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[3] == "│      Hi│")
    }

    @Test func should_render_borderless_text_rectangle_with_alignment() {
        // given
        var canvas = Canvas(columns: 10, rows: 4)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 4),
            hasBorder: false,
            label: "Hi",
            textHorizontalAlignment: .left,
            textVerticalAlignment: .top
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[0] == "Hi        ")
    }

    @Test func should_allow_text_on_border_with_padding() {
        // given
        var canvas = Canvas(columns: 10, rows: 5)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            label: "Hi",
            textHorizontalAlignment: .left,
            textVerticalAlignment: .top,
            allowTextOnBorder: true,
            textPaddingLeft: 1,
            textPaddingTop: 1
        )

        // when
        rectangle.render(into: &canvas)

        // then
        let rendered = canvas.render()
        let lines = rendered.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines[1] == "│Hi      │")
    }

    @Test func should_render_shadow_with_default_offset_size_bottom_right() {
        // given
        var canvas = Canvas(columns: 8, rows: 6)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 4, height: 3),
            hasShadow: true
        )

        // when
        rectangle.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 4, row: 1) == "░")
        #expect(canvas.character(atColumn: 4, row: 2) == "░")
        #expect(canvas.character(atColumn: 1, row: 3) == "░")
        #expect(canvas.character(atColumn: 0, row: 0) == "┌")
    }

    @Test func should_render_dark_shadow_with_custom_xy_offsets() {
        // given
        var canvas = Canvas(columns: 12, rows: 8)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 4, height: 3),
            hasShadow: true,
            shadowStyle: .dark,
            shadowOffsetX: 2,
            shadowOffsetY: 2
        )

        // when
        rectangle.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 6, row: 5) == "▓")
    }

    @Test func should_not_render_shadow_inside_unfilled_rectangle() {
        // given
        var canvas = Canvas(columns: 8, rows: 6)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 4, height: 3),
            hasBorder: true,
            fillMode: .transparent,
            hasShadow: true,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )

        // when
        rectangle.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 1, row: 1) == " ")
        #expect(canvas.character(atColumn: 4, row: 1) == "░")
        #expect(canvas.character(atColumn: 1, row: 3) == "░")
    }
}
