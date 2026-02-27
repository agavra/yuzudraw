import Foundation

enum DSLParserError: Error, Equatable {
    case invalidSyntax(String)
    case unexpectedToken(String)
}

enum DSLParser {
    private struct GroupStackEntry {
        var name: String
        var shapeIDs: [UUID]
        var children: [ShapeGroup]
        var indent: Int
    }

    static func parse(_ input: String) throws -> Document {
        var layers: [Layer] = []
        var currentLayer: Layer?
        var groupStack: [GroupStackEntry] = []

        let lines = input.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            let indentLevel = line.prefix(while: { $0 == " " }).count

            if trimmed.hasPrefix("layer ") {
                // Flush group stack
                flushGroupStack(&groupStack, into: &currentLayer)

                // Flush previous layer if any
                if let layer = currentLayer {
                    layers.append(layer)
                }

                currentLayer = try parseLayerHeader(trimmed)
            } else if trimmed.hasPrefix("group ") {
                // Pop groups from stack that are at same or deeper indent
                popGroupsToIndent(indentLevel, stack: &groupStack, layer: &currentLayer)

                let name = try parseQuotedString(from: trimmed, after: "group ")
                groupStack.append(
                    GroupStackEntry(name: name, shapeIDs: [], children: [], indent: indentLevel))
            } else if trimmed.hasPrefix("box ") || trimmed.hasPrefix("arrow ")
                || trimmed.hasPrefix("text ")
            {
                // Pop groups whose indent is >= this shape's indent
                popGroupsToIndent(indentLevel, stack: &groupStack, layer: &currentLayer)

                let shape = try parseShape(trimmed)
                if !groupStack.isEmpty {
                    groupStack[groupStack.count - 1].shapeIDs.append(shape.id)
                }
                currentLayer?.addShape(shape)
            }
        }

        // Flush remaining group stack
        flushGroupStack(&groupStack, into: &currentLayer)

        // Flush last layer
        if let layer = currentLayer {
            layers.append(layer)
        }

        if layers.isEmpty {
            return Document()
        }

