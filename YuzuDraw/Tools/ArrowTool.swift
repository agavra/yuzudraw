import Foundation

final class ArrowTool: Tool, @unchecked Sendable {
    private static let attachmentSnapRadius: Double = 1.5
    private static let attachmentDisplayRadius: Double = 3.0

    private struct AttachPoint {
        let box: BoxShape
        let point: GridPoint
        let side: ArrowAttachmentSide
    }

    let toolType: ToolType = .arrow

    /// When true, attachment snapping is suppressed (e.g. Option key held).
    var suppressAttachment: Bool = false

    private var startPoint: GridPoint?
    private var startBox: BoxShape?
    private var startAttachmentSide: ArrowAttachmentSide?
    private var currentPoint: GridPoint?
    private var previewArrow: ArrowShape?

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int) -> ToolAction {
        if suppressAttachment {
            startPoint = point
            startBox = nil
            startAttachmentSide = nil
        } else if let containingBox = box(at: point, in: document) {
            if let side = attachmentSide(at: point, on: containingBox) {
                let snapped = AttachPoint(
                    box: containingBox,
                    point: containingBox.attachmentPoint(for: side),
                    side: side
                )
                startPoint = snapped.point
                startBox = snapped.box
                startAttachmentSide = snapped.side
            } else {
                startPoint = point
                startBox = containingBox
                startAttachmentSide = nil
            }
        } else if let snapped = snappedAttachment(near: point, in: document) {
            startPoint = snapped.point
            startBox = snapped.box
            startAttachmentSide = snapped.side
        } else {
            startPoint = point
            startBox = nil
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
        startBox = nil
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

        let allBoxes = document.layers
            .filter(\.isVisible)
            .flatMap(\.shapes)
            .compactMap { shape -> BoxShape? in
                guard case .box(let box) = shape else { return nil }
                return box
            }

        if startPoint == nil {
            // Not drawing: show attachment points only for boxes near the cursor.
            return allBoxes.filter { box in
                nearestAttachmentDistance(from: hoverPoint, box: box) <= Self.attachmentDisplayRadius
            }.flatMap { box in
                ArrowAttachmentSide.allCases.map { box.attachmentPoint(for: $0) }
            }
        }

        // While drawing: show start box + boxes near the cursor.
        var boxesByID: [UUID: BoxShape] = [:]
        if let startBox {
            boxesByID[startBox.id] = startBox
        }

        for box in allBoxes where nearestAttachmentDistance(from: hoverPoint, box: box) <= Self.attachmentDisplayRadius {
            boxesByID[box.id] = box
        }

        return boxesByID.values.flatMap { box in
            ArrowAttachmentSide.allCases.map { box.attachmentPoint(for: $0) }
        }
    }

    private func routedArrow(to endPoint: GridPoint, in document: Document) -> ArrowShape? {
        guard let startPoint else { return nil }

        let containingEndBox = suppressAttachment ? nil : box(at: endPoint, in: document)
        let snappedEnd = containingEndBox == nil && !suppressAttachment ? snappedAttachment(near: endPoint, in: document) : nil
        let endBox = containingEndBox ?? snappedEnd?.box

        let endTarget = startBox.map(\.boundingRect.centerPoint) ?? startPoint
        let startTarget = endBox.map(\.boundingRect.centerPoint) ?? endPoint

        let startAttach = startBox.map { box in
            if let startAttachmentSide {
                return AttachPoint(
                    box: box,
                    point: box.attachmentPoint(for: startAttachmentSide),
                    side: startAttachmentSide
                )
            }
            return attachPoint(on: box, toward: startTarget)
        }
        let endAttach = endBox.map { box in
            if let snappedEnd, snappedEnd.box.id == box.id {
                return snappedEnd
            }
            if let side = attachmentSide(at: endPoint, on: box) {
                return AttachPoint(box: box, point: box.attachmentPoint(for: side), side: side)
            }
            return attachPoint(on: box, toward: endTarget)
        }

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
            startAttachment: startBox.map { ArrowAttachment(shapeID: $0.id, side: startAttach?.side ?? .right) },
            endAttachment: endBox.map { ArrowAttachment(shapeID: $0.id, side: endAttach?.side ?? .left) }
        )
    }

    private func box(at point: GridPoint, in document: Document) -> BoxShape? {
        guard case .box(let box) = document.hitTest(at: point) else {
            return nil
        }
        return box
    }

    private func attachPoint(on box: BoxShape, toward target: GridPoint) -> AttachPoint {
        let rect = box.boundingRect
        let center = rect.centerPoint
        let dx = target.column - center.column
        let dy = target.row - center.row

        if abs(dx) >= abs(dy) {
            if dx >= 0 {
                return AttachPoint(
                    box: box,
                    point: box.attachmentPoint(for: .right),
                    side: .right
                )
            }
            return AttachPoint(
                box: box,
                point: box.attachmentPoint(for: .left),
                side: .left
            )
        }

        if dy >= 0 {
            return AttachPoint(
                box: box,
                point: box.attachmentPoint(for: .bottom),
                side: .bottom
            )
        }
        return AttachPoint(
            box: box,
            point: box.attachmentPoint(for: .top),
            side: .top
        )
    }

    private func attachmentSide(at point: GridPoint, on box: BoxShape) -> ArrowAttachmentSide? {
        var bestSide: ArrowAttachmentSide?
        var bestDistance = Double.greatestFiniteMagnitude

        for side in ArrowAttachmentSide.allCases {
            let attachPoint = box.attachmentPoint(for: side)
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
                guard case .box(let box) = shape else { continue }
                for side in ArrowAttachmentSide.allCases {
                    let attachPoint = box.attachmentPoint(for: side)
                    let distance = hypot(
                        Double(attachPoint.column - point.column),
                        Double(attachPoint.row - point.row)
                    )
                    guard distance <= Self.attachmentSnapRadius else { continue }
                    if distance < bestDistance {
                        bestDistance = distance
                        best = AttachPoint(box: box, point: attachPoint, side: side)
                    }
                }
            }
        }

        return best
    }

    private func nearestAttachmentDistance(from point: GridPoint, box: BoxShape) -> Double {
        ArrowAttachmentSide.allCases.map { side in
            let ap = box.attachmentPoint(for: side)
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
