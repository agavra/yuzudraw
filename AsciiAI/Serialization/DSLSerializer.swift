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

            // Track which shapes belong to groups
            var groupedShapeIDs = Set<UUID>()
            for group in layer.groups {
                groupedShapeIDs.formUnion(group.shapeIDs)
            }

            // Emit groups with their shapes
            for group in layer.groups {
                lines.append("  group \"\(group.name)\"")
                for shapeID in group.shapeIDs {
                    if let shape = layer.findShape(id: shapeID) {
                        lines.append("    \(serializeShape(shape))")
                    }
                }
            }

            // Emit ungrouped shapes
            for shape in layer.shapes where !groupedShapeIDs.contains(shape.id) {
                lines.append("  \(serializeShape(shape))")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func serializeShape(_ shape: AnyShape) -> String {
        switch shape {
        case .box(let box):
            var result =
                "box \"\(box.label)\" at \(box.origin.column),\(box.origin.row) size \(box.size.width)x\(box.size.height) style \(box.borderStyle.rawValue)"
            return result
        case .arrow(let arrow):
            var result =
                "arrow from \(arrow.start.column),\(arrow.start.row) to \(arrow.end.column),\(arrow.end.row)"
            if !arrow.label.isEmpty {
                result += " label \"\(arrow.label)\""
            }
            return result
        case .text(let text):
            let escaped = text.text.replacingOccurrences(of: "\n", with: "\\n")
            return "text \"\(escaped)\" at \(text.origin.column),\(text.origin.row)"
        }
    }
}
