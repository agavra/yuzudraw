import Foundation
import Testing

@testable import YuzuDraw

struct PencilToolTests {
    @Test func should_create_shape_on_click_and_release() {
        // given
        let tool = PencilTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.pencil(let pencil), let layerIndex) = action {
            #expect(layerIndex == 0)
            #expect(pencil.origin == GridPoint(column: 5, row: 3))
            #expect(pencil.cells.count == 1)
            #expect(pencil.cells[GridPoint(column: 0, row: 0)]?.character == "*")
        } else {
            Issue.record("Expected addShape action with pencil")
        }
    }

    @Test func should_add_cells_along_drag_path() {
        // given
        let tool = PencilTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(
            to: GridPoint(column: 8, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 8, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.pencil(let pencil), _) = action {
            // Should have cells at columns 5,6,7,8 (all row 3)
            #expect(pencil.cells.count == 4)
            for col in 0...3 {
                #expect(
                    pencil.cells[GridPoint(column: col, row: 0)] != nil,
                    "Expected cell at offset column \(col)")
            }
        } else {
            Issue.record("Expected addShape action with pencil")
        }
    }

    @Test func should_interpolate_between_distant_points() {
        // given — test Bresenham directly
        let points = PencilTool.bresenhamLine(
            from: GridPoint(column: 0, row: 0),
            to: GridPoint(column: 4, row: 2)
        )

        // then — should produce gap-free line
        #expect(!points.isEmpty)
        #expect(points.last == GridPoint(column: 4, row: 2))

        // Verify no gaps (each step differs by at most 1 in each axis)
        var prev = GridPoint(column: 0, row: 0)
        for point in points {
            let dc = abs(point.column - prev.column)
            let dr = abs(point.row - prev.row)
            #expect(dc <= 1, "Column gap too large: \(dc)")
            #expect(dr <= 1, "Row gap too large: \(dr)")
            prev = point
        }
    }

    @Test func should_show_preview_during_drag() {
        // given
        let tool = PencilTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(
            to: GridPoint(column: 7, row: 3), in: doc, activeLayerIndex: 0)
        let preview = tool.previewShape()

        // then
        #expect(preview != nil)
        if case .pencil(let pencil) = preview {
            #expect(pencil.cells.count >= 3)
        } else {
            Issue.record("Expected pencil preview shape")
        }
    }

    @Test func should_clear_preview_after_mouse_up() {
        // given
        let tool = PencilTool()
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        _ = tool.mouseUp(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        let preview = tool.previewShape()

        // then
        #expect(preview == nil)
    }

    @Test func should_use_configured_draw_character() {
        // given
        let tool = PencilTool()
        tool.drawCharacter = "#"
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.pencil(let pencil), _) = action {
            #expect(pencil.cells[GridPoint(column: 0, row: 0)]?.character == "#")
        } else {
            Issue.record("Expected addShape action with pencil")
        }
    }

    @Test func should_handle_negative_offset_by_shifting_origin() {
        // given
        let tool = PencilTool()
        let doc = Document()

        // when — draw right then left past origin
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        _ = tool.mouseDragged(
            to: GridPoint(column: 3, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 3, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.pencil(let pencil), _) = action {
            #expect(pencil.origin == GridPoint(column: 3, row: 3))
            // All offsets should be non-negative
            for offset in pencil.cells.keys {
                #expect(offset.column >= 0, "Negative column offset: \(offset)")
                #expect(offset.row >= 0, "Negative row offset: \(offset)")
            }
        } else {
            Issue.record("Expected addShape action with pencil")
        }
    }

    @Test func should_append_cells_to_existing_shape() {
        // given
        let tool = PencilTool()
        let existingPencil = PencilShape(
            origin: GridPoint(column: 5, row: 3),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*")
            ]
        )
        var doc = Document()
        doc.addShape(.pencil(existingPencil), toLayerAt: 0)
        tool.targetShapeID = existingPencil.id

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 6, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 6, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .updateShape(.pencil(let pencil)) = action {
            #expect(pencil.id == existingPencil.id)
            #expect(pencil.cells.count == 2)
            #expect(pencil.cells[GridPoint(column: 0, row: 0)]?.character == "*")
            #expect(pencil.cells[GridPoint(column: 1, row: 0)]?.character == "*")
        } else {
            Issue.record("Expected updateShape action with pencil, got \(action)")
        }
    }

    @Test func should_use_configured_draw_color() {
        // given
        let tool = PencilTool()
        tool.drawColor = .red
        let doc = Document()

        // when
        _ = tool.mouseDown(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)
        let action = tool.mouseUp(
            at: GridPoint(column: 5, row: 3), in: doc, activeLayerIndex: 0)

        // then
        if case .addShape(.pencil(let pencil), _) = action {
            #expect(pencil.cells[GridPoint(column: 0, row: 0)]?.color == .red)
        } else {
            Issue.record("Expected addShape action with pencil")
        }
    }

    @Test func should_interpolate_diagonal_line() {
        // given
        let points = PencilTool.bresenhamLine(
            from: GridPoint(column: 0, row: 0),
            to: GridPoint(column: 3, row: 3)
        )

        // then — Bresenham may produce intermediate steps; verify endpoint and continuity
        #expect(points.last == GridPoint(column: 3, row: 3))
        #expect(points.contains(GridPoint(column: 1, row: 1)))
        #expect(points.contains(GridPoint(column: 2, row: 2)))
        #expect(points.contains(GridPoint(column: 3, row: 3)))

        // Verify no gaps
        var prev = GridPoint(column: 0, row: 0)
        for point in points {
            let dc = abs(point.column - prev.column)
            let dr = abs(point.row - prev.row)
            #expect(dc <= 1)
            #expect(dr <= 1)
            prev = point
        }
    }

    @Test func should_return_empty_for_same_point_interpolation() {
        // given/when
        let points = PencilTool.bresenhamLine(
            from: GridPoint(column: 5, row: 5),
            to: GridPoint(column: 5, row: 5)
        )

        // then
        #expect(points.isEmpty)
    }
}
