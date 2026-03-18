import Foundation

enum DSLSemanticAnalyzer {
    private struct ResolvedRect {
        var origin: GridPoint
        var size: GridSize
        var id: String?
        var label: String

        var minColumn: Int { origin.column }
        var minRow: Int { origin.row }
        var maxColumn: Int { origin.column + size.width - 1 }
        var maxRow: Int { origin.row + size.height - 1 }
    }

    private struct ResolvedGroup {
        var id: String?
        var absoluteOrigin: GridPoint
    }

    static func lower(_ document: DSLDocumentNode) throws -> Document {
        let statements = document.statements
        let scopeChains = buildScopeChains(for: statements)
        let resolvedGroups = try resolveGroups(in: statements, scopeChains: scopeChains)

        var shapesByStatement: [Int: AnyShape] = [:]
        var rectsByStatement: [Int: ResolvedRect] = [:]
        var rectanglesByStatement: [Int: RectangleShape] = [:]

        for (index, statement) in statements.enumerated() {
            guard case .rectangle(let node) = statement else { continue }
            let resolved = try resolveRectangle(
                node: node,
                statementIndex: index,
                statements: statements,
                scopeChains: scopeChains,
                resolvedGroups: resolvedGroups,
                rectsByStatement: rectsByStatement
            )
            let rectangle = makeRectangle(node: node, resolved: resolved)
            rectsByStatement[index] = resolved
            rectanglesByStatement[index] = rectangle
            shapesByStatement[index] = .rectangle(rectangle)
        }

        for (index, statement) in statements.enumerated() {
            switch statement {
            case .rectangle, .layer, .group:
                continue
            case .arrow(let node):
                shapesByStatement[index] = .arrow(
                    try makeArrow(
                        node: node,
                        statementIndex: index,
                        statements: statements,
                        scopeChains: scopeChains,
                        rectanglesByStatement: rectanglesByStatement
                    ))
            case .text(let node):
                shapesByStatement[index] = .text(
                    try makeText(
                        node: node,
                        statementIndex: index,
                        statements: statements,
                        scopeChains: scopeChains,
                        resolvedGroups: resolvedGroups,
                        rectsByStatement: rectsByStatement
                    ))
            case .pencil(let node):
                shapesByStatement[index] = .pencil(
                    try makePencil(
                        node: node,
                        statementIndex: index,
                        statements: statements,
                        scopeChains: scopeChains,
                        resolvedGroups: resolvedGroups,
                        rectsByStatement: rectsByStatement
                    ))
            }
        }

        let orderedShapes = statements.enumerated().compactMap { shapesByStatement[$0.offset] }
        let groups = buildGroups(
            from: statements,
            shapesByStatement: shapesByStatement,
            resolvedGroups: resolvedGroups
        )
        return Document(shapes: orderedShapes, groups: groups)
    }

    private static func buildScopeChains(for statements: [DSLStatementNode]) -> [Int: [Int]] {
        var scopeChains: [Int: [Int]] = [:]
        var stack: [(index: Int, indent: Int)] = []

        for (index, statement) in statements.enumerated() {
            let indent = statement.indent
            while let top = stack.last, top.indent >= indent {
                stack.removeLast()
            }

            scopeChains[index] = stack.map(\.index)

            if case .group = statement {
                stack.append((index, indent))
            } else if case .layer = statement {
                stack.removeAll()
            }
        }

        return scopeChains
    }

    private static func resolveGroups(
        in statements: [DSLStatementNode],
        scopeChains: [Int: [Int]]
    ) throws -> [Int: ResolvedGroup] {
        var resolved: [Int: ResolvedGroup] = [:]

        for (index, statement) in statements.enumerated() {
            guard case .group(let node) = statement else { continue }
            let scopeChain = scopeChains[index] ?? []
            let parentOrigin = effectiveScopeOrigin(
                for: scopeChain,
                resolvedGroups: resolved
            )

            let absoluteOrigin: GridPoint
            if let position = node.position {
                absoluteOrigin = try resolveGroupPosition(
                    position,
                    statementIndex: index,
                    statements: statements,
                    scopeChains: scopeChains,
                    resolvedGroups: resolved,
                    parentOrigin: parentOrigin
                )
            } else {
                absoluteOrigin = parentOrigin
            }

            resolved[index] = ResolvedGroup(id: node.id, absoluteOrigin: absoluteOrigin)
        }

        return resolved
    }

