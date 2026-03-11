import Foundation

struct Document: Codable, Equatable, Sendable {
    var layers: [Layer]
    var canvasSize: GridSize
    var palette: ColorPalette

    private enum CodingKeys: String, CodingKey {
        case layers
        case canvasSize
        case palette
    }

    init(
        layers: [Layer] = [Layer(name: "Layer 1")],
        canvasSize: GridSize = GridSize(width: Canvas.defaultColumns, height: Canvas.defaultRows),
        palette: ColorPalette = .default
    ) {
        self.layers = layers
        self.canvasSize = canvasSize
        self.palette = palette
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        layers = try container.decode([Layer].self, forKey: .layers)
        canvasSize = try container.decode(GridSize.self, forKey: .canvasSize)
        palette = try container.decodeIfPresent(ColorPalette.self, forKey: .palette) ?? .default
    }

    var hasContent: Bool {
        layers.contains { !$0.shapes.isEmpty }
    }

    // MARK: - Shape queries

    func findShape(id shapeID: UUID) -> AnyShape? {
        for layer in layers {
            if let shape = layer.findShape(id: shapeID) {
                return shape
            }
        }
        return nil
    }

    func layerIndex(containingShape shapeID: UUID) -> Int? {
        layers.firstIndex { layer in
            layer.shapes.contains { $0.id == shapeID }
        }
    }

    // MARK: - Shape mutations

    mutating func addShape(_ shape: AnyShape, toLayerAt layerIndex: Int) {
        guard layers.indices.contains(layerIndex), !layers[layerIndex].isLocked else { return }
        layers[layerIndex].addShape(shape)
    }

    mutating func removeShape(id shapeID: UUID) {
        for index in layers.indices {
            if layers[index].isLocked { continue }
            layers[index].removeShape(id: shapeID)
        }
    }

