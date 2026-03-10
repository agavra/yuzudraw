import Foundation

struct TextShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var origin: GridPoint
    var text: String
    var textColor: ShapeColor?
    var float: Bool

    init(
        id: UUID = UUID(),
        name: String? = nil,
        origin: GridPoint,
        text: String = "",
        textColor: ShapeColor? = nil,
        float: Bool = false
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.text = text
        self.textColor = textColor
        self.float = float
    }

    var lines: [String] {
        text.components(separatedBy: "\n")
    }

    var boundingRect: GridRect {
        let textLines = lines
        let maxWidth = textLines.map(\.count).max() ?? 0
        return GridRect(
            origin: origin,
            size: GridSize(width: max(maxWidth, 1), height: max(textLines.count, 1))
        )
    }

    func contains(point: GridPoint) -> Bool {
        boundingRect.contains(point)
    }

    func render(into canvas: inout Canvas) {
        for (rowOffset, line) in lines.enumerated() {
            for (colOffset, char) in line.enumerated() {
                canvas.setCharacter(
                    char,
                    foreground: textColor,
                    background: nil,
                    atColumn: origin.column + colOffset,
                    row: origin.row + rowOffset
                )
            }
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, name, origin, text, textColor, float
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        origin = try container.decode(GridPoint.self, forKey: .origin)
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        textColor = try container.decodeIfPresent(ShapeColor.self, forKey: .textColor)
        float = try container.decodeIfPresent(Bool.self, forKey: .float) ?? false
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(origin, forKey: .origin)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        if float {
            try container.encode(float, forKey: .float)
        }
    }
}
