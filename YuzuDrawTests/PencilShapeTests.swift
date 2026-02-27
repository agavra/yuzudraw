import Foundation
import Testing

@testable import YuzuDraw

struct PencilShapeTests {
    @Test func should_render_cells_at_correct_positions() {
        // given
        var canvas = Canvas(columns: 10, rows: 5)
        let shape = PencilShape(
            origin: GridPoint(column: 2, row: 1),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*"),
                GridPoint(column: 1, row: 0): PencilCell(character: "#"),
                GridPoint(column: 0, row: 1): PencilCell(character: "."),
            ]
        )

        // when
        shape.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 2, row: 1) == "*")
        #expect(canvas.character(atColumn: 3, row: 1) == "#")
        #expect(canvas.character(atColumn: 2, row: 2) == ".")
        #expect(canvas.character(atColumn: 4, row: 1) == " ")
    }

    @Test func should_compute_bounding_rect_from_cells() {
        // given
        let shape = PencilShape(
            origin: GridPoint(column: 5, row: 3),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*"),
                GridPoint(column: 3, row: 2): PencilCell(character: "*"),
            ]
        )

        // when
        let rect = shape.boundingRect

        // then
        #expect(rect.origin == GridPoint(column: 5, row: 3))
        #expect(rect.size == GridSize(width: 4, height: 3))
    }

    @Test func should_return_1x1_bounding_rect_for_empty_cells() {
        // given
        let shape = PencilShape(
            origin: GridPoint(column: 5, row: 3),
            cells: [:]
        )

        // when
        let rect = shape.boundingRect

        // then
        #expect(rect.size == GridSize(width: 1, height: 1))
    }

    @Test func should_contain_point_on_occupied_cell() {
        // given
        let shape = PencilShape(
            origin: GridPoint(column: 2, row: 1),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*"),
                GridPoint(column: 1, row: 1): PencilCell(character: "#"),
            ]
        )

        // when/then
        #expect(shape.contains(point: GridPoint(column: 2, row: 1)))
        #expect(shape.contains(point: GridPoint(column: 3, row: 2)))
    }

    @Test func should_not_contain_point_on_empty_cell_within_bounds() {
        // given
        let shape = PencilShape(
            origin: GridPoint(column: 2, row: 1),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*"),
                GridPoint(column: 2, row: 2): PencilCell(character: "#"),
            ]
        )

        // when/then
        #expect(!shape.contains(point: GridPoint(column: 3, row: 2)))
        #expect(!shape.contains(point: GridPoint(column: 0, row: 0)))
    }

    @Test func should_encode_and_decode_via_json() throws {
        // given
        let original = PencilShape(
            origin: GridPoint(column: 3, row: 5),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*"),
                GridPoint(column: 1, row: 1): PencilCell(
                    character: "#", color: .red),
            ]
        )
        let wrapped = AnyShape.pencil(original)

        // when
        let data = try JSONEncoder().encode(wrapped)
        let decoded = try JSONDecoder().decode(AnyShape.self, from: data)

        // then
        #expect(decoded == wrapped)
        if case .pencil(let pencil) = decoded {
            #expect(pencil.origin == GridPoint(column: 3, row: 5))
            #expect(pencil.cells.count == 2)
            #expect(pencil.cells[GridPoint(column: 0, row: 0)]?.character == "*")
            #expect(pencil.cells[GridPoint(column: 1, row: 1)]?.color == .red)
        } else {
            Issue.record("Expected pencil shape")
        }
    }

    @Test func should_add_cell_and_shift_origin_for_negative_offsets() {
        // given
        var shape = PencilShape(
            origin: GridPoint(column: 5, row: 5),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(character: "*")
            ]
        )

        // when
        shape.addCell(
            PencilCell(character: "#"),
            at: GridPoint(column: 3, row: 4)
        )

        // then
        #expect(shape.origin == GridPoint(column: 3, row: 4))
        #expect(shape.cells[GridPoint(column: 0, row: 0)]?.character == "#")
        #expect(shape.cells[GridPoint(column: 2, row: 1)]?.character == "*")
    }

    @Test func should_render_cells_with_color() {
        // given
        var canvas = Canvas(columns: 5, rows: 3)
        let shape = PencilShape(
            origin: GridPoint(column: 0, row: 0),
            cells: [
                GridPoint(column: 0, row: 0): PencilCell(
                    character: "*", color: .red)
            ]
        )

        // when
        shape.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 0, row: 0) == "*")
    }
}
