import Foundation

struct TextShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var origin: GridPoint
    var text: String
    var textColor: ShapeColor?

    init(
        id: UUID = UUID(),
        name: String? = nil,
        origin: GridPoint,
        text: String = "",
        textColor: ShapeColor? = nil
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.text = text
        self.textColor = textColor
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
}
