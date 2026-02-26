import Foundation

enum AnyShape: Codable, Equatable, Identifiable, Sendable {
    case box(BoxShape)
    case arrow(ArrowShape)
    case text(TextShape)

    var id: UUID {
        switch self {
        case .box(let shape): return shape.id
        case .arrow(let shape): return shape.id
        case .text(let shape): return shape.id
        }
    }

    var boundingRect: GridRect {
        switch self {
        case .box(let shape): return shape.boundingRect
        case .arrow(let shape): return shape.boundingRect
        case .text(let shape): return shape.boundingRect
        }
    }

    func contains(point: GridPoint) -> Bool {
        switch self {
        case .box(let shape): return shape.contains(point: point)
        case .arrow(let shape): return shape.contains(point: point)
        case .text(let shape): return shape.contains(point: point)
        }
    }

    func render(into canvas: inout Canvas) {
        switch self {
        case .box(let shape): shape.render(into: &canvas)
        case .arrow(let shape): shape.render(into: &canvas)
        case .text(let shape): shape.render(into: &canvas)
        }
    }

    var displayName: String {
        switch self {
        case .box(let shape): return shape.label.isEmpty ? "Box" : shape.label
        case .arrow(let shape): return shape.label.isEmpty ? "Arrow" : shape.label
        case .text(let shape):
            let firstLine = shape.text.components(separatedBy: "\n").first ?? ""
            return firstLine.isEmpty ? "Text" : String(firstLine.prefix(20))
        }
    }

    var typeName: String {
        switch self {
        case .box: return "Box"
        case .arrow: return "Arrow"
        case .text: return "Text"
        }
    }

    // MARK: - Resize handles

    var resizeHandlePlacements: [ResizeHandlePlacement] {
        switch self {
        case .box(let shape):
            let rect = shape.boundingRect
            let rightColumn = rect.maxColumn + 1
            let bottomRow = rect.maxRow + 1
            let centerColumn = rect.origin.column + rect.size.width / 2
            let centerRow = rect.origin.row + rect.size.height / 2
            return [
                ResizeHandlePlacement(
                    handle: .topLeft, point: GridPoint(column: rect.minColumn, row: rect.minRow)),
                ResizeHandlePlacement(
                    handle: .top, point: GridPoint(column: centerColumn, row: rect.minRow)),
                ResizeHandlePlacement(
                    handle: .topRight, point: GridPoint(column: rightColumn, row: rect.minRow)),
                ResizeHandlePlacement(
                    handle: .right, point: GridPoint(column: rightColumn, row: centerRow)),
                ResizeHandlePlacement(
                    handle: .bottomLeft, point: GridPoint(column: rect.minColumn, row: bottomRow)),
                ResizeHandlePlacement(
                    handle: .bottom, point: GridPoint(column: centerColumn, row: bottomRow)),
                ResizeHandlePlacement(
                    handle: .bottomRight, point: GridPoint(column: rightColumn, row: bottomRow)),
                ResizeHandlePlacement(
                    handle: .left, point: GridPoint(column: rect.minColumn, row: centerRow)),
            ]
        case .arrow(let shape):
            return [
                ResizeHandlePlacement(handle: .start, point: shape.start),
                ResizeHandlePlacement(handle: .end, point: shape.end),
            ]
        case .text:
            return []
        }
    }

    func resizeHandle(at point: GridPoint) -> ResizeHandle? {
        if case .arrow(let shape) = self {
            return [
                ResizeHandlePlacement(handle: .start, point: shape.start),
                ResizeHandlePlacement(handle: .end, point: shape.end),
            ]
            .compactMap { placement -> (ResizeHandle, Int)? in
                let dx = abs(placement.point.column - point.column)
                let dy = abs(placement.point.row - point.row)
                let distance = dx + dy
                guard distance <= 2 else { return nil }
                return (placement.handle, distance)
            }
            .min(by: { $0.1 < $1.1 })?
            .0
        }

        if case .box(let shape) = self {
            let rect = shape.boundingRect
            let centerColumn = rect.origin.column + rect.size.width / 2
            let centerRow = rect.origin.row + rect.size.height / 2
            if point == GridPoint(column: rect.maxColumn, row: rect.minRow) { return .topRight }
            if point == GridPoint(column: rect.minColumn, row: rect.maxRow) { return .bottomLeft }
            if point == GridPoint(column: rect.maxColumn, row: rect.maxRow) { return .bottomRight }
            if point == GridPoint(column: rect.maxColumn, row: centerRow) { return .right }
            if point == GridPoint(column: centerColumn, row: rect.maxRow) { return .bottom }
        }

        return resizeHandlePlacements
            .compactMap { placement -> (ResizeHandle, Int)? in
                let dx = abs(placement.point.column - point.column)
                let dy = abs(placement.point.row - point.row)
                let distance = dx + dy
                guard dx <= 1, dy <= 1 else { return nil }
                return (placement.handle, distance)
            }
            .min(by: { $0.1 < $1.1 })?
            .0
    }

    func resized(using handle: ResizeHandle, to point: GridPoint) -> AnyShape {
        switch self {
        case .box(var shape):
            let rect = shape.boundingRect
            let left = rect.minColumn
            let right = rect.maxColumn
            let top = rect.minRow
            let bottom = rect.maxRow

            var newLeft = left
            var newRight = right
            var newTop = top
            var newBottom = bottom

            switch handle {
            case .topLeft:
                newLeft = max(0, min(point.column, right - 1))
                newTop = max(0, min(point.row, bottom - 1))
            case .top:
                newTop = max(0, min(point.row, bottom - 1))
            case .topRight:
                newRight = max(left + 1, point.column)
                newTop = max(0, min(point.row, bottom - 1))
            case .right:
                newRight = max(left + 1, point.column)
            case .bottomLeft:
                newLeft = max(0, min(point.column, right - 1))
                newBottom = max(top + 1, point.row)
            case .bottom:
                newBottom = max(top + 1, point.row)
            case .bottomRight:
                newRight = max(left + 1, point.column)
                newBottom = max(top + 1, point.row)
            case .left:
                newLeft = max(0, min(point.column, right - 1))
            case .start, .end:
                return self
            }

            shape.origin = GridPoint(column: newLeft, row: newTop)
            shape.size = GridSize(
                width: max(2, newRight - newLeft + 1),
                height: max(2, newBottom - newTop + 1)
            )
            return .box(shape)

        case .arrow(var shape):
            let clampedPoint = GridPoint(
                column: max(0, point.column),
                row: max(0, point.row)
            )
            switch handle {
            case .start:
                shape.start = clampedPoint
                shape.startAttachment = nil
            case .end:
                shape.end = clampedPoint
                shape.endAttachment = nil
            case .topLeft, .top, .topRight, .right, .bottomLeft, .bottom, .bottomRight, .left:
                return self
            }
            return .arrow(shape)

        case .text:
            return self
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum ShapeType: String, Codable {
        case box, arrow, text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ShapeType.self, forKey: .type)
        switch type {
        case .box:
            self = .box(try BoxShape(from: decoder))
        case .arrow:
            self = .arrow(try ArrowShape(from: decoder))
        case .text:
            self = .text(try TextShape(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .box(let shape):
            try container.encode(ShapeType.box, forKey: .type)
            try shape.encode(to: encoder)
        case .arrow(let shape):
            try container.encode(ShapeType.arrow, forKey: .type)
            try shape.encode(to: encoder)
        case .text(let shape):
            try container.encode(ShapeType.text, forKey: .type)
            try shape.encode(to: encoder)
        }
    }
}
