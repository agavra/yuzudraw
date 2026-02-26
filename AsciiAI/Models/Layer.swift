import Foundation

struct ShapeGroup: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var shapeIDs: [UUID]

    init(id: UUID = UUID(), name: String, shapeIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.shapeIDs = shapeIDs
    }
}

struct Layer: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var isVisible: Bool
    var isLocked: Bool
    var shapes: [AnyShape]
    var groups: [ShapeGroup]

    init(
        id: UUID = UUID(),
        name: String,
        isVisible: Bool = true,
        isLocked: Bool = false,
        shapes: [AnyShape] = [],
        groups: [ShapeGroup] = []
    ) {
        self.id = id
        self.name = name
        self.isVisible = isVisible
        self.isLocked = isLocked
        self.shapes = shapes
        self.groups = groups
    }

    func findShape(id shapeID: UUID) -> AnyShape? {
        shapes.first { $0.id == shapeID }
    }

    mutating func addShape(_ shape: AnyShape) {
        shapes.append(shape)
    }

    mutating func removeShape(id shapeID: UUID) {
        shapes.removeAll { $0.id == shapeID }
        for index in groups.indices {
            groups[index].shapeIDs.removeAll { $0 == shapeID }
        }
    }
}
