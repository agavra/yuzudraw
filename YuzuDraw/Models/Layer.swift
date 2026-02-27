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

    private enum CodingKeys: String, CodingKey {
        case id, name, isVisible, isLocked, shapes, groups, backgroundColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isVisible = try container.decode(Bool.self, forKey: .isVisible)
        isLocked = try container.decode(Bool.self, forKey: .isLocked)
        shapes = try container.decode([AnyShape].self, forKey: .shapes)
        groups = try container.decodeIfPresent([ShapeGroup].self, forKey: .groups) ?? []
        // backgroundColor decoded and ignored for backward compatibility
        _ = try container.decodeIfPresent(ShapeColor.self, forKey: .backgroundColor)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(shapes, forKey: .shapes)
        try container.encode(groups, forKey: .groups)
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
