import Antlr4
import Foundation

enum DSLASTBuilder {
    static func build(from context: YuzuDrawDSLParser.DocumentContext, source: String) throws
        -> DSLDocumentNode
    {
        let nonEmptyLines = source.components(separatedBy: "\n").compactMap { line -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty ? nil : line
        }

        var indentIndex = 0
        var statements: [DSLStatementNode] = []
        for statementContext in context.statement() {
            let rawLine = indentIndex < nonEmptyLines.count ? nonEmptyLines[indentIndex] : ""
            let indent = rawLine.prefix(while: { $0 == " " }).count
            indentIndex += 1
            if let node = try buildStatement(from: statementContext, indent: indent, rawLine: rawLine) {
                statements.append(node)
            }
        }
        return DSLDocumentNode(statements: statements)
    }

    private static func buildStatement(
        from context: YuzuDrawDSLParser.StatementContext,
        indent: Int,
        rawLine _: String
    ) throws -> DSLStatementNode? {
        if let layer = context.layerStatement() {
            return .layer(DSLLayerNode(name: try string(from: layer.stringValue()), indent: indent))
        }
        if let group = context.groupStatement() {
            return .group(try buildGroup(from: group, indent: indent))
        }
        if let rectangle = context.rectangleStatement() {
            return .rectangle(try buildRectangle(from: rectangle, indent: indent))
        }
        if let arrow = context.arrowStatement() {
            return .arrow(try buildArrow(from: arrow, indent: indent))
        }
        if let text = context.textStatement() {
            return .text(try buildText(from: text, indent: indent))
        }
        if let pencil = context.pencilStatement() {
            return .pencil(try buildPencil(from: pencil, indent: indent))
        }
        return nil
    }

    private static func buildGroup(
        from context: YuzuDrawDSLParser.GroupStatementContext,
        indent: Int
    ) throws -> DSLGroupNode {
        DSLGroupNode(
            name: try string(from: context.stringValue()),
            id: context.idClause()?.identifier()?.getText(),
            position: try context.atClause().flatMap { try position(from: $0.positionExpr()) },
            indent: indent
        )
    }

    private static func buildRectangle(
        from context: YuzuDrawDSLParser.RectangleStatementContext,
        indent: Int
    ) throws -> DSLRectangleNode {
        var node = DSLRectangleNode(
            keyword: context.rectKeyword()?.getText() ?? "rect",
            label: try string(from: context.stringValue()),
            indent: indent,
            id: nil,
            position: nil,
            semanticPosition: nil,
            size: nil,
            strokeStyle: nil,
            fillMode: nil,
            fillCharacter: nil,
            hasBorder: nil,
            visibleBorders: nil,
            borderLineStyle: nil,
            borderDashLength: nil,
            borderGapLength: nil,
            textHorizontalAlignment: nil,
            textVerticalAlignment: nil,
            allowTextOnBorder: nil,
            padding: nil,
            shadow: nil,
            borderColor: nil,
            fillColor: nil,
            textColor: nil,
            float: false
        )

        for clause in context.rectangleClause() {
            if let idClause = clause.idClause() {
                node.id = idClause.identifier()?.getText()
                continue
            }
            if let atClause = clause.atClause() {
                node.semanticPosition = nil
                node.position = try position(from: atClause.positionExpr())
                continue
            }
            if let semanticClause = clause.semanticPositionClause() {
                node.position = nil
                node.semanticPosition = try semanticPosition(from: semanticClause)
                continue
            }
            if let sizeClause = clause.sizeClause(), let dimension = sizeClause.dimension() {
                node.size = try gridSize(from: dimension)
                continue
            }
            if let styleClause = clause.styleClause() {
                node.strokeStyle = try strokeStyle(from: styleClause.strokeStyleValue())
                continue
            }
            if let strokeClause = clause.strokeClause() {
                node.strokeStyle = try strokeStyle(from: strokeClause.strokeStyleValue())
                continue
            }
            if let fillClause = clause.fillClause() {
                node.fillMode = try fillMode(from: fillClause.fillModeValue())
                if let charValue = fillClause.stringValue() {
                    node.fillCharacter = try singleCharacter(from: charValue)
                }
                continue
            }
            if let borderClause = clause.borderClause() {
                node.hasBorder = borderClause.HIDDEN_KW() == nil
                continue
            }
            if clause.noborderClause() != nil {
                node.hasBorder = false
                continue
            }
            if let bordersClause = clause.bordersClause() {
                node.visibleBorders = try Set(bordersClause.sideValue().map(borderSide(from:)))
                continue
            }
            if let lineClause = clause.lineClause() {
                node.borderLineStyle = try borderLineStyle(from: lineClause.borderLineStyleValue())
                continue
            }
            if let dashClause = clause.dashClause() {
                node.borderDashLength = try int(from: dashClause.intValue())
                continue
            }
            if let gapClause = clause.gapClause() {
                node.borderGapLength = try int(from: gapClause.intValue())
                continue
            }
            if let halignClause = clause.halignClause() {
                node.textHorizontalAlignment = try horizontalAlignment(from: halignClause.horizontalAlignValue())
                continue
            }
            if let valignClause = clause.valignClause() {
                node.textVerticalAlignment = try verticalAlignment(from: valignClause.verticalAlignValue())
                continue
            }
            if let textOnBorderClause = clause.textOnBorderClause() {
                if let boolValue = textOnBorderClause.boolValue() {
                    node.allowTextOnBorder = try bool(from: boolValue)
                } else {
                    node.allowTextOnBorder = true
                }
                continue
            }
            if let paddingClause = clause.paddingClause() {
                let values = try paddingClause.intValue().map(int(from:))
                if values.count == 4 {
                    node.padding = (values[0], values[1], values[2], values[3])
                }
                continue
            }
            if let shadowClause = clause.shadowClause() {
                node.shadow = try shadow(from: shadowClause)
                continue
            }
            if let borderColorClause = clause.borderColorClause() {
                node.borderColor = try color(from: borderColorClause.colorValue())
                continue
            }
            if let fillColorClause = clause.fillColorClause() {
                node.fillColor = try color(from: fillColorClause.colorValue())
                continue
            }
            if let textColorClause = clause.textColorClause() {
                node.textColor = try color(from: textColorClause.colorValue())
                continue
            }
            if clause.floatClause() != nil {
                node.float = true
            }
        }

        return node
    }

