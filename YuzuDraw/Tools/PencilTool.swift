import Foundation

final class PencilTool: Tool, @unchecked Sendable {
    let toolType: ToolType = .pencil

    var drawCharacter: Character = "*"
    var drawColor: ShapeColor?

    /// When set, new strokes append cells into the existing shape with this ID.
    var targetShapeID: UUID?

    private var currentShape: PencilShape?
    private var lastPoint: GridPoint?
    private var isAppending = false
    private var activeLayerIndexAtStart: Int = 0

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex: Int) -> ToolAction {
        activeLayerIndexAtStart = activeLayerIndex
        lastPoint = point

        if let targetID = targetShapeID,
            let existingShape = document.findShape(id: targetID),
            case .pencil(var pencil) = existingShape
        {
            // Appending to existing shape
            isAppending = true
            pencil.addCell(PencilCell(character: drawCharacter, color: drawColor), at: point)
            currentShape = pencil
        } else {
            // New shape
            isAppending = false
            var shape = PencilShape(origin: point)
            shape.cells[GridPoint(column: 0, row: 0)] = PencilCell(
                character: drawCharacter, color: drawColor)
            currentShape = shape
        }

        return .none
    }

    func mouseDragged(to point: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        guard var shape = currentShape, let last = lastPoint else { return .none }

        let interpolated = Self.bresenhamLine(from: last, to: point)
        for p in interpolated {
            shape.addCell(PencilCell(character: drawCharacter, color: drawColor), at: p)
        }

        currentShape = shape
        lastPoint = point
        return .none
    }

    func mouseUp(at point: GridPoint, in _: Document, activeLayerIndex _: Int) -> ToolAction {
        guard var shape = currentShape, let last = lastPoint else {
            cancel()
            return .none
        }

        // Add final interpolation
        let interpolated = Self.bresenhamLine(from: last, to: point)
        for p in interpolated {
            shape.addCell(PencilCell(character: drawCharacter, color: drawColor), at: p)
        }

        let result: ToolAction
        if isAppending {
            result = .updateShape(.pencil(shape))
        } else {
            result = .addShape(.pencil(shape), layerIndex: activeLayerIndexAtStart)
        }

        cancel()
        return result
    }

    func cancel() {
        currentShape = nil
        lastPoint = nil
        isAppending = false
    }

    func previewShape() -> AnyShape? {
        guard let shape = currentShape else { return nil }
        return .pencil(shape)
    }

    // MARK: - Bresenham line interpolation

    /// Returns all points from `from` to `to` (excluding `from`, including `to`).
    static func bresenhamLine(from start: GridPoint, to end: GridPoint) -> [GridPoint] {
        guard start != end else { return [] }

        var points: [GridPoint] = []
        var x0 = start.column
        var y0 = start.row
        let x1 = end.column
        let y1 = end.row

        let dx = abs(x1 - x0)
        let dy = -abs(y1 - y0)
        let sx = x0 < x1 ? 1 : -1
        let sy = y0 < y1 ? 1 : -1
        var err = dx + dy

        while true {
            if x0 == x1 && y0 == y1 {
                points.append(GridPoint(column: x0, row: y0))
                break
            }
            let e2 = 2 * err
            if e2 >= dy {
                err += dy
                x0 += sx
            }
            if e2 <= dx {
                err += dx
                y0 += sy
            }
            points.append(GridPoint(column: x0, row: y0))
        }

        return points
    }
}
