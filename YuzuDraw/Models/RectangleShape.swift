import Foundation

enum RectangleFillMode: String, Codable, CaseIterable, Sendable {
    case none
    case opaque
    case block
    case character

    static let filledCases: [RectangleFillMode] = [.opaque, .block, .character]

    var isFilled: Bool {
        self != .none
    }

    var label: String {
        switch self {
        case .none: return "None"
        case .opaque: return "Opaque"
        case .block: return "Block"
        case .character: return "Char"
        }
    }
}

enum RectangleTextHorizontalAlignment: String, Codable, CaseIterable, Sendable {
    case left
    case center
    case right
}

enum RectangleTextVerticalAlignment: String, Codable, CaseIterable, Sendable {
    case top
    case middle
    case bottom
}

enum RectangleBorderSide: String, Codable, CaseIterable, Hashable, Sendable {
    case top
    case bottom
    case right
    case left
}

enum RectangleBorderLineStyle: String, Codable, CaseIterable, Sendable {
    case solid
    case dashed
}

enum RectangleShadowStyle: String, Codable, CaseIterable, Sendable {
    case light
    case medium
    case dark
    case full

    var character: Character {
        switch self {
        case .light:
            return "░"
        case .medium:
            return "▒"
        case .dark:
            return "▓"
        case .full:
            return "█"
        }
    }
}

enum RectangleShadowDirection: String, Codable, Sendable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var xSign: Int {
        switch self {
        case .topLeft, .bottomLeft:
            return -1
        case .topRight, .bottomRight:
            return 1
        }
    }

    var ySign: Int {
        switch self {
        case .topLeft, .topRight:
            return -1
        case .bottomLeft, .bottomRight:
            return 1
        }
    }
}