    private static func resolveGroupPosition(
        _ position: DSLPositionSpec,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        resolvedGroups: [Int: ResolvedGroup],
        parentOrigin: GridPoint
    ) throws -> GridPoint {
        switch position {
        case .absolute(let point):
            return parentOrigin + point
        case .reference(let reference):
            guard reference.side == nil else {
                throw DSLParserError.invalidSyntax("Group positions do not support side attachments")
            }
            if reference.target == "root" {
                return GridPoint.zero
                    + GridPoint(column: reference.columnOffset, row: reference.rowOffset)
            }
            guard let groupIndex = resolveGroupIdentifier(
                named: reference.target,
                currentScope: scopeChains[statementIndex] ?? [],
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let group = resolvedGroups[groupIndex]
            else {
                throw DSLParserError.invalidSyntax("Unknown group reference: \(reference.target)")
            }
            return group.absoluteOrigin
                + GridPoint(column: reference.columnOffset, row: reference.rowOffset)
        }
    }

    private static func resolveRectangle(
        node: DSLRectangleNode,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        resolvedGroups: [Int: ResolvedGroup],
        rectsByStatement: [Int: ResolvedRect]
    ) throws -> ResolvedRect {
        let size = node.size ?? inferredSize(for: node.label)
        let scopeChain = scopeChains[statementIndex] ?? []
        let scopeOrigin = effectiveScopeOrigin(for: scopeChain, resolvedGroups: resolvedGroups)

        let origin: GridPoint
        if let position = node.position {
            origin = try resolvePosition(
                position,
                statementIndex: statementIndex,
                statements: statements,
                scopeChains: scopeChains,
                resolvedGroups: resolvedGroups,
                rectsByStatement: rectsByStatement,
                localScopeOrigin: scopeOrigin
            )
        } else if let semantic = node.semanticPosition {
            guard let targetIndex = resolveRectangleReference(
                named: semantic.target,
                currentScope: scopeChain,
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let refRect = rectsByStatement[targetIndex]
            else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(semantic.target)")
            }
            switch semantic.direction {
            case .rightOf:
                origin = GridPoint(
                    column: refRect.origin.column + refRect.size.width + (semantic.gap ?? 4),
                    row: refRect.origin.row
                )
            case .below:
                origin = GridPoint(
                    column: refRect.origin.column,
                    row: refRect.origin.row + refRect.size.height + (semantic.gap ?? 2)
                )
            case .leftOf:
                origin = GridPoint(
                    column: refRect.origin.column - size.width - (semantic.gap ?? 4),
                    row: refRect.origin.row
                )
            case .above:
                origin = GridPoint(
                    column: refRect.origin.column,
                    row: refRect.origin.row - size.height - (semantic.gap ?? 2)
                )
            }
        } else {
            origin = scopeOrigin
        }

        return ResolvedRect(origin: origin, size: size, id: node.id, label: node.label)
    }

    private static func resolvePosition(
        _ position: DSLPositionSpec,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        resolvedGroups: [Int: ResolvedGroup],
        rectsByStatement: [Int: ResolvedRect],
        localScopeOrigin: GridPoint
    ) throws -> GridPoint {
        switch position {
        case .absolute(let point):
            return localScopeOrigin + point
        case .reference(let reference):
            if reference.target == "root" {
                guard reference.side == nil else {
                    throw DSLParserError.invalidSyntax("The root reference does not support side attachments")
                }
                return GridPoint.zero
                    + GridPoint(column: reference.columnOffset, row: reference.rowOffset)
            }

            if let groupIndex = resolveGroupIdentifier(
                named: reference.target,
                currentScope: scopeChains[statementIndex] ?? [],
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let group = resolvedGroups[groupIndex]
            {
                guard reference.side == nil else {
                    throw DSLParserError.invalidSyntax("Group references do not support side attachments")
                }
                return group.absoluteOrigin
                    + GridPoint(column: reference.columnOffset, row: reference.rowOffset)
            }

            guard let rectIndex = resolveRectangleReference(
                named: reference.target,
                currentScope: scopeChains[statementIndex] ?? [],
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let rect = rectsByStatement[rectIndex]
            else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(reference.target)")
            }
            let base = attachmentOrigin(for: reference.side, rect: rect)
            return base + GridPoint(column: reference.columnOffset, row: reference.rowOffset)
        }
    }

    private static func makeRectangle(node: DSLRectangleNode, resolved: ResolvedRect) -> RectangleShape {
        let shadow = node.shadow
        let fillMode = node.fillMode ?? .none
        let fillCharacter: Character
        switch fillMode {
        case .block:
            fillCharacter = node.fillCharacter ?? "\u{2588}"
        case .character:
            fillCharacter = node.fillCharacter ?? " "
        case .opaque, .none:
            fillCharacter = node.fillCharacter ?? " "
        }

        return RectangleShape(
            name: node.id,
            origin: resolved.origin,
            size: resolved.size,
            strokeStyle: node.strokeStyle ?? .single,
            hasBorder: node.hasBorder ?? true,
            visibleBorders: node.visibleBorders ?? Set(RectangleBorderSide.allCases),
            borderLineStyle: node.borderLineStyle ?? .solid,
            borderDashLength: max(1, node.borderDashLength ?? 1),
            borderGapLength: max(0, node.borderGapLength ?? 1),
            fillMode: fillMode,
            fillCharacter: fillCharacter,
            label: node.label,
            textHorizontalAlignment: node.textHorizontalAlignment ?? .center,
            textVerticalAlignment: node.textVerticalAlignment ?? .middle,
            allowTextOnBorder: node.allowTextOnBorder ?? false,
            textPaddingLeft: max(0, node.padding?.left ?? 0),
            textPaddingRight: max(0, node.padding?.right ?? 0),
            textPaddingTop: max(0, node.padding?.top ?? 0),
            textPaddingBottom: max(0, node.padding?.bottom ?? 0),
            hasShadow: shadow != nil,
            shadowStyle: shadow?.style ?? .light,
            shadowOffsetX: shadow?.offsetX ?? 1,
            shadowOffsetY: shadow?.offsetY ?? 1,
            borderColor: node.borderColor,
            fillColor: node.fillColor,
            textColor: node.textColor,
            float: node.float
        )
    }

    private static func makeArrow(
        node: DSLArrowNode,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        rectanglesByStatement: [Int: RectangleShape]
    ) throws -> ArrowShape {
        let start = try resolve(
            endpoint: node.start,
            other: node.end,
            statementIndex: statementIndex,
            statements: statements,
            scopeChains: scopeChains,
            rectanglesByStatement: rectanglesByStatement
        )
        let end = try resolve(
            endpoint: node.end,
            other: node.start,
            statementIndex: statementIndex,
            statements: statements,
            scopeChains: scopeChains,
            rectanglesByStatement: rectanglesByStatement
        )

        return ArrowShape(
            start: start.point,
            end: end.point,
            label: node.label,
            strokeStyle: node.strokeStyle ?? .single,
            startAttachment: start.attachment,
            endAttachment: end.attachment,
            strokeColor: node.strokeColor,
            labelColor: node.labelColor,
            float: node.float
        )
    }

    private static func makeText(
        node: DSLTextNode,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        resolvedGroups: [Int: ResolvedGroup],
        rectsByStatement: [Int: ResolvedRect]
    ) throws -> TextShape {
        guard let position = node.position else {
            throw DSLParserError.invalidSyntax("Text requires a position")
        }
        let scopeOrigin = effectiveScopeOrigin(
            for: scopeChains[statementIndex] ?? [],
            resolvedGroups: resolvedGroups
        )
        return TextShape(
            origin: try resolvePosition(
                position,
                statementIndex: statementIndex,
                statements: statements,
                scopeChains: scopeChains,
                resolvedGroups: resolvedGroups,
                rectsByStatement: rectsByStatement,
                localScopeOrigin: scopeOrigin
            ),
            text: node.text,
            textColor: node.textColor
        )
    }

    private static func makePencil(
        node: DSLPencilNode,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        resolvedGroups: [Int: ResolvedGroup],
        rectsByStatement: [Int: ResolvedRect]
    ) throws -> PencilShape {
        let scopeOrigin = effectiveScopeOrigin(
            for: scopeChains[statementIndex] ?? [],
            resolvedGroups: resolvedGroups
        )
        var cells: [GridPoint: PencilCell] = [:]
        for cell in node.cells {
            cells[GridPoint(column: cell.column, row: cell.row)] = PencilCell(
                character: cell.character,
                color: cell.color
            )
        }
        return PencilShape(
            origin: try resolvePosition(
                node.position,
                statementIndex: statementIndex,
                statements: statements,
                scopeChains: scopeChains,
                resolvedGroups: resolvedGroups,
                rectsByStatement: rectsByStatement,
                localScopeOrigin: scopeOrigin
            ),
            cells: cells
        )
    }

    private static func resolve(
        endpoint: DSLEndpointSpec,
        other: DSLEndpointSpec,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        rectanglesByStatement: [Int: RectangleShape]
    ) throws -> (point: GridPoint, attachment: ArrowAttachment?) {
        switch endpoint {
        case .absolute(let point):
            return (point, nil)
        case .reference(let target, let explicitSide):
            guard let rectIndex = resolveRectangleReference(
                named: target,
                currentScope: scopeChains[statementIndex] ?? [],
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let rectangle = rectanglesByStatement[rectIndex]
            else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(target)")
            }
            let side = explicitSide
                ?? inferSide(
                    for: rectangle,
                    toward: other,
                    statementIndex: statementIndex,
                    statements: statements,
                    scopeChains: scopeChains,
                    rectanglesByStatement: rectanglesByStatement
                )
            let attachment = ArrowAttachment(shapeID: rectangle.id, side: side)
            return (rectangle.attachmentPoint(for: side), attachment)
        }
    }

    private static func inferSide(
        for rect: RectangleShape,
        toward other: DSLEndpointSpec,
        statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]],
        rectanglesByStatement: [Int: RectangleShape]
    ) -> ArrowAttachmentSide {
        let rectCenter = GridPoint(
            column: rect.boundingRect.minColumn + rect.boundingRect.size.width / 2,
            row: rect.boundingRect.minRow + rect.boundingRect.size.height / 2
        )
        let otherPoint: GridPoint
        switch other {
        case .absolute(let point):
            otherPoint = point
        case .reference(let target, let explicitSide):
            if let rectIndex = resolveRectangleReference(
                named: target,
                currentScope: scopeChains[statementIndex] ?? [],
                before: statementIndex,
                statements: statements,
                scopeChains: scopeChains
            ),
                let otherRect = rectanglesByStatement[rectIndex]
            {
                let side = explicitSide ?? inferredSide(from: otherRect, to: rect)
                otherPoint = otherRect.attachmentPoint(for: side)
            } else {
                otherPoint = rectCenter
            }
        }

        let deltaColumn = otherPoint.column - rectCenter.column
        let deltaRow = otherPoint.row - rectCenter.row
        if abs(deltaColumn) >= abs(deltaRow) {
            return deltaColumn >= 0 ? .right : .left
        }
        return deltaRow >= 0 ? .bottom : .top
    }

