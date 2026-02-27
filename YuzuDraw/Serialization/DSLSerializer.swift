import Foundation

enum DSLSerializer {
    static func serialize(_ document: Document) -> String {
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
                serializeGroup(group, layer: layer, indent: 2, lines: &lines)
            }

            // Emit ungrouped shapes
            for shape in layer.ungroupedShapes {
                lines.append("  \(serializeShape(shape))")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func serializeGroup(
        _ group: ShapeGroup, layer: Layer, indent: Int, lines: inout [String]
    ) {
        let pad = String(repeating: " ", count: indent)
        lines.append("\(pad)group \"\(group.name)\"")

        // Nested child groups
        for child in group.children {
            serializeGroup(child, layer: layer, indent: indent + 2, lines: &lines)
        }

        // Direct shape members
        let shapePad = String(repeating: " ", count: indent + 2)
        for shapeID in group.shapeIDs {
            if let shape = layer.findShape(id: shapeID) {
                lines.append("\(shapePad)\(serializeShape(shape))")
            }
        }
    }

    private static func serializeShape(_ shape: AnyShape) -> String {
        switch shape {
        case .box(let box):
            var result =
                "box \"\(box.label)\" at \(box.origin.column),\(box.origin.row) size \(box.size.width)x\(box.size.height) style \(box.strokeStyle.rawValue)"
            let fill = " fill \(box.fillMode.rawValue)"
            if box.fillMode == .solid {
                result += "\(fill) char \"\(String(box.fillCharacter))\""
            } else {
                result += fill
            }
            result += box.hasBorder ? " border visible" : " border hidden"
            if box.hasBorder && box.visibleBorders != Set(BoxBorderSide.allCases) {
                let sideOrder: [BoxBorderSide] = [.top, .bottom, .right, .left]
                let encodedSides = sideOrder
                    .filter { box.visibleBorders.contains($0) }
                    .map(\.rawValue)
                    .joined(separator: ",")
                result += " borders \(encodedSides)"
            }
            if box.borderLineStyle == .dashed {
                result += " line dashed dash \(box.borderDashLength) gap \(box.borderGapLength)"
            }
            result +=
                " halign \(box.textHorizontalAlignment.rawValue) valign \(box.textVerticalAlignment.rawValue)"
            result +=
                " textOnBorder \(box.allowTextOnBorder ? "true" : "false")"
            result +=
                " padding \(box.textPaddingLeft),\(box.textPaddingRight),\(box.textPaddingTop),\(box.textPaddingBottom)"
            if box.hasShadow {
                result += " shadow \(box.shadowStyle.rawValue) x \(box.shadowOffsetX) y \(box.shadowOffsetY)"
            }
            if let borderColor = box.borderColor {
                result += " borderColor \(borderColor.hexString)"
            }
            if let fillColor = box.fillColor {
                result += " fillColor \(fillColor.hexString)"
            }
            if let textColor = box.textColor {
                result += " textColor \(textColor.hexString)"
            }
            return result
        case .arrow(let arrow):
            var result =
                "arrow from \(arrow.start.column),\(arrow.start.row) to \(arrow.end.column),\(arrow.end.row)"
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
            return result
        case .text(let text):
            let escaped = text.text.replacingOccurrences(of: "\n", with: "\\n")
            var result = "text \"\(escaped)\" at \(text.origin.column),\(text.origin.row)"
            if let textColor = text.textColor {
                result += " textColor \(textColor.hexString)"
            }
            return result
        case .pencil(let pencil):
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
}