    private static func buildArrow(
        from context: YuzuDrawDSLParser.ArrowStatementContext,
        indent: Int
    ) throws -> DSLArrowNode {
        var node = DSLArrowNode(
            indent: indent,
            start: try endpoint(from: context.endpointExpr(0)),
            end: try endpoint(from: context.endpointExpr(1)),
            label: "",
            strokeStyle: nil,
            strokeColor: nil,
            labelColor: nil,
            float: false
        )

        for clause in context.arrowClause() {
            if let styleClause = clause.styleClause() {
                node.strokeStyle = try strokeStyle(from: styleClause.strokeStyleValue())
                continue
            }
            if let strokeClause = clause.strokeClause() {
                node.strokeStyle = try strokeStyle(from: strokeClause.strokeStyleValue())
                continue
            }
            if let labelClause = clause.labelClause() {
                node.label = try string(from: labelClause.stringValue())
                continue
            }
            if let strokeColorClause = clause.strokeColorClause() {
                node.strokeColor = try color(from: strokeColorClause.colorValue())
                continue
            }
            if let labelColorClause = clause.labelColorClause() {
                node.labelColor = try color(from: labelColorClause.colorValue())
                continue
            }
            if clause.floatClause() != nil {
                node.float = true
            }
        }

        return node
    }

    private static func buildText(
        from context: YuzuDrawDSLParser.TextStatementContext,
        indent: Int
    ) throws -> DSLTextNode {
        DSLTextNode(
            indent: indent,
            text: try string(from: context.stringValue()),
            position: try context.atClause().flatMap { try position(from: $0.positionExpr()) },
            textColor: try context.textColorClause().flatMap { try color(from: $0.colorValue()) }
        )
    }

    private static func buildPencil(
        from context: YuzuDrawDSLParser.PencilStatementContext,
        indent: Int
    ) throws -> DSLPencilNode {
        let cells = try context.pencilCell().map { cell in
            DSLPencilCellNode(
                column: try int(from: cell.intValue(0)),
                row: try int(from: cell.intValue(1)),
                character: try singleCharacter(from: cell.stringValue()),
                color: try cell.colorValue().flatMap { try color(from: $0) }
            )
        }

        return DSLPencilNode(
            indent: indent,
            position: try position(from: context.positionExpr()),
            cells: cells
        )
    }

