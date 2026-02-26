import Foundation

struct BoxShape: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var origin: GridPoint
    var size: GridSize
    var borderStyle: BorderStyle
    var label: String

    init(
        id: UUID = UUID(),
        origin: GridPoint,
        size: GridSize,
        borderStyle: BorderStyle = .single,
        label: String = ""
    ) {
        self.id = id
        self.origin = origin
        self.size = size
        self.borderStyle = borderStyle
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

        let style = borderStyle
        let col = origin.column
        let row = origin.row
        let w = size.width
        let h = size.height

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
}
