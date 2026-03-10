import Foundation

enum ArrowBendDirection: String, Codable, Equatable, Sendable, CaseIterable {
    case horizontalFirst
    case verticalFirst
}

enum ArrowHeadStyle: String, Codable, Equatable, Sendable, CaseIterable {
    case none
    case filled
    case ascii
    case dot
    case openDot
    case diamond
    case openDiamond
    case square
    case openSquare

    var pickerCharacter: String {
        switch self {
        case .none: return "—"
        case .filled: return "▶"
        case .ascii: return ">"
        case .dot: return "●"
        case .openDot: return "○"
        case .diamond: return "◆"
        case .openDiamond: return "◇"
        case .square: return "■"
        case .openSquare: return "□"
        }
    }

    func character(for direction: ArrowHeadDirection) -> Character {
        switch self {
        case .none:
            return " "
        case .filled:
            switch direction {
            case .right: return "▶"
            case .left: return "◀"
            case .down: return "▼"
            case .up: return "▲"
            }
        case .ascii:
            switch direction {
            case .right: return ">"
            case .left: return "<"
            case .down: return "v"
            case .up: return "^"
            }
        case .dot: return "●"
        case .openDot: return "○"
        case .diamond: return "◆"
        case .openDiamond: return "◇"
        case .square: return "■"
        case .openSquare: return "□"
        }
    }
}

enum ArrowHeadDirection: Sendable {
    case left
    case right
    case up
    case down
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
    var name: String?
    var start: GridPoint
    var end: GridPoint
    var label: String
    var strokeStyle: StrokeStyle
    var bendDirection: ArrowBendDirection
    var startAttachment: ArrowAttachment?
    var endAttachment: ArrowAttachment?
    var startHeadStyle: ArrowHeadStyle
    var endHeadStyle: ArrowHeadStyle
    var strokeColor: ShapeColor?
    var labelColor: ShapeColor?
    var float: Bool

    init(
        id: UUID = UUID(),
        name: String? = nil,
        start: GridPoint,
        end: GridPoint,
        label: String = "",
        strokeStyle: StrokeStyle = .single,
        bendDirection: ArrowBendDirection = .horizontalFirst,
        startAttachment: ArrowAttachment? = nil,
        endAttachment: ArrowAttachment? = nil,
        startHeadStyle: ArrowHeadStyle = .none,
        endHeadStyle: ArrowHeadStyle = .filled,
        strokeColor: ShapeColor? = nil,
        labelColor: ShapeColor? = nil,
        float: Bool = false
    ) {
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.label = label
        self.strokeStyle = strokeStyle
        self.bendDirection = bendDirection
        self.startAttachment = startAttachment
        self.endAttachment = endAttachment
        self.startHeadStyle = startHeadStyle
        self.endHeadStyle = endHeadStyle
        self.strokeColor = strokeColor
        self.labelColor = labelColor
        self.float = float
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
            let endHeadChar: Character? = isLast ? endHeadCharacter(for: segment) : nil
            segment.render(
                into: &canvas,
                drawHead: isLast && endHeadStyle != .none,
                includeFrom: index == 0,
                includeTo: isLast,
                headCharacterOverride: endHeadChar,
                mergeGlyph: mergeGlyph,
                foregroundColor: strokeColor
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
                canvas.setCharacter(
                    merged,
                    foreground: strokeColor,
                    background: nil,
                    atColumn: corner.column, row: corner.row
                )
            }
        }

        normalizeAttachedStartGlyph(into: &canvas)

        // Render start head
        if startHeadStyle != .none, let firstSegment = segments.first {
            let direction = startHeadDirection(for: firstSegment)
            let headChar = startHeadStyle.character(for: direction)
            canvas.setCharacter(
                headChar,
                foreground: strokeColor,
                background: nil,
                atColumn: start.column, row: start.row
            )
        }

