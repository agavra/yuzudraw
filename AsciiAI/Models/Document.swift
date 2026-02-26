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

    // MARK: - Hit testing

    /// Hit-test in reverse render order (top layer first, last shape first).
    func hitTest(at point: GridPoint) -> AnyShape? {
        for layer in layers.reversed() {
            guard layer.isVisible else { continue }
            for shape in layer.shapes.reversed() {
                if shape.contains(point: point) {
                    return shape
                }
            }
        }
        return nil
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
}
