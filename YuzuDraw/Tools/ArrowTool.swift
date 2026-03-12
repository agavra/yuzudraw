import Foundation

final class ArrowTool: Tool, @unchecked Sendable {
    private static let attachmentSnapRadius: Double = 0.75
    private static let attachmentDisplayRadius: Double = 2.0

    private struct AttachPoint {
        let rectangle: RectangleShape
        let point: GridPoint
        let side: ArrowAttachmentSide
    }

    let toolType: ToolType = .arrow

    /// When true, attachment snapping is suppressed (e.g. Option key held).
    var suppressAttachment: Bool = false

    private var startPoint: GridPoint?
    private var startRectangle: RectangleShape?
    private var startAttachmentSide: ArrowAttachmentSide?
    private var currentPoint: GridPoint?
    private var previewArrow: ArrowShape?

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int) -> ToolAction {
        if suppressAttachment {
            startPoint = point
            startRectangle = nil
            startAttachmentSide = nil
        } else if let containingRectangle = rectangle(at: point, in: document),
                  let side = attachmentSide(at: point, on: containingRectangle) {
            let snapped = AttachPoint(
                rectangle: containingRectangle,
                point: containingRectangle.attachmentPoint(for: side),
                side: side
            )
            startPoint = snapped.point
            startRectangle = snapped.rectangle
            startAttachmentSide = snapped.side
        } else if let snapped = snappedAttachment(near: point, in: document) {
            startPoint = snapped.point
            startRectangle = snapped.rectangle
            startAttachmentSide = snapped.side
        } else {
            startPoint = point
            startRectangle = nil
            startAttachmentSide = nil
        }
        currentPoint = point
        previewArrow = nil
        return .none
    }

    func mouseDragged(to point: GridPoint, in document: Document, activeLayerIndex _: Int) -> ToolAction {
        currentPoint = point
        previewArrow = routedArrow(to: point, in: document)
        return .none
    }

    func mouseUp(at point: GridPoint, in document: Document, activeLayerIndex: Int) -> ToolAction {
        currentPoint = point

        guard let arrow = routedArrow(to: point, in: document) else {
            cancel()
            return .none
        }

        cancel()
        return .addShape(.arrow(arrow), layerIndex: activeLayerIndex)
    }

    func cancel() {
        startPoint = nil
        startRectangle = nil
        startAttachmentSide = nil
        currentPoint = nil
        previewArrow = nil
    }

    func previewShape() -> AnyShape? {
        guard let arrow = previewArrow else { return nil }
        return .arrow(arrow)
    }

    func attachmentPreviewPoints(near hoverPoint: GridPoint?, in document: Document) -> [GridPoint] {
        guard !suppressAttachment, let hoverPoint else { return [] }

        let allRectangles = document.layers
            .filter(\.isVisible)
            .flatMap(\.shapes)
            .compactMap { shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape else { return nil }
                return rectangle
            }

        if startPoint == nil {
            // Not drawing: show attachment points only for rectangles near the cursor.
            return allRectangles.filter { rectangle in
                nearestAttachmentDistance(from: hoverPoint, rectangle: rectangle) <= Self.attachmentDisplayRadius
            }.flatMap { rectangle in
                ArrowAttachmentSide.allCases.map { rectangle.attachmentPoint(for: $0) }
            }
        }

        // While drawing: show start rectangle + rectangles near the cursor.
        var rectanglesByID: [UUID: RectangleShape] = [:]
        if let startRectangle {
            rectanglesByID[startRectangle.id] = startRectangle
        }

        for rectangle in allRectangles where nearestAttachmentDistance(from: hoverPoint, rectangle: rectangle) <= Self.attachmentDisplayRadius {
            rectanglesByID[rectangle.id] = rectangle
        }

        return rectanglesByID.values.flatMap { rectangle in
            ArrowAttachmentSide.allCases.map { rectangle.attachmentPoint(for: $0) }
        }
    }

    private func routedArrow(to endPoint: GridPoint, in document: Document) -> ArrowShape? {
        guard let startPoint else { return nil }

        // For the end point, only snap to a rectangle if near an attachment point.
        let endSnapped: AttachPoint? = suppressAttachment ? nil : {
            // First check rectangles the cursor is inside of
            if let rect = rectangle(at: endPoint, in: document),
               let side = attachmentSide(at: endPoint, on: rect) {
                return AttachPoint(rectangle: rect, point: rect.attachmentPoint(for: side), side: side)
            }
            // Then check nearby attachment points
            return snappedAttachment(near: endPoint, in: document)
        }()
        let endRectangle = endSnapped?.rectangle

        let startTarget = endRectangle.map(\.boundingRect.centerPoint) ?? endPoint

        let startAttach = startRectangle.map { rectangle in
            if let startAttachmentSide {
                return AttachPoint(
                    rectangle: rectangle,
                    point: rectangle.attachmentPoint(for: startAttachmentSide),
                    side: startAttachmentSide
                )
            }
            return attachPoint(on: rectangle, toward: startTarget)
        }
        let endAttach = endSnapped

        let start = startAttach?.point ?? startPoint
        var end = endAttach?.point ?? endPoint

        // Freehand drags default to straight arrows along the dominant axis.
        if startAttach == nil, endAttach == nil {
            end = ArrowRouter.projectedFreeEnd(start: start, rawEnd: end)
        }

        guard start != end else { return nil }

        let bendDirection = ArrowRouter.bendDirection(
            start: start,
            end: end,
            startSide: startAttach?.side,
            endSide: endAttach?.side
        )

        return ArrowShape(
            start: start,
            end: end,
            bendDirection: bendDirection,
            startAttachment: startRectangle.map { ArrowAttachment(shapeID: $0.id, side: startAttach?.side ?? .right) },
            endAttachment: endRectangle.map { ArrowAttachment(shapeID: $0.id, side: endAttach?.side ?? .left) }
        )
    }

    private func rectangle(at point: GridPoint, in document: Document) -> RectangleShape? {
        guard case .rectangle(let rectangle) = document.hitTest(at: point) else {
            return nil
        }
        return rectangle
    }

    private func attachPoint(on rectangle: RectangleShape, toward target: GridPoint) -> AttachPoint {
        let rect = rectangle.boundingRect
        let center = rect.centerPoint
        let dx = target.column - center.column
        let dy = target.row - center.row

        if abs(dx) >= abs(dy) {
            if dx >= 0 {
                return AttachPoint(
                    rectangle: rectangle,
                    point: rectangle.attachmentPoint(for: .right),
                    side: .right
                )
            }
            return AttachPoint(
                rectangle: rectangle,
                point: rectangle.attachmentPoint(for: .left),
                side: .left
            )
        }

        if dy >= 0 {
            return AttachPoint(
                rectangle: rectangle,
                point: rectangle.attachmentPoint(for: .bottom),
                side: .bottom
            )
        }
        return AttachPoint(
            rectangle: rectangle,
            point: rectangle.attachmentPoint(for: .top),
            side: .top
        )
    }

    private func attachmentSide(at point: GridPoint, on rectangle: RectangleShape) -> ArrowAttachmentSide? {
        var bestSide: ArrowAttachmentSide?
        var bestDistance = Double.greatestFiniteMagnitude

        for side in ArrowAttachmentSide.allCases {
            let attachPoint = rectangle.attachmentPoint(for: side)
            let distance = hypot(
                Double(attachPoint.column - point.column),
                Double(attachPoint.row - point.row)
            )
            guard distance <= Self.attachmentSnapRadius else { continue }
            if distance < bestDistance {
                bestDistance = distance
                bestSide = side
            }
        }

        return bestSide
    }

    private func snappedAttachment(near point: GridPoint, in document: Document) -> AttachPoint? {
        var best: AttachPoint?
        var bestDistance = Double.greatestFiniteMagnitude

        for layer in document.layers where layer.isVisible {
            for shape in layer.shapes {
                guard case .rectangle(let rectangle) = shape else { continue }
                for side in ArrowAttachmentSide.allCases {
                    let attachPoint = rectangle.attachmentPoint(for: side)
                    let distance = hypot(
                        Double(attachPoint.column - point.column),
                        Double(attachPoint.row - point.row)
                    )
                    guard distance <= Self.attachmentSnapRadius else { continue }
                    if distance < bestDistance {
                        bestDistance = distance
                        best = AttachPoint(rectangle: rectangle, point: attachPoint, side: side)
                    }
                }
            }
        }

        return best
    }

    private func nearestAttachmentDistance(from point: GridPoint, rectangle: RectangleShape) -> Double {
        ArrowAttachmentSide.allCases.map { side in
            let ap = rectangle.attachmentPoint(for: side)
            return hypot(Double(point.column - ap.column), Double(point.row - ap.row))
        }.min() ?? .greatestFiniteMagnitude
    }

}

private extension GridRect {
    var centerPoint: GridPoint {
        GridPoint(
            column: minColumn + size.width / 2,
            row: minRow + size.height / 2
        )
    }
}