        // Render label at midpoint of path
        if !label.isEmpty {
            let mid = labelEditPoint
            let lines = label.components(separatedBy: "\n")
            for (lineIndex, line) in lines.enumerated() {
                for (i, char) in line.enumerated() {
                    canvas.setCharacter(
                        char,
                        foreground: labelColor,
                        background: nil,
                        atColumn: mid.column + i, row: mid.row + lineIndex
                    )
                }
            }
        }
    }

    /// Generates an orthogonal path with up to two elbows.
    func pathSegments() -> [ArrowSegment] {
        ArrowRouter.route(
            start: start,
            end: end,
            startSide: startAttachment?.side,
            endSide: endAttachment?.side,
            bendHint: bendDirection
        )?.segments ?? []
    }

    var labelEditPoint: GridPoint {
        let segments = pathSegments()
        guard !segments.isEmpty else { return start }
        let labelLines = label.components(separatedBy: "\n")
        let labelLength = max(1, labelLines.map(\.count).max() ?? label.count)
        let (anchor, anchorSegmentIndex) = midpointAnchor(in: segments)

        if let horizontalPlacement = horizontalLabelPlacement(
            in: segments,
            anchor: anchor,
            anchorSegmentIndex: anchorSegmentIndex,
            labelLength: labelLength
        ) {
            return horizontalPlacement
        }

        // If there is no viable horizontal span, keep the label centered on the path anchor.
        return GridPoint(
            column: anchor.column - labelLength / 2,
            row: anchor.row
        )
    }

    private func midpointAnchor(in segments: [ArrowSegment]) -> (point: GridPoint, segmentIndex: Int) {
        let totalLength = segments.reduce(0) { $0 + $1.length }
        guard totalLength > 0 else { return (start, 0) }

        let targetDistance = totalLength / 2
        var traversed = 0

        for (index, segment) in segments.enumerated() {
            let next = traversed + segment.length
            if targetDistance <= next {
                let offset = targetDistance - traversed
                return (segment.point(at: offset), index)
            }
            traversed = next
        }

        let lastIndex = max(segments.count - 1, 0)
        return (segments[lastIndex].to, lastIndex)
    }

    private func horizontalLabelPlacement(
        in segments: [ArrowSegment],
        anchor: GridPoint,
        anchorSegmentIndex: Int,
        labelLength: Int
    ) -> GridPoint? {
        let horizontalSegments = segments.enumerated().filter { $0.element.isHorizontal }
        guard !horizontalSegments.isEmpty else { return nil }

        let preferred = horizontalSegments.sorted { lhs, rhs in
            if lhs.offset == anchorSegmentIndex { return true }
            if rhs.offset == anchorSegmentIndex { return false }
            return abs(lhs.offset - anchorSegmentIndex) < abs(rhs.offset - anchorSegmentIndex)
        }
        let endpointPadding = 1
        let cornerPadding = 1

        for candidate in preferred {
            let index = candidate.offset
            let segment = candidate.element
            let hasPrevious = index > 0
            let hasNext = index < segments.count - 1
            let leftPadding = hasPrevious ? cornerPadding : endpointPadding
            let rightPadding = hasNext ? cornerPadding : endpointPadding

            let minColumn = min(segment.from.column, segment.to.column) + leftPadding
            let maxColumn = max(segment.from.column, segment.to.column) - rightPadding
            let minStart = minColumn
            let maxStart = maxColumn - labelLength + 1

            guard minStart <= maxStart else { continue }

            let targetCenter = anchor.column
            let centeredStart = targetCenter - labelLength / 2
            let clampedStart = min(max(centeredStart, minStart), maxStart)
            return GridPoint(column: clampedStart, row: segment.from.row)
        }

        return nil
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
        GlyphMerge.mergeGlyph(existing: existing, adding: adding, style: strokeStyle)
    }

    private func endHeadCharacter(for segment: ArrowSegment) -> Character {
        let direction: ArrowHeadDirection
        if let attachment = endAttachment {
            switch attachment.side {
            case .top: direction = .down
            case .bottom: direction = .up
            case .left: direction = .right
            case .right: direction = .left
            }
        } else if segment.isHorizontal {
            direction = segment.to.column >= segment.from.column ? .right : .left
        } else {
            direction = segment.to.row >= segment.from.row ? .down : .up
        }
        return endHeadStyle.character(for: direction)
    }

    private func startHeadDirection(for segment: ArrowSegment) -> ArrowHeadDirection {
        if let attachment = startAttachment {
            switch attachment.side {
            case .top: return .down
            case .bottom: return .up
            case .left: return .right
            case .right: return .left
            }
        }
        if segment.isHorizontal {
            return segment.to.column >= segment.from.column ? .left : .right
        } else {
            return segment.to.row >= segment.from.row ? .up : .down
        }
    }

    private func normalizeAttachedStartGlyph(into canvas: inout Canvas) {
        guard let attachment = startAttachment else { return }

        let existing = canvas.character(atColumn: start.column, row: start.row) ?? " "
        let parsed = GlyphMerge.connections(for: existing)
        var connections = parsed?.directions ?? baseConnections(for: attachment.side)

        let inward = inwardConnection(for: attachment.side)
        let outward = outwardConnection(for: attachment.side)
        connections.remove(inward)
        connections.insert(outward)

        let merged = GlyphMerge.mergeGlyph(existing: " ", adding: connections, style: strokeStyle)
        canvas.setCharacter(
            merged,
            foreground: strokeColor,
            background: nil,
            atColumn: start.column, row: start.row
        )
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


    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case start
        case end
        case label
        case strokeStyle
        case bendDirection
        case startAttachment
        case endAttachment
        case startHeadStyle
        case endHeadStyle
        case strokeColor
        case labelColor
        case float
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        start = try container.decode(GridPoint.self, forKey: .start)
        end = try container.decode(GridPoint.self, forKey: .end)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        strokeStyle = try container.decodeIfPresent(StrokeStyle.self, forKey: .strokeStyle) ?? .single
        bendDirection =
            try container.decodeIfPresent(ArrowBendDirection.self, forKey: .bendDirection)
            ?? .horizontalFirst
        startAttachment = try container.decodeIfPresent(ArrowAttachment.self, forKey: .startAttachment)
        endAttachment = try container.decodeIfPresent(ArrowAttachment.self, forKey: .endAttachment)
        startHeadStyle =
            try container.decodeIfPresent(ArrowHeadStyle.self, forKey: .startHeadStyle) ?? .none
        endHeadStyle =
            try container.decodeIfPresent(ArrowHeadStyle.self, forKey: .endHeadStyle) ?? .filled
        strokeColor = try container.decodeIfPresent(ShapeColor.self, forKey: .strokeColor)
        labelColor = try container.decodeIfPresent(ShapeColor.self, forKey: .labelColor)
        float = try container.decodeIfPresent(Bool.self, forKey: .float) ?? false
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(label, forKey: .label)
        try container.encode(strokeStyle, forKey: .strokeStyle)
        try container.encode(bendDirection, forKey: .bendDirection)
        try container.encodeIfPresent(startAttachment, forKey: .startAttachment)
        try container.encodeIfPresent(endAttachment, forKey: .endAttachment)
        try container.encode(startHeadStyle, forKey: .startHeadStyle)
        try container.encode(endHeadStyle, forKey: .endHeadStyle)
        try container.encodeIfPresent(strokeColor, forKey: .strokeColor)
        try container.encodeIfPresent(labelColor, forKey: .labelColor)
        if float {
            try container.encode(float, forKey: .float)
        }
    }
}