struct RectangleShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var origin: GridPoint
    var size: GridSize
    var strokeStyle: StrokeStyle
    var hasBorder: Bool
    var visibleBorders: Set<RectangleBorderSide>
    var borderLineStyle: RectangleBorderLineStyle
    var borderDashLength: Int
    var borderGapLength: Int
    var fillMode: RectangleFillMode
    var fillCharacter: Character
    var label: String
    var textHorizontalAlignment: RectangleTextHorizontalAlignment
    var textVerticalAlignment: RectangleTextVerticalAlignment
    var allowTextOnBorder: Bool
    var textPaddingLeft: Int
    var textPaddingRight: Int
    var textPaddingTop: Int
    var textPaddingBottom: Int
    var hasShadow: Bool
    var shadowStyle: RectangleShadowStyle
    var shadowOffsetX: Int
    var shadowOffsetY: Int
    var borderColor: ShapeColor?
    var fillColor: ShapeColor?
    var textColor: ShapeColor?
    var float: Bool

    init(
        id: UUID = UUID(),
        name: String? = nil,
        origin: GridPoint,
        size: GridSize,
        strokeStyle: StrokeStyle = .single,
        hasBorder: Bool = true,
        visibleBorders: Set<RectangleBorderSide> = Set(RectangleBorderSide.allCases),
        borderLineStyle: RectangleBorderLineStyle = .solid,
        borderDashLength: Int = 1,
        borderGapLength: Int = 1,
        fillMode: RectangleFillMode = .none,
        fillCharacter: Character = " ",
        label: String = "",
        textHorizontalAlignment: RectangleTextHorizontalAlignment = .center,
        textVerticalAlignment: RectangleTextVerticalAlignment = .middle,
        allowTextOnBorder: Bool = false,
        textPaddingLeft: Int = 0,
        textPaddingRight: Int = 0,
        textPaddingTop: Int = 0,
        textPaddingBottom: Int = 0,
        hasShadow: Bool = false,
        shadowStyle: RectangleShadowStyle = .light,
        shadowOffsetX: Int = 1,
        shadowOffsetY: Int = 1,
        borderColor: ShapeColor? = nil,
        fillColor: ShapeColor? = nil,
        textColor: ShapeColor? = nil,
        float: Bool = false
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.size = size
        self.strokeStyle = strokeStyle
        self.hasBorder = hasBorder
        self.visibleBorders = visibleBorders
        self.borderLineStyle = borderLineStyle
        self.borderDashLength = max(1, borderDashLength)
        self.borderGapLength = max(0, borderGapLength)
        self.fillMode = fillMode
        self.fillCharacter = fillCharacter
        self.label = label
        self.textHorizontalAlignment = textHorizontalAlignment
        self.textVerticalAlignment = textVerticalAlignment
        self.allowTextOnBorder = allowTextOnBorder
        self.textPaddingLeft = max(0, textPaddingLeft)
        self.textPaddingRight = max(0, textPaddingRight)
        self.textPaddingTop = max(0, textPaddingTop)
        self.textPaddingBottom = max(0, textPaddingBottom)
        self.hasShadow = hasShadow
        self.shadowStyle = shadowStyle
        self.shadowOffsetX = shadowOffsetX
        self.shadowOffsetY = shadowOffsetY
        self.borderColor = borderColor
        self.fillColor = fillColor
        self.textColor = textColor
        self.float = float
    }

    var boundingRect: GridRect {
        GridRect(origin: origin, size: size)
    }

    var renderBoundingRect: GridRect {
        guard hasShadow else { return boundingRect }
        let baseRect = boundingRect
        let shadowMaxColumn = baseRect.origin.column + shadowOffsetX + size.width - 1
        let shadowMaxRow = baseRect.origin.row + shadowOffsetY + size.height - 1
        let minColumn = min(baseRect.minColumn, baseRect.origin.column + shadowOffsetX)
        let minRow = min(baseRect.minRow, baseRect.origin.row + shadowOffsetY)
        let maxColumn = max(baseRect.maxColumn, shadowMaxColumn)
        let maxRow = max(baseRect.maxRow, shadowMaxRow)
        return GridRect(
            origin: GridPoint(column: minColumn, row: minRow),
            size: GridSize(width: maxColumn - minColumn + 1, height: maxRow - minRow + 1)
        )
    }

    func contains(point: GridPoint) -> Bool {
        boundingRect.contains(point)
    }

    var labelEditPoint: GridPoint {
        let col = origin.column
        let row = origin.row
        let w = size.width
        let h = size.height

        let drawLeft = shouldDraw(.left)
        let drawRight = shouldDraw(.right)
        let drawTop = shouldDraw(.top)
        let drawBottom = shouldDraw(.bottom)
        let shouldInsetTextForBorders = hasBorder && !allowTextOnBorder
        let baseTextAreaStartCol = shouldInsetTextForBorders ? col + (drawLeft ? 1 : 0) : col
        let baseTextAreaStartRow = shouldInsetTextForBorders ? row + (drawTop ? 1 : 0) : row
        let baseTextAreaWidth =
            shouldInsetTextForBorders ? w - (drawLeft ? 1 : 0) - (drawRight ? 1 : 0) : w
        let baseTextAreaHeight =
            shouldInsetTextForBorders ? h - (drawTop ? 1 : 0) - (drawBottom ? 1 : 0) : h

        let textAreaStartCol = baseTextAreaStartCol + textPaddingLeft
        let textAreaStartRow = baseTextAreaStartRow + textPaddingTop
        let textAreaWidth = baseTextAreaWidth - textPaddingLeft - textPaddingRight
        let textAreaHeight = baseTextAreaHeight - textPaddingTop - textPaddingBottom

        guard textAreaWidth > 0, textAreaHeight > 0 else {
            return origin
        }

        let labelLines = label.components(separatedBy: "\n")
        let firstLine = labelLines.first ?? label
        let truncatedLine = String(firstLine.prefix(max(0, textAreaWidth)))
        let lineCount = labelLines.count

        let horizontalOffset: Int
        switch textHorizontalAlignment {
        case .left:
            horizontalOffset = 0
        case .center:
            horizontalOffset = (textAreaWidth - truncatedLine.count) / 2
        case .right:
            horizontalOffset = textAreaWidth - truncatedLine.count
        }

        let verticalOffset: Int
        switch textVerticalAlignment {
        case .top:
            verticalOffset = 0
        case .middle:
            verticalOffset = max(0, (textAreaHeight - lineCount) / 2)
        case .bottom:
            verticalOffset = max(0, textAreaHeight - lineCount)
        }

        return GridPoint(
            column: textAreaStartCol + horizontalOffset,
            row: textAreaStartRow + verticalOffset
        )
    }

    func render(into canvas: inout Canvas) {
        guard size.width >= 1, size.height >= 1 else { return }

        let style = strokeStyle
        let col = origin.column
        let row = origin.row
        let w = size.width
        let h = size.height
        let drawTop = shouldDraw(.top)
        let drawBottom = shouldDraw(.bottom)
        let drawLeft = shouldDraw(.left)
        let drawRight = shouldDraw(.right)

        if hasShadow {
            let shadowCol = col + shadowOffsetX
            let shadowRow = row + shadowOffsetY

            for r in shadowRow..<(shadowRow + h) {
                for c in shadowCol..<(shadowCol + w) {
                    let insideRectX = c >= col && c < (col + w)
                    let insideRectY = r >= row && r < (row + h)
                    if insideRectX && insideRectY {
                        continue
                    }
                    canvas.setCharacter(
                        shadowStyle.character,
                        foreground: nil,
                        background: nil,
                        atColumn: c, row: r
                    )
                }
            }
        }

        let bordersWillRender = hasBorder && w >= 2 && h >= 2
        let fillAreaStartCol = col + (bordersWillRender && drawLeft ? 1 : 0)
        let fillAreaStartRow = row + (bordersWillRender && drawTop ? 1 : 0)
        let fillAreaWidth = w - (bordersWillRender && drawLeft ? 1 : 0) - (bordersWillRender && drawRight ? 1 : 0)
        let fillAreaHeight =
            h - (bordersWillRender && drawTop ? 1 : 0) - (bordersWillRender && drawBottom ? 1 : 0)

        if fillMode.isFilled, fillAreaWidth > 0, fillAreaHeight > 0 {
            for r in fillAreaStartRow..<(fillAreaStartRow + fillAreaHeight) {
                for c in fillAreaStartCol..<(fillAreaStartCol + fillAreaWidth) {
                    canvas.setCharacter(
                        fillCharacter,
                        foreground: fillCharacter != " " ? fillColor : nil,
                        background: fillCharacter == " " ? fillColor : nil,
                        atColumn: c, row: r
                    )
                }
            }
        }

        if hasBorder, w >= 2, h >= 2 {
            let hasFillArea = fillMode.isFilled && fillAreaWidth > 0 && fillAreaHeight > 0
            if drawTop {
                for (index, c) in ((col + 1)..<(col + w - 1)).enumerated() {
                    guard shouldDrawBorderSegment(at: index) else { continue }
                    setBorderChar(
                        style.horizontal, connections: [.left, .right],
                        occludedDirection: hasFillArea ? [.down] : [],
                        into: &canvas, col: c, row: row
                    )
                }
            }
            if drawBottom {
                for (index, c) in ((col + 1)..<(col + w - 1)).enumerated() {
                    guard shouldDrawBorderSegment(at: index) else { continue }
                    setBorderChar(
                        style.horizontal, connections: [.left, .right],
                        occludedDirection: hasFillArea ? [.up] : [],
                        into: &canvas, col: c, row: row + h - 1
                    )
                }
            }
            if drawLeft {
                for (index, r) in ((row + 1)..<(row + h - 1)).enumerated() {
                    guard shouldDrawBorderSegment(at: index) else { continue }
                    setBorderChar(
                        style.vertical, connections: [.up, .down],
                        occludedDirection: hasFillArea ? [.right] : [],
                        into: &canvas, col: col, row: r
                    )
                }
            }
            if drawRight {
                for (index, r) in ((row + 1)..<(row + h - 1)).enumerated() {
                    guard shouldDrawBorderSegment(at: index) else { continue }
                    setBorderChar(
                        style.vertical, connections: [.up, .down],
                        occludedDirection: hasFillArea ? [.left] : [],
                        into: &canvas, col: col + w - 1, row: r
                    )
                }
            }

            // Corners adapt to enabled adjacent sides.
            // Occlude directions into fill only when the adjacent border is absent
            // (when both borders are drawn, the corner's connections go along borders, not into fill).
            if let cornerConns = cornerConnections(
                horizontalEnabled: drawTop,
                verticalEnabled: drawLeft,
                horizontalDir: .right,
                verticalDir: .down
            ) {
                var occluded: LineConnections = []
                if hasFillArea {
                    if !drawTop { occluded.insert(.right) }
                    if !drawLeft { occluded.insert(.down) }
                }
                setBorderChar(
                    cornerCharacter(horizontalEnabled: drawTop, verticalEnabled: drawLeft, corner: style.topLeft, style: style) ?? style.topLeft,
                    connections: cornerConns,
                    occludedDirection: occluded,
                    into: &canvas, col: col, row: row
                )
            }
            if let cornerConns = cornerConnections(
                horizontalEnabled: drawTop,
                verticalEnabled: drawRight,
                horizontalDir: .left,
                verticalDir: .down
            ) {
                var occluded: LineConnections = []
                if hasFillArea {
                    if !drawTop { occluded.insert(.left) }
                    if !drawRight { occluded.insert(.down) }
                }
                setBorderChar(
                    cornerCharacter(horizontalEnabled: drawTop, verticalEnabled: drawRight, corner: style.topRight, style: style) ?? style.topRight,
                    connections: cornerConns,
                    occludedDirection: occluded,
                    into: &canvas, col: col + w - 1, row: row
                )
            }
            if let cornerConns = cornerConnections(
                horizontalEnabled: drawBottom,
                verticalEnabled: drawLeft,
                horizontalDir: .right,
                verticalDir: .up
            ) {
                var occluded: LineConnections = []
                if hasFillArea {
                    if !drawBottom { occluded.insert(.right) }
                    if !drawLeft { occluded.insert(.up) }
                }
                setBorderChar(
                    cornerCharacter(horizontalEnabled: drawBottom, verticalEnabled: drawLeft, corner: style.bottomLeft, style: style) ?? style.bottomLeft,
                    connections: cornerConns,
                    occludedDirection: occluded,
                    into: &canvas, col: col, row: row + h - 1
                )
            }
            if let cornerConns = cornerConnections(
                horizontalEnabled: drawBottom,
                verticalEnabled: drawRight,
                horizontalDir: .left,
                verticalDir: .up
            ) {
                var occluded: LineConnections = []
                if hasFillArea {
                    if !drawBottom { occluded.insert(.left) }
                    if !drawRight { occluded.insert(.up) }
                }
                setBorderChar(
                    cornerCharacter(horizontalEnabled: drawBottom, verticalEnabled: drawRight, corner: style.bottomRight, style: style) ?? style.bottomRight,
                    connections: cornerConns,
                    occludedDirection: occluded,
                    into: &canvas, col: col + w - 1, row: row + h - 1
                )
            }
        }

        // Text
        let shouldInsetTextForBorders = bordersWillRender && !allowTextOnBorder
        let baseTextAreaStartCol = shouldInsetTextForBorders ? col + (drawLeft ? 1 : 0) : col
        let baseTextAreaStartRow = shouldInsetTextForBorders ? row + (drawTop ? 1 : 0) : row
        let baseTextAreaWidth =
            shouldInsetTextForBorders ? w - (drawLeft ? 1 : 0) - (drawRight ? 1 : 0) : w
        let baseTextAreaHeight =
            shouldInsetTextForBorders ? h - (drawTop ? 1 : 0) - (drawBottom ? 1 : 0) : h

        let textAreaStartCol = baseTextAreaStartCol + textPaddingLeft
        let textAreaStartRow = baseTextAreaStartRow + textPaddingTop
        let textAreaWidth = baseTextAreaWidth - textPaddingLeft - textPaddingRight
        let textAreaHeight = baseTextAreaHeight - textPaddingTop - textPaddingBottom

        if !label.isEmpty, textAreaWidth > 0, textAreaHeight > 0 {
            let labelLines = label.components(separatedBy: "\n")
            let lineCount = labelLines.count

            let verticalOffset: Int
            switch textVerticalAlignment {
            case .top:
                verticalOffset = 0
            case .middle:
                verticalOffset = max(0, (textAreaHeight - lineCount) / 2)
            case .bottom:
                verticalOffset = max(0, textAreaHeight - lineCount)
            }

            for (lineIndex, line) in labelLines.enumerated() {
                let textRow = textAreaStartRow + verticalOffset + lineIndex
                guard textRow < textAreaStartRow + textAreaHeight else { break }

                let truncatedLine = String(line.prefix(max(0, textAreaWidth)))
                let horizontalOffset: Int
                switch textHorizontalAlignment {
                case .left:
                    horizontalOffset = 0
                case .center:
                    horizontalOffset = (textAreaWidth - truncatedLine.count) / 2
                case .right:
                    horizontalOffset = textAreaWidth - truncatedLine.count
                }

                for (i, char) in truncatedLine.enumerated() {
                    canvas.setCharacter(
                        char,
                        foreground: textColor,
                        background: fillColor,
                        atColumn: textAreaStartCol + horizontalOffset + i,
                        row: textRow
                    )
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case size
        case strokeStyle
        case borderStyle
        case hasBorder
        case visibleBorders
        case borderLineStyle
        case borderDashLength
        case borderGapLength
        case fillMode
        case fillCharacter
        case label
        case textHorizontalAlignment
        case textVerticalAlignment
        case allowTextOnBorder
        case textPaddingLeft
        case textPaddingRight
        case textPaddingTop
        case textPaddingBottom
        case hasShadow
        case shadowStyle
        case shadowOffsetX
        case shadowOffsetY
        case borderColor
        case fillColor
        case textColor
        case float
        // Legacy keys
        case shadowDirection
        case shadowOffset
        case shadowSize
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        origin = try container.decode(GridPoint.self, forKey: .origin)
        size = try container.decode(GridSize.self, forKey: .size)
        strokeStyle =
            try container.decodeIfPresent(StrokeStyle.self, forKey: .strokeStyle)
            ?? container.decodeIfPresent(StrokeStyle.self, forKey: .borderStyle)
            ?? .single
        hasBorder = try container.decodeIfPresent(Bool.self, forKey: .hasBorder) ?? true
        visibleBorders =
            try container.decodeIfPresent(Set<RectangleBorderSide>.self, forKey: .visibleBorders)
            ?? Set(RectangleBorderSide.allCases)
        borderLineStyle =
            try container.decodeIfPresent(RectangleBorderLineStyle.self, forKey: .borderLineStyle)
            ?? .solid
        borderDashLength = max(
            1,
            try container.decodeIfPresent(Int.self, forKey: .borderDashLength) ?? 1
        )
        borderGapLength = max(
            0,
            try container.decodeIfPresent(Int.self, forKey: .borderGapLength) ?? 1
        )
        // Decode fillMode with migration from legacy "transparent"/"solid" values
        if let rawFillMode = try container.decodeIfPresent(String.self, forKey: .fillMode) {
            fillMode = RectangleFillMode(rawValue: rawFillMode)
                ?? (rawFillMode == "solid" ? .opaque : .none)
        } else {
            fillMode = .none
        }
        let fillCharacterString =
            try container.decodeIfPresent(String.self, forKey: .fillCharacter) ?? " "
        fillCharacter = fillCharacterString.first ?? Character(" ")
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        textHorizontalAlignment =
            try container.decodeIfPresent(
                RectangleTextHorizontalAlignment.self,
                forKey: .textHorizontalAlignment
            ) ?? .center
        textVerticalAlignment =
            try container.decodeIfPresent(
                RectangleTextVerticalAlignment.self,
                forKey: .textVerticalAlignment
            ) ?? .middle
        allowTextOnBorder = try container.decodeIfPresent(Bool.self, forKey: .allowTextOnBorder) ?? false
        textPaddingLeft = max(0, try container.decodeIfPresent(Int.self, forKey: .textPaddingLeft) ?? 0)
        textPaddingRight = max(
            0, try container.decodeIfPresent(Int.self, forKey: .textPaddingRight) ?? 0)
        textPaddingTop = max(0, try container.decodeIfPresent(Int.self, forKey: .textPaddingTop) ?? 0)
        textPaddingBottom = max(
            0, try container.decodeIfPresent(Int.self, forKey: .textPaddingBottom) ?? 0)
        hasShadow = try container.decodeIfPresent(Bool.self, forKey: .hasShadow) ?? false
        shadowStyle = try container.decodeIfPresent(RectangleShadowStyle.self, forKey: .shadowStyle) ?? .light

        if let x = try container.decodeIfPresent(Int.self, forKey: .shadowOffsetX),
            let y = try container.decodeIfPresent(Int.self, forKey: .shadowOffsetY)
        {
            shadowOffsetX = x
            shadowOffsetY = y
        } else {
            // Backward compatibility for old direction/offset fields.
            let legacyDirection =
                try container.decodeIfPresent(RectangleShadowDirection.self, forKey: .shadowDirection)
                ?? .bottomRight
            let legacyOffset = max(
                0, try container.decodeIfPresent(Int.self, forKey: .shadowOffset) ?? 1)
            shadowOffsetX = legacyDirection.xSign * legacyOffset
            shadowOffsetY = legacyDirection.ySign * legacyOffset
        }
        borderColor = try container.decodeIfPresent(ShapeColor.self, forKey: .borderColor)
        fillColor = try container.decodeIfPresent(ShapeColor.self, forKey: .fillColor)
        textColor = try container.decodeIfPresent(ShapeColor.self, forKey: .textColor)
        float = try container.decodeIfPresent(Bool.self, forKey: .float) ?? false
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(origin, forKey: .origin)
        try container.encode(size, forKey: .size)
        try container.encode(strokeStyle, forKey: .strokeStyle)
        try container.encode(hasBorder, forKey: .hasBorder)
        try container.encode(visibleBorders, forKey: .visibleBorders)
        try container.encode(borderLineStyle, forKey: .borderLineStyle)
        try container.encode(borderDashLength, forKey: .borderDashLength)
        try container.encode(borderGapLength, forKey: .borderGapLength)
        try container.encode(fillMode, forKey: .fillMode)
        try container.encode(String(fillCharacter), forKey: .fillCharacter)
        try container.encode(label, forKey: .label)
        try container.encode(textHorizontalAlignment, forKey: .textHorizontalAlignment)
        try container.encode(textVerticalAlignment, forKey: .textVerticalAlignment)
        try container.encode(allowTextOnBorder, forKey: .allowTextOnBorder)
        try container.encode(textPaddingLeft, forKey: .textPaddingLeft)
        try container.encode(textPaddingRight, forKey: .textPaddingRight)
        try container.encode(textPaddingTop, forKey: .textPaddingTop)
        try container.encode(textPaddingBottom, forKey: .textPaddingBottom)
        try container.encode(hasShadow, forKey: .hasShadow)
        try container.encode(shadowStyle, forKey: .shadowStyle)
        try container.encode(shadowOffsetX, forKey: .shadowOffsetX)
        try container.encode(shadowOffsetY, forKey: .shadowOffsetY)
        try container.encodeIfPresent(borderColor, forKey: .borderColor)
        try container.encodeIfPresent(fillColor, forKey: .fillColor)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        if float {
            try container.encode(float, forKey: .float)
        }
    }

    private func shouldDraw(_ side: RectangleBorderSide) -> Bool {
        hasBorder && visibleBorders.contains(side)
    }

    private func shouldDrawBorderSegment(at index: Int) -> Bool {
        guard borderLineStyle == .dashed else { return true }
        let cycleLength = max(1, borderDashLength + borderGapLength)
        return (index % cycleLength) < borderDashLength
    }

    private func setBorderChar(
        _ char: Character,
        connections: LineConnections,
        occludedDirection: LineConnections = [],
        into canvas: inout Canvas,
        col: Int,
        row: Int
    ) {
        if float {
            canvas.setCharacter(char, foreground: borderColor, background: nil, atColumn: col, row: row)
        } else {
            let existing = canvas.character(atColumn: col, row: row) ?? " "
            var base = GlyphMerge.connections(for: existing) ?? StyledLineConnections(up: nil, right: nil, down: nil, left: nil)
            // Strip connections that point into our filled interior — those paths
            // have been overwritten by fill and should not produce junction glyphs.
            if fillMode.isFilled, !occludedDirection.isEmpty {
                if occludedDirection.contains(.up) { base.up = nil }
                if occludedDirection.contains(.down) { base.down = nil }
                if occludedDirection.contains(.left) { base.left = nil }
                if occludedDirection.contains(.right) { base.right = nil }
            }
            let merged = base.adding(connections, style: strokeStyle)
            canvas.setCharacter(GlyphMerge.glyph(for: merged), foreground: borderColor, background: nil, atColumn: col, row: row)
        }
    }

    private func cornerConnections(
        horizontalEnabled: Bool,
        verticalEnabled: Bool,
        horizontalDir: LineConnections,
        verticalDir: LineConnections
    ) -> LineConnections? {
        if horizontalEnabled && verticalEnabled {
            return horizontalDir.union(verticalDir)
        }
        if horizontalEnabled {
            return [.left, .right]
        }
        if verticalEnabled {
            return [.up, .down]
        }
        return nil
    }

    private func cornerCharacter(
        horizontalEnabled: Bool,
        verticalEnabled: Bool,
        corner: Character,
        style: StrokeStyle
    ) -> Character? {
        if horizontalEnabled && verticalEnabled {
            return corner
        }
        if horizontalEnabled {
            return style.horizontal
        }
        if verticalEnabled {
            return style.vertical
        }
        return nil
    }
}
