import Foundation

struct ArrowRoute: Sendable {
    let points: [GridPoint]
    let segments: [ArrowSegment]
    let bendDirection: ArrowBendDirection
}

enum ArrowRouter {
    static func route(
        start: GridPoint,
        end: GridPoint,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        bendHint: ArrowBendDirection = .horizontalFirst
    ) -> ArrowRoute? {
        guard start != end else { return nil }

        let startStub = startSide.map { side in
            GridPoint(column: start.column + outwardVector(for: side).dx, row: start.row + outwardVector(for: side).dy)
        }
        let endStub = endSide.map { side in
            GridPoint(column: end.column + outwardVector(for: side).dx, row: end.row + outwardVector(for: side).dy)
        }

        let coreStart = startStub ?? start
        let coreEnd = endStub ?? end

        var candidates: [[GridPoint]] = []
        candidates.append(contentsOf: coreCandidates(from: coreStart, to: coreEnd))

        let hintedTwoElbows = twoElbowCandidates(
            from: coreStart,
            to: coreEnd,
            startSide: startSide,
            endSide: endSide,
            bendHint: bendHint
        )
        candidates.append(contentsOf: hintedTwoElbows)

        var best: (route: ArrowRoute, score: Int)?

        for core in candidates {
            guard !core.isEmpty else { continue }

            var points: [GridPoint] = []
            appendPoint(start, into: &points)
            if let startStub { appendPoint(startStub, into: &points) }
            for point in core {
                appendPoint(point, into: &points)
            }
            if let endStub { appendPoint(endStub, into: &points) }
            appendPoint(end, into: &points)

            let simplifiedPoints = simplified(points)
            guard simplifiedPoints.count >= 2 else { continue }
            guard let segments = segments(from: simplifiedPoints), !segments.isEmpty else { continue }
            guard satisfiesEndpointConstraints(
                segments: segments,
                start: start,
                end: end,
                startSide: startSide,
                endSide: endSide
            ) else { continue }

            let score = scoreRoute(
                points: simplifiedPoints,
                segments: segments,
                start: start,
                end: end,
                startSide: startSide,
                endSide: endSide,
                bendHint: bendHint
            )

            let route = ArrowRoute(
                points: simplifiedPoints,
                segments: segments,
                bendDirection: bendDirection(for: segments, fallback: bendHint)
            )

            if let currentBest = best {
                if score < currentBest.score {
                    best = (route, score)
                }
            } else {
                best = (route, score)
            }
        }

        return best?.route
    }

    static func bendDirection(
        start: GridPoint,
        end: GridPoint,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        bendHint: ArrowBendDirection = .horizontalFirst
    ) -> ArrowBendDirection {
        route(
            start: start,
            end: end,
            startSide: startSide,
            endSide: endSide,
            bendHint: bendHint
        )?.bendDirection ?? bendHint
    }

    static func projectedFreeEnd(start: GridPoint, rawEnd: GridPoint) -> GridPoint {
        let dx = rawEnd.column - start.column
        let dy = rawEnd.row - start.row
        if abs(dx) >= abs(dy) {
            return GridPoint(column: rawEnd.column, row: start.row)
        }
        return GridPoint(column: start.column, row: rawEnd.row)
    }

    private static func coreCandidates(from start: GridPoint, to end: GridPoint) -> [[GridPoint]] {
        if start == end {
            return [[start]]
        }

        let horizontalFirst = GridPoint(column: end.column, row: start.row)
        let verticalFirst = GridPoint(column: start.column, row: end.row)

        return [
            [start, end],
            [start, horizontalFirst, end],
            [start, verticalFirst, end],
        ]
    }

    private static func twoElbowCandidates(
        from start: GridPoint,
        to end: GridPoint,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        bendHint: ArrowBendDirection
    ) -> [[GridPoint]] {
        var result: [[GridPoint]] = []

        let columns = candidateMiddleValues(
            a: start.column,
            b: end.column,
            startSide: startSide,
            endSide: endSide,
            axis: .horizontal
        )
        for column in columns {
            result.append([
                start,
                GridPoint(column: column, row: start.row),
                GridPoint(column: column, row: end.row),
                end,
            ])
        }

        let rows = candidateMiddleValues(
            a: start.row,
            b: end.row,
            startSide: startSide,
            endSide: endSide,
            axis: .vertical
        )
        for row in rows {
            result.append([
                start,
                GridPoint(column: start.column, row: row),
                GridPoint(column: end.column, row: row),
                end,
            ])
        }

        if bendHint == .horizontalFirst {
            return result
        }

        let split = result.partitioned { candidate in
            guard candidate.count > 1 else { return false }
            return candidate[0].column == candidate[1].column
        }
        return split.matching + split.nonMatching
    }

    private static func candidateMiddleValues(
        a: Int,
        b: Int,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        axis: CandidateAxis
    ) -> [Int] {
        var values: [Int] = []

        func add(_ value: Int) {
            if !values.contains(value) {
                values.append(value)
            }
        }

        let minValue = min(a, b)
        let maxValue = max(a, b)
        add((a + b) / 2)
        add(minValue + 1)
        add(maxValue - 1)
        add(minValue - 1)
        add(maxValue + 1)

        if let startDirection = outwardDirection(for: startSide, axis: axis) {
            add(a + startDirection)
            add(startDirection < 0 ? minValue - 1 : maxValue + 1)
        }
        if let endDirection = outwardDirection(for: endSide, axis: axis) {
            add(b + endDirection)
            add(endDirection < 0 ? minValue - 1 : maxValue + 1)
        }

        return values
    }