extension RectangleShape {
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
    var length: Int { abs(to.column - from.column) + abs(to.row - from.row) }

    func point(at distance: Int) -> GridPoint {
        let clamped = min(max(distance, 0), length)
        if isHorizontal {
            let step = to.column >= from.column ? clamped : -clamped
            return GridPoint(column: from.column + step, row: from.row)
        }
        if isVertical {
            let step = to.row >= from.row ? clamped : -clamped
            return GridPoint(column: from.column, row: from.row + step)
        }
        return from
    }

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
        mergeGlyph: (Character, LineConnections) -> Character,
        foregroundColor: ShapeColor? = nil
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
                canvas.setCharacter(
                    merged,
                    foreground: foregroundColor,
                    background: nil,
                    atColumn: col, row: from.row
                )
            }
            if drawHead {
                let headChar: Character =
                    headCharacterOverride ?? (to.column >= from.column ? "▶" : "◀")
                canvas.setCharacter(
                    headChar,
                    foreground: foregroundColor,
                    background: nil,
                    atColumn: to.column, row: to.row
                )
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
                canvas.setCharacter(
                    merged,
                    foreground: foregroundColor,
                    background: nil,
                    atColumn: from.column, row: row
                )
            }
            if drawHead {
                let headChar: Character =
                    headCharacterOverride ?? (to.row >= from.row ? "▼" : "▲")
                canvas.setCharacter(
                    headChar,
                    foreground: foregroundColor,
                    background: nil,
                    atColumn: to.column, row: to.row
                )
            }
        }

        // Draw corner if this segment connects at a bend
        if !drawHead && !isHorizontal && !isVertical {
            // Only straight segments are generated, so this won't fire
        }
    }
}

