import Testing

@testable import YuzuDraw

struct GeometryTests {
    // MARK: - GridPoint

    @Test func should_create_zero_point() {
        // given/when
        let point = GridPoint.zero

        // then
        #expect(point.column == 0)
        #expect(point.row == 0)
    }

    // MARK: - GridSize

    @Test func should_detect_empty_size() {
        // given
        let empty1 = GridSize(width: 0, height: 5)
        let empty2 = GridSize(width: 5, height: 0)
        let empty3 = GridSize(width: -1, height: 5)
        let nonEmpty = GridSize(width: 3, height: 3)

        // then
        #expect(empty1.isEmpty)
        #expect(empty2.isEmpty)
        #expect(empty3.isEmpty)
        #expect(!nonEmpty.isEmpty)
    }

    // MARK: - GridRect

    @Test func should_compute_rect_bounds() {
        // given
        let rect = GridRect(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4)
        )

        // then
        #expect(rect.minColumn == 5)
        #expect(rect.minRow == 3)
        #expect(rect.maxColumn == 14)
        #expect(rect.maxRow == 6)
    }

    @Test func should_detect_point_inside_rect() {
        // given
        let rect = GridRect(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4)
        )

        // then
        #expect(rect.contains(GridPoint(column: 5, row: 3)))
        #expect(rect.contains(GridPoint(column: 14, row: 6)))
        #expect(rect.contains(GridPoint(column: 10, row: 5)))
    }

    @Test func should_detect_point_outside_rect() {
        // given
        let rect = GridRect(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4)
        )

        // then
        #expect(!rect.contains(GridPoint(column: 4, row: 3)))
        #expect(!rect.contains(GridPoint(column: 15, row: 3)))
        #expect(!rect.contains(GridPoint(column: 5, row: 2)))
        #expect(!rect.contains(GridPoint(column: 5, row: 7)))
    }

    @Test func should_create_enclosing_rect() {
        // given
        let pointA = GridPoint(column: 10, row: 5)
        let pointB = GridPoint(column: 3, row: 8)

        // when
        let rect = GridRect.enclosing(from: pointA, to: pointB)

        // then
        #expect(rect.origin == GridPoint(column: 3, row: 5))
        #expect(rect.size == GridSize(width: 8, height: 4))
    }
}