    private static func segments(from points: [GridPoint]) -> [ArrowSegment]? {
        guard points.count >= 2 else { return nil }

        var segments: [ArrowSegment] = []
        for index in 0..<(points.count - 1) {
            let from = points[index]
            let to = points[index + 1]
            guard from != to else { continue }
            guard from.column == to.column || from.row == to.row else { return nil }
            segments.append(ArrowSegment(from: from, to: to))
        }

        return segments
    }

    private static func satisfiesEndpointConstraints(
        segments: [ArrowSegment],
        start: GridPoint,
        end: GridPoint,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?
    ) -> Bool {
        guard let first = segments.first, let last = segments.last else {
            return false
        }
        guard first.from == start, last.to == end else {
            return false
        }

        if let startSide {
            let expected = outwardVector(for: startSide)
            guard direction(from: first.from, to: first.to) == expected else { return false }
        }

        if let endSide {
            let expected = inwardVector(for: endSide)
            guard direction(from: last.from, to: last.to) == expected else { return false }
        }

        return true
    }

    private static func scoreRoute(
        points: [GridPoint],
        segments: [ArrowSegment],
        start: GridPoint,
        end: GridPoint,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        bendHint: ArrowBendDirection
    ) -> Int {
        let bends = max(0, segments.count - 1)
        let length = segments.reduce(0) { partial, segment in
            partial + abs(segment.to.column - segment.from.column) + abs(segment.to.row - segment.from.row)
        }

        var penalty = 0

        for index in 1..<(points.count - 1) {
            let elbow = points[index]
            let fromStart = abs(elbow.column - start.column) + abs(elbow.row - start.row)
            let fromEnd = abs(elbow.column - end.column) + abs(elbow.row - end.row)
            if (startSide != nil && fromStart <= 1) || (endSide != nil && fromEnd <= 1) {
                penalty += 8
            }
        }

        if segments.count >= 3 {
            let middle = segments[1]
            let middleLength = abs(middle.to.column - middle.from.column) + abs(middle.to.row - middle.from.row)
            if middleLength <= 1 {
                penalty += 5
            }
        }

        if let first = segments.first {
            let isHorizontalFirst = first.from.row == first.to.row
            switch bendHint {
            case .horizontalFirst:
                if !isHorizontalFirst { penalty += 1 }
            case .verticalFirst:
                if isHorizontalFirst { penalty += 1 }
            }
        }

        return bends * 1000 + length * 10 + penalty
    }

    private static func bendDirection(for segments: [ArrowSegment], fallback: ArrowBendDirection) -> ArrowBendDirection {
        guard let first = segments.first else { return fallback }
        return first.isHorizontal ? .horizontalFirst : .verticalFirst
    }

    private static func outwardVector(for side: ArrowAttachmentSide) -> (dx: Int, dy: Int) {
        switch side {
        case .left: return (-1, 0)
        case .right: return (1, 0)
        case .top: return (0, -1)
        case .bottom: return (0, 1)
        }
    }

    private static func inwardVector(for side: ArrowAttachmentSide) -> (dx: Int, dy: Int) {
        let outward = outwardVector(for: side)
        return (-outward.dx, -outward.dy)
    }

    private static func direction(from: GridPoint, to: GridPoint) -> (dx: Int, dy: Int) {
        let dx = to.column - from.column
        let dy = to.row - from.row
        if dx > 0 { return (1, 0) }
        if dx < 0 { return (-1, 0) }
        if dy > 0 { return (0, 1) }
        if dy < 0 { return (0, -1) }
        return (0, 0)
    }

    private static func appendPoint(_ point: GridPoint, into points: inout [GridPoint]) {
        if points.last != point {
            points.append(point)
        }
    }

    private static func simplified(_ points: [GridPoint]) -> [GridPoint] {
        guard points.count >= 3 else { return points }
        var result: [GridPoint] = [points[0]]

        for index in 1..<(points.count - 1) {
            let previous = result[result.count - 1]
            let current = points[index]
            let next = points[index + 1]
            if isCollinear(previous: previous, current: current, next: next) {
                continue
            }
            result.append(current)
        }

        result.append(points[points.count - 1])
        return result
    }

    private static func isCollinear(previous: GridPoint, current: GridPoint, next: GridPoint) -> Bool {
        (previous.row == current.row && current.row == next.row)
            || (previous.column == current.column && current.column == next.column)
    }

    private enum CandidateAxis {
        case horizontal
        case vertical
    }

    private static func outwardDirection(for side: ArrowAttachmentSide?, axis: CandidateAxis) -> Int? {
        guard let side else { return nil }
        switch (axis, side) {
        case (.horizontal, .left):
            return -1
        case (.horizontal, .right):
            return 1
        case (.vertical, .top):
            return -1
        case (.vertical, .bottom):
            return 1
        case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .left), (.vertical, .right):
            return nil
        }
    }

}

private extension Array {
    func partitioned(_ isMatching: (Element) -> Bool) -> (matching: [Element], nonMatching: [Element]) {
        var matching: [Element] = []
        var nonMatching: [Element] = []

        for element in self {
            if isMatching(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }

        return (matching, nonMatching)
    }
}
