import Foundation
import os

private let layerPanelLog = OSLog(subsystem: "com.yuzudraw", category: "LayerPanel")

struct Document: Codable, Equatable, Sendable {
    var shapes: [AnyShape]
    var groups: [ShapeGroup]
    var hiddenShapeIDs: Set<UUID>
    var lockedShapeIDs: Set<UUID>
    var hiddenGroupIDs: Set<UUID>
    var lockedGroupIDs: Set<UUID>
    var canvasSize: GridSize
    var palette: ColorPalette

    private enum CodingKeys: String, CodingKey {
        case shapes
        case groups
        case hiddenShapeIDs
        case lockedShapeIDs
        case hiddenGroupIDs
        case lockedGroupIDs
        case layers
        case canvasSize
        case palette
    }

    init(
        shapes: [AnyShape] = [],
        groups: [ShapeGroup] = [],
        hiddenShapeIDs: Set<UUID> = [],
        lockedShapeIDs: Set<UUID> = [],
        hiddenGroupIDs: Set<UUID> = [],
        lockedGroupIDs: Set<UUID> = [],
        canvasSize: GridSize = GridSize(width: Canvas.defaultColumns, height: Canvas.defaultRows),
        palette: ColorPalette = .default
    ) {
        self.shapes = shapes
        self.groups = groups
        self.hiddenShapeIDs = hiddenShapeIDs
        self.lockedShapeIDs = lockedShapeIDs
        self.hiddenGroupIDs = hiddenGroupIDs
        self.lockedGroupIDs = lockedGroupIDs
        self.canvasSize = canvasSize
        self.palette = palette
        pruneState()
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        canvasSize = try container.decode(GridSize.self, forKey: .canvasSize)
        palette = try container.decodeIfPresent(ColorPalette.self, forKey: .palette) ?? .default

        // Try new format first (shapes/groups), fall back to legacy layers format
        if let decodedShapes = try container.decodeIfPresent([AnyShape].self, forKey: .shapes) {
            shapes = decodedShapes
            groups = try container.decodeIfPresent([ShapeGroup].self, forKey: .groups) ?? []
            hiddenShapeIDs =
                try container.decodeIfPresent(Set<UUID>.self, forKey: .hiddenShapeIDs) ?? []
            lockedShapeIDs =
                try container.decodeIfPresent(Set<UUID>.self, forKey: .lockedShapeIDs) ?? []
            hiddenGroupIDs =
                try container.decodeIfPresent(Set<UUID>.self, forKey: .hiddenGroupIDs) ?? []
            lockedGroupIDs =
                try container.decodeIfPresent(Set<UUID>.self, forKey: .lockedGroupIDs) ?? []
        } else if let layers = try container.decodeIfPresent([LegacyLayer].self, forKey: .layers) {
            // Flatten legacy layers into shapes/groups
            var allShapes: [AnyShape] = []
            var allGroups: [ShapeGroup] = []
            for layer in layers {
                allShapes.append(contentsOf: layer.shapes)
                allGroups.append(contentsOf: layer.groups)
            }
            shapes = allShapes
            groups = allGroups
            hiddenShapeIDs = []
            lockedShapeIDs = []
            hiddenGroupIDs = []
            lockedGroupIDs = []
        } else {
            shapes = []
            groups = []
            hiddenShapeIDs = []
            lockedShapeIDs = []
            hiddenGroupIDs = []
            lockedGroupIDs = []
        }
        pruneState()
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shapes, forKey: .shapes)
        try container.encode(groups, forKey: .groups)
        try container.encode(hiddenShapeIDs, forKey: .hiddenShapeIDs)
        try container.encode(lockedShapeIDs, forKey: .lockedShapeIDs)
        try container.encode(hiddenGroupIDs, forKey: .hiddenGroupIDs)
        try container.encode(lockedGroupIDs, forKey: .lockedGroupIDs)
        try container.encode(canvasSize, forKey: .canvasSize)
        try container.encode(palette, forKey: .palette)
    }

    var hasContent: Bool {
        !visibleShapes.isEmpty
    }

    var visibleShapes: [AnyShape] {
        shapes.filter { !isShapeHidden($0.id) }
    }

    var selectableShapes: [AnyShape] {
        shapes.filter { isShapeSelectable($0.id) }
    }

    // MARK: - Group helpers

    var groupedShapeIDs: Set<UUID> {
        var ids = Set<UUID>()
        for group in groups {
            ids.formUnion(group.allShapeIDs)
        }
        return ids
    }

    var orderedItems: [DocumentItem] {
        os_signpost(.begin, log: layerPanelLog, name: "orderedItems", "shapes=%d groups=%d", shapes.count, groups.count)
        let grouped = groupedShapeIDs
        var emittedGroupIDs = Set<UUID>()
        var items: [DocumentItem] = []
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
        os_signpost(.end, log: layerPanelLog, name: "orderedItems")
        return items
    }

    var ungroupedShapes: [AnyShape] {
        let grouped = groupedShapeIDs
        return shapes.filter { !grouped.contains($0.id) }
    }

    // MARK: - Shape queries

    func findShape(id shapeID: UUID) -> AnyShape? {
        shapes.first { $0.id == shapeID }
    }

    // MARK: - Shape mutations

    mutating func addShape(_ shape: AnyShape) {
        shapes.append(shape)
    }

    mutating func removeShape(id shapeID: UUID) {
        shapes.removeAll { $0.id == shapeID }
        for index in groups.indices {
            groups[index].removeShapeRecursively(id: shapeID)
        }
        groups.removeAll { $0.allShapeIDs.isEmpty }
        pruneState()
    }

    mutating func updateShape(_ shape: AnyShape) {
        if let shapeIndex = shapes.firstIndex(where: { $0.id == shape.id }) {
            shapes[shapeIndex] = shape
        }
    }

    // MARK: - Group queries

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

    func findGroupByID(_ groupID: UUID) -> ShapeGroup? {
        for group in groups {
            if let found = group.findGroupByID(groupID) {
                return found
            }
        }
        return nil
    }

    func parentGroupID(of groupID: UUID) -> UUID? {
        func search(_ groups: [ShapeGroup]) -> UUID? {
            for group in groups {
                if group.children.contains(where: { $0.id == groupID }) {
                    return group.id
                }
                if let found = search(group.children) {
                    return found
                }
            }
            return nil
        }
        return search(groups)
    }

    mutating func insertSiblingGroup(_ newGroup: ShapeGroup, nextTo siblingID: UUID?) -> Bool {
        guard let siblingID else {
            groups.append(newGroup)
            return true
        }
        // Check root level
        if let index = groups.firstIndex(where: { $0.id == siblingID }) {
            groups.insert(newGroup, at: index + 1)
            return true
        }
        // Check nested levels
        for i in groups.indices {
            if groups[i].insertChildGroupNextTo(newGroup, siblingID: siblingID) {
                return true
            }
        }
        groups.append(newGroup)
        return true
    }

    func isShapeHidden(_ shapeID: UUID) -> Bool {
        if hiddenShapeIDs.contains(shapeID) {
            return true
        }
        return findGroupAncestry(containingShape: shapeID)
            .contains(where: { hiddenGroupIDs.contains($0.id) })
    }

    func isShapeLocked(_ shapeID: UUID) -> Bool {
        if lockedShapeIDs.contains(shapeID) {
            return true
        }
        return findGroupAncestry(containingShape: shapeID)
            .contains(where: { lockedGroupIDs.contains($0.id) })
    }

    func isShapeSelectable(_ shapeID: UUID) -> Bool {
        !isShapeHidden(shapeID) && !isShapeLocked(shapeID)
    }

    func isGroupHiddenEffectively(_ groupID: UUID) -> Bool {
        if hiddenGroupIDs.contains(groupID) {
            return true
        }
        return groupAncestorIDs(for: groupID).contains(where: { hiddenGroupIDs.contains($0) })
    }

    func isGroupLockedEffectively(_ groupID: UUID) -> Bool {
        if lockedGroupIDs.contains(groupID) {
            return true
        }
        return groupAncestorIDs(for: groupID).contains(where: { lockedGroupIDs.contains($0) })
    }

    mutating func setShapeHidden(_ shapeID: UUID, isHidden: Bool) {
        if isHidden {
            hiddenShapeIDs.insert(shapeID)
        } else {
            hiddenShapeIDs.remove(shapeID)
        }
    }

    mutating func setShapeLocked(_ shapeID: UUID, isLocked: Bool) {
        if isLocked {
            lockedShapeIDs.insert(shapeID)
        } else {
            lockedShapeIDs.remove(shapeID)
        }
    }

    mutating func setGroupHidden(_ groupID: UUID, isHidden: Bool) {
        if isHidden {
            hiddenGroupIDs.insert(groupID)
        } else {
            hiddenGroupIDs.remove(groupID)
        }
    }

    mutating func setGroupLocked(_ groupID: UUID, isLocked: Bool) {
        if isLocked {
            lockedGroupIDs.insert(groupID)
        } else {
            lockedGroupIDs.remove(groupID)
        }
    }

    mutating func pruneOrphanedVisibilityAndLockState() {
        pruneState()
    }

    mutating func removeShapesFromGroups(ids: Set<UUID>) {
        for index in groups.indices {
            groups[index].removeShapesRecursively(ids: ids)
        }
        groups.removeAll { $0.allShapeIDs.isEmpty }
        pruneState()
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

    // MARK: - Shape z-order

    @discardableResult
    mutating func moveShapeForward(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              shapeIndex < shapes.count - 1
        else { return false }
        shapes.swapAt(shapeIndex, shapeIndex + 1)
        return true
    }

    @discardableResult
    mutating func moveShapeBackward(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              shapeIndex > 0
        else { return false }
        shapes.swapAt(shapeIndex, shapeIndex - 1)
        return true
    }

    @discardableResult
    mutating func moveShapeToFront(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              shapeIndex < shapes.count - 1
        else { return false }

        let shape = shapes.remove(at: shapeIndex)
        shapes.append(shape)
        return true
    }

    @discardableResult
    mutating func moveShapeToBack(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              shapeIndex > 0
        else { return false }

        let shape = shapes.remove(at: shapeIndex)
        shapes.insert(shape, at: 0)
        return true
    }

    func canMoveShapeForward(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }
        return shapeIndex < shapes.count - 1
    }

    func canMoveShapeBackward(id shapeID: UUID) -> Bool {
        guard let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }
        return shapeIndex > 0
    }

    @discardableResult
    mutating func moveShape(id shapeID: UUID, before targetShapeID: UUID) -> Bool {
        guard shapeID != targetShapeID,
              shapes.contains(where: { $0.id == targetShapeID })
        else { return false }

        guard let sourceShapeIndex = shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }

        let shape = shapes.remove(at: sourceShapeIndex)
        guard let targetIndex = shapes.firstIndex(where: { $0.id == targetShapeID }) else {
            return false
        }
        shapes.insert(shape, at: targetIndex)
        return true
    }

    @discardableResult
    mutating func moveShape(id shapeID: UUID, after targetShapeID: UUID) -> Bool {
        guard shapeID != targetShapeID,
              shapes.contains(where: { $0.id == targetShapeID })
        else { return false }

        guard let sourceShapeIndex = shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }

        let shape = shapes.remove(at: sourceShapeIndex)
        guard let targetIndex = shapes.firstIndex(where: { $0.id == targetShapeID }) else {
            return false
        }
        shapes.insert(shape, at: targetIndex + 1)
        return true
    }

    // MARK: - Group z-order

    @discardableResult
    mutating func moveGroupForward(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              range.upperBound < shapes.count
        else { return false }

        let nextIndex = range.upperBound
        let nextShapeID = shapes[nextIndex].id
        if let nextGroup = findRootGroup(containingShape: nextShapeID),
           nextGroup.id != groupID,
           let nextGroupRange = groupShapeIndexRange(for: nextGroup.id)
        {
            let block = Array(shapes[range])
            shapes.removeSubrange(range)
            let insertAt = nextGroupRange.upperBound - range.count
            shapes.insert(contentsOf: block, at: insertAt)
        } else {
            let block = Array(shapes[range])
            shapes.removeSubrange(range)
            let insertAt = range.lowerBound + 1
            shapes.insert(contentsOf: block, at: insertAt)
        }
        return true
    }

    @discardableResult
    mutating func moveGroupBackward(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              range.lowerBound > 0
        else { return false }

        let prevIndex = range.lowerBound - 1
        let prevShapeID = shapes[prevIndex].id
        if let prevGroup = findRootGroup(containingShape: prevShapeID),
           prevGroup.id != groupID,
           let prevGroupRange = groupShapeIndexRange(for: prevGroup.id)
        {
            let block = Array(shapes[range])
            shapes.removeSubrange(range)
            shapes.insert(contentsOf: block, at: prevGroupRange.lowerBound)
        } else {
            let block = Array(shapes[range])
            shapes.removeSubrange(range)
            shapes.insert(contentsOf: block, at: range.lowerBound - 1)
        }
        return true
    }

    @discardableResult
    mutating func moveGroupToFront(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              range.upperBound < shapes.count
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)
        shapes.append(contentsOf: block)
        return true
    }

    @discardableResult
    mutating func moveGroupToBack(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              range.lowerBound > 0
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)
        shapes.insert(contentsOf: block, at: 0)
        return true
    }

    func canMoveGroupForward(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID)
        else { return false }
        return range.upperBound < shapes.count
    }

    func canMoveGroupBackward(groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID)
        else { return false }
        return range.lowerBound > 0
    }

    // MARK: - Within-group shape z-order

    @discardableResult
    mutating func moveShapeWithinGroup(id shapeID: UUID, forward: Bool, groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              range.contains(shapeIndex)
        else { return false }

        if forward {
            guard shapeIndex < range.upperBound - 1 else { return false }
            shapes.swapAt(shapeIndex, shapeIndex + 1)
        } else {
            guard shapeIndex > range.lowerBound else { return false }
            shapes.swapAt(shapeIndex, shapeIndex - 1)
        }
        return true
    }

    func canMoveShapeWithinGroup(id shapeID: UUID, forward: Bool, groupID: UUID) -> Bool {
        guard let range = groupShapeIndexRange(for: groupID),
              let shapeIndex = shapes.firstIndex(where: { $0.id == shapeID }),
              range.contains(shapeIndex)
        else { return false }

        if forward {
            return shapeIndex < range.upperBound - 1
        } else {
            return shapeIndex > range.lowerBound
        }
    }

    // MARK: - Group positional moves (drag-and-drop)

    @discardableResult
    mutating func moveGroup(groupID: UUID, beforeShape targetShapeID: UUID) -> Bool {
        guard let group = findGroupByID(groupID),
              !group.allShapeIDs.contains(targetShapeID),
              let range = groupShapeIndexRange(for: groupID)
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)

        guard let targetIndex = shapes.firstIndex(where: { $0.id == targetShapeID })
        else {
            shapes.insert(contentsOf: block, at: min(range.lowerBound, shapes.count))
            return false
        }
        shapes.insert(contentsOf: block, at: targetIndex)
        return true
    }

    @discardableResult
    mutating func moveGroup(groupID: UUID, afterShape targetShapeID: UUID) -> Bool {
        guard let group = findGroupByID(groupID),
              !group.allShapeIDs.contains(targetShapeID),
              let range = groupShapeIndexRange(for: groupID)
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)

        guard let targetIndex = shapes.firstIndex(where: { $0.id == targetShapeID })
        else {
            shapes.insert(contentsOf: block, at: min(range.lowerBound, shapes.count))
            return false
        }
        shapes.insert(contentsOf: block, at: targetIndex + 1)
        return true
    }

    @discardableResult
    mutating func moveGroup(groupID: UUID, beforeGroup targetGroupID: UUID) -> Bool {
        guard groupID != targetGroupID,
              let range = groupShapeIndexRange(for: groupID)
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)

        guard let targetRange = groupShapeIndexRange(for: targetGroupID)
        else { return false }
        shapes.insert(contentsOf: block, at: targetRange.lowerBound)
        return true
    }

    @discardableResult
    mutating func moveGroup(groupID: UUID, afterGroup targetGroupID: UUID) -> Bool {
        guard groupID != targetGroupID,
              let range = groupShapeIndexRange(for: groupID)
        else { return false }

        let block = Array(shapes[range])
        shapes.removeSubrange(range)

        guard let targetRange = groupShapeIndexRange(for: targetGroupID)
        else { return false }
        shapes.insert(contentsOf: block, at: targetRange.upperBound)
        return true
    }

    // MARK: - Marquee selection

    func shapesInRect(_ rect: GridRect) -> [AnyShape] {
        var result: [AnyShape] = []
        for shape in selectableShapes {
            if shape.boundingRect.intersects(rect) {
                result.append(shape)
            }
        }
        return result
    }

    // MARK: - Hit testing

    /// Hit-test in reverse render order (last shape first).
    func hitTest(at point: GridPoint) -> AnyShape? {
        // First, strict geometry hit-testing.
        for shape in selectableShapes.reversed() {
            if shape.contains(point: point) {
                return shape
            }
        }

        // Then, allow a small proximity pick radius for arrows to make selecting thin lines easier.
        for shape in selectableShapes.reversed() {
            guard case .arrow(let arrow) = shape else { continue }
            if isNearArrow(arrow, point: point, tolerance: 1.0) {
                return shape
            }
        }

        return nil
    }

    // MARK: - Bounding box

    /// Computes the bounding rect enclosing all shapes.
    func boundingBox() -> GridRect? {
        var minCol = Int.max
        var minRow = Int.max
        var maxCol = Int.min
        var maxRow = Int.min
        var found = false

        for shape in visibleShapes {
            let rect = shape.boundingRect
            minCol = min(minCol, rect.minColumn)
            minRow = min(minRow, rect.minRow)
            maxCol = max(maxCol, rect.maxColumn)
            maxRow = max(maxRow, rect.maxRow)
            found = true
        }

        guard found else { return nil }
        return GridRect(
            origin: GridPoint(column: minCol, row: minRow),
            size: GridSize(width: maxCol - minCol + 1, height: maxRow - minRow + 1)
        )
    }

    // MARK: - Rendering

    func render(into canvas: inout Canvas) {
        canvas.clear()
        for shape in visibleShapes {
            shape.render(into: &canvas)
        }
    }

    private func isNearArrow(_ arrow: ArrowShape, point: GridPoint, tolerance: Double) -> Bool {
        for segment in arrow.pathSegments() {
            if pointToSegmentDistance(point, segment: segment) <= tolerance {
                return true
            }
        }
        return false
    }

    private func pointToSegmentDistance(_ point: GridPoint, segment: ArrowSegment) -> Double {
        let px = Double(point.column)
        let py = Double(point.row)
        let x1 = Double(segment.from.column)
        let y1 = Double(segment.from.row)
        let x2 = Double(segment.to.column)
        let y2 = Double(segment.to.row)

        if x1 == x2 {
            let clampedY = min(max(py, min(y1, y2)), max(y1, y2))
            return hypot(px - x1, py - clampedY)
        }

        if y1 == y2 {
            let clampedX = min(max(px, min(x1, x2)), max(x1, x2))
            return hypot(px - clampedX, py - y1)
        }

        return .greatestFiniteMagnitude
    }

    private func groupAncestorIDs(for groupID: UUID) -> [UUID] {
        func pathToGroup(_ searchID: UUID, in groups: [ShapeGroup], path: [UUID]) -> [UUID]? {
            for group in groups {
                let nextPath = path + [group.id]
                if group.id == searchID {
                    return path
                }
                if let found = pathToGroup(searchID, in: group.children, path: nextPath) {
                    return found
                }
            }
            return nil
        }

        return pathToGroup(groupID, in: groups, path: []) ?? []
    }

    private mutating func pruneState() {
        let validShapeIDs = Set(shapes.map(\.id))
        hiddenShapeIDs = hiddenShapeIDs.intersection(validShapeIDs)
        lockedShapeIDs = lockedShapeIDs.intersection(validShapeIDs)

        let validGroupIDs = Set(flattenGroupIDs(from: groups))
        hiddenGroupIDs = hiddenGroupIDs.intersection(validGroupIDs)
        lockedGroupIDs = lockedGroupIDs.intersection(validGroupIDs)
    }

    private func flattenGroupIDs(from groups: [ShapeGroup]) -> [UUID] {
        var result: [UUID] = []
        for group in groups {
            result.append(group.id)
            result.append(contentsOf: flattenGroupIDs(from: group.children))
        }
        return result
    }
}

// MARK: - Legacy layer format for backward-compatible decoding

private struct LegacyLayer: Decodable {
    let shapes: [AnyShape]
    let groups: [ShapeGroup]

    private enum CodingKeys: String, CodingKey {
        case id, name, isVisible, isLocked, shapes, groups, backgroundColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shapes = try container.decode([AnyShape].self, forKey: .shapes)
        groups = try container.decodeIfPresent([ShapeGroup].self, forKey: .groups) ?? []
        // Ignore other fields (id, name, isVisible, isLocked, backgroundColor)
        _ = try? container.decode(UUID.self, forKey: .id)
        _ = try? container.decode(String.self, forKey: .name)
        _ = try? container.decode(Bool.self, forKey: .isVisible)
        _ = try? container.decode(Bool.self, forKey: .isLocked)
    }
}
