import Testing
@testable import YuzuDraw

struct CanvasTests {
    // MARK: - Initialization

    @Test func should_create_canvas_with_default_dimensions() {
        // given/when
        let canvas = Canvas()

        // then
        #expect(canvas.columns == Canvas.defaultColumns)
        #expect(canvas.rows == Canvas.defaultRows)
    }

    @Test func should_create_canvas_with_custom_dimensions() {
        // given/when
        let canvas = Canvas(columns: 40, rows: 12)

        // then
        #expect(canvas.columns == 40)
        #expect(canvas.rows == 12)
    }

    @Test func should_initialize_grid_with_spaces() {
        // given/when
        let canvas = Canvas(columns: 3, rows: 2)

        // then
        for row in 0..<2 {
            for col in 0..<3 {
                #expect(canvas.character(atColumn: col, row: row) == " ")
            }
        }
    }

    // MARK: - Character access

    @Test func should_set_and_get_character() {
        // given
        var canvas = Canvas(columns: 10, rows: 10)

        // when
        canvas.setCharacter("#", atColumn: 5, row: 3)

        // then
        #expect(canvas.character(atColumn: 5, row: 3) == "#")
    }

    @Test func should_return_nil_for_out_of_bounds_access() {
        // given
        let canvas = Canvas(columns: 10, rows: 10)

        // then
        #expect(canvas.character(atColumn: -1, row: 0) == nil)
        #expect(canvas.character(atColumn: 10, row: 0) == nil)
        #expect(canvas.character(atColumn: 0, row: -1) == nil)
        #expect(canvas.character(atColumn: 0, row: 10) == nil)
    }

    @Test func should_ignore_set_for_out_of_bounds() {
        // given
        var canvas = Canvas(columns: 10, rows: 10)

        // when
        canvas.setCharacter("#", atColumn: -1, row: 0)
        canvas.setCharacter("#", atColumn: 10, row: 0)

        // then - no crash, grid unchanged
        #expect(canvas.character(atColumn: 0, row: 0) == " ")
    }

    // MARK: - Rendering

    @Test func should_render_empty_canvas() {
        // given
        let canvas = Canvas(columns: 3, rows: 2)

        // when
        let rendered = canvas.render()

        // then
        #expect(rendered == "   \n   ")
    }

    @Test func should_render_canvas_with_content() {
        // given
        var canvas = Canvas(columns: 3, rows: 2)
        canvas.setCharacter("A", atColumn: 0, row: 0)
        canvas.setCharacter("B", atColumn: 2, row: 1)

        // when
        let rendered = canvas.render()

        // then
        #expect(rendered == "A  \n  B")
    }

    // MARK: - CanvasCell

    @Test func should_set_and_get_colored_cell() {
        // given
        var canvas = Canvas(columns: 10, rows: 10)

        // when
        canvas.setCharacter(
            "#",
            foreground: .red,
            background: .blue,
            atColumn: 3, row: 2
        )

        // then
        let cell = canvas.cell(atColumn: 3, row: 2)
        #expect(cell?.character == "#")
        #expect(cell?.foregroundColor == .red)
        #expect(cell?.backgroundColor == .blue)
    }

    @Test func should_preserve_existing_background_when_foreground_only() {
        // given
        var canvas = Canvas(columns: 10, rows: 10)
        canvas.setCharacter(
            " ",
            foreground: nil,
            background: .green,
            atColumn: 1, row: 1
        )

        // when
        canvas.setCharacter(
            "X",
            foreground: .red,
            background: nil,
            atColumn: 1, row: 1
        )

        // then
        let cell = canvas.cell(atColumn: 1, row: 1)
        #expect(cell?.character == "X")
        #expect(cell?.foregroundColor == .red)
        #expect(cell?.backgroundColor == .green)
    }

    @Test func should_return_nil_cell_for_out_of_bounds() {
        // given
        let canvas = Canvas(columns: 5, rows: 5)

        // then
        #expect(canvas.cell(atColumn: -1, row: 0) == nil)
        #expect(canvas.cell(atColumn: 5, row: 0) == nil)
    }

    @Test func should_render_plain_text_ignoring_colors() {
        // given
        var canvas = Canvas(columns: 3, rows: 1)
        canvas.setCharacter(
            "A",
            foreground: .red,
            background: .blue,
            atColumn: 0, row: 0
        )
        canvas.setCharacter("B", atColumn: 1, row: 0)

        // when
        let rendered = canvas.render()

        // then
        #expect(rendered == "AB ")
    }

    @Test func should_clear_canvas_cells() {
        // given
        var canvas = Canvas(columns: 5, rows: 5)
        canvas.setCharacter(
            "X",
            foreground: .red,
            background: .blue,
            atColumn: 2, row: 2
        )

        // when
        canvas.clear()

        // then
        let cell = canvas.cell(atColumn: 2, row: 2)
        #expect(cell?.character == " ")
        #expect(cell?.foregroundColor == nil)
        #expect(cell?.backgroundColor == nil)
    }
}
