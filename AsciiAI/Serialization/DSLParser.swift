import Foundation

enum DSLParserError: Error, Equatable {
    case invalidSyntax(String)
    case unexpectedToken(String)
}

enum DSLParser {
    static func parse(_ input: String) throws -> Document {
        var layers: [Layer] = []
        var currentLayer: Layer?
        var currentGroupName: String?
        var currentGroupShapes: [AnyShape] = []

        let lines = input.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            let indentLevel = line.prefix(while: { $0 == " " }).count

            if trimmed.hasPrefix("layer ") {
                // Flush previous group if any
                if let groupName = currentGroupName {
                    let group = ShapeGroup(
                        name: groupName,
                        shapeIDs: currentGroupShapes.map(\.id)
                    )
                    currentLayer?.groups.append(group)
                    for shape in currentGroupShapes {
                        currentLayer?.addShape(shape)
                    }
                    currentGroupShapes = []
                    currentGroupName = nil
                }

                // Flush previous layer if any
                if let layer = currentLayer {
                    layers.append(layer)
                }

                currentLayer = try parseLayerHeader(trimmed)
            } else if trimmed.hasPrefix("group ") {
                // Flush previous group
                if let groupName = currentGroupName {
                    let group = ShapeGroup(
                        name: groupName,
                        shapeIDs: currentGroupShapes.map(\.id)
                    )
                    currentLayer?.groups.append(group)
                    for shape in currentGroupShapes {
                        currentLayer?.addShape(shape)
                    }
                    currentGroupShapes = []
                }
                currentGroupName = try parseQuotedString(from: trimmed, after: "group ")
            } else if trimmed.hasPrefix("box ") || trimmed.hasPrefix("arrow ")
                || trimmed.hasPrefix("text ")
            {
                let shape = try parseShape(trimmed)
                if currentGroupName != nil {
                    currentGroupShapes.append(shape)
                } else {
                    currentLayer?.addShape(shape)
                }
            }
        }

        // Flush last group
        if let groupName = currentGroupName {
            let group = ShapeGroup(
                name: groupName,
                shapeIDs: currentGroupShapes.map(\.id)
            )
            currentLayer?.groups.append(group)
            for shape in currentGroupShapes {
                currentLayer?.addShape(shape)
            }
        }

        // Flush last layer
        if let layer = currentLayer {
            layers.append(layer)
        }

        if layers.isEmpty {
            return Document()
        }

