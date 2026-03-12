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
        let expanded = DSLPreprocessor.expand(input)

        var shapes: [AnyShape] = []
        var groups: [ShapeGroup] = []
        var groupStack: [GroupStackEntry] = []

        let lines = expanded.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            let indentLevel = line.prefix(while: { $0 == " " }).count

            if trimmed.hasPrefix("layer ") {
                // Legacy layer lines — flush group stack and ignore
                flushGroupStack(&groupStack, into: &groups)
                continue
            } else if trimmed.hasPrefix("group ") {
                // Pop groups from stack that are at same or deeper indent
                popGroupsToIndent(indentLevel, stack: &groupStack, groups: &groups)

                let name = try parseQuotedString(from: trimmed, after: "group ")
                groupStack.append(
                    GroupStackEntry(name: name, shapeIDs: [], children: [], indent: indentLevel))
            } else if trimmed.hasPrefix("arrow ") {
                // Pop groups whose indent is >= this shape's indent
                popGroupsToIndent(indentLevel, stack: &groupStack, groups: &groups)

                let arrow = try parseArrow(trimmed, allShapes: shapes)
                let shape = AnyShape.arrow(arrow)
                if !groupStack.isEmpty {
                    groupStack[groupStack.count - 1].shapeIDs.append(shape.id)
                }
                shapes.append(shape)
            } else if trimmed.hasPrefix("rectangle ") || trimmed.hasPrefix("rect ")
                || trimmed.hasPrefix("box ")
                || trimmed.hasPrefix("text ") || trimmed.hasPrefix("pencil ")
            {
                // Pop groups whose indent is >= this shape's indent
                popGroupsToIndent(indentLevel, stack: &groupStack, groups: &groups)

                let shape = try parseShape(trimmed)
                if !groupStack.isEmpty {
                    groupStack[groupStack.count - 1].shapeIDs.append(shape.id)
                }
                shapes.append(shape)
            }
        }

        // Flush remaining group stack
        flushGroupStack(&groupStack, into: &groups)

        return Document(shapes: shapes, groups: groups)
    }

    private static func popGroupsToIndent(
        _ indent: Int, stack: inout [GroupStackEntry], groups: inout [ShapeGroup]
    ) {
        while let top = stack.last, top.indent >= indent {
            let entry = stack.removeLast()
            let group = ShapeGroup(
                name: entry.name, shapeIDs: entry.shapeIDs, children: entry.children)
            if stack.isEmpty {
                groups.append(group)
            } else {
                stack[stack.count - 1].children.append(group)
            }
        }
    }

    private static func flushGroupStack(
        _ stack: inout [GroupStackEntry], into groups: inout [ShapeGroup]
    ) {
        while let entry = stack.popLast() {
            let group = ShapeGroup(
                name: entry.name, shapeIDs: entry.shapeIDs, children: entry.children)
            if stack.isEmpty {
                groups.append(group)
            } else {
                stack[stack.count - 1].children.append(group)
            }
        }
    }

    private static func parseShape(_ line: String) throws -> AnyShape {
        if line.hasPrefix("rectangle ") || line.hasPrefix("rect ") || line.hasPrefix("box ") {
            return try .rectangle(parseRectangle(line))
        } else if line.hasPrefix("text ") {
            return try .text(parseText(line))
        } else if line.hasPrefix("pencil ") {
            return try .pencil(parsePencil(line))
        }
        throw DSLParserError.unexpectedToken(line)
    }

    private static func parseRectangle(_ line: String) throws -> RectangleShape {
        // rectangle "label" at col,row size WxH [style|stroke styleName] [fill transparent|solid [char "x"]]
        let keyword: String
        if line.hasPrefix("box ") {
            keyword = "box "
        } else if line.hasPrefix("rect ") {
            keyword = "rect "
        } else {
            keyword = "rectangle "
        }
        guard let rawLabel = try? parseQuotedString(from: line, after: keyword) else {
            throw DSLParserError.invalidSyntax("Expected rectangle label: \(line)")
        }
        let label = rawLabel.replacingOccurrences(of: "\\n", with: "\n")

        guard let atRange = line.range(of: " at ") else {
            throw DSLParserError.invalidSyntax("Expected 'at' in rectangle: \(line)")
        }
        let afterAt = String(line[atRange.upperBound...])
        let (col, row) = try parseCoordinate(afterAt)

        guard let sizeRange = line.range(of: " size ") else {
            throw DSLParserError.invalidSyntax("Expected 'size' in rectangle: \(line)")
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

        var fillMode: RectangleFillMode = .none
        var fillCharacter: Character = " "
        if line.contains(" fill opaque") {
            fillMode = .opaque
        } else if line.contains(" fill block") {
            fillMode = .block
            if let char = try? parseQuotedString(from: line, after: "char "), let first = char.first {
                fillCharacter = first
            } else {
                fillCharacter = "\u{2588}" // default block: █
            }
        } else if line.contains(" fill character") {
            fillMode = .character
            if let char = try? parseQuotedString(from: line, after: "char "), let first = char.first {
                fillCharacter = first
            }
        } else if line.contains(" fill solid") {
            // Legacy: migrate "solid" to opaque or character based on char
            if let char = try? parseQuotedString(from: line, after: "char "), let first = char.first {
                if first == " " {
                    fillMode = .opaque
                } else {
                    fillMode = .character
                    fillCharacter = first
                }
            } else {
                fillMode = .opaque
            }
        } else if line.contains(" fill transparent") || line.contains(" fill none") {
            fillMode = .none
        }

        // Parse optional name/ID
        var name: String?
        if let idRange = line.range(of: " id ") {
            let afterId = String(line[idRange.upperBound...])
            let idValue = String(afterId.prefix(while: { !$0.isWhitespace }))
            if !idValue.isEmpty {
                name = idValue
            }
        }

        var hasBorder = true
        if line.contains(" noborder") {
            hasBorder = false
        } else if line.contains(" border hidden") {
            hasBorder = false
        }
        var visibleBorders = Set(RectangleBorderSide.allCases)
        if let bordersRange = line.range(of: " borders ") {
            let value = String(line[bordersRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            let parsedSides = value
                .split(separator: ",")
                .compactMap { RectangleBorderSide(rawValue: String($0)) }
            if !parsedSides.isEmpty {
                visibleBorders = Set(parsedSides)
            }
        }
        var borderLineStyle: RectangleBorderLineStyle = .solid
        var borderDashLength = 1
        var borderGapLength = 1
        if let lineStyleRange = line.range(of: " line ") {
            let value = String(
                line[lineStyleRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = RectangleBorderLineStyle(rawValue: value) {
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

        var textHorizontalAlignment: RectangleTextHorizontalAlignment = .center
        if let horizontalRange = line.range(of: " halign ") {
            let value = String(
                line[horizontalRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = RectangleTextHorizontalAlignment(rawValue: value) {
                textHorizontalAlignment = parsed
            }
        }

        var textVerticalAlignment: RectangleTextVerticalAlignment = .middle
        if let verticalRange = line.range(of: " valign ") {
            let value = String(line[verticalRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if let parsed = RectangleTextVerticalAlignment(rawValue: value) {
                textVerticalAlignment = parsed
            }
        }

        var allowTextOnBorder = false
        if let textOnBorderRange = line.range(of: " textOnBorder ") {
            let value = String(
                line[textOnBorderRange.upperBound...].prefix(while: { !$0.isWhitespace }))
            if value == "false" {
                allowTextOnBorder = false
            } else {
                // "true" or any non-boolean token (bare flag followed by next keyword)
                allowTextOnBorder = true
            }
        } else if line.contains(" textOnBorder") {
            // Bare textOnBorder flag at end of line means true
            allowTextOnBorder = true
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
        var shadowStyle: RectangleShadowStyle = .light
        var shadowOffsetX = 1
        var shadowOffsetY = 1
        if let shadowRange = line.range(of: " shadow ") {
            hasShadow = true
            let shadowSection = String(line[shadowRange.upperBound...])

            let styleValue = String(shadowSection.prefix(while: { !$0.isWhitespace }))
            if let parsed = RectangleShadowStyle(rawValue: styleValue) {
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
                var legacyDirection: RectangleShadowDirection = .bottomRight
                var legacyOffset = 1
                if let directionRange = shadowSection.range(of: " direction ") {
                    let value = String(
                        shadowSection[directionRange.upperBound...].prefix(while: { !$0.isWhitespace }))
                    if let parsed = RectangleShadowDirection(rawValue: value) {
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

        let float = line.contains(" float")

        return RectangleShape(
            name: name,
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
            textColor: textColor,
            float: float
        )
    }

    // MARK: - Arrow parsing

    private struct NamedEndpoint {
        let label: String
        let side: ArrowAttachmentSide
    }

    private static func parseArrow(
        _ line: String, allShapes: [AnyShape]
    ) throws -> ArrowShape {
        // Supports two endpoint formats:
        //   arrow from col,row to col,row ...
        //   arrow from "RectangleLabel".side to "RectangleLabel".side ...
        guard let fromRange = line.range(of: "from ") else {
            throw DSLParserError.invalidSyntax("Expected 'from' in arrow: \(line)")
        }
        let afterFrom = String(line[fromRange.upperBound...])

        guard let toRange = line.range(of: " to ") else {
            throw DSLParserError.invalidSyntax("Expected 'to' in arrow: \(line)")
        }
        let afterTo = String(line[toRange.upperBound...])

        // Parse start endpoint
        var startPoint: GridPoint
        var startAttachment: ArrowAttachment?
        if let ref = parseNamedEndpoint(afterFrom) {
            guard let rectangle = findRectangleByLabel(ref.label, in: allShapes) else {
                throw DSLParserError.invalidSyntax(
                    "Rectangle '\(ref.label)' not found for arrow attachment")
            }
            startPoint = rectangle.attachmentPoint(for: ref.side)
            startAttachment = ArrowAttachment(shapeID: rectangle.id, side: ref.side)
        } else {
            let (col, row) = try parseCoordinate(afterFrom)
            startPoint = GridPoint(column: col, row: row)
        }

        // Parse end endpoint
        var endPoint: GridPoint
        var endAttachment: ArrowAttachment?
        if let ref = parseNamedEndpoint(afterTo) {
            guard let rectangle = findRectangleByLabel(ref.label, in: allShapes) else {
                throw DSLParserError.invalidSyntax(
                    "Rectangle '\(ref.label)' not found for arrow attachment")
            }
            endPoint = rectangle.attachmentPoint(for: ref.side)
            endAttachment = ArrowAttachment(shapeID: rectangle.id, side: ref.side)
        } else {
            let (col, row) = try parseCoordinate(afterTo)
            endPoint = GridPoint(column: col, row: row)
        }

        // Parse remaining properties (style, label, colors)
        var label = ""
        if line.contains(" label ") {
            label = (try? parseQuotedString(from: line, after: "label "))?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
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

        let float = line.contains(" float")

        return ArrowShape(
            start: startPoint,
            end: endPoint,
            label: label,
            strokeStyle: strokeStyle,
            startAttachment: startAttachment,
            endAttachment: endAttachment,
            strokeColor: strokeColor,
            labelColor: labelColor,
            float: float
        )
    }

    /// Parse a named endpoint like `"RectangleLabel".right`
    private static func parseNamedEndpoint(_ text: String) -> NamedEndpoint? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard trimmed.first == "\"" else { return nil }

        let afterOpen = trimmed.index(after: trimmed.startIndex)
        guard let closeQuote = trimmed[afterOpen...].firstIndex(of: "\"") else { return nil }
        let label = String(trimmed[afterOpen..<closeQuote]).replacingOccurrences(of: "\\n", with: "\n")

        let afterClose = trimmed.index(after: closeQuote)
        guard afterClose < trimmed.endIndex, trimmed[afterClose] == "." else { return nil }

        let sideStart = trimmed.index(after: afterClose)
        let sideStr = String(trimmed[sideStart...].prefix(while: { !$0.isWhitespace }))
        guard let side = ArrowAttachmentSide(rawValue: sideStr) else { return nil }

        return NamedEndpoint(label: label, side: side)
    }

    /// Find the first rectangle with a matching name (ID) or label across all shapes.
    /// Name (ID) takes priority over label.
    private static func findRectangleByLabel(_ label: String, in shapes: [AnyShape]) -> RectangleShape? {
        // First try to find by name (ID)
        for shape in shapes {
            if case .rectangle(let rectangle) = shape, rectangle.name == label {
                return rectangle
            }
        }
        // Fall back to label
        for shape in shapes {
            if case .rectangle(let rectangle) = shape, rectangle.label == label {
                return rectangle
            }
        }
        return nil
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

    private static func parsePencil(_ line: String) throws -> PencilShape {
        // pencil at col,row cells [col,row,"char";col,row,"char",#color;...]
        guard let atRange = line.range(of: " at ") else {
            throw DSLParserError.invalidSyntax("Expected 'at' in pencil: \(line)")
        }
        let afterAt = String(line[atRange.upperBound...])
        let (col, row) = try parseCoordinate(afterAt)

        var cells: [GridPoint: PencilCell] = [:]
        if let cellsRange = line.range(of: " cells [") {
            let afterCells = String(line[cellsRange.upperBound...])
            if let closeBracket = afterCells.firstIndex(of: "]") {
                let cellsString = String(afterCells[afterCells.startIndex..<closeBracket])
                let entries = cellsString.split(separator: ";")
                for entry in entries {
                    let parts = String(entry)
                    // Parse: col,row,"char"[,#color]
                    var remaining = parts[parts.startIndex...]
                    // Parse column
                    let colStr = String(remaining.prefix(while: { $0 != "," }))
                    guard let cellCol = Int(colStr) else { continue }
                    remaining = remaining.dropFirst(colStr.count + 1)
                    // Parse row
                    let rowStr = String(remaining.prefix(while: { $0 != "," }))
                    guard let cellRow = Int(rowStr) else { continue }
                    remaining = remaining.dropFirst(rowStr.count + 1)
                    // Parse quoted character
                    guard remaining.first == "\"" else { continue }
                    remaining = remaining.dropFirst()
                    guard let closeQuote = remaining.firstIndex(of: "\"") else { continue }
                    let charStr = String(remaining[remaining.startIndex..<closeQuote])
                    guard let character = charStr.first else { continue }
                    remaining = remaining[remaining.index(after: closeQuote)...]
                    // Parse optional color
                    var color: ShapeColor?
                    if remaining.first == "," {
                        remaining = remaining.dropFirst()
                        let hexStr = String(remaining)
                        color = ShapeColor(hex: hexStr)
                    }
                    cells[GridPoint(column: cellCol, row: cellRow)] = PencilCell(
                        character: character, color: color)
                }
            }
        }

        return PencilShape(
            origin: GridPoint(column: col, row: row),
            cells: cells
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
