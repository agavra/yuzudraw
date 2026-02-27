import Foundation

enum BoxFillMode: String, Codable, CaseIterable, Sendable {
    case transparent
    case solid
}

enum BoxTextHorizontalAlignment: String, Codable, CaseIterable, Sendable {
    case left
    case center
    case right
}

enum BoxTextVerticalAlignment: String, Codable, CaseIterable, Sendable {
    case top
    case middle
    case bottom
}

enum BoxBorderSide: String, Codable, CaseIterable, Hashable, Sendable {
    case top
    case bottom
    case right
    case left
}

enum BoxShadowStyle: String, Codable, CaseIterable, Sendable {
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

enum BoxShadowDirection: String, Codable, Sendable {
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

struct BoxShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var origin: GridPoint
    var size: GridSize
    var strokeStyle: StrokeStyle
    var hasBorder: Bool
    var visibleBorders: Set<BoxBorderSide>
    var fillMode: BoxFillMode
    var fillCharacter: Character
    var label: String
    var textHorizontalAlignment: BoxTextHorizontalAlignment
    var textVerticalAlignment: BoxTextVerticalAlignment
    var allowTextOnBorder: Bool
    var textPaddingLeft: Int
    var textPaddingRight: Int
    var textPaddingTop: Int
    var textPaddingBottom: Int
    var hasShadow: Bool
    var shadowStyle: BoxShadowStyle
    var shadowOffsetX: Int
    var shadowOffsetY: Int

    init(
        id: UUID = UUID(),
        name: String? = nil,
        origin: GridPoint,
        size: GridSize,
        strokeStyle: StrokeStyle = .single,
        hasBorder: Bool = true,
        visibleBorders: Set<BoxBorderSide> = Set(BoxBorderSide.allCases),
        fillMode: BoxFillMode = .transparent,
        fillCharacter: Character = " ",
        label: String = "",
        textHorizontalAlignment: BoxTextHorizontalAlignment = .center,
        textVerticalAlignment: BoxTextVerticalAlignment = .middle,
        allowTextOnBorder: Bool = false,
        textPaddingLeft: Int = 0,
        textPaddingRight: Int = 0,
        textPaddingTop: Int = 0,
        textPaddingBottom: Int = 0,
        hasShadow: Bool = false,
        shadowStyle: BoxShadowStyle = .light,
        shadowOffsetX: Int = 1,
        shadowOffsetY: Int = 1
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.size = size
        self.strokeStyle = strokeStyle
        self.hasBorder = hasBorder
        self.visibleBorders = visibleBorders
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
    }

    var boundingRect: GridRect {
        GridRect(origin: origin, size: size)
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
                    let insideBoxX = c >= col && c < (col + w)
                    let insideBoxY = r >= row && r < (row + h)
                    if insideBoxX && insideBoxY {
                        continue
                    }
                    canvas.setCharacter(shadowStyle.character, atColumn: c, row: r)
                }
            }
        }

        let fillAreaStartCol = col + (drawLeft ? 1 : 0)
        let fillAreaStartRow = row + (drawTop ? 1 : 0)
        let fillAreaWidth = w - (drawLeft ? 1 : 0) - (drawRight ? 1 : 0)
        let fillAreaHeight = h - (drawTop ? 1 : 0) - (drawBottom ? 1 : 0)

        if fillMode == .solid, fillAreaWidth > 0, fillAreaHeight > 0 {
            for r in fillAreaStartRow..<(fillAreaStartRow + fillAreaHeight) {
                for c in fillAreaStartCol..<(fillAreaStartCol + fillAreaWidth) {
                    canvas.setCharacter(fillCharacter, atColumn: c, row: r)
                }
            }
        }

        if hasBorder, w >= 2, h >= 2 {
            if drawTop {
                for c in (col + 1)..<(col + w - 1) {
                    canvas.setCharacter(style.horizontal, atColumn: c, row: row)
                }
            }
            if drawBottom {
                for c in (col + 1)..<(col + w - 1) {
                    canvas.setCharacter(style.horizontal, atColumn: c, row: row + h - 1)
                }
            }
            if drawLeft {
                for r in (row + 1)..<(row + h - 1) {
                    canvas.setCharacter(style.vertical, atColumn: col, row: r)
                }
            }
            if drawRight {
                for r in (row + 1)..<(row + h - 1) {
                    canvas.setCharacter(style.vertical, atColumn: col + w - 1, row: r)
                }
            }

            // Corners adapt to enabled adjacent sides.
            if let topLeftCharacter = cornerCharacter(
                horizontalEnabled: drawTop,
                verticalEnabled: drawLeft,
                corner: style.topLeft,
                style: style
            ) {
                canvas.setCharacter(topLeftCharacter, atColumn: col, row: row)
            }
            if let topRightCharacter = cornerCharacter(
                horizontalEnabled: drawTop,
                verticalEnabled: drawRight,
                corner: style.topRight,
                style: style
            ) {
                canvas.setCharacter(topRightCharacter, atColumn: col + w - 1, row: row)
            }
            if let bottomLeftCharacter = cornerCharacter(
                horizontalEnabled: drawBottom,
                verticalEnabled: drawLeft,
                corner: style.bottomLeft,
                style: style
            ) {
                canvas.setCharacter(bottomLeftCharacter, atColumn: col, row: row + h - 1)
            }
            if let bottomRightCharacter = cornerCharacter(
                horizontalEnabled: drawBottom,
                verticalEnabled: drawRight,
                corner: style.bottomRight,
                style: style
            ) {
                canvas.setCharacter(bottomRightCharacter, atColumn: col + w - 1, row: row + h - 1)
            }
        }

        // Text
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
            try container.decodeIfPresent(Set<BoxBorderSide>.self, forKey: .visibleBorders)
            ?? Set(BoxBorderSide.allCases)
        fillMode = try container.decodeIfPresent(BoxFillMode.self, forKey: .fillMode) ?? .transparent
        let fillCharacterString =
            try container.decodeIfPresent(String.self, forKey: .fillCharacter) ?? " "
        fillCharacter = fillCharacterString.first ?? Character(" ")
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        textHorizontalAlignment =
            try container.decodeIfPresent(
                BoxTextHorizontalAlignment.self,
                forKey: .textHorizontalAlignment
            ) ?? .center
        textVerticalAlignment =
            try container.decodeIfPresent(
                BoxTextVerticalAlignment.self,
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
        shadowStyle = try container.decodeIfPresent(BoxShadowStyle.self, forKey: .shadowStyle) ?? .light

        if let x = try container.decodeIfPresent(Int.self, forKey: .shadowOffsetX),
            let y = try container.decodeIfPresent(Int.self, forKey: .shadowOffsetY)
        {
            shadowOffsetX = x
            shadowOffsetY = y
        } else {
            // Backward compatibility for old direction/offset fields.
            let legacyDirection =
                try container.decodeIfPresent(BoxShadowDirection.self, forKey: .shadowDirection)
                ?? .bottomRight
            let legacyOffset = max(
                0, try container.decodeIfPresent(Int.self, forKey: .shadowOffset) ?? 1)
            shadowOffsetX = legacyDirection.xSign * legacyOffset
            shadowOffsetY = legacyDirection.ySign * legacyOffset
        }
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
    }

    private func shouldDraw(_ side: BoxBorderSide) -> Bool {
        hasBorder && visibleBorders.contains(side)
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
