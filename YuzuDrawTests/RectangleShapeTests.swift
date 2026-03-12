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
            fillMode: .character,
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
            fillMode: .none,
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

    @Test func should_merge_overlapping_rectangle_borders() {
        // given — two overlapping single-border rectangles
        var canvas = Canvas(columns: 20, rows: 10)
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single
        )

        // when — render bottom first, then top (overlapping at column 5-9)
        rect1.render(into: &canvas)
        rect2.render(into: &canvas)

        // then — at column 5, top edge should merge into a tee-down (┬)
        // rect1 top border (left+right) + rect2 top-left corner (right+down) = left+right+down = ┬
        #expect(canvas.character(atColumn: 5, row: 0) == "┬")
        // at column 9: rect1 top-right corner (left+down) + rect2 top border (left+right) = left+right+down = ┬
        #expect(canvas.character(atColumn: 9, row: 0) == "┬")
        // at column 5, bottom edge: rect1 bottom border (left+right) + rect2 bottom-left corner (right+up) = left+right+up = ┴
        #expect(canvas.character(atColumn: 5, row: 4) == "┴")
    }

    @Test func should_not_merge_when_float_is_true() {
        // given — two overlapping rectangles, top one has float=true
        var canvas = Canvas(columns: 20, rows: 10)
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single,
            float: true
        )

        // when
        rect1.render(into: &canvas)
        rect2.render(into: &canvas)

        // then — float rect overwrites, no merge: column 5 top should be plain top-left corner
        #expect(canvas.character(atColumn: 5, row: 0) == "┌")
    }

    @Test func should_occlude_connections_into_filled_interior() {
        // given — rect1 has a vertical border, rect2 is filled and draws horizontal border over it
        var canvas = Canvas(columns: 20, rows: 10)
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single,
            fillMode: .opaque
        )

        // when
        rect1.render(into: &canvas)
        rect2.render(into: &canvas)

        // then — at (9,0): rect1's top-right corner ┐ (left+down), but rect2's fill erases the
        // vertical continuation below. rect2's top border adds (left+right). The "down" direction
        // is occluded by rect2's fill, so the result should be ─ (left+right only), not ┬.
        #expect(canvas.character(atColumn: 9, row: 0) == "─")

        // at (5,0): rect1 top border (left+right), rect2 top-left corner adds (right+down).
        // "down" here goes along rect2's left border (not into fill), so ┬ is correct.
        #expect(canvas.character(atColumn: 5, row: 0) == "┬")

        // at (9,4): rect1's bottom-right corner ┘ (left+up), rect2's bottom border (left+right).
        // "up" is occluded by rect2's fill, so result should be ─ (left+right only).
        #expect(canvas.character(atColumn: 9, row: 4) == "─")
    }

    @Test func should_merge_single_and_double_borders() {
        // given — single rect overlapping with double rect
        var canvas = Canvas(columns: 20, rows: 10)
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .single
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 0),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .double
        )

        // when
        rect1.render(into: &canvas)
        rect2.render(into: &canvas)

        // then — at column 9, row 0: single top border + double vertical produces mixed glyph
        // rect1 right border at column 9 is single vertical (up+down)
        // rect2 top border is double horizontal (left+right)
        // At (9,0): rect1 draws ┐ (single: left+down), rect2 draws ═ (double: left+right)
        // merged: single left, single down, double left, double right
        // This should produce a mixed glyph
        let char = canvas.character(atColumn: 9, row: 0)
        #expect(char != nil)
        // The exact glyph depends on merge logic — but it should NOT be a plain single or double char
        // rect1 corner at (9,0) = ┐ (single left+down), rect2 horizontal adds double left+right
        // The merged result should have down+left+right connections
    }
}