    mutating func updateShape(_ shape: AnyShape) {
        for layerIndex in layers.indices {
            if let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shape.id })
            {
                guard !layers[layerIndex].isLocked else { return }
                layers[layerIndex].shapes[shapeIndex] = shape
                return
            }
        }
    }

    // MARK: - Layer mutations

    mutating func addLayer(name: String) {
        layers.append(Layer(name: name))
    }

    mutating func removeLayer(at index: Int) {
        guard layers.indices.contains(index), layers.count > 1 else { return }
        layers.remove(at: index)
    }

    @discardableResult
    mutating func moveLayerUp(at index: Int) -> Bool {
        guard layers.indices.contains(index), index < layers.count - 1 else { return false }
        layers.swapAt(index, index + 1)
        return true
    }

    @discardableResult
    mutating func moveLayerDown(at index: Int) -> Bool {
        guard layers.indices.contains(index), index > 0 else { return false }
        layers.swapAt(index, index - 1)
        return true
    }

    @discardableResult
    mutating func moveShapeForward(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID }),
            shapeIndex < layers[layerIndex].shapes.count - 1
        else { return false }
        layers[layerIndex].shapes.swapAt(shapeIndex, shapeIndex + 1)
        return true
    }

    @discardableResult
    mutating func moveShapeBackward(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID }),
            shapeIndex > 0
        else { return false }
        layers[layerIndex].shapes.swapAt(shapeIndex, shapeIndex - 1)
        return true
    }

    @discardableResult
    mutating func moveShapeToFront(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID }),
            shapeIndex < layers[layerIndex].shapes.count - 1
        else { return false }

        let shape = layers[layerIndex].shapes.remove(at: shapeIndex)
        layers[layerIndex].shapes.append(shape)
        return true
    }

    @discardableResult
    mutating func moveShapeToBack(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID }),
            shapeIndex > 0
        else { return false }

        let shape = layers[layerIndex].shapes.remove(at: shapeIndex)
        layers[layerIndex].shapes.insert(shape, at: 0)
        return true
    }

    @discardableResult
    mutating func moveLayer(id layerID: UUID, before targetLayerID: UUID) -> Bool {
        guard layerID != targetLayerID,
            let sourceIndex = layers.firstIndex(where: { $0.id == layerID }),
            layers.contains(where: { $0.id == targetLayerID })
        else { return false }

        let layer = layers.remove(at: sourceIndex)
        guard let targetIndex = layers.firstIndex(where: { $0.id == targetLayerID }) else { return false }
        let insertionIndex = targetIndex
        layers.insert(layer, at: insertionIndex)
        return true
    }

    @discardableResult
    mutating func moveShape(id shapeID: UUID, before targetShapeID: UUID, in layerID: UUID) -> Bool {
        guard shapeID != targetShapeID,
            let targetLayerIndex = layers.firstIndex(where: { $0.id == layerID }),
            !layers[targetLayerIndex].isLocked,
            layers[targetLayerIndex].shapes.contains(where: { $0.id == targetShapeID })
        else { return false }

        guard let sourceLayerIndex = layerIndex(containingShape: shapeID),
            !layers[sourceLayerIndex].isLocked,
            let sourceShapeIndex = layers[sourceLayerIndex].shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }

        let shape = layers[sourceLayerIndex].shapes.remove(at: sourceShapeIndex)
        if sourceLayerIndex != targetLayerIndex {
            layers[sourceLayerIndex].removeShapesFromGroups(ids: [shapeID])
        }
        guard let targetIndex = layers[targetLayerIndex].shapes.firstIndex(where: { $0.id == targetShapeID }) else {
            return false
        }
        let insertionIndex = targetIndex
        layers[targetLayerIndex].shapes.insert(shape, at: insertionIndex)
        return true
    }

    @discardableResult
    mutating func moveLayer(id layerID: UUID, after targetLayerID: UUID) -> Bool {
        guard layerID != targetLayerID,
            let sourceIndex = layers.firstIndex(where: { $0.id == layerID }),
            layers.contains(where: { $0.id == targetLayerID })
        else { return false }

        let layer = layers.remove(at: sourceIndex)
        guard let targetIndex = layers.firstIndex(where: { $0.id == targetLayerID }) else { return false }
        layers.insert(layer, at: targetIndex + 1)
        return true
    }

    @discardableResult
    mutating func moveShape(id shapeID: UUID, after targetShapeID: UUID, in layerID: UUID) -> Bool {
        guard shapeID != targetShapeID,
            let targetLayerIndex = layers.firstIndex(where: { $0.id == layerID }),
            !layers[targetLayerIndex].isLocked,
            layers[targetLayerIndex].shapes.contains(where: { $0.id == targetShapeID })
        else { return false }

        guard let sourceLayerIndex = layerIndex(containingShape: shapeID),
            !layers[sourceLayerIndex].isLocked,
            let sourceShapeIndex = layers[sourceLayerIndex].shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }

        let shape = layers[sourceLayerIndex].shapes.remove(at: sourceShapeIndex)
        if sourceLayerIndex != targetLayerIndex {
            layers[sourceLayerIndex].removeShapesFromGroups(ids: [shapeID])
        }
        guard let targetIndex = layers[targetLayerIndex].shapes.firstIndex(where: { $0.id == targetShapeID }) else {
            return false
        }
        layers[targetLayerIndex].shapes.insert(shape, at: targetIndex + 1)
        return true
    }

    @discardableResult
    mutating func moveShape(id shapeID: UUID, toLayer targetLayerID: UUID) -> Bool {
        guard let sourceLayerIndex = layerIndex(containingShape: shapeID),
            let targetLayerIndex = layers.firstIndex(where: { $0.id == targetLayerID }),
            !layers[sourceLayerIndex].isLocked,
            !layers[targetLayerIndex].isLocked,
            let shape = findShape(id: shapeID)
        else { return false }

        layers[sourceLayerIndex].removeShape(id: shapeID)
        layers[targetLayerIndex].addShape(shape)
        return true
    }

    func canMoveShapeForward(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }
        return shapeIndex < layers[layerIndex].shapes.count - 1
    }

    func canMoveShapeBackward(id shapeID: UUID) -> Bool {
        guard let layerIndex = layerIndex(containingShape: shapeID),
            !layers[layerIndex].isLocked,
            let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shapeID })
        else { return false }
        return shapeIndex > 0
    }

    // MARK: - Marquee selection

    func shapesInRect(_ rect: GridRect, excludingLockedLayers: Bool) -> [AnyShape] {
        var result: [AnyShape] = []
        for layer in layers {
            guard layer.isVisible else { continue }
            if excludingLockedLayers && layer.isLocked { continue }
            for shape in layer.shapes {
                if shape.boundingRect.intersects(rect) {
                    result.append(shape)
                }
            }
        }
        return result
    }

    // MARK: - Hit testing

    /// Hit-test in reverse render order (top layer first, last shape first).
    func hitTest(at point: GridPoint, excludingLockedLayers: Bool = false) -> AnyShape? {
        // First, strict geometry hit-testing.
        for layer in layers.reversed() {
            guard layer.isVisible else { continue }
            if excludingLockedLayers && layer.isLocked { continue }
            for shape in layer.shapes.reversed() {
                if shape.contains(point: point) {
                    return shape
                }
            }
        }

        // Then, allow a small proximity pick radius for arrows to make selecting thin lines easier.
        for layer in layers.reversed() {
            guard layer.isVisible else { continue }
            if excludingLockedLayers && layer.isLocked { continue }
            for shape in layer.shapes.reversed() {
                guard case .arrow(let arrow) = shape else { continue }
                if isNearArrow(arrow, point: point, tolerance: 1.0) {
                    return shape
                }
            }
        }

        return nil
    }

    // MARK: - Bounding box

    /// Computes the bounding rect enclosing all shapes across all layers.
    func boundingBox() -> GridRect? {
        var minCol = Int.max
        var minRow = Int.max
        var maxCol = Int.min
        var maxRow = Int.min
        var found = false

        for layer in layers {
            for shape in layer.shapes {
                let rect = shape.boundingRect
                minCol = min(minCol, rect.minColumn)
                minRow = min(minRow, rect.minRow)
                maxCol = max(maxCol, rect.maxColumn)
                maxRow = max(maxRow, rect.maxRow)
                found = true
            }
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
        for layer in layers {
            guard layer.isVisible else { continue }
            for shape in layer.shapes {
                shape.render(into: &canvas)
            }
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
}
