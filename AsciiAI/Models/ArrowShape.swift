import Foundation

struct ArrowShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var start: GridPoint
    var end: GridPoint
    var label: String

    init(
        id: UUID = UUID(),
        start: GridPoint,
        end: GridPoint,
        label: String = ""
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.label = label
    }

    var boundingRect: GridRect {
        GridRect.enclosing(from: start, to: end)
    }

    func contains(point: GridPoint) -> Bool {
        for segment in pathSegments() {
            if segment.contains(point) {
                return true
            }
        }
        return false
    }

    func render(into canvas: inout Canvas) {
        let segments = pathSegments()
        for (index, segment) in segments.enumerated() {
            let isLast = index == segments.count - 1
            segment.render(into: &canvas, drawHead: isLast)
        }

        // Render label at midpoint of path
        if !label.isEmpty {
            let mid = midpoint()
            for (i, char) in label.enumerated() {
                canvas.setCharacter(char, atColumn: mid.column + i, row: mid.row)
            }
        }
    }

    /// Generates an L-shaped orthogonal path: horizontal first, then vertical.
    func pathSegments() -> [ArrowSegment] {
        if start == end {
            return []
        }

        let cornerPoint = GridPoint(column: end.column, row: start.row)

        if cornerPoint == start || cornerPoint == end {
            // Straight line (purely horizontal or vertical)
            return [ArrowSegment(from: start, to: end)]
        }

        return [
            ArrowSegment(from: start, to: cornerPoint),
            ArrowSegment(from: cornerPoint, to: end),
        ]
    }

    private func midpoint() -> GridPoint {
        let segments = pathSegments()
        guard !segments.isEmpty else { return start }

        // Place label at midpoint of the first segment
        let seg = segments[0]
        return GridPoint(
            column: (seg.from.column + seg.to.column) / 2,
            row: (seg.from.row + seg.to.row) / 2
        )
    }
}

struct ArrowSegment: Equatable, Sendable {
    let from: GridPoint
    let to: GridPoint

    var isHorizontal: Bool { from.row == to.row }
    var isVertical: Bool { from.column == to.column }

    func contains(_ point: GridPoint) -> Bool {
        if isHorizontal {
            return point.row == from.row
                && point.column >= min(from.column, to.column)
                && point.column <= max(from.column, to.column)
        } else if isVertical {
            return point.column == from.column
                && point.row >= min(from.row, to.row)
                && point.row <= max(from.row, to.row)
        }
        return false
    }

    func render(into canvas: inout Canvas, drawHead: Bool) {
        if isHorizontal {
            let minCol = min(from.column, to.column)
            let maxCol = max(from.column, to.column)
            for col in minCol...maxCol {
                canvas.setCharacter("─", atColumn: col, row: from.row)
            }
            if drawHead {
                let headChar: Character = to.column >= from.column ? "▶" : "◀"
                canvas.setCharacter(headChar, atColumn: to.column, row: to.row)
            }
        } else if isVertical {
            let minRow = min(from.row, to.row)
            let maxRow = max(from.row, to.row)
            for row in minRow...maxRow {
                canvas.setCharacter("│", atColumn: from.column, row: row)
            }
            if drawHead {
                let headChar: Character = to.row >= from.row ? "▼" : "▲"
                canvas.setCharacter(headChar, atColumn: to.column, row: to.row)
            }
        }

        // Draw corner if this segment connects at a bend
        if !drawHead && !isHorizontal && !isVertical {
            // Only straight segments are generated, so this won't fire
        }
    }
}