        return Document(layers: layers)
    }

    private static func parseLayerHeader(_ line: String) throws -> Layer {
        // layer "name" visible|hidden [locked]
        guard let name = try? parseQuotedString(from: line, after: "layer ") else {
            throw DSLParserError.invalidSyntax("Expected layer name: \(line)")
        }

        let isVisible = line.contains(" visible")
        let isLocked = line.contains(" locked")

        return Layer(name: name, isVisible: isVisible, isLocked: isLocked)
    }

    private static func parseShape(_ line: String) throws -> AnyShape {
        if line.hasPrefix("box ") {
            return try .box(parseBox(line))
        } else if line.hasPrefix("arrow ") {
            return try .arrow(parseArrow(line))
        } else if line.hasPrefix("text ") {
            return try .text(parseText(line))
        }
        throw DSLParserError.unexpectedToken(line)
    }

    private static func parseBox(_ line: String) throws -> BoxShape {
        // box "label" at col,row size WxH style styleName
        guard let label = try? parseQuotedString(from: line, after: "box ") else {
            throw DSLParserError.invalidSyntax("Expected box label: \(line)")
        }

        guard let atRange = line.range(of: " at ") else {
            throw DSLParserError.invalidSyntax("Expected 'at' in box: \(line)")
        }
        let afterAt = String(line[atRange.upperBound...])
        let (col, row) = try parseCoordinate(afterAt)

        guard let sizeRange = line.range(of: " size ") else {
            throw DSLParserError.invalidSyntax("Expected 'size' in box: \(line)")
        }
        let afterSize = String(line[sizeRange.upperBound...])
        let (width, height) = try parseDimension(afterSize)

        var borderStyle = BorderStyle.single
        if let styleRange = line.range(of: " style ") {
            let styleName = String(
                line[styleRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = BorderStyle(rawValue: styleName) {
                borderStyle = parsed
            }
        }

        return BoxShape(
            origin: GridPoint(column: col, row: row),
            size: GridSize(width: width, height: height),
            borderStyle: borderStyle,
            label: label
        )
    }

    private static func parseArrow(_ line: String) throws -> ArrowShape {
        // arrow from col,row to col,row [label "text"]
        guard let fromRange = line.range(of: "from ") else {
            throw DSLParserError.invalidSyntax("Expected 'from' in arrow: \(line)")
        }
        let afterFrom = String(line[fromRange.upperBound...])
        let (startCol, startRow) = try parseCoordinate(afterFrom)

        guard let toRange = line.range(of: " to ") else {
            throw DSLParserError.invalidSyntax("Expected 'to' in arrow: \(line)")
        }
        let afterTo = String(line[toRange.upperBound...])
        let (endCol, endRow) = try parseCoordinate(afterTo)

        var label = ""
        if line.contains(" label ") {
            label = (try? parseQuotedString(from: line, after: "label ")) ?? ""
        }

        return ArrowShape(
            start: GridPoint(column: startCol, row: startRow),
            end: GridPoint(column: endCol, row: endRow),
            label: label
        )
    }

    private static func parseText(_ line: String) throws -> TextShape {
        // text "content" at col,row
        guard let content = try? parseQuotedString(from: line, after: "text ") else {
            throw DSLParserError.invalidSyntax("Expected text content: \(line)")
        }

        guard let atRange = line.range(of: " at ") else {
            throw DSLParserError.invalidSyntax("Expected 'at' in text: \(line)")
        }
        let afterAt = String(line[atRange.upperBound...])
        let (col, row) = try parseCoordinate(afterAt)

        let unescaped = content.replacingOccurrences(of: "\\n", with: "\n")
        return TextShape(origin: GridPoint(column: col, row: row), text: unescaped)
    }

    // MARK: - Parsing helpers

    static func parseQuotedString(from text: String, after prefix: String) throws -> String {
        guard let prefixRange = text.range(of: prefix) else {
            throw DSLParserError.invalidSyntax("Missing prefix '\(prefix)' in: \(text)")
        }
        let afterPrefix = text[prefixRange.upperBound...]
        guard let openQuote = afterPrefix.firstIndex(of: "\"") else {
            throw DSLParserError.invalidSyntax("Missing opening quote in: \(text)")
        }
        let afterOpen = afterPrefix.index(after: openQuote)
        guard let closeQuote = afterPrefix[afterOpen...].firstIndex(of: "\"") else {
            throw DSLParserError.invalidSyntax("Missing closing quote in: \(text)")
        }
        return String(afterPrefix[afterOpen..<closeQuote])
    }

    private static func parseCoordinate(_ text: String) throws -> (Int, Int) {
        let cleaned = text.prefix(while: { $0.isNumber || $0 == "," || $0 == " " })
            .trimmingCharacters(in: .whitespaces)
        let parts = cleaned.split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        guard parts.count == 2, let a = Int(parts[0]), let b = Int(parts[1]) else {
            throw DSLParserError.invalidSyntax("Invalid coordinate: \(text)")
        }
        return (a, b)
    }

    private static func parseDimension(_ text: String) throws -> (Int, Int) {
        let cleaned = text.prefix(while: { $0.isNumber || $0 == "x" || $0 == "X" })
        let parts = cleaned.lowercased().split(separator: "x")
        guard parts.count == 2, let w = Int(parts[0]), let h = Int(parts[1]) else {
            throw DSLParserError.invalidSyntax("Invalid dimension: \(text)")
        }
        return (w, h)
    }
}