    private static func position(from context: YuzuDrawDSLParser.PositionExprContext?) throws
        -> DSLPositionSpec
    {
        guard let context else {
            throw DSLParserError.invalidSyntax("Missing position")
        }
        if let coordinate = context.coordinate() {
            return .absolute(try gridPoint(from: coordinate))
        }
        if let reference = context.referenceExpr() {
            return .reference(try referencePosition(from: reference))
        }
        throw DSLParserError.invalidSyntax("Unsupported position expression")
    }

    private static func endpoint(from context: YuzuDrawDSLParser.EndpointExprContext?) throws
        -> DSLEndpointSpec
    {
        guard let context else {
            throw DSLParserError.invalidSyntax("Missing endpoint")
        }
        if let coordinate = context.coordinate() {
            return .absolute(try gridPoint(from: coordinate))
        }
        guard let referenceTarget = context.referenceTarget() else {
            throw DSLParserError.invalidSyntax("Unsupported endpoint")
        }
        let target = try target(from: referenceTarget)
        let side = try context.sideValue().flatMap(sideValue(from:))
        return .reference(target: target, side: side)
    }

    private static func referencePosition(
        from context: YuzuDrawDSLParser.ReferenceExprContext
    ) throws -> DSLReferencePosition {
        let target = try self.target(from: context.referenceTarget())
        let side = try context.sideValue().flatMap(sideValue(from:))

        var columnOffset = 0
        var rowOffset = 0
        if let offset = context.offsetExpr() {
            let raw = offset.getText()
            let parts = raw.split(separator: ",", maxSplits: 1).map(String.init)
            if let first = parts.first, let value = Int(first) {
                columnOffset = value
            }
            if parts.count == 2, let value = Int(parts[1]) {
                rowOffset = value
            }
        }

        return DSLReferencePosition(
            target: target,
            side: side,
            columnOffset: columnOffset,
            rowOffset: rowOffset
        )
    }

    private static func semanticPosition(
        from context: YuzuDrawDSLParser.SemanticPositionClauseContext
    ) throws -> DSLSemanticPositionSpec {
        guard let directionText = context.directionKeyword()?.getText(),
              let direction = DSLSemanticDirection(rawValue: directionText)
        else {
            throw DSLParserError.invalidSyntax("Unsupported semantic direction")
        }

        return DSLSemanticPositionSpec(
            direction: direction,
            target: try target(from: context.referenceTarget()),
            gap: try context.gapClause()?.intValue().flatMap(int(from:))
        )
    }

    private static func shadow(from context: YuzuDrawDSLParser.ShadowClauseContext) throws
        -> DSLShadowSpec
    {
        var offsetX = 1
        var offsetY = 1
        for clause in context.shadowOffsetClause() {
            if clause.XKW() != nil {
                offsetX = try int(from: clause.signedInt())
            }
            if clause.YKW() != nil {
                offsetY = try int(from: clause.signedInt())
            }
        }

        return DSLShadowSpec(
            style: try shadowStyle(from: context.shadowStyleValue()),
            offsetX: offsetX,
            offsetY: offsetY
        )
    }

    private static func target(from context: YuzuDrawDSLParser.ReferenceTargetContext?) throws
        -> String
    {
        guard let context else {
            throw DSLParserError.invalidSyntax("Missing reference target")
        }
        if let stringValue = context.stringValue() {
            return try string(from: stringValue)
        }
        if let identifier = context.identifier() {
            return identifier.getText()
        }
        throw DSLParserError.invalidSyntax("Invalid reference target")
    }

    private static func string(from context: YuzuDrawDSLParser.StringValueContext?) throws -> String {
        guard let raw = context?.getText(), raw.first == "\"", raw.last == "\"" else {
            throw DSLParserError.invalidSyntax("Expected quoted string")
        }
        let body = String(raw.dropFirst().dropLast())
        return body
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\", with: "\\")
    }

    private static func singleCharacter(from context: YuzuDrawDSLParser.StringValueContext?) throws
        -> Character
    {
        let value = try string(from: context)
        guard let first = value.first else {
            throw DSLParserError.invalidSyntax("Expected non-empty character literal")
        }
        return first
    }

    private static func gridPoint(from context: YuzuDrawDSLParser.CoordinateContext?) throws
        -> GridPoint
    {
        guard let context else {
            throw DSLParserError.invalidSyntax("Missing coordinate")
        }
        return GridPoint(
            column: try int(from: context.signedInt(0)),
            row: try int(from: context.signedInt(1))
        )
    }

