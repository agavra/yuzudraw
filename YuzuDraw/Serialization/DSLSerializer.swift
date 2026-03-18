import Foundation

enum DSLSerializer {
    static func serialize(_ document: Document) -> String {
        let allShapes = document.shapes
        var lines: [String] = []

        // Walk shapes in z-order, emitting each group block when its first member is encountered
        let groupedIDs = document.groupedShapeIDs
        var emittedGroupIDs = Set<UUID>()

        for shape in document.shapes {
            if groupedIDs.contains(shape.id) {
                // Find the root group containing this shape
                guard let rootGroup = document.findRootGroup(containingShape: shape.id),
                      !emittedGroupIDs.contains(rootGroup.id)
                else { continue }
                emittedGroupIDs.insert(rootGroup.id)
                serializeGroup(
                    rootGroup,
                    document: document,
                    allShapes: allShapes,
                    indent: 2,
                    parentOrigin: .zero,
                    lines: &lines
                )
            } else {
                lines.append("  \(serializeShape(shape, allShapes: allShapes, scopeOrigin: .zero))")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func serializeGroup(
        _ group: ShapeGroup, document: Document, allShapes: [AnyShape], indent: Int,
        parentOrigin: GridPoint,
        lines: inout [String]
    ) {
        let pad = String(repeating: " ", count: indent)
        let effectiveOrigin = group.origin ?? parentOrigin
        var groupLine = "\(pad)group \"\(group.name)\""
        if let identifier = group.identifier {
            groupLine += " id \(identifier)"
        }
        if let origin = group.origin {
            let relativeOrigin = origin - parentOrigin
            groupLine += " at \(relativeOrigin.column),\(relativeOrigin.row)"
        }
        lines.append(groupLine)

        // Nested child groups
        for child in group.children {
            serializeGroup(
                child,
                document: document,
                allShapes: allShapes,
                indent: indent + 2,
                parentOrigin: effectiveOrigin,
                lines: &lines
            )
        }

        // Direct shape members
        let shapePad = String(repeating: " ", count: indent + 2)
        for shapeID in group.shapeIDs {
            if let shape = document.findShape(id: shapeID) {
                lines.append(
                    "\(shapePad)\(serializeShape(shape, allShapes: allShapes, scopeOrigin: effectiveOrigin))"
                )
            }
        }
    }

    private static func serializeShape(
        _ shape: AnyShape,
        allShapes: [AnyShape],
        scopeOrigin: GridPoint
    ) -> String {
        switch shape {
        case .rectangle(let rectangle):
            return serializeRectangle(rectangle, scopeOrigin: scopeOrigin)
        case .arrow(let arrow):
            return serializeArrow(arrow, allShapes: allShapes, scopeOrigin: scopeOrigin)
        case .text(let text):
            return serializeText(text, scopeOrigin: scopeOrigin)
        case .pencil(let pencil):
            return serializePencil(pencil, scopeOrigin: scopeOrigin)
        }
    }

    private static func serializeRectangle(_ rectangle: RectangleShape, scopeOrigin: GridPoint) -> String {
        let escapedLabel = rectangle.label.replacingOccurrences(of: "\n", with: "\\n")
        var result = "rect \"\(escapedLabel)\""

        // Emit ID if set
        if let name = rectangle.name {
            result += " id \(name)"
        }

        let relativeOrigin = rectangle.origin - scopeOrigin
        result +=
            " at \(relativeOrigin.column),\(relativeOrigin.row) size \(rectangle.size.width)x\(rectangle.size.height)"

        // Style: omit when default (single)
        if rectangle.strokeStyle != .single {
            result += " style \(rectangle.strokeStyle.rawValue)"
        }

        // Fill: omit when default (none)
        switch rectangle.fillMode {
        case .none:
            break
        case .opaque:
            result += " fill opaque"
        case .block:
            result += " fill block char \"\(String(rectangle.fillCharacter))\""
        case .character:
            result += " fill character char \"\(String(rectangle.fillCharacter))\""
        }

        // Border: omit when default (visible), use noborder shorthand
        if !rectangle.hasBorder {
            result += " noborder"
        } else {
            if rectangle.visibleBorders != Set(RectangleBorderSide.allCases) {
                let sideOrder: [RectangleBorderSide] = [.top, .bottom, .right, .left]
                let encodedSides = sideOrder
                    .filter { rectangle.visibleBorders.contains($0) }
                    .map(\.rawValue)
                    .joined(separator: ",")
                result += " borders \(encodedSides)"
            }
        }

        if rectangle.borderLineStyle == .dashed {
            result +=
                " line dashed dash \(rectangle.borderDashLength) gap \(rectangle.borderGapLength)"
        }

        // Alignment: omit when default (center/middle)
        if rectangle.textHorizontalAlignment != .center {
            result += " halign \(rectangle.textHorizontalAlignment.rawValue)"
        }
        if rectangle.textVerticalAlignment != .middle {
            result += " valign \(rectangle.textVerticalAlignment.rawValue)"
        }

        // textOnBorder: omit when false (default), emit bare flag when true
        if rectangle.allowTextOnBorder {
            result += " textOnBorder"
        }

        // Padding: omit when all zeros
        if rectangle.textPaddingLeft != 0 || rectangle.textPaddingRight != 0
            || rectangle.textPaddingTop != 0 || rectangle.textPaddingBottom != 0
        {
            result +=
                " padding \(rectangle.textPaddingLeft),\(rectangle.textPaddingRight),\(rectangle.textPaddingTop),\(rectangle.textPaddingBottom)"
        }

        if rectangle.hasShadow {
            result +=
                " shadow \(rectangle.shadowStyle.rawValue) x \(rectangle.shadowOffsetX) y \(rectangle.shadowOffsetY)"
        }
        if let borderColor = rectangle.borderColor {
            result += " borderColor \(borderColor.hexString)"
        }
        if let fillColor = rectangle.fillColor {
            result += " fillColor \(fillColor.hexString)"
        }
        if let textColor = rectangle.textColor {
            result += " textColor \(textColor.hexString)"
        }
        if rectangle.float {
            result += " float"
        }
        return result
    }

    private static func serializeArrow(
        _ arrow: ArrowShape,
        allShapes: [AnyShape],
        scopeOrigin: GridPoint
    ) -> String {
        let startStr = serializeEndpoint(
            point: arrow.start,
            attachment: arrow.startAttachment,
            allShapes: allShapes,
            scopeOrigin: scopeOrigin
        )
        let endStr = serializeEndpoint(
            point: arrow.end,
            attachment: arrow.endAttachment,
            allShapes: allShapes,
            scopeOrigin: scopeOrigin
        )

        var result = "arrow from \(startStr) to \(endStr)"

        // Style: omit when default (single)
        if arrow.strokeStyle != .single {
            result += " style \(arrow.strokeStyle.rawValue)"
        }

        if !arrow.label.isEmpty {
            let escapedLabel = arrow.label.replacingOccurrences(of: "\n", with: "\\n")
            result += " label \"\(escapedLabel)\""
        }
        if let strokeColor = arrow.strokeColor {
            result += " strokeColor \(strokeColor.hexString)"
        }
        if let labelColor = arrow.labelColor {
            result += " labelColor \(labelColor.hexString)"
        }
        if arrow.float {
            result += " float"
        }
        return result
    }

    private static func serializeEndpoint(
        point: GridPoint,
        attachment: ArrowAttachment?,
        allShapes: [AnyShape],
        scopeOrigin: GridPoint
    ) -> String {
        if let attachment,
            let rectangle = findRectangleByID(attachment.shapeID, in: allShapes)
        {
            let ref = rectangle.name ?? rectangle.label.replacingOccurrences(of: "\n", with: "\\n")
            return "\"\(ref)\".\(attachment.side.rawValue)"
        }
        let relativePoint = point - scopeOrigin
        return "\(relativePoint.column),\(relativePoint.row)"
    }

    private static func findRectangleByID(_ id: UUID, in shapes: [AnyShape]) -> RectangleShape? {
        for shape in shapes {
            if case .rectangle(let rectangle) = shape, rectangle.id == id {
                return rectangle
            }
        }
        return nil
    }

    private static func serializeText(_ text: TextShape, scopeOrigin: GridPoint) -> String {
        let escaped = text.text.replacingOccurrences(of: "\n", with: "\\n")
        let relativeOrigin = text.origin - scopeOrigin
        var result = "text \"\(escaped)\" at \(relativeOrigin.column),\(relativeOrigin.row)"
        if let textColor = text.textColor {
            result += " textColor \(textColor.hexString)"
        }
        return result
    }

    private static func serializePencil(_ pencil: PencilShape, scopeOrigin: GridPoint) -> String {
        let relativeOrigin = pencil.origin - scopeOrigin
        var result =
            "pencil at \(relativeOrigin.column),\(relativeOrigin.row)"
        let sortedCells = pencil.cells.sorted {
            ($0.key.row, $0.key.column) < ($1.key.row, $1.key.column)
        }
        var cellParts: [String] = []
        for (offset, cell) in sortedCells {
            var part = "\(offset.column),\(offset.row),\"\(String(cell.character))\""
            if let color = cell.color {
                part += ",\(color.hexString)"
            }
            cellParts.append(part)
        }
        result += " cells [\(cellParts.joined(separator: ";"))]"
        return result
    }
}
