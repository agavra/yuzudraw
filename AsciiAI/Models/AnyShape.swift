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
