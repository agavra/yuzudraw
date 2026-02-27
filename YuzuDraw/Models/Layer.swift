import Foundation

struct ShapeGroup: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var shapeIDs: [UUID]
    var children: [ShapeGroup]

    init(id: UUID = UUID(), name: String, shapeIDs: [UUID] = [], children: [ShapeGroup] = []) {
        self.id = id
        self.name = name
        self.shapeIDs = shapeIDs
        self.children = children
    }

    // Backward-compatible decoding: children defaults to [] if missing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shapeIDs = try container.decode([UUID].self, forKey: .shapeIDs)
        children = try container.decodeIfPresent([ShapeGroup].self, forKey: .children) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, shapeIDs, children
    }

    var allShapeIDs: Set<UUID> {
        var ids = Set(shapeIDs)
        for child in children {
            ids.formUnion(child.allShapeIDs)
        }
        return ids
    }

    mutating func removeShapeRecursively(id shapeID: UUID) {
        shapeIDs.removeAll { $0 == shapeID }
        for index in children.indices {
            children[index].removeShapeRecursively(id: shapeID)
        }
    }

    mutating func removeShapesRecursively(ids: Set<UUID>) {
        shapeIDs.removeAll { ids.contains($0) }
        for index in children.indices {
            children[index].removeShapesRecursively(ids: ids)
        }
    }

    mutating func renameGroupRecursively(id groupID: UUID, to newName: String) -> Bool {
        if id == groupID {
            name = newName
            return true
        }

        for index in children.indices {
            if children[index].renameGroupRecursively(id: groupID, to: newName) {
                return true
            }
        }

        return false
    }
}

struct Layer: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var isVisible: Bool
    var isLocked: Bool
    var shapes: [AnyShape]
    var groups: [ShapeGroup]
    var backgroundColor: ShapeColor?

    init(
        id: UUID = UUID(),
        name: String,
        isVisible: Bool = true,
        isLocked: Bool = false,
        shapes: [AnyShape] = [],
        groups: [ShapeGroup] = [],
        backgroundColor: ShapeColor? = nil
    ) {
        self.id = id
        self.name = name
        self.isVisible = isVisible
        self.isLocked = isLocked
        self.shapes = shapes
        self.groups = groups
        self.backgroundColor = backgroundColor
    }

    var groupedShapeIDs: Set<UUID> {
        var ids = Set<UUID>()
        for group in groups {
            ids.formUnion(group.allShapeIDs)
        }
        return ids
    }

    var ungroupedShapes: [AnyShape] {
        let grouped = groupedShapeIDs
        return shapes.filter { !grouped.contains($0.id) }
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
            groups[index].removeShapeRecursively(id: shapeID)
        }
    }

    mutating func removeShapesFromGroups(ids: Set<UUID>) {
        for index in groups.indices {
            groups[index].removeShapesRecursively(ids: ids)
        }
    }

    mutating func renameGroup(id groupID: UUID, to newName: String) -> Bool {
        for index in groups.indices {
            if groups[index].renameGroupRecursively(id: groupID, to: newName) {
                return true
            }
        }
        return false
    }
}