    private static func gridSize(from context: YuzuDrawDSLParser.DimensionContext?) throws
        -> GridSize
    {
        guard let raw = context?.getText() else {
            throw DSLParserError.invalidSyntax("Missing size")
        }
        let parts = raw.lowercased().split(separator: "x")
        guard parts.count == 2, let width = Int(parts[0]), let height = Int(parts[1]) else {
            throw DSLParserError.invalidSyntax("Invalid size literal")
        }
        return GridSize(width: width, height: height)
    }

    private static func int(from context: YuzuDrawDSLParser.IntValueContext?) throws -> Int {
        guard let raw = context?.getText(), let value = Int(raw) else {
            throw DSLParserError.invalidSyntax("Expected integer")
        }
        return value
    }

    private static func int(from context: YuzuDrawDSLParser.SignedIntContext?) throws -> Int {
        guard let raw = context?.getText(), let value = Int(raw) else {
            throw DSLParserError.invalidSyntax("Expected signed integer")
        }
        return value
    }

    private static func color(from context: YuzuDrawDSLParser.ColorValueContext?) throws -> ShapeColor {
        guard let raw = context?.getText(), let color = ShapeColor(hex: raw) else {
            throw DSLParserError.invalidSyntax("Invalid color literal")
        }
        return color
    }

    private static func strokeStyle(from context: YuzuDrawDSLParser.StrokeStyleValueContext?) throws
        -> StrokeStyle
    {
        guard let raw = context?.getText(), let style = StrokeStyle(rawValue: raw) else {
            throw DSLParserError.invalidSyntax("Invalid stroke style")
        }
        return style
    }

    private static func fillMode(from context: YuzuDrawDSLParser.FillModeValueContext?) throws
        -> RectangleFillMode
    {
        guard let raw = context?.getText() else {
            throw DSLParserError.invalidSyntax("Invalid fill mode")
        }
        switch raw {
        case "opaque": return .opaque
        case "block": return .block
        case "character": return .character
        case "solid": return .opaque
        case "transparent", "none": return .none
        default: throw DSLParserError.invalidSyntax("Invalid fill mode")
        }
    }

    private static func borderLineStyle(
        from context: YuzuDrawDSLParser.BorderLineStyleValueContext?
    ) throws -> RectangleBorderLineStyle {
        guard let raw = context?.getText(), let style = RectangleBorderLineStyle(rawValue: raw) else {
            throw DSLParserError.invalidSyntax("Invalid border line style")
        }
        return style
    }

    private static func horizontalAlignment(
        from context: YuzuDrawDSLParser.HorizontalAlignValueContext?
    ) throws -> RectangleTextHorizontalAlignment {
        guard let raw = context?.getText(),
              let alignment = RectangleTextHorizontalAlignment(rawValue: raw)
        else {
            throw DSLParserError.invalidSyntax("Invalid horizontal alignment")
        }
        return alignment
    }

    private static func verticalAlignment(
        from context: YuzuDrawDSLParser.VerticalAlignValueContext?
    ) throws -> RectangleTextVerticalAlignment {
        guard let raw = context?.getText(),
              let alignment = RectangleTextVerticalAlignment(rawValue: raw)
        else {
            throw DSLParserError.invalidSyntax("Invalid vertical alignment")
        }
        return alignment
    }

    private static func shadowStyle(from context: YuzuDrawDSLParser.ShadowStyleValueContext?) throws
        -> RectangleShadowStyle
    {
        guard let raw = context?.getText(), let style = RectangleShadowStyle(rawValue: raw) else {
            throw DSLParserError.invalidSyntax("Invalid shadow style")
        }
        return style
    }

    private static func sideValue(from context: YuzuDrawDSLParser.SideValueContext?) throws
        -> ArrowAttachmentSide
    {
        guard let raw = context?.getText(), let side = ArrowAttachmentSide(rawValue: raw) else {
            throw DSLParserError.invalidSyntax("Invalid side value")
        }
        return side
    }

    private static func borderSide(from context: YuzuDrawDSLParser.SideValueContext?) throws
        -> RectangleBorderSide
    {
        guard let raw = context?.getText(), let side = RectangleBorderSide(rawValue: raw) else {
            throw DSLParserError.invalidSyntax("Invalid border side")
        }
        return side
    }

    private static func bool(from context: YuzuDrawDSLParser.BoolValueContext?) throws -> Bool {
        guard let raw = context?.getText() else {
            throw DSLParserError.invalidSyntax("Invalid boolean value")
        }
        switch raw {
        case "true": return true
        case "false": return false
        default: throw DSLParserError.invalidSyntax("Invalid boolean value")
        }
    }
}
