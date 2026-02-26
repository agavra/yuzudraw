import Foundation

final class ArrowTool: Tool, @unchecked Sendable {
    private static let attachmentSnapRadius: Double = 1.5

    private struct AttachPoint {
        let box: BoxShape
        let point: GridPoint
        let side: ArrowAttachmentSide
    }

    let toolType: ToolType = .arrow

    private var startPoint: GridPoint?
    private var startBox: BoxShape?
    private var startAttachmentSide: ArrowAttachmentSide?
    private var currentPoint: GridPoint?
    private var previewArrow: ArrowShape?

    func mouseDown(at point: GridPoint, in document: Document, activeLayerIndex _: Int) -> ToolAction {
        if let containingBox = box(at: point, in: document) {
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

    func attachmentPreviewPoints(in document: Document) -> [GridPoint] {
        // When not drawing, show all visible box attachment points to hint valid termini.
        if startPoint == nil {
            return document.layers
                .filter(\.isVisible)
                .flatMap(\.shapes)
                .compactMap { shape -> BoxShape? in
                    guard case .box(let box) = shape else { return nil }
                    return box
                }
                .flatMap { box in
                    ArrowAttachmentSide.allCases.map { box.attachmentPoint(for: $0) }
                }
        }

        var boxesByID: [UUID: BoxShape] = [:]
        if let startBox {
            boxesByID[startBox.id] = startBox
        }

        if let currentPoint, let endBox = box(at: currentPoint, in: document) {
            boxesByID[endBox.id] = endBox
        }

        return boxesByID.values.flatMap { box in
            ArrowAttachmentSide.allCases.map { box.attachmentPoint(for: $0) }
        }
    }

    private func routedArrow(to endPoint: GridPoint, in document: Document) -> ArrowShape? {
        guard let startPoint else { return nil }

        let containingEndBox = box(at: endPoint, in: document)
        let snappedEnd = containingEndBox == nil ? snappedAttachment(near: endPoint, in: document) : nil
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

}

private extension GridRect {
    var centerPoint: GridPoint {
        GridPoint(
            column: minColumn + size.width / 2,
            row: minRow + size.height / 2
        )
    }
}
