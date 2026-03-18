import Foundation

struct GridPoint: Codable, Equatable, Hashable, Sendable {
    var column: Int
    var row: Int

    static let zero = GridPoint(column: 0, row: 0)

    static func + (lhs: GridPoint, rhs: GridPoint) -> GridPoint {
        GridPoint(column: lhs.column + rhs.column, row: lhs.row + rhs.row)
    }

    static func - (lhs: GridPoint, rhs: GridPoint) -> GridPoint {
        GridPoint(column: lhs.column - rhs.column, row: lhs.row - rhs.row)
    }
}

struct GridSize: Codable, Equatable, Hashable, Sendable {
    var width: Int
    var height: Int

    static let zero = GridSize(width: 0, height: 0)

    var isEmpty: Bool {
        width <= 0 || height <= 0
    }
}

struct GridRect: Codable, Equatable, Hashable, Sendable {
    var origin: GridPoint
    var size: GridSize

    var minColumn: Int { origin.column }
    var minRow: Int { origin.row }
    var maxColumn: Int { origin.column + size.width - 1 }
    var maxRow: Int { origin.row + size.height - 1 }

    func contains(_ point: GridPoint) -> Bool {
        point.column >= minColumn && point.column <= maxColumn
            && point.row >= minRow && point.row <= maxRow
    }

    func intersects(_ other: GridRect) -> Bool {
        minColumn <= other.maxColumn && maxColumn >= other.minColumn
            && minRow <= other.maxRow && maxRow >= other.minRow
    }

    static func enclosing(from pointA: GridPoint, to pointB: GridPoint) -> GridRect {
        let minCol = min(pointA.column, pointB.column)
        let maxCol = max(pointA.column, pointB.column)
        let minRow = min(pointA.row, pointB.row)
        let maxRow = max(pointA.row, pointB.row)
        return GridRect(
            origin: GridPoint(column: minCol, row: minRow),
            size: GridSize(width: maxCol - minCol + 1, height: maxRow - minRow + 1)
        )
    }
}

enum ResizeHandle: Equatable, Sendable {
    case topLeft
    case top
    case topRight
    case right
    case bottomLeft
    case bottom
    case bottomRight
    case left
    case start
    case end
}

struct ResizeHandlePlacement: Equatable, Hashable, Sendable {
    let handle: ResizeHandle
    let point: GridPoint
}
