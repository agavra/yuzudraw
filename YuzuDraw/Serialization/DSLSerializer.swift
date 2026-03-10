import Foundation

enum DSLSerializer {
    static func serialize(_ document: Document) -> String {
        let allShapes = document.layers.flatMap(\.shapes)
        var lines: [String] = []

        for layer in document.layers {
            var layerLine = "layer \"\(layer.name)\""
            if layer.isVisible {
                layerLine += " visible"
            } else {
                layerLine += " hidden"
            }
            if layer.isLocked {
                layerLine += " locked"
            }
            lines.append(layerLine)

            // Emit groups with their shapes
            for group in layer.groups {
                serializeGroup(group, layer: layer, allShapes: allShapes, indent: 2, lines: &lines)
            }

            // Emit ungrouped shapes
            for shape in layer.ungroupedShapes {
                lines.append("  \(serializeShape(shape, allShapes: allShapes))")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func serializeGroup(
        _ group: ShapeGroup, layer: Layer, allShapes: [AnyShape], indent: Int,
        lines: inout [String]
    ) {
        let pad = String(repeating: " ", count: indent)
        lines.append("\(pad)group \"\(group.name)\"")

        // Nested child groups
        for child in group.children {
            serializeGroup(
                child, layer: layer, allShapes: allShapes, indent: indent + 2, lines: &lines)
        }

        // Direct shape members
        let shapePad = String(repeating: " ", count: indent + 2)
        for shapeID in group.shapeIDs {
            if let shape = layer.findShape(id: shapeID) {
                lines.append("\(shapePad)\(serializeShape(shape, allShapes: allShapes))")
            }
        }
    }

    private static func serializeShape(_ shape: AnyShape, allShapes: [AnyShape]) -> String {
        switch shape {
        case .rectangle(let rectangle):
            return serializeRectangle(rectangle)
        case .arrow(let arrow):
            return serializeArrow(arrow, allShapes: allShapes)
        case .text(let text):
            return serializeText(text)
        case .pencil(let pencil):
            return serializePencil(pencil)
        }
    }

    private static func serializeRectangle(_ rectangle: RectangleShape) -> String {
        let escapedLabel = rectangle.label.replacingOccurrences(of: "\n", with: "\\n")
        var result =
            "rectangle \"\(escapedLabel)\" at \(rectangle.origin.column),\(rectangle.origin.row) size \(rectangle.size.width)x\(rectangle.size.height) style \(rectangle.strokeStyle.rawValue)"
        let fill = " fill \(rectangle.fillMode.rawValue)"
        if rectangle.fillMode == .solid {
            result += "\(fill) char \"\(String(rectangle.fillCharacter))\""
        } else {
            result += fill
        }
        result += rectangle.hasBorder ? " border visible" : " border hidden"
        if rectangle.hasBorder && rectangle.visibleBorders != Set(RectangleBorderSide.allCases) {
            let sideOrder: [RectangleBorderSide] = [.top, .bottom, .right, .left]
            let encodedSides = sideOrder
                .filter { rectangle.visibleBorders.contains($0) }
                .map(\.rawValue)
                .joined(separator: ",")
            result += " borders \(encodedSides)"
        }
        if rectangle.borderLineStyle == .dashed {
            result += " line dashed dash \(rectangle.borderDashLength) gap \(rectangle.borderGapLength)"
        }
        result +=
            " halign \(rectangle.textHorizontalAlignment.rawValue) valign \(rectangle.textVerticalAlignment.rawValue)"
        result +=
            " textOnBorder \(rectangle.allowTextOnBorder ? "true" : "false")"
        result +=
            " padding \(rectangle.textPaddingLeft),\(rectangle.textPaddingRight),\(rectangle.textPaddingTop),\(rectangle.textPaddingBottom)"
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

    private static func serializeArrow(_ arrow: ArrowShape, allShapes: [AnyShape]) -> String {
        let startStr = serializeEndpoint(
            point: arrow.start, attachment: arrow.startAttachment, allShapes: allShapes)
        let endStr = serializeEndpoint(
            point: arrow.end, attachment: arrow.endAttachment, allShapes: allShapes)

        var result = "arrow from \(startStr) to \(endStr)"
        result += " style \(arrow.strokeStyle.rawValue)"
        if !arrow.label.isEmpty {
            result += " label \"\(arrow.label)\""
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
        point: GridPoint, attachment: ArrowAttachment?, allShapes: [AnyShape]
    ) -> String {
        if let attachment,
            let rectangle = findRectangleByID(attachment.shapeID, in: allShapes)
        {
            return "\"\(rectangle.label)\".\(attachment.side.rawValue)"
        }
        return "\(point.column),\(point.row)"
    }

    private static func findRectangleByID(_ id: UUID, in shapes: [AnyShape]) -> RectangleShape? {
        for shape in shapes {
            if case .rectangle(let rectangle) = shape, rectangle.id == id {
                return rectangle
            }
        }
        return nil
    }

    private static func serializeText(_ text: TextShape) -> String {
        let escaped = text.text.replacingOccurrences(of: "\n", with: "\\n")
        var result = "text \"\(escaped)\" at \(text.origin.column),\(text.origin.row)"
        if let textColor = text.textColor {
            result += " textColor \(textColor.hexString)"
        }
        return result
    }

    private static func serializePencil(_ pencil: PencilShape) -> String {
        var result =
            "pencil at \(pencil.origin.column),\(pencil.origin.row)"
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
