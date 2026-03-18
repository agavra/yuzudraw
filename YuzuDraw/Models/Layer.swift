import Foundation
import os

private let layerPanelLog = OSLog(subsystem: "com.yuzudraw", category: "LayerPanel")

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

    mutating func insertChildGroupNextTo(_ newGroup: ShapeGroup, siblingID: UUID) -> Bool {
        if let index = children.firstIndex(where: { $0.id == siblingID }) {
            children.insert(newGroup, at: index + 1)
            return true
        }
        for i in children.indices {
            if children[i].insertChildGroupNextTo(newGroup, siblingID: siblingID) {
                return true
            }
        }
        return false
    }

    func remappingIDs(_ idMap: [UUID: UUID]) -> ShapeGroup {
        ShapeGroup(
            id: UUID(),
            name: name,
            shapeIDs: shapeIDs.compactMap { idMap[$0] },
            children: children.map { $0.remappingIDs(idMap) }
        )
    }

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

/// Items in z-order for display in the objects panel. Each item is either
/// a root group (emitted once when its first member shape is encountered)
/// or an ungrouped shape.
enum DocumentItem: Equatable {
    case group(ShapeGroup)
    case shape(AnyShape)

    var id: UUID {
        switch self {
        case .group(let g): return g.id
        case .shape(let s): return s.id
        }
    }
}
