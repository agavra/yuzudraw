import Foundation

struct Document: Codable, Equatable, Sendable {
    var layers: [Layer]
    var canvasSize: GridSize

    init(
        layers: [Layer] = [Layer(name: "Layer 1")],
        canvasSize: GridSize = GridSize(width: Canvas.defaultColumns, height: Canvas.defaultRows)
    ) {
        self.layers = layers
        self.canvasSize = canvasSize
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
        guard layers.indices.contains(layerIndex) else { return }
        layers[layerIndex].addShape(shape)
    }

    mutating func removeShape(id shapeID: UUID) {
        for index in layers.indices {
            layers[index].removeShape(id: shapeID)
        }
    }

    mutating func updateShape(_ shape: AnyShape) {
        for layerIndex in layers.indices {
            if let shapeIndex = layers[layerIndex].shapes.firstIndex(where: { $0.id == shape.id })
            {
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
    func hitTest(at point: GridPoint) -> AnyShape? {
        // First, strict geometry hit-testing.
        for layer in layers.reversed() {
            guard layer.isVisible else { continue }
            for shape in layer.shapes.reversed() {
                if shape.contains(point: point) {
                    return shape
                }
            }
        }

        // Then, allow a small proximity pick radius for arrows to make selecting thin lines easier.
        for layer in layers.reversed() {
            guard layer.isVisible else { continue }
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
