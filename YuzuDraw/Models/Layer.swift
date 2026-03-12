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

    func containsShape(_ shapeID: UUID) -> Bool {
        if shapeIDs.contains(shapeID) { return true }
        return children.contains { $0.containsShape(shapeID) }
    }

    func childGroup(containingShape shapeID: UUID) -> ShapeGroup? {
        for child in children {
            if child.containsShape(shapeID) {
                return child
            }
        }
        return nil
    }

    func ancestryPath(to shapeID: UUID) -> [ShapeGroup]? {
        if shapeIDs.contains(shapeID) {
            return []
        }
        for child in children {
            if let subPath = child.ancestryPath(to: shapeID) {
                return [child] + subPath
            }
        }
        return nil
    }

    func findGroupByID(_ id: UUID) -> ShapeGroup? {
        if self.id == id { return self }
        for child in children {
            if let found = child.findGroupByID(id) {
                return found
            }
        }
        return nil
    }

    mutating func removeShapeRecursively(id shapeID: UUID) {
        shapeIDs.removeAll { $0 == shapeID }
        for index in children.indices {
            children[index].removeShapeRecursively(id: shapeID)
        }
        children.removeAll { $0.allShapeIDs.isEmpty }
    }

    mutating func removeShapesRecursively(ids: Set<UUID>) {
        shapeIDs.removeAll { ids.contains($0) }
        for index in children.indices {
            children[index].removeShapesRecursively(ids: ids)
        }
        children.removeAll { $0.allShapeIDs.isEmpty }
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

    /// Items in z-order for display in the layer panel. Each item is either
    /// a root group (emitted once when its first member shape is encountered)
    /// or an ungrouped shape.
    enum LayerItem: Equatable {
        case group(ShapeGroup)
        case shape(AnyShape)

        var id: UUID {
            switch self {
            case .group(let g): return g.id
            case .shape(let s): return s.id
            }
        }
    }

    var orderedItems: [LayerItem] {
        let grouped = groupedShapeIDs
        var emittedGroupIDs = Set<UUID>()
        var items: [LayerItem] = []
        for shape in shapes {
            if grouped.contains(shape.id) {
                guard let rootGroup = findRootGroup(containingShape: shape.id),
                      !emittedGroupIDs.contains(rootGroup.id)
                else { continue }
                emittedGroupIDs.insert(rootGroup.id)
                items.append(.group(rootGroup))
            } else {
                items.append(.shape(shape))
            }
        }
        return items
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
        groups.removeAll { $0.allShapeIDs.isEmpty }
    }

    mutating func removeShapesFromGroups(ids: Set<UUID>) {
        for index in groups.indices {
            groups[index].removeShapesRecursively(ids: ids)
        }
        groups.removeAll { $0.allShapeIDs.isEmpty }
    }

    func findRootGroup(containingShape shapeID: UUID) -> ShapeGroup? {
        for group in groups {
            if group.containsShape(shapeID) {
                return group
            }
        }
        return nil
    }

    func findGroupAncestry(containingShape shapeID: UUID) -> [ShapeGroup] {
        for group in groups {
            if let path = group.ancestryPath(to: shapeID) {
                return [group] + path
            }
        }
        return []
    }

    mutating func renameGroup(id groupID: UUID, to newName: String) -> Bool {
        for index in groups.indices {
            if groups[index].renameGroupRecursively(id: groupID, to: newName) {
                return true
            }
        }
        return false
    }

    mutating func appendShapesToGroup(ids: [UUID], groupID: UUID) -> Bool {
        guard !ids.isEmpty else { return false }
        for index in groups.indices {
            if groups[index].appendShapesRecursively(ids: ids, groupID: groupID) {
                return true
            }
        }
        return false
    }

    func findGroupByID(_ groupID: UUID) -> ShapeGroup? {
        for group in groups {
            if let found = group.findGroupByID(groupID) {
                return found
            }
        }
        return nil
    }

    /// Returns the min..<max+1 index range of all shapes belonging to a group (including nested children).
    func groupShapeIndexRange(for groupID: UUID) -> Range<Int>? {
        guard let group = findGroupByID(groupID) else { return nil }
        let memberIDs = group.allShapeIDs
        guard !memberIDs.isEmpty else { return nil }
        var minIndex = Int.max
        var maxIndex = Int.min
        for (index, shape) in shapes.enumerated() {
            if memberIDs.contains(shape.id) {
                minIndex = min(minIndex, index)
                maxIndex = max(maxIndex, index)
            }
        }
        guard minIndex <= maxIndex else { return nil }
        return minIndex..<(maxIndex + 1)
    }

    /// Ensures all shapes for a group are contiguous in the shapes array.
    /// Collects them preserving relative order, removes them, re-inserts at the highest original position.
    mutating func consolidateGroup(_ groupID: UUID) {
        guard let group = findGroupByID(groupID) else { return }
        let memberIDs = group.allShapeIDs
        guard !memberIDs.isEmpty else { return }

        let memberShapes = shapes.filter { memberIDs.contains($0.id) }
        guard memberShapes.count > 1 else { return }

        let memberIndices = shapes.enumerated().filter { memberIDs.contains($0.element.id) }.map(\.offset)
        let maxIdx = memberIndices.last!
        if maxIdx - memberIndices.first! + 1 == memberShapes.count { return }

        shapes.removeAll { memberIDs.contains($0.id) }
        let insertionIndex = maxIdx + 1 - memberShapes.count
        shapes.insert(contentsOf: memberShapes, at: insertionIndex)
    }
}

private extension ShapeGroup {
    mutating func appendShapesRecursively(ids: [UUID], groupID: UUID) -> Bool {
        if id == groupID {
            shapeIDs.append(contentsOf: ids)
            return true
        }

        for index in children.indices {
            if children[index].appendShapesRecursively(ids: ids, groupID: groupID) {
                return true
            }
        }

        return false
    }
}