    private static func inferredSide(from rect: RectangleShape, to other: RectangleShape) -> ArrowAttachmentSide {
        let rectCenter = GridPoint(
            column: rect.boundingRect.minColumn + rect.boundingRect.size.width / 2,
            row: rect.boundingRect.minRow + rect.boundingRect.size.height / 2
        )
        let otherCenter = GridPoint(
            column: other.boundingRect.minColumn + other.boundingRect.size.width / 2,
            row: other.boundingRect.minRow + other.boundingRect.size.height / 2
        )
        let deltaColumn = otherCenter.column - rectCenter.column
        let deltaRow = otherCenter.row - rectCenter.row
        if abs(deltaColumn) >= abs(deltaRow) {
            return deltaColumn >= 0 ? .right : .left
        }
        return deltaRow >= 0 ? .bottom : .top
    }

    private static func buildGroups(
        from statements: [DSLStatementNode],
        shapesByStatement: [Int: AnyShape],
        resolvedGroups: [Int: ResolvedGroup]
    ) -> [ShapeGroup] {
        struct StackEntry {
            var statementIndex: Int
            var name: String
            var identifier: String?
            var origin: GridPoint?
            var indent: Int
            var shapeIDs: [UUID]
            var children: [ShapeGroup]
        }

        var stack: [StackEntry] = []
        var groups: [ShapeGroup] = []

        func flush(to indent: Int) {
            while let top = stack.last, top.indent >= indent {
                let entry = stack.removeLast()
                let group = ShapeGroup(
                    name: entry.name,
                    identifier: entry.identifier,
                    origin: entry.origin,
                    shapeIDs: entry.shapeIDs,
                    children: entry.children
                )
                if stack.isEmpty {
                    groups.append(group)
                } else {
                    stack[stack.count - 1].children.append(group)
                }
            }
        }

        for (index, statement) in statements.enumerated() {
            switch statement {
            case .layer:
                flush(to: Int.min)
            case .group(let node):
                flush(to: node.indent)
                stack.append(
                    StackEntry(
                        statementIndex: index,
                        name: node.name,
                        identifier: node.id,
                        origin: node.position == nil ? nil : resolvedGroups[index]?.absoluteOrigin,
                        indent: node.indent,
                        shapeIDs: [],
                        children: []
                    ))
            case .rectangle(let node):
                flush(to: node.indent)
                if let shape = shapesByStatement[index], !stack.isEmpty {
                    stack[stack.count - 1].shapeIDs.append(shape.id)
                }
            case .arrow(let node):
                flush(to: node.indent)
                if let shape = shapesByStatement[index], !stack.isEmpty {
                    stack[stack.count - 1].shapeIDs.append(shape.id)
                }
            case .text(let node):
                flush(to: node.indent)
                if let shape = shapesByStatement[index], !stack.isEmpty {
                    stack[stack.count - 1].shapeIDs.append(shape.id)
                }
            case .pencil(let node):
                flush(to: node.indent)
                if let shape = shapesByStatement[index], !stack.isEmpty {
                    stack[stack.count - 1].shapeIDs.append(shape.id)
                }
            }
        }

        flush(to: Int.min)
        return groups
    }

