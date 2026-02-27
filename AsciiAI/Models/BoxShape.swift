import Foundation

enum BoxFillMode: String, Codable, CaseIterable, Sendable {
    case transparent
    case solid
}

struct BoxShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var origin: GridPoint
    var size: GridSize
    var strokeStyle: StrokeStyle
    var fillMode: BoxFillMode
    var fillCharacter: Character
    var label: String

    init(
        id: UUID = UUID(),
        origin: GridPoint,
        size: GridSize,
        strokeStyle: StrokeStyle = .single,
        fillMode: BoxFillMode = .transparent,
        fillCharacter: Character = " ",
        label: String = ""
    ) {
        self.id = id
        self.origin = origin
        self.size = size
        self.strokeStyle = strokeStyle
        self.fillMode = fillMode
        self.fillCharacter = fillCharacter
        self.label = label
    }

    var boundingRect: GridRect {
        GridRect(origin: origin, size: size)
    }

    func contains(point: GridPoint) -> Bool {
        boundingRect.contains(point)
    }

    func render(into canvas: inout Canvas) {
        guard size.width >= 2, size.height >= 2 else { return }

        let style = strokeStyle
        let col = origin.column
        let row = origin.row
        let w = size.width
        let h = size.height

        if fillMode == .solid, w >= 3, h >= 3 {
            for r in (row + 1)..<(row + h - 1) {
                for c in (col + 1)..<(col + w - 1) {
                    canvas.setCharacter(fillCharacter, atColumn: c, row: r)
                }
            }
        }

        // Top border
        canvas.setCharacter(style.topLeft, atColumn: col, row: row)
        for c in (col + 1)..<(col + w - 1) {
            canvas.setCharacter(style.horizontal, atColumn: c, row: row)
        }
        canvas.setCharacter(style.topRight, atColumn: col + w - 1, row: row)

        // Side borders
        for r in (row + 1)..<(row + h - 1) {
            canvas.setCharacter(style.vertical, atColumn: col, row: r)
            canvas.setCharacter(style.vertical, atColumn: col + w - 1, row: r)
        }

        // Bottom border
        canvas.setCharacter(style.bottomLeft, atColumn: col, row: row + h - 1)
        for c in (col + 1)..<(col + w - 1) {
            canvas.setCharacter(style.horizontal, atColumn: c, row: row + h - 1)
        }
        canvas.setCharacter(style.bottomRight, atColumn: col + w - 1, row: row + h - 1)

        // Label — centered on the middle row
        if !label.isEmpty, h >= 3, w >= 3 {
            let midRow = row + h / 2
            let interiorWidth = w - 2
            let truncatedLabel = String(label.prefix(interiorWidth))
            let padding = (interiorWidth - truncatedLabel.count) / 2
            for (i, char) in truncatedLabel.enumerated() {
                canvas.setCharacter(char, atColumn: col + 1 + padding + i, row: midRow)
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case origin
        case size
        case strokeStyle
        case borderStyle
        case fillMode
        case fillCharacter
        case label
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        origin = try container.decode(GridPoint.self, forKey: .origin)
        size = try container.decode(GridSize.self, forKey: .size)
        strokeStyle =
            try container.decodeIfPresent(StrokeStyle.self, forKey: .strokeStyle)
            ?? container.decodeIfPresent(StrokeStyle.self, forKey: .borderStyle)
            ?? .single
        fillMode = try container.decodeIfPresent(BoxFillMode.self, forKey: .fillMode) ?? .transparent
        let fillCharacterString =
            try container.decodeIfPresent(String.self, forKey: .fillCharacter) ?? " "
        fillCharacter = fillCharacterString.first ?? Character(" ")
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(origin, forKey: .origin)
        try container.encode(size, forKey: .size)
        try container.encode(strokeStyle, forKey: .strokeStyle)
        try container.encode(fillMode, forKey: .fillMode)
        try container.encode(String(fillCharacter), forKey: .fillCharacter)
        try container.encode(label, forKey: .label)
    }
}
