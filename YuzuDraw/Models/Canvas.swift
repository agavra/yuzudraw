import Foundation

struct CanvasCell: Equatable, Sendable {
    var character: Character
    var foregroundColor: ShapeColor?
    var backgroundColor: ShapeColor?

    static let empty = CanvasCell(character: " ")
}

struct Canvas: Equatable {
    static let defaultColumns = 80
    static let defaultRows = 24

    let columns: Int
    let rows: Int
    private(set) var grid: [[CanvasCell]]

    init(columns: Int = Canvas.defaultColumns, rows: Int = Canvas.defaultRows) {
        self.columns = columns
        self.rows = rows
        self.grid = Array(
            repeating: Array(repeating: CanvasCell.empty, count: columns),
            count: rows
        )
    }

    init(size: GridSize) {
        self.init(columns: size.width, rows: size.height)
    }

    mutating func clear() {
        grid = Array(
            repeating: Array(repeating: CanvasCell.empty, count: columns),
            count: rows
        )
    }

    func character(atColumn column: Int, row: Int) -> Character? {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return nil
        }
        return grid[row][column].character
    }

    mutating func setCharacter(_ char: Character, atColumn column: Int, row: Int) {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return
        }
        grid[row][column].character = char
    }

    mutating func setCharacter(
        _ char: Character,
        foreground: ShapeColor?,
        background: ShapeColor?,
        atColumn column: Int,
        row: Int
    ) {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return
        }
        grid[row][column] = CanvasCell(
            character: char,
            foregroundColor: foreground ?? grid[row][column].foregroundColor,
            backgroundColor: background ?? grid[row][column].backgroundColor
        )
    }

    func cell(atColumn column: Int, row: Int) -> CanvasCell? {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return nil
        }
        return grid[row][column]
    }

    func render() -> String {
        grid.map { row in String(row.map(\.character)) }.joined(separator: "\n")
    }

    func renderAttributed(defaultForeground: ShapeColor) -> AttributedString {
        var result = AttributedString()

        for (rowIndex, row) in grid.enumerated() {
            if rowIndex > 0 {
                result += AttributedString("\n")
            }

            var runStart = 0
            while runStart < row.count {
                let currentFg = row[runStart].foregroundColor
                let currentBg = row[runStart].backgroundColor

                var runEnd = runStart + 1
                while runEnd < row.count,
                    row[runEnd].foregroundColor == currentFg,
                    row[runEnd].backgroundColor == currentBg
                {
                    runEnd += 1
                }

                let chars = String(row[runStart..<runEnd].map(\.character))
                var segment = AttributedString(chars)

                let fg = currentFg ?? defaultForeground
                segment.foregroundColor = fg.swiftUIColor

                if let bg = currentBg {
                    segment.backgroundColor = bg.swiftUIColor
                }

                result += segment
                runStart = runEnd
            }
        }

        return result
    }
}
