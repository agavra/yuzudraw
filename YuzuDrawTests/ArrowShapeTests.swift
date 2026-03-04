import Foundation
import Testing

@testable import YuzuDraw

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

    @Test func should_render_single_elbow_horizontal_first_arrow() {
        // given
        var canvas = Canvas(columns: 10, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 8, row: 6)
        )

        // when
        arrow.render(into: &canvas)

        // then
        // H-V route with a single corner at end column.
        #expect(canvas.character(atColumn: 1, row: 1) == "─")
        #expect(canvas.character(atColumn: 8, row: 1) == "┐")
        #expect(canvas.character(atColumn: 8, row: 3) == "│")
        #expect(canvas.character(atColumn: 8, row: 6) == "▼")
    }

    @Test func should_render_single_elbow_vertical_first_arrow() {
        // given
        var canvas = Canvas(columns: 10, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 8, row: 6),
            bendDirection: .verticalFirst
        )

        // when
        arrow.render(into: &canvas)

        // then
        // V-H route with a single corner at end row.
        #expect(canvas.character(atColumn: 1, row: 2) == "│")
        #expect(canvas.character(atColumn: 1, row: 6) == "└")
        #expect(canvas.character(atColumn: 6, row: 6) == "─")
        #expect(canvas.character(atColumn: 8, row: 6) == "▶")
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

    @Test func should_place_label_centered_on_horizontal_path_midpoint() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 9, row: 1),
            label: "ABC"
        )

        // when
        let editPoint = arrow.labelEditPoint

        // then
        #expect(editPoint == GridPoint(column: 4, row: 1))
    }

    @Test func should_slide_label_onto_horizontal_segment_when_midpoint_is_on_corner() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 9, row: 9),
            label: "HTTP",
            bendDirection: .verticalFirst
        )

        // when
        let editPoint = arrow.labelEditPoint

        // then
        #expect(editPoint == GridPoint(column: 2, row: 9))
    }

    @Test func should_fallback_to_anchor_centering_when_only_vertical_segments_exist() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 5, row: 1),
            end: GridPoint(column: 5, row: 9),
            label: "DB"
        )

        // when
        let editPoint = arrow.labelEditPoint

        // then
        #expect(editPoint == GridPoint(column: 4, row: 5))
    }

    @Test func should_render_cross_intersection_when_arrows_overlap() {
        // given
        var canvas = Canvas(columns: 12, rows: 8)
        let horizontal = ArrowShape(
            start: GridPoint(column: 1, row: 3),
            end: GridPoint(column: 10, row: 3)
        )
        let vertical = ArrowShape(
            start: GridPoint(column: 5, row: 0),
            end: GridPoint(column: 5, row: 7)
        )

        // when
        horizontal.render(into: &canvas)
        vertical.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 5, row: 3) == "┼")
    }

    @Test func should_render_tee_intersection_when_elbow_joins_horizontal_line() {
        // given
        var canvas = Canvas(columns: 12, rows: 8)
        let baseline = ArrowShape(
            start: GridPoint(column: 1, row: 2),
            end: GridPoint(column: 10, row: 2)
        )
        let joining = ArrowShape(
            start: GridPoint(column: 5, row: 5),
            end: GridPoint(column: 8, row: 0),
            bendDirection: .verticalFirst
        )

        // when
        baseline.render(into: &canvas)
        joining.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 5, row: 2) == "┼")
    }

    @Test func should_orient_arrowhead_from_end_attachment_side() {
        // given
        var canvas = Canvas(columns: 12, rows: 8)
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 8, row: 2),
            endAttachment: ArrowAttachment(shapeID: UUID(), side: .left)
        )

        // when
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 8, row: 2) == "▶")
    }

    @Test func should_use_tee_not_cross_at_attached_start() {
        // given
        var canvas = Canvas(columns: 16, rows: 10)
        let rectangle = RectangleShape(
            origin: GridPoint(column: 4, row: 2),
            size: GridSize(width: 6, height: 5)
        )
        let arrow = ArrowShape(
            start: GridPoint(column: 4, row: 4),
            end: GridPoint(column: 0, row: 4),
            startAttachment: ArrowAttachment(shapeID: UUID(), side: .left)
        )

        // when
        rectangle.render(into: &canvas)
        arrow.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 4, row: 4) == "┤")
    }

    @Test func should_exit_attached_start_in_declared_direction() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 10, row: 4),
            end: GridPoint(column: 11, row: 8),
            startAttachment: ArrowAttachment(shapeID: UUID(), side: .right)
        )

        // when
        let segments = arrow.pathSegments()

        // then
        #expect(!segments.isEmpty)
        #expect(segments[0].isHorizontal)
        #expect(segments[0].to.column > segments[0].from.column)
    }

    @Test func should_approach_attached_end_from_declared_side() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 0, row: 4),
            end: GridPoint(column: 10, row: 4),
            endAttachment: ArrowAttachment(shapeID: UUID(), side: .left)
        )

        // when
        let segments = arrow.pathSegments()

        // then
        #expect(!segments.isEmpty)
        let last = segments[segments.count - 1]
        #expect(last.isHorizontal)
        #expect(last.to.column > last.from.column)
    }

    @Test func should_detour_when_straight_horizontal_route_would_align_with_rectangle_edge() {
        // given
        let arrow = ArrowShape(
            start: GridPoint(column: 10, row: 4),
            end: GridPoint(column: 20, row: 4),
            startAttachment: ArrowAttachment(shapeID: UUID(), side: .top)
        )

        // when
        let segments = arrow.pathSegments()

        // then
        #expect(segments.count == 3)
        #expect(segments[0].isVertical)
        #expect(segments[0].to.row == 3)
        #expect(segments[1].isHorizontal)
        #expect(segments[1].from.row == 3)
        #expect(segments[2].isVertical)
    }
}