        return Document(layers: layers)
    }

    private static func popGroupsToIndent(
        _ indent: Int, stack: inout [GroupStackEntry], layer: inout Layer?
    ) {
        while let top = stack.last, top.indent >= indent {
            let entry = stack.removeLast()
            let group = ShapeGroup(
                name: entry.name, shapeIDs: entry.shapeIDs, children: entry.children)
            if stack.isEmpty {
                layer?.groups.append(group)
            } else {
                stack[stack.count - 1].children.append(group)
            }
        }
    }

    private static func flushGroupStack(
        _ stack: inout [GroupStackEntry], into layer: inout Layer?
    ) {
        while let entry = stack.popLast() {
            let group = ShapeGroup(
                name: entry.name, shapeIDs: entry.shapeIDs, children: entry.children)
            if stack.isEmpty {
                layer?.groups.append(group)
            } else {
                stack[stack.count - 1].children.append(group)
            }
        }
    }

    private static func parseLayerHeader(_ line: String) throws -> Layer {
        // layer "name" visible|hidden [locked]
        guard let name = try? parseQuotedString(from: line, after: "layer ") else {
            throw DSLParserError.invalidSyntax("Expected layer name: \(line)")
        }

        let isVisible = line.contains(" visible")
        let isLocked = line.contains(" locked")
        let bgColor = parseColorKeyword("bgColor", in: line)

        return Layer(name: name, isVisible: isVisible, isLocked: isLocked, backgroundColor: bgColor)
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
        // box "label" at col,row size WxH [style|stroke styleName] [fill transparent|solid [char "x"]]
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

        var strokeStyle = StrokeStyle.single
        if let styleRange = line.range(of: " style ") {
            let styleName = String(
                line[styleRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = StrokeStyle(rawValue: styleName) {
                strokeStyle = parsed
            }
        } else if let strokeRange = line.range(of: " stroke ") {
            let styleName = String(
                line[strokeRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = StrokeStyle(rawValue: styleName) {
                strokeStyle = parsed
            }
        }

        var fillMode: BoxFillMode = .transparent
        var fillCharacter: Character = " "
        if line.contains(" fill solid") {
            fillMode = .solid
            if let char = try? parseQuotedString(from: line, after: "char "), let first = char.first {
                fillCharacter = first
            }
        } else if line.contains(" fill transparent") {
            fillMode = .transparent
        }

        var hasBorder = true
        if line.contains(" border hidden") {
            hasBorder = false
        }
        var visibleBorders = Set(BoxBorderSide.allCases)
        if let bordersRange = line.range(of: " borders ") {
            let value = String(line[bordersRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            let parsedSides = value
                .split(separator: ",")
                .compactMap { BoxBorderSide(rawValue: String($0)) }
            if !parsedSides.isEmpty {
                visibleBorders = Set(parsedSides)
            }
        }
        var borderLineStyle: BoxBorderLineStyle = .solid
        var borderDashLength = 1
        var borderGapLength = 1
        if let lineStyleRange = line.range(of: " line ") {
            let value = String(
                line[lineStyleRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = BoxBorderLineStyle(rawValue: value) {
                borderLineStyle = parsed
            }
            if let dashRange = line.range(of: " dash ") {
                let value = String(
                    line[dashRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                borderDashLength = max(1, Int(value) ?? 1)
            }
            if let gapRange = line.range(of: " gap ") {
                let value = String(
                    line[gapRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                borderGapLength = max(0, Int(value) ?? 1)
            }
        }

        var textHorizontalAlignment: BoxTextHorizontalAlignment = .center
        if let horizontalRange = line.range(of: " halign ") {
            let value = String(
                line[horizontalRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = BoxTextHorizontalAlignment(rawValue: value) {
                textHorizontalAlignment = parsed
            }
        }

        var textVerticalAlignment: BoxTextVerticalAlignment = .middle
        if let verticalRange = line.range(of: " valign ") {
            let value = String(line[verticalRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = BoxTextVerticalAlignment(rawValue: value) {
                textVerticalAlignment = parsed
            }
        }

        var allowTextOnBorder = false
        if let textOnBorderRange = line.range(of: " textOnBorder ") {
            let value = String(
                line[textOnBorderRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            allowTextOnBorder = value == "true"
        }

        var textPaddingLeft = 0
        var textPaddingRight = 0
        var textPaddingTop = 0
        var textPaddingBottom = 0
        if let paddingRange = line.range(of: " padding ") {
            let value = String(
                line[paddingRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            let parts = value.split(separator: ",")
            if parts.count == 4 {
                textPaddingLeft = Int(parts[0]) ?? 0
                textPaddingRight = Int(parts[1]) ?? 0
                textPaddingTop = Int(parts[2]) ?? 0
                textPaddingBottom = Int(parts[3]) ?? 0
            }
        }

        var hasShadow = false
        var shadowStyle: BoxShadowStyle = .light
        var shadowOffsetX = 1
        var shadowOffsetY = 1
        if let shadowRange = line.range(of: " shadow ") {
            hasShadow = true
            let shadowSection = String(line[shadowRange.upperBound...])

            let styleValue = String(shadowSection.prefix(while: { !$0.isWhitespace }))
            if let parsed = BoxShadowStyle(rawValue: styleValue) {
                shadowStyle = parsed
            }

            if let xRange = shadowSection.range(of: " x ") {
                let value = String(
                    shadowSection[xRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                shadowOffsetX = Int(value) ?? 1
            }

            if let yRange = shadowSection.range(of: " y ") {
                let value = String(
                    shadowSection[yRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                shadowOffsetY = Int(value) ?? 1
            }

            // Backward compatibility with old syntax:
            // shadow <style> direction <dir> offset <n> size <n>
            if shadowSection.contains(" direction ") || shadowSection.contains(" offset ") {
                var legacyDirection: BoxShadowDirection = .bottomRight
                var legacyOffset = 1
                if let directionRange = shadowSection.range(of: " direction ") {
                    let value = String(
                        shadowSection[directionRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                    if let parsed = BoxShadowDirection(rawValue: value) {
                        legacyDirection = parsed
                    }
                }
                if let offsetRange = shadowSection.range(of: " offset ") {
                    let value = String(
                        shadowSection[offsetRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                    legacyOffset = Int(value) ?? 1
                }
                shadowOffsetX = legacyDirection.xSign * legacyOffset
                shadowOffsetY = legacyDirection.ySign * legacyOffset
            }
        }

        let borderColor = parseColorKeyword("borderColor", in: line)
        let fillColor = parseColorKeyword("fillColor", in: line)
        let textColor = parseColorKeyword("textColor", in: line)

        return BoxShape(
            origin: GridPoint(column: col, row: row),
            size: GridSize(width: width, height: height),
            strokeStyle: strokeStyle,
            hasBorder: hasBorder,
            visibleBorders: visibleBorders,
            borderLineStyle: borderLineStyle,
            borderDashLength: borderDashLength,
            borderGapLength: borderGapLength,
            fillMode: fillMode,
            fillCharacter: fillCharacter,
            label: label,
            textHorizontalAlignment: textHorizontalAlignment,
            textVerticalAlignment: textVerticalAlignment,
            allowTextOnBorder: allowTextOnBorder,
            textPaddingLeft: textPaddingLeft,
            textPaddingRight: textPaddingRight,
            textPaddingTop: textPaddingTop,
            textPaddingBottom: textPaddingBottom,
            hasShadow: hasShadow,
            shadowStyle: shadowStyle,
            shadowOffsetX: shadowOffsetX,
            shadowOffsetY: shadowOffsetY,
            borderColor: borderColor,
            fillColor: fillColor,
            textColor: textColor
        )
    }

    private static func parseArrow(_ line: String) throws -> ArrowShape {
        // arrow from col,row to col,row [style|stroke styleName] [label "text"]
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

        var strokeStyle = StrokeStyle.single
        if let styleRange = line.range(of: " style ") {
            let styleName = String(
                line[styleRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = StrokeStyle(rawValue: styleName) {
                strokeStyle = parsed
            }
        } else if let strokeRange = line.range(of: " stroke ") {
            let styleName = String(
                line[strokeRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = StrokeStyle(rawValue: styleName) {
                strokeStyle = parsed
            }
        }

        let strokeColor = parseColorKeyword("strokeColor", in: line)
        let labelColor = parseColorKeyword("labelColor", in: line)

        return ArrowShape(
            start: GridPoint(column: startCol, row: startRow),
            end: GridPoint(column: endCol, row: endRow),
            label: label,
            strokeStyle: strokeStyle,
            strokeColor: strokeColor,
            labelColor: labelColor
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
        let textColor = parseColorKeyword("textColor", in: line)
        return TextShape(
            origin: GridPoint(column: col, row: row),
            text: unescaped,
            textColor: textColor
        )
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

    private static func parseColorKeyword(_ keyword: String, in line: String) -> ShapeColor? {
        guard let range = line.range(of: " \(keyword) ") else { return nil }
        let hex = String(line[range.upperBound...].prefix(while: { !$0.isWhitespace }))
        return ShapeColor(hex: hex)
    }
}
