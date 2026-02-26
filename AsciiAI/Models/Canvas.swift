import Foundation

struct Canvas: Equatable {
    static let defaultColumns = 80
    static let defaultRows = 24

    let columns: Int
    let rows: Int
    private(set) var grid: [[Character]]

    init(columns: Int = Canvas.defaultColumns, rows: Int = Canvas.defaultRows) {
        self.columns = columns
        self.rows = rows
        self.grid = Array(
            repeating: Array(repeating: Character(" "), count: columns),
            count: rows
        )
    }

    func character(atColumn column: Int, row: Int) -> Character? {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return nil
        }
        return grid[row][column]
    }

    mutating func setCharacter(_ char: Character, atColumn column: Int, row: Int) {
        guard column >= 0, column < columns, row >= 0, row < rows else {
            return
        }
        grid[row][column] = char
    }

    func render() -> String {
        grid.map { row in String(row) }.joined(separator: "\n")
    }
}
