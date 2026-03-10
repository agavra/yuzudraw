import Foundation

enum AnyShape: Codable, Equatable, Identifiable, Sendable {
    case rectangle(RectangleShape)
    case arrow(ArrowShape)
    case text(TextShape)
    case pencil(PencilShape)

    var id: UUID {
        switch self {
        case .rectangle(let shape): return shape.id
        case .arrow(let shape): return shape.id
        case .text(let shape): return shape.id
        case .pencil(let shape): return shape.id
        }
    }

    var colors: [ShapeColor] {
        switch self {
        case .rectangle(let shape):
            return [shape.borderColor, shape.fillColor, shape.textColor].compactMap { $0 }
        case .arrow(let shape):
            return [shape.strokeColor, shape.labelColor].compactMap { $0 }
        case .text(let shape):
            return [shape.textColor].compactMap { $0 }
        case .pencil(let shape):
            return shape.cells.values.compactMap { $0.color }
        }
    }

    var boundingRect: GridRect {
        switch self {
        case .rectangle(let shape): return shape.boundingRect
        case .arrow(let shape): return shape.boundingRect
        case .text(let shape): return shape.boundingRect
        case .pencil(let shape): return shape.boundingRect
        }
    }

    var renderBoundingRect: GridRect {
        switch self {
        case .rectangle(let shape): return shape.renderBoundingRect
        case .arrow(let shape): return shape.boundingRect
        case .text(let shape): return shape.boundingRect
        case .pencil(let shape): return shape.boundingRect
        }
    }

    func contains(point: GridPoint) -> Bool {
        switch self {
        case .rectangle(let shape): return shape.contains(point: point)
        case .arrow(let shape): return shape.contains(point: point)
        case .text(let shape): return shape.contains(point: point)
        case .pencil(let shape): return shape.contains(point: point)
        }
    }

    func render(into canvas: inout Canvas) {
        switch self {
        case .rectangle(let shape): shape.render(into: &canvas)
        case .arrow(let shape): shape.render(into: &canvas)
        case .text(let shape): shape.render(into: &canvas)
        case .pencil(let shape): shape.render(into: &canvas)
        }
    }

    var displayName: String {
        if let customName = customName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !customName.isEmpty
        {
            return customName
        }

        switch self {
        case .rectangle(let shape): return shape.label.isEmpty ? "Rectangle" : shape.label
        case .arrow(let shape): return shape.label.isEmpty ? "Arrow" : shape.label
        case .text(let shape):
            let firstLine = shape.text.components(separatedBy: "\n").first ?? ""
            return firstLine.isEmpty ? "Text" : String(firstLine.prefix(20))
        case .pencil: return "Pencil"
        }
    }

    var typeName: String {
        switch self {
        case .rectangle: return "Rectangle"
        case .arrow: return "Arrow"
        case .text: return "Text"
        case .pencil: return "Pencil"
        }
    }

    var customName: String? {
        switch self {
        case .rectangle(let shape): return shape.name
        case .arrow(let shape): return shape.name
        case .text(let shape): return shape.name
        case .pencil(let shape): return shape.name
        }
    }

    var float: Bool {
        switch self {
        case .rectangle(let shape): return shape.float
        case .arrow(let shape): return shape.float
        case .text(let shape): return shape.float
        case .pencil: return true
        }
    }

    func renamedForPanel(_ name: String) -> AnyShape {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedName = trimmed.isEmpty ? nil : trimmed
        switch self {
        case .rectangle(var shape):
            shape.name = normalizedName
            return .rectangle(shape)
        case .arrow(var shape):
            shape.name = normalizedName
            return .arrow(shape)
        case .text(var shape):
            shape.name = normalizedName
            return .text(shape)
        case .pencil(var shape):
            shape.name = normalizedName
            return .pencil(shape)
        }
    }

    // MARK: - Resize handles

    var resizeHandlePlacements: [ResizeHandlePlacement] {
        switch self {
        case .rectangle(let shape):
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
        case .pencil:
            return []
        }
    }

    func resizeHandle(at point: GridPoint) -> ResizeHandle? {
        if case .arrow = self {
            return resizeHandlePlacements
                .compactMap { placement -> (ResizeHandle, Int)? in
                    let dx = abs(placement.point.column - point.column)
                    let dy = abs(placement.point.row - point.row)
                    let distance = dx + dy
                    guard distance <= 1 else { return nil }
                    return (placement.handle, distance)
                }
                .min(by: { $0.1 < $1.1 })?
                .0
        }

        return resizeHandlePlacements.first { $0.point == point }?.handle
    }

    func resized(using handle: ResizeHandle, to point: GridPoint) -> AnyShape {
        switch self {
        case .rectangle(var shape):
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
                newLeft = max(0, min(point.column, right))
                newTop = max(0, min(point.row, bottom))
            case .top:
                newTop = max(0, min(point.row, bottom))
            case .topRight:
                newRight = max(left, point.column)
                newTop = max(0, min(point.row, bottom))
            case .right:
                newRight = max(left, point.column)
            case .bottomLeft:
                newLeft = max(0, min(point.column, right))
                newBottom = max(top, point.row)
            case .bottom:
                newBottom = max(top, point.row)
            case .bottomRight:
                newRight = max(left, point.column)
                newBottom = max(top, point.row)
            case .left:
                newLeft = max(0, min(point.column, right))
            case .start, .end:
                return self
            }

            shape.origin = GridPoint(column: newLeft, row: newTop)
            shape.size = GridSize(
                width: max(1, newRight - newLeft + 1),
                height: max(1, newBottom - newTop + 1)
            )
            return .rectangle(shape)

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
        case .pencil:
            return self
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum ShapeType: String, Codable {
        case rectangle, arrow, text, pencil

        // Backward compatibility: accept "box" from older documents
        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            if raw == "box" {
                self = .rectangle
            } else if let value = ShapeType(rawValue: raw) {
                self = value
            } else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Unknown shape type: \(raw)"
                )
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ShapeType.self, forKey: .type)
        switch type {
        case .rectangle:
            self = .rectangle(try RectangleShape(from: decoder))
        case .arrow:
            self = .arrow(try ArrowShape(from: decoder))
        case .text:
            self = .text(try TextShape(from: decoder))
        case .pencil:
            self = .pencil(try PencilShape(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .rectangle(let shape):
            try container.encode(ShapeType.rectangle, forKey: .type)
            try shape.encode(to: encoder)
        case .arrow(let shape):
            try container.encode(ShapeType.arrow, forKey: .type)
            try shape.encode(to: encoder)
        case .text(let shape):
            try container.encode(ShapeType.text, forKey: .type)
            try shape.encode(to: encoder)
        case .pencil(let shape):
            try container.encode(ShapeType.pencil, forKey: .type)
            try shape.encode(to: encoder)
        }
    }
}
