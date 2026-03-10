import Foundation

struct LineConnections: OptionSet, Sendable {
    let rawValue: Int
    static let up = LineConnections(rawValue: 1 << 0)
    static let right = LineConnections(rawValue: 1 << 1)
    static let down = LineConnections(rawValue: 1 << 2)
    static let left = LineConnections(rawValue: 1 << 3)
}

struct StyledLineConnections: Equatable, Sendable {
    var up: StrokeStyle?
    var right: StrokeStyle?
    var down: StrokeStyle?
    var left: StrokeStyle?

    var directions: LineConnections {
        var result: LineConnections = []
        if up != nil { result.insert(.up) }
        if right != nil { result.insert(.right) }
        if down != nil { result.insert(.down) }
        if left != nil { result.insert(.left) }
        return result
    }

    func adding(_ directions: LineConnections, style: StrokeStyle) -> StyledLineConnections {
        var copy = self
        if directions.contains(.up) { copy.up = copy.up ?? style }
        if directions.contains(.right) { copy.right = copy.right ?? style }
        if directions.contains(.down) { copy.down = copy.down ?? style }
        if directions.contains(.left) { copy.left = copy.left ?? style }
        return copy
    }

    var isMixedSingleDouble: Bool {
        let styles = [up, right, down, left].compactMap { $0 }
        let hasSingle = styles.contains(where: { $0 == .single || $0 == .rounded })
        let hasDouble = styles.contains { $0 == .double }
        return hasSingle && hasDouble
    }

    private var effectiveStyles: [StrokeStyle?] {
        [up, right, down, left]
    }

