import Foundation

enum ArrowBendDirection: String, Codable, Equatable, Sendable {
    case horizontalFirst
    case verticalFirst
}

enum ArrowAttachmentSide: String, Codable, Equatable, Sendable, CaseIterable {
    case left
    case right
    case top
    case bottom
}

struct ArrowAttachment: Codable, Equatable, Sendable {
    var shapeID: UUID
    var side: ArrowAttachmentSide
}

struct ArrowShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var start: GridPoint
    var end: GridPoint
    var label: String
    var bendDirection: ArrowBendDirection
    var startAttachment: ArrowAttachment?
    var endAttachment: ArrowAttachment?

    init(
        id: UUID = UUID(),
        start: GridPoint,
        end: GridPoint,
        label: String = "",
        bendDirection: ArrowBendDirection = .horizontalFirst,
        startAttachment: ArrowAttachment? = nil,
        endAttachment: ArrowAttachment? = nil
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.label = label
        self.bendDirection = bendDirection
        self.startAttachment = startAttachment
        self.endAttachment = endAttachment
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
            segment.render(
                into: &canvas,
                drawHead: isLast,
                includeFrom: index == 0,
                includeTo: isLast,
                headCharacterOverride: isLast ? endAttachment.map(headCharacter(for:)) : nil,
                mergeGlyph: mergeGlyph
            )
        }

        if segments.count >= 2 {
            for index in 0..<(segments.count - 1) {
                let corner = segments[index].to
                let cornerConnections = elbowConnections(
                    previous: segments[index].from,
                    corner: corner,
                    next: segments[index + 1].to
                )
                let existing = canvas.character(atColumn: corner.column, row: corner.row) ?? " "
                let merged = mergeGlyph(existing: existing, adding: cornerConnections)
                canvas.setCharacter(merged, atColumn: corner.column, row: corner.row)
            }
        }

        normalizeAttachedStartGlyph(into: &canvas)

        // Render label at midpoint of path
        if !label.isEmpty {
            let mid = midpoint()
            for (i, char) in label.enumerated() {
                canvas.setCharacter(char, atColumn: mid.column + i, row: mid.row)
            }
        }
    }

    /// Generates an orthogonal path with up to two elbows.
    func pathSegments() -> [ArrowSegment] {
        if start == end {
            return []
        }

        if start.column == end.column {
            if requiresEdgeAlignedDetour(for: .vertical) {
                let middleColumn = alignedDetourCoordinate(
                    base: start.column,
                    startSide: startAttachment?.side,
                    endSide: endAttachment?.side,
                    axis: .horizontal
                )
                return [
                    ArrowSegment(from: start, to: GridPoint(column: middleColumn, row: start.row)),
                    ArrowSegment(from: GridPoint(column: middleColumn, row: start.row), to: GridPoint(column: middleColumn, row: end.row)),
                    ArrowSegment(from: GridPoint(column: middleColumn, row: end.row), to: end),
                ].filter { $0.from != $0.to }
            }
            return [ArrowSegment(from: start, to: end)]
        }

        if start.row == end.row {
            if requiresEdgeAlignedDetour(for: .horizontal) {
                let middleRow = alignedDetourCoordinate(
                    base: start.row,
                    startSide: startAttachment?.side,
                    endSide: endAttachment?.side,
                    axis: .vertical
                )
                return [
                    ArrowSegment(from: start, to: GridPoint(column: start.column, row: middleRow)),
                    ArrowSegment(from: GridPoint(column: start.column, row: middleRow), to: GridPoint(column: end.column, row: middleRow)),
                    ArrowSegment(from: GridPoint(column: end.column, row: middleRow), to: end),
                ].filter { $0.from != $0.to }
            }
            return [ArrowSegment(from: start, to: end)]
        }

        let routePoints: [GridPoint]
        switch bendDirection {
        case .horizontalFirst:
            let middleColumn = middleAxisCoordinate(
                start: start.column,
                end: end.column,
                startSide: startAttachment?.side,
                endSide: endAttachment?.side,
                axis: .horizontal
            )
            routePoints = [
                start,
                GridPoint(column: middleColumn, row: start.row),
                GridPoint(column: middleColumn, row: end.row),
                end,
            ]
        case .verticalFirst:
            let middleRow = middleAxisCoordinate(
                start: start.row,
                end: end.row,
                startSide: startAttachment?.side,
                endSide: endAttachment?.side,
                axis: .vertical
            )
            routePoints = [
                start,
                GridPoint(column: start.column, row: middleRow),
                GridPoint(column: end.column, row: middleRow),
                end,
            ]
        }

        var segments: [ArrowSegment] = []
        for index in 0..<(routePoints.count - 1) {
            let from = routePoints[index]
            let to = routePoints[index + 1]
            if from != to {
                segments.append(ArrowSegment(from: from, to: to))
            }
        }
        return segments
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

    private func elbowConnections(previous: GridPoint, corner: GridPoint, next: GridPoint) -> LineConnections {
        var connections: LineConnections = []
        if previous.column < corner.column { connections.insert(.left) }
        if previous.column > corner.column { connections.insert(.right) }
        if previous.row < corner.row { connections.insert(.up) }
        if previous.row > corner.row { connections.insert(.down) }

        if next.column < corner.column { connections.insert(.left) }
        if next.column > corner.column { connections.insert(.right) }
        if next.row < corner.row { connections.insert(.up) }
        if next.row > corner.row { connections.insert(.down) }

        return connections
    }

    private func mergeGlyph(existing: Character, adding: LineConnections) -> Character {
        let base = connections(for: existing) ?? []
        return glyph(for: base.union(adding))
    }

    private func headCharacter(for attachment: ArrowAttachment) -> Character {
        switch attachment.side {
        case .top: return "▼"
        case .right: return "◀"
        case .bottom: return "▲"
        case .left: return "▶"
        }
    }

    private func normalizeAttachedStartGlyph(into canvas: inout Canvas) {
        guard let attachment = startAttachment else { return }

        let existing = canvas.character(atColumn: start.column, row: start.row) ?? " "
        var connections = connections(for: existing) ?? baseConnections(for: attachment.side)

        let inward = inwardConnection(for: attachment.side)
        let outward = outwardConnection(for: attachment.side)
        connections.remove(inward)
        connections.insert(outward)

        canvas.setCharacter(glyph(for: connections), atColumn: start.column, row: start.row)
    }

    private func baseConnections(for side: ArrowAttachmentSide) -> LineConnections {
        switch side {
        case .left, .right:
            return [.up, .down]
        case .top, .bottom:
            return [.left, .right]
        }
    }

    private func inwardConnection(for side: ArrowAttachmentSide) -> LineConnections {
        switch side {
        case .left: return .right
        case .right: return .left
        case .top: return .down
        case .bottom: return .up
        }
    }

    private func outwardConnection(for side: ArrowAttachmentSide) -> LineConnections {
        switch side {
        case .left: return .left
        case .right: return .right
        case .top: return .up
        case .bottom: return .down
        }
    }

    private enum RouteAxis {
        case horizontal
        case vertical
    }

    private enum SegmentAxis {
        case horizontal
        case vertical
    }

    private func middleAxisCoordinate(
        start: Int,
        end: Int,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        axis: RouteAxis
    ) -> Int {
        let minValue = min(start, end)
        let maxValue = max(start, end)

        // Prefer an interior middle coordinate only when both elbows can sit away from
        // attachment termini. Tight spans are routed outside instead of producing cramped bends.
        let interiorCandidates = Array((minValue + 1)..<maxValue)
        let comfortableCandidates = interiorCandidates.filter { candidate in
            abs(candidate - start) >= 2 && abs(candidate - end) >= 2
        }
        if !comfortableCandidates.isEmpty {
            let targetMidpoint = Double(start + end) / 2.0
            return comfortableCandidates.min { lhs, rhs in
                abs(Double(lhs) - targetMidpoint) < abs(Double(rhs) - targetMidpoint)
            } ?? comfortableCandidates[0]
        }

        // No comfortable interior coordinate available: route outside span and bias by outward side.
        if let outward = outwardDirection(for: startSide, axis: axis) {
            return outward < 0 ? minValue - 1 : maxValue + 1
        }
        if let outward = outwardDirection(for: endSide, axis: axis) {
            return outward < 0 ? minValue - 1 : maxValue + 1
        }

        return minValue - 1
    }

    private func outwardDirection(for side: ArrowAttachmentSide?, axis: RouteAxis) -> Int? {
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

    private func requiresEdgeAlignedDetour(for axis: SegmentAxis) -> Bool {
        func isEdgeAligned(_ side: ArrowAttachmentSide?) -> Bool {
            guard let side else { return false }
            switch (axis, side) {
            case (.horizontal, .top), (.horizontal, .bottom):
                return true
            case (.vertical, .left), (.vertical, .right):
                return true
            default:
                return false
            }
        }

        return isEdgeAligned(startAttachment?.side) || isEdgeAligned(endAttachment?.side)
    }

    private func alignedDetourCoordinate(
        base: Int,
        startSide: ArrowAttachmentSide?,
        endSide: ArrowAttachmentSide?,
        axis: RouteAxis
    ) -> Int {
        let startOutward = outwardDirection(for: startSide, axis: axis)
        let endOutward = outwardDirection(for: endSide, axis: axis)

        if let startOutward, let endOutward, startOutward == endOutward {
            return base + startOutward
        }
        if let startOutward {
            return base + startOutward
        }
        if let endOutward {
            return base + endOutward
        }

        return base - 1
    }

    private func connections(for char: Character) -> LineConnections? {
        switch char {
        case "─": return [.left, .right]
        case "│": return [.up, .down]
        case "┌", "╭": return [.right, .down]
        case "┐", "╮": return [.left, .down]
        case "└", "╰": return [.right, .up]
        case "┘", "╯": return [.left, .up]
        case "├": return [.up, .right, .down]
        case "┤": return [.up, .left, .down]
        case "┬": return [.left, .right, .down]
        case "┴": return [.left, .right, .up]
        case "┼": return [.up, .left, .right, .down]
        case "▶": return [.left]
        case "◀": return [.right]
        case "▲": return [.down]
        case "▼": return [.up]
        default:
            return nil
        }
    }

    private func glyph(for connections: LineConnections) -> Character {
        switch connections {
        case [.left, .right]:
            return "─"
        case [.up, .down]:
            return "│"
        case [.right, .down]:
            return "┌"
        case [.left, .down]:
            return "┐"
        case [.right, .up]:
            return "└"
        case [.left, .up]:
            return "┘"
        case [.up, .right, .down]:
            return "├"
        case [.up, .left, .down]:
            return "┤"
        case [.left, .right, .down]:
            return "┬"
        case [.left, .right, .up]:
            return "┴"
        case [.up, .left, .right, .down]:
            return "┼"
        default:
            if connections.contains(.left) || connections.contains(.right) {
                return "─"
            }
            if connections.contains(.up) || connections.contains(.down) {
                return "│"
            }
            return "+"
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case start
        case end
        case label
        case bendDirection
        case startAttachment
        case endAttachment
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        start = try container.decode(GridPoint.self, forKey: .start)
        end = try container.decode(GridPoint.self, forKey: .end)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        bendDirection =
            try container.decodeIfPresent(ArrowBendDirection.self, forKey: .bendDirection)
            ?? .horizontalFirst
        startAttachment = try container.decodeIfPresent(ArrowAttachment.self, forKey: .startAttachment)
        endAttachment = try container.decodeIfPresent(ArrowAttachment.self, forKey: .endAttachment)
    }
}

extension BoxShape {
    func attachmentPoint(for side: ArrowAttachmentSide) -> GridPoint {
        let rect = boundingRect
        let centerColumn = rect.minColumn + rect.size.width / 2
        let centerRow = rect.minRow + rect.size.height / 2
        switch side {
        case .left:
            return GridPoint(column: rect.minColumn, row: centerRow)
        case .right:
            return GridPoint(column: rect.maxColumn, row: centerRow)
        case .top:
            return GridPoint(column: centerColumn, row: rect.minRow)
        case .bottom:
            return GridPoint(column: centerColumn, row: rect.maxRow)
        }
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

    func render(
        into canvas: inout Canvas,
        drawHead: Bool,
        includeFrom: Bool,
        includeTo: Bool,
        headCharacterOverride: Character?,
        mergeGlyph: (Character, LineConnections) -> Character
    ) {
        if isHorizontal {
            let minCol = min(from.column, to.column)
            let maxCol = max(from.column, to.column)
            for col in minCol...maxCol {
                if drawHead, col == to.column {
                    continue
                }
                if !includeFrom, col == from.column { continue }
                if !includeTo, col == to.column { continue }
                let existing = canvas.character(atColumn: col, row: from.row) ?? " "
                let merged = mergeGlyph(existing, [.left, .right])
                canvas.setCharacter(merged, atColumn: col, row: from.row)
            }
            if drawHead {
                let headChar: Character =
                    headCharacterOverride ?? (to.column >= from.column ? "▶" : "◀")
                canvas.setCharacter(headChar, atColumn: to.column, row: to.row)
            }
        } else if isVertical {
            let minRow = min(from.row, to.row)
            let maxRow = max(from.row, to.row)
            for row in minRow...maxRow {
                if drawHead, row == to.row {
                    continue
                }
                if !includeFrom, row == from.row { continue }
                if !includeTo, row == to.row { continue }
                let existing = canvas.character(atColumn: from.column, row: row) ?? " "
                let merged = mergeGlyph(existing, [.up, .down])
                canvas.setCharacter(merged, atColumn: from.column, row: row)
            }
            if drawHead {
                let headChar: Character =
                    headCharacterOverride ?? (to.row >= from.row ? "▼" : "▲")
                canvas.setCharacter(headChar, atColumn: to.column, row: to.row)
            }
        }

        // Draw corner if this segment connects at a bend
        if !drawHead && !isHorizontal && !isVertical {
            // Only straight segments are generated, so this won't fire
        }
    }
}

struct LineConnections: OptionSet, Sendable {
    let rawValue: Int
    static let up = LineConnections(rawValue: 1 << 0)
    static let right = LineConnections(rawValue: 1 << 1)
    static let down = LineConnections(rawValue: 1 << 2)
    static let left = LineConnections(rawValue: 1 << 3)
}
