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
        var centerColumn: Int { minColumn + size.width / 2 }
        var centerRow: Int { minRow + size.height / 2 }
    }

    static func lower(_ document: DSLDocumentNode) throws -> Document {
        let statements = document.statements
        let rects = try resolveRectangles(in: statements)

        var shapesByStatement: [Int: AnyShape] = [:]
        var rectangleLookup: [String: RectangleShape] = [:]

        for (index, statement) in statements.enumerated() {
            guard case .rectangle(let node) = statement else { continue }
            guard let resolved = rects[index] else {
                throw DSLParserError.invalidSyntax("Failed to resolve rectangle")
            }
            let rectangle = makeRectangle(node: node, resolved: resolved)
            shapesByStatement[index] = .rectangle(rectangle)
            if let id = node.id {
                rectangleLookup[id] = rectangle
            }
            if rectangleLookup[node.label] == nil {
                rectangleLookup[node.label] = rectangle
            }
        }

        for (index, statement) in statements.enumerated() {
            switch statement {
            case .rectangle:
                continue
            case .arrow(let node):
                shapesByStatement[index] = .arrow(try makeArrow(node: node, rectangles: rectangleLookup))
            case .text(let node):
                shapesByStatement[index] = .text(try makeText(node: node, rects: rects))
            case .pencil(let node):
                shapesByStatement[index] = .pencil(try makePencil(node: node, rects: rects))
            case .layer, .group:
                continue
            }
        }

        let orderedShapes = statements.enumerated().compactMap { shapesByStatement[$0.offset] }
        let groups = try buildGroups(from: statements, shapesByStatement: shapesByStatement)
        return Document(shapes: orderedShapes, groups: groups)
    }

    private static func resolveRectangles(in statements: [DSLStatementNode]) throws
        -> [Int: ResolvedRect]
    {
        var nodes: [Int: DSLRectangleNode] = [:]
        var sizes: [Int: GridSize] = [:]
        var dependencies: [Int: Set<Int>] = [:]
        var nameToIndex: [String: Int] = [:]

        for (index, statement) in statements.enumerated() {
            guard case .rectangle(let node) = statement else { continue }
            nodes[index] = node
            sizes[index] = node.size ?? inferredSize(for: node.label)
            if let id = node.id {
                nameToIndex[id] = index
            }
            if nameToIndex[node.label] == nil {
                nameToIndex[node.label] = index
            }
        }

        for (index, node) in nodes {
            if case .reference(let reference)? = node.position,
               let dependency = nameToIndex[reference.target]
            {
                dependencies[index, default: []].insert(dependency)
            }
            if let semantic = node.semanticPosition,
               let dependency = nameToIndex[semantic.target]
            {
                dependencies[index, default: []].insert(dependency)
            }
        }

        var resolved: [Int: ResolvedRect] = [:]
        var remaining = Set(nodes.keys)

        while !remaining.isEmpty {
            var progressed = false

            for index in remaining.sorted() {
                let unresolvedDependencies = dependencies[index, default: []].filter { resolved[$0] == nil }
                guard unresolvedDependencies.isEmpty,
                      let node = nodes[index],
                      let size = sizes[index]
                else {
                    continue
                }

                let origin = try resolveOrigin(
                    for: node,
                    size: size,
                    resolved: resolved,
                    names: nameToIndex
                )

                resolved[index] = ResolvedRect(
                    origin: origin,
                    size: size,
                    id: node.id,
                    label: node.label
                )
                remaining.remove(index)
                progressed = true
            }

            if !progressed {
                throw DSLParserError.invalidSyntax("Unresolvable rectangle layout dependencies")
            }
        }

        return resolved
    }

    private static func resolveOrigin(
        for node: DSLRectangleNode,
        size: GridSize,
        resolved: [Int: ResolvedRect],
        names: [String: Int]
    ) throws -> GridPoint {
        if let position = node.position {
            return try resolve(position: position, resolved: resolved, names: names)
        }

        if let semantic = node.semanticPosition {
            guard let index = names[semantic.target], let refRect = resolved[index] else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(semantic.target)")
            }
            switch semantic.direction {
            case .rightOf:
                return GridPoint(
                    column: refRect.origin.column + refRect.size.width + (semantic.gap ?? 4),
                    row: refRect.origin.row
                )
            case .below:
                return GridPoint(
                    column: refRect.origin.column,
                    row: refRect.origin.row + refRect.size.height + (semantic.gap ?? 2)
                )
            case .leftOf:
                return GridPoint(
                    column: refRect.origin.column - size.width - (semantic.gap ?? 4),
                    row: refRect.origin.row
                )
            case .above:
                return GridPoint(
                    column: refRect.origin.column,
                    row: refRect.origin.row - size.height - (semantic.gap ?? 2)
                )
            }
        }

        return GridPoint(column: 0, row: 0)
    }

    private static func resolve(
        position: DSLPositionSpec,
        resolved: [Int: ResolvedRect],
        names: [String: Int]
    ) throws -> GridPoint {
        switch position {
        case .absolute(let point):
            return point
        case .reference(let reference):
            guard let index = names[reference.target], let refRect = resolved[index] else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(reference.target)")
            }
            let base = attachmentOrigin(for: reference.side, rect: refRect)
            return GridPoint(
                column: base.column + reference.columnOffset,
                row: base.row + reference.rowOffset
            )
        }
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

    private static func makeArrow(node: DSLArrowNode, rectangles: [String: RectangleShape]) throws -> ArrowShape {
        let start = try resolve(endpoint: node.start, other: node.end, rectangles: rectangles)
        let end = try resolve(endpoint: node.end, other: node.start, rectangles: rectangles)

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

    private static func makeText(node: DSLTextNode, rects: [Int: ResolvedRect]) throws -> TextShape {
        let lookup = rectangleLookup(from: rects)
        guard let position = node.position else {
            throw DSLParserError.invalidSyntax("Text requires a position")
        }
        return TextShape(
            origin: try resolve(position: position, rectLookup: lookup),
            text: node.text,
            textColor: node.textColor
        )
    }

    private static func makePencil(node: DSLPencilNode, rects: [Int: ResolvedRect]) throws -> PencilShape {
        let lookup = rectangleLookup(from: rects)
        var cells: [GridPoint: PencilCell] = [:]
        for cell in node.cells {
            cells[GridPoint(column: cell.column, row: cell.row)] = PencilCell(
                character: cell.character,
                color: cell.color
            )
        }
        return PencilShape(
            origin: try resolve(position: node.position, rectLookup: lookup),
            cells: cells
        )
    }

    private static func resolve(
        position: DSLPositionSpec,
        rectLookup: [String: ResolvedRect]
    ) throws -> GridPoint {
        switch position {
        case .absolute(let point):
            return point
        case .reference(let reference):
            guard let rect = rectLookup[reference.target] else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(reference.target)")
            }
            let base = attachmentOrigin(for: reference.side, rect: rect)
            return GridPoint(
                column: base.column + reference.columnOffset,
                row: base.row + reference.rowOffset
            )
        }
    }

    private static func resolve(
        endpoint: DSLEndpointSpec,
        other: DSLEndpointSpec,
        rectangles: [String: RectangleShape]
    ) throws -> (point: GridPoint, attachment: ArrowAttachment?) {
        switch endpoint {
        case .absolute(let point):
            return (point, nil)
        case .reference(let target, let explicitSide):
            guard let rectangle = rectangles[target] else {
                throw DSLParserError.invalidSyntax("Unknown rectangle reference: \(target)")
            }
            let side = explicitSide ?? inferSide(for: rectangle, toward: other, rectangles: rectangles)
            let attachment = ArrowAttachment(shapeID: rectangle.id, side: side)
            return (rectangle.attachmentPoint(for: side), attachment)
        }
    }

    private static func inferSide(
        for rect: RectangleShape,
        toward other: DSLEndpointSpec,
        rectangles: [String: RectangleShape]
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
            if let otherRect = rectangles[target] {
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

    private static func rectangleLookup(from rects: [Int: ResolvedRect]) -> [String: ResolvedRect] {
        var lookup: [String: ResolvedRect] = [:]
        for rect in rects.values {
            if let id = rect.id {
                lookup[id] = rect
            }
            if lookup[rect.label] == nil {
                lookup[rect.label] = rect
            }
        }
        return lookup
    }

    private static func buildGroups(
        from statements: [DSLStatementNode],
        shapesByStatement: [Int: AnyShape]
    ) throws -> [ShapeGroup] {
        struct StackEntry {
            var name: String
            var indent: Int
            var shapeIDs: [UUID]
            var children: [ShapeGroup]
        }

        var stack: [StackEntry] = []
        var groups: [ShapeGroup] = []

        func flush(to indent: Int) {
            while let top = stack.last, top.indent >= indent {
                let entry = stack.removeLast()
                let group = ShapeGroup(name: entry.name, shapeIDs: entry.shapeIDs, children: entry.children)
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
                stack.append(StackEntry(name: node.name, indent: node.indent, shapeIDs: [], children: []))
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

    private static func inferredSize(for label: String) -> GridSize {
        let lines = label.split(separator: "\n", omittingEmptySubsequences: false)
        let width = max((lines.map(\.count).max() ?? 0) + 4, 10)
        let height = lines.count + 2
        return GridSize(width: width, height: height)
    }
}