    var dominantStyle: StrokeStyle {
        let styles = effectiveStyles.compactMap { $0 }
        guard !styles.isEmpty else { return .single }
        // Count occurrences
        var counts: [StrokeStyle: Int] = [:]
        for s in styles { counts[s, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key ?? .single
    }
}

enum GlyphMerge {
    // MARK: - Reverse lookup: character → styled connections

    static func connections(for char: Character) -> StyledLineConnections? {
        // Single style
        switch char {
        case "─": return StyledLineConnections(up: nil, right: .single, down: nil, left: .single)
        case "│": return StyledLineConnections(up: .single, right: nil, down: .single, left: nil)
        case "┌": return StyledLineConnections(up: nil, right: .single, down: .single, left: nil)
        case "┐": return StyledLineConnections(up: nil, right: nil, down: .single, left: .single)
        case "└": return StyledLineConnections(up: .single, right: .single, down: nil, left: nil)
        case "┘": return StyledLineConnections(up: .single, right: nil, down: nil, left: .single)
        case "├": return StyledLineConnections(up: .single, right: .single, down: .single, left: nil)
        case "┤": return StyledLineConnections(up: .single, right: nil, down: .single, left: .single)
        case "┬": return StyledLineConnections(up: nil, right: .single, down: .single, left: .single)
        case "┴": return StyledLineConnections(up: .single, right: .single, down: nil, left: .single)
        case "┼": return StyledLineConnections(up: .single, right: .single, down: .single, left: .single)

        // Rounded style (same connections as single)
        case "╭": return StyledLineConnections(up: nil, right: .rounded, down: .rounded, left: nil)
        case "╮": return StyledLineConnections(up: nil, right: nil, down: .rounded, left: .rounded)
        case "╰": return StyledLineConnections(up: .rounded, right: .rounded, down: nil, left: nil)
        case "╯": return StyledLineConnections(up: .rounded, right: nil, down: nil, left: .rounded)

        // Double style
        case "═": return StyledLineConnections(up: nil, right: .double, down: nil, left: .double)
        case "║": return StyledLineConnections(up: .double, right: nil, down: .double, left: nil)
        case "╔": return StyledLineConnections(up: nil, right: .double, down: .double, left: nil)
        case "╗": return StyledLineConnections(up: nil, right: nil, down: .double, left: .double)
        case "╚": return StyledLineConnections(up: .double, right: .double, down: nil, left: nil)
        case "╝": return StyledLineConnections(up: .double, right: nil, down: nil, left: .double)
        case "╠": return StyledLineConnections(up: .double, right: .double, down: .double, left: nil)
        case "╣": return StyledLineConnections(up: .double, right: nil, down: .double, left: .double)
        case "╦": return StyledLineConnections(up: nil, right: .double, down: .double, left: .double)
        case "╩": return StyledLineConnections(up: .double, right: .double, down: nil, left: .double)
        case "╬": return StyledLineConnections(up: .double, right: .double, down: .double, left: .double)

        // Heavy style
        case "━": return StyledLineConnections(up: nil, right: .heavy, down: nil, left: .heavy)
        case "┃": return StyledLineConnections(up: .heavy, right: nil, down: .heavy, left: nil)
        case "┏": return StyledLineConnections(up: nil, right: .heavy, down: .heavy, left: nil)
        case "┓": return StyledLineConnections(up: nil, right: nil, down: .heavy, left: .heavy)
        case "┗": return StyledLineConnections(up: .heavy, right: .heavy, down: nil, left: nil)
        case "┛": return StyledLineConnections(up: .heavy, right: nil, down: nil, left: .heavy)
        case "┣": return StyledLineConnections(up: .heavy, right: .heavy, down: .heavy, left: nil)
        case "┫": return StyledLineConnections(up: .heavy, right: nil, down: .heavy, left: .heavy)
        case "┳": return StyledLineConnections(up: nil, right: .heavy, down: .heavy, left: .heavy)
        case "┻": return StyledLineConnections(up: .heavy, right: .heavy, down: nil, left: .heavy)
        case "╋": return StyledLineConnections(up: .heavy, right: .heavy, down: .heavy, left: .heavy)

        // Mixed single+double glyphs
        case "╒": return StyledLineConnections(up: nil, right: .double, down: .single, left: nil)
        case "╓": return StyledLineConnections(up: nil, right: .single, down: .double, left: nil)
        case "╕": return StyledLineConnections(up: nil, right: nil, down: .single, left: .double)
        case "╖": return StyledLineConnections(up: nil, right: nil, down: .double, left: .single)
        case "╘": return StyledLineConnections(up: .single, right: .double, down: nil, left: nil)
        case "╙": return StyledLineConnections(up: .double, right: .single, down: nil, left: nil)
        case "╛": return StyledLineConnections(up: .single, right: nil, down: nil, left: .double)
        case "╜": return StyledLineConnections(up: .double, right: nil, down: nil, left: .single)
        case "╞": return StyledLineConnections(up: .single, right: .double, down: .single, left: nil)
        case "╟": return StyledLineConnections(up: .double, right: .single, down: .double, left: nil)
        case "╡": return StyledLineConnections(up: .single, right: nil, down: .single, left: .double)
        case "╢": return StyledLineConnections(up: .double, right: nil, down: .double, left: .single)
        case "╤": return StyledLineConnections(up: nil, right: .double, down: .single, left: .double)
        case "╥": return StyledLineConnections(up: nil, right: .single, down: .double, left: .single)
        case "╧": return StyledLineConnections(up: .single, right: .double, down: nil, left: .double)
        case "╨": return StyledLineConnections(up: .double, right: .single, down: nil, left: .single)
        case "╪": return StyledLineConnections(up: .single, right: .double, down: .single, left: .double)
        case "╫": return StyledLineConnections(up: .double, right: .single, down: .double, left: .single)

        // Arrow heads
        case "▶": return StyledLineConnections(up: nil, right: nil, down: nil, left: .single)
        case "◀": return StyledLineConnections(up: nil, right: .single, down: nil, left: nil)
        case "▲": return StyledLineConnections(up: nil, right: nil, down: .single, left: nil)
        case "▼": return StyledLineConnections(up: .single, right: nil, down: nil, left: nil)

        default: return nil
        }
    }

    // MARK: - Forward lookup: styled connections → character

    static func glyph(for conn: StyledLineConnections) -> Character {
        let dirs = conn.directions

        // Try mixed single+double first
        if conn.isMixedSingleDouble {
            if let mixed = mixedGlyph(for: conn) {
                return mixed
            }
            // Fall back to dominant style
            return uniformGlyph(for: dirs, style: conn.dominantStyle)
        }

        // Uniform style — use the dominant (or only) style
        return uniformGlyph(for: dirs, style: conn.dominantStyle)
    }

    // MARK: - Convenience merge functions

    /// Merge a new set of directions (at a given style) with an existing character.
    static func mergeGlyph(existing: Character, adding directions: LineConnections, style: StrokeStyle) -> Character {
        let base = connections(for: existing) ?? StyledLineConnections(up: nil, right: nil, down: nil, left: nil)
        let merged = base.adding(directions, style: style)
        return glyph(for: merged)
    }

    // MARK: - Private helpers

    private static func uniformGlyph(for connections: LineConnections, style: StrokeStyle) -> Character {
        switch connections {
        case [.left, .right]:
            return style.horizontal
        case [.up, .down]:
            return style.vertical
        case [.right, .down]:
            return style.topLeft
        case [.left, .down]:
            return style.topRight
        case [.right, .up]:
            return style.bottomLeft
        case [.left, .up]:
            return style.bottomRight
        case [.up, .right, .down]:
            return style.teeRight
        case [.up, .left, .down]:
            return style.teeLeft
        case [.left, .right, .down]:
            return style.teeDown
        case [.left, .right, .up]:
            return style.teeUp
        case [.up, .left, .right, .down]:
            return style.cross
        default:
            if connections.contains(.left) || connections.contains(.right) {
                return style.horizontal
            }
            if connections.contains(.up) || connections.contains(.down) {
                return style.vertical
            }
            return "+"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func mixedGlyph(for conn: StyledLineConnections) -> Character? {
        let s = StrokeStyle.single
        let r = StrokeStyle.rounded
        let d = StrokeStyle.double

        func isSingle(_ style: StrokeStyle?) -> Bool { style == s || style == r }
        func isDouble(_ style: StrokeStyle?) -> Bool { style == d }

        let upS = isSingle(conn.up)
        let upD = isDouble(conn.up)
        let rightS = isSingle(conn.right)
        let rightD = isDouble(conn.right)
        let downS = isSingle(conn.down)
        let downD = isDouble(conn.down)
        let leftS = isSingle(conn.left)
        let leftD = isDouble(conn.left)

        // Corners: single vertical + double horizontal
        if rightD && downS && conn.up == nil && conn.left == nil { return "╒" }
        if leftD && downS && conn.up == nil && conn.right == nil { return "╕" }
        if rightD && upS && conn.down == nil && conn.left == nil { return "╘" }
        if leftD && upS && conn.down == nil && conn.right == nil { return "╛" }

        // Corners: double vertical + single horizontal
        if rightS && downD && conn.up == nil && conn.left == nil { return "╓" }
        if leftS && downD && conn.up == nil && conn.right == nil { return "╖" }
        if rightS && upD && conn.down == nil && conn.left == nil { return "╙" }
        if leftS && upD && conn.down == nil && conn.right == nil { return "╜" }

        // Tees: single vertical + double horizontal
        if upS && rightD && downS && conn.left == nil { return "╞" }
        if upS && downS && leftD && conn.right == nil { return "╡" }
        if rightD && downS && leftD && conn.up == nil { return "╤" }
        if upS && rightD && leftD && conn.down == nil { return "╧" }

        // Tees: double vertical + single horizontal
        if upD && rightS && downD && conn.left == nil { return "╟" }
        if upD && downD && leftS && conn.right == nil { return "╢" }
        if rightS && downD && leftS && conn.up == nil { return "╥" }
        if upD && rightS && leftS && conn.down == nil { return "╨" }

        // Crosses
        if upS && rightD && downS && leftD { return "╪" }
        if upD && rightS && downD && leftS { return "╫" }

        return nil
    }
}