    private static func effectiveScopeOrigin(
        for scopeChain: [Int],
        resolvedGroups: [Int: ResolvedGroup]
    ) -> GridPoint {
        guard let groupIndex = scopeChain.last, let group = resolvedGroups[groupIndex] else {
            return .zero
        }
        return group.absoluteOrigin
    }

    private static func resolveGroupIdentifier(
        named name: String,
        currentScope: [Int],
        before statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]]
    ) -> Int? {
        for ancestorIndex in currentScope.reversed() {
            guard ancestorIndex < statementIndex,
                  case .group(let node) = statements[ancestorIndex],
                  node.id == name
            else { continue }
            return ancestorIndex
        }

        for depth in stride(from: currentScope.count, through: 0, by: -1) {
            let scope = Array(currentScope.prefix(depth))
            for index in stride(from: statementIndex - 1, through: 0, by: -1) {
                guard case .group(let node) = statements[index],
                      node.id == name,
                      scopeChains[index] == scope
                else { continue }
                return index
            }
        }

        return nil
    }

    private static func resolveRectangleReference(
        named name: String,
        currentScope: [Int],
        before statementIndex: Int,
        statements: [DSLStatementNode],
        scopeChains: [Int: [Int]]
    ) -> Int? {
        for depth in stride(from: currentScope.count, through: 0, by: -1) {
            let scope = Array(currentScope.prefix(depth))
            for index in stride(from: statementIndex - 1, through: 0, by: -1) {
                guard case .rectangle(let node) = statements[index], scopeChains[index] == scope else {
                    continue
                }
                if node.id == name || node.label == name {
                    return index
                }
            }
        }

        // Preserve legacy cross-group references by falling back to any prior rectangle
        // when there is no lexical-scope match.
        for index in stride(from: statementIndex - 1, through: 0, by: -1) {
            guard case .rectangle(let node) = statements[index] else { continue }
            if node.id == name || node.label == name {
                return index
            }
        }

        return nil
    }

    private static func attachmentOrigin(for side: ArrowAttachmentSide?, rect: ResolvedRect) -> GridPoint {
        switch side {
        case .right:
            return GridPoint(column: rect.origin.column + rect.size.width, row: rect.origin.row)
        case .bottom:
            return GridPoint(column: rect.origin.column, row: rect.origin.row + rect.size.height)
        case .left, .top, nil:
            return rect.origin
        }
    }

    private static func inferredSize(for label: String) -> GridSize {
        let lines = label.split(separator: "\n", omittingEmptySubsequences: false)
        let width = max((lines.map(\.count).max() ?? 0) + 4, 10)
        let height = lines.count + 2
        return GridSize(width: width, height: height)
    }
}
