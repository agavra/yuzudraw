import Foundation

/// Expands compact DSL (reference coords, auto-sizing, semantic sugar, arrow inference)
/// into absolute-coordinate DSL that the existing parser understands.
///
/// Pipeline: `input DSL → DSLPreprocessor.expand() → expanded DSL → DSLParser.parse()`
enum DSLPreprocessor {
    // MARK: - Public API

    static func expand(_ input: String) -> String {
        let lines = input.components(separatedBy: "\n")
        var classified = lines.map { classifyLine($0) }

        // Pass 2: resolve sizes, then positions
        resolveAutoSizes(&classified)

        let registry = buildRegistry(classified)
        let order = topologicalOrder(classified, registry: registry)
        let resolved = resolvePositions(&classified, registry: registry, order: order)

        // Pass 3: rewrite lines
        resolveArrows(&classified, registry: resolved)
        return classified.map(\.output).joined(separator: "\n")
    }

    // MARK: - Line classification

    private enum LineKind {
        case rect(RectInfo)
        case arrow(ArrowInfo)
        case textLine(TextInfo)
        case pencilLine(PencilInfo)
        case passthrough
    }

    private struct RectInfo {
        var label: String
        var id: String?
        var explicitPosition: (Int, Int)?
        var referencePosition: ReferencePosition?
        var semanticPosition: SemanticPosition?
        var explicitSize: (Int, Int)?
        var resolvedPosition: (Int, Int)?
        var resolvedSize: (Int, Int)?
        var remainingProps: String  // everything after label/id/position/size
        var indent: String
        var keyword: String  // "rect", "rectangle", "box"
    }

    private struct ArrowInfo {
        var fromRef: EndpointRef?
        var toRef: EndpointRef?
        var originalLine: String
        var indent: String
    }

    private struct TextInfo {
        var referencePosition: ReferencePosition?
        var resolvedPosition: (Int, Int)?
        var originalLine: String
        var indent: String
    }

    private struct PencilInfo {
        var referencePosition: ReferencePosition?
        var resolvedPosition: (Int, Int)?
        var originalLine: String
        var indent: String
    }

    private struct ReferencePosition {
        var ref: String     // ID or quoted label (without quotes)
        var side: String?   // "right", "bottom", "left", "top", or nil for origin
        var colOffset: Int
        var rowOffset: Int
    }

    private struct SemanticPosition {
        var direction: String  // "right-of", "below", "left-of", "above"
        var ref: String        // ID or label
        var gap: Int?          // custom gap override
    }

    private enum EndpointRef {
        case bare(String)           // just "Label" or id — needs side inference
        case explicit(String)       // already has .side — pass through
    }

    private struct ClassifiedLine {
        var kind: LineKind
        var original: String
        var output: String  // rewritten output, starts as original

        /// Key used in the registry (id or label) for rect lines
        var registryKeys: [String] {
            guard case .rect(let info) = kind else { return [] }
            var keys: [String] = []
            if let id = info.id { keys.append(id) }
            if !info.label.isEmpty { keys.append(info.label) }
            return keys
        }

        /// Dependencies: what refs does this line's position depend on?
        var positionDependencies: [String] {
            switch kind {
            case .rect(let info):
                if let ref = info.referencePosition { return [ref.ref] }
                if let sem = info.semanticPosition { return [sem.ref] }
                return []
            case .textLine(let info):
                if let ref = info.referencePosition { return [ref.ref] }
                return []
            case .pencilLine(let info):
                if let ref = info.referencePosition { return [ref.ref] }
                return []
            default:
                return []
            }
        }
    }

    // MARK: - Pass 1: Classify

    private static func classifyLine(_ line: String) -> ClassifiedLine {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let indent = String(line.prefix(while: { $0 == " " }))

        if let info = parseRectLine(trimmed, indent: indent) {
            return ClassifiedLine(kind: .rect(info), original: line, output: line)
        }
        if let info = parseArrowLine(trimmed, indent: indent) {
            return ClassifiedLine(kind: .arrow(info), original: line, output: line)
        }
        if let info = parseTextLine(trimmed, indent: indent) {
            return ClassifiedLine(kind: .textLine(info), original: line, output: line)
        }
        if let info = parsePencilLine(trimmed, indent: indent) {
            return ClassifiedLine(kind: .pencilLine(info), original: line, output: line)
        }
        return ClassifiedLine(kind: .passthrough, original: line, output: line)
    }

    // MARK: - Rect line parsing

    private static let rectKeywords: Set<String> = [
        "at", "size", "style", "stroke", "fill", "border", "noborder",
        "borders", "line", "dash", "halign", "valign", "textOnBorder",
        "padding", "shadow", "borderColor", "fillColor", "textColor",
        "float", "char", "id", "right-of", "below", "left-of", "above",
        "gap", "right", "left", "top", "bottom",
    ]

    private static func parseRectLine(_ trimmed: String, indent: String) -> RectInfo? {
        let keyword: String
        let afterKeyword: String
        if trimmed.hasPrefix("rect ") {
            keyword = "rect"
            afterKeyword = String(trimmed.dropFirst(5))
        } else if trimmed.hasPrefix("rectangle ") {
            keyword = "rectangle"
            afterKeyword = String(trimmed.dropFirst(10))
        } else if trimmed.hasPrefix("box ") {
            keyword = "box"
            afterKeyword = String(trimmed.dropFirst(4))
        } else {
            return nil
        }

        // Parse quoted label
        guard let (label, afterLabel) = parseQuotedStringAndRemainder(afterKeyword) else {
            return nil
        }

        // Parse remainder for id, position, size, and other properties
        var remaining = afterLabel.trimmingCharacters(in: .whitespaces)
        var id: String?
        var explicitPosition: (Int, Int)?
        var referencePosition: ReferencePosition?
        var semanticPosition: SemanticPosition?
        var explicitSize: (Int, Int)?
        var props: [String] = []

        while !remaining.isEmpty {
            // id keyword
            if remaining.hasPrefix("id ") {
                let afterId = String(remaining.dropFirst(3))
                let idValue = String(afterId.prefix(while: { !$0.isWhitespace }))
                if !idValue.isEmpty {
                    id = idValue
                    remaining = String(afterId.dropFirst(idValue.count))
                        .trimmingCharacters(in: .whitespaces)
                    continue
                }
            }

            // Semantic sugar: right-of, below, left-of, above
            if let sem = parseSemanticSugar(&remaining) {
                semanticPosition = sem
                continue
            }

            // at keyword with reference or absolute coords
            if remaining.hasPrefix("at ") {
                let afterAt = String(remaining.dropFirst(3))
                if let refPos = parseReferenceCoordinate(afterAt, consumedCount: &remaining) {
                    referencePosition = refPos
                    continue
                }
                // Try absolute coordinates
                if let (col, row, consumed) = parseAbsoluteCoordinate(afterAt) {
                    explicitPosition = (col, row)
                    remaining = String(afterAt.dropFirst(consumed))
                        .trimmingCharacters(in: .whitespaces)
                    continue
                }
            }

            // size keyword
            if remaining.hasPrefix("size ") {
                let afterSize = String(remaining.dropFirst(5))
                if let (w, h, consumed) = parseDimensionToken(afterSize) {
                    explicitSize = (w, h)
                    remaining = String(afterSize.dropFirst(consumed))
                        .trimmingCharacters(in: .whitespaces)
                    continue
                }
            }

            // Anything else is a property to pass through
            // Consume one token (handle quoted strings and special multi-token props)
            let token = consumeToken(&remaining)
            props.append(token)
        }

        return RectInfo(
            label: label.replacingOccurrences(of: "\\n", with: "\n"),
            id: id,
            explicitPosition: explicitPosition,
            referencePosition: referencePosition,
            semanticPosition: semanticPosition,
            explicitSize: explicitSize,
            resolvedPosition: explicitPosition,
            resolvedSize: explicitSize,
            remainingProps: props.joined(separator: " "),
            indent: indent,
            keyword: keyword
        )
    }

    // MARK: - Arrow line parsing

    private static func parseArrowLine(_ trimmed: String, indent: String) -> ArrowInfo? {
        guard trimmed.hasPrefix("arrow ") else { return nil }
        guard trimmed.contains(" from ") || trimmed.hasPrefix("arrow from ") else { return nil }

        let fromRef = parseArrowEndpoint(trimmed, keyword: "from ")
        let toRef = parseArrowEndpoint(trimmed, keyword: " to ")

        return ArrowInfo(
            fromRef: fromRef,
            toRef: toRef,
            originalLine: trimmed,
            indent: indent
        )
    }

    private static func parseArrowEndpoint(_ line: String, keyword: String) -> EndpointRef? {
        guard let range = line.range(of: keyword) else { return nil }
        let afterKeyword = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)

        // Quoted reference: "Label".side or bare "Label"
        if afterKeyword.hasPrefix("\"") {
            if let (label, afterLabel) = parseQuotedStringAndRemainder(afterKeyword) {
                let rest = afterLabel.trimmingCharacters(in: .whitespaces)
                if rest.hasPrefix(".") {
                    // Has explicit side — pass through
                    return .explicit("\"\(label)\".\(String(rest.dropFirst().prefix(while: { !$0.isWhitespace })))")
                }
                // Bare quoted label — needs side inference
                return .bare(label)
            }
        }

        // Unquoted ID reference: id.side or bare id
        let token = String(afterKeyword.prefix(while: { !$0.isWhitespace }))
        if token.isEmpty { return nil }

        // Check if it looks like coordinates (digits,digits)
        if token.contains(",") {
            let parts = token.split(separator: ",")
            if parts.count == 2, Int(parts[0]) != nil, Int(parts[1]) != nil {
                return nil  // absolute coordinates, not a reference
            }
        }

        // Check for .side
        if token.contains(".") {
            let dotParts = token.split(separator: ".", maxSplits: 1)
            if dotParts.count == 2 {
                let idPart = String(dotParts[0])
                let sidePart = String(dotParts[1])
                if ["left", "right", "top", "bottom"].contains(sidePart) {
                    return .explicit("\(idPart).\(sidePart)")
                }
            }
        }

        // Bare ID — needs side inference
        if isValidIdentifier(token) {
            return .bare(token)
        }

        return nil
    }

    // MARK: - Text line parsing

    private static func parseTextLine(_ trimmed: String, indent: String) -> TextInfo? {
        guard trimmed.hasPrefix("text ") else { return nil }
        guard trimmed.contains(" at ") else { return nil }

        // Check if the "at" part has a reference coordinate
        guard let atRange = trimmed.range(of: " at ") else { return nil }
        let afterAt = String(trimmed[atRange.upperBound...])

        var consumedStr = ""
        if let refPos = parseReferenceCoordinate(afterAt, consumedCount: &consumedStr) {
            return TextInfo(
                referencePosition: refPos,
                resolvedPosition: nil,
                originalLine: trimmed,
                indent: indent
            )
        }

        return nil  // absolute coords — no preprocessing needed
    }

    // MARK: - Pencil line parsing

    private static func parsePencilLine(_ trimmed: String, indent: String) -> PencilInfo? {
        guard trimmed.hasPrefix("pencil ") else { return nil }
        guard trimmed.contains(" at ") else { return nil }

        guard let atRange = trimmed.range(of: " at ") else { return nil }
        let afterAt = String(trimmed[atRange.upperBound...])

        var consumedStr = ""
        if let refPos = parseReferenceCoordinate(afterAt, consumedCount: &consumedStr) {
            return PencilInfo(
                referencePosition: refPos,
                resolvedPosition: nil,
                originalLine: trimmed,
                indent: indent
            )
        }

        return nil
    }

    // MARK: - Reference coordinate parsing

    /// Parse a reference coordinate like `"Label".right+4,2` or `srv1.bottom+0,-3` or `"A".right` or `"A"+4,2`
    /// Updates `consumedCount` with the remaining string after consuming.
    private static func parseReferenceCoordinate(
        _ text: String, consumedCount: inout String
    ) -> ReferencePosition? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        var ref: String
        var afterRef: Substring

        // Quoted reference
        if trimmed.hasPrefix("\"") {
            guard let (label, remainder) = parseQuotedStringAndRemainder(trimmed) else {
                return nil
            }
            ref = label
            afterRef = Substring(remainder)
        } else {
            // Unquoted ID: consume identifier chars
            let idStr = String(trimmed.prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" }))
            if idStr.isEmpty || !isValidIdentifier(idStr) { return nil }
            ref = idStr
            afterRef = trimmed.dropFirst(idStr.count)
        }

        // Must have . or + or - after ref (otherwise not a reference coord)
        var side: String?
        if afterRef.hasPrefix(".") {
            afterRef = afterRef.dropFirst()
            let sideStr = String(afterRef.prefix(while: { $0.isLetter }))
            if ["right", "bottom", "left", "top"].contains(sideStr) {
                side = sideStr
                afterRef = afterRef.dropFirst(sideStr.count)
            } else {
                return nil
            }
        }

        // Parse optional offset: +col,row or -col,row
        var colOffset = 0
        var rowOffset = 0
        if afterRef.hasPrefix("+") || afterRef.hasPrefix("-") {
            let sign: Int = afterRef.hasPrefix("-") ? -1 : 1
            afterRef = afterRef.dropFirst()

            // Parse first number (could be negative if sign was for it)
            let firstNumStr = String(afterRef.prefix(while: { $0.isNumber }))
            guard let firstNum = Int(firstNumStr), !firstNumStr.isEmpty else {
                return nil
            }
            colOffset = sign * firstNum
            afterRef = afterRef.dropFirst(firstNumStr.count)

            if afterRef.hasPrefix(",") {
                afterRef = afterRef.dropFirst()

                // Parse second number (may have its own sign)
                var rowSign = 1
                if afterRef.hasPrefix("-") {
                    rowSign = -1
                    afterRef = afterRef.dropFirst()
                } else if afterRef.hasPrefix("+") {
                    afterRef = afterRef.dropFirst()
                }

                let secondNumStr = String(afterRef.prefix(while: { $0.isNumber }))
                guard let secondNum = Int(secondNumStr), !secondNumStr.isEmpty else {
                    return nil
                }
                rowOffset = rowSign * secondNum
                afterRef = afterRef.dropFirst(secondNumStr.count)
            }
        } else if side == nil {
            // No side and no offset — this isn't a reference coordinate
            return nil
        }

        consumedCount = String(afterRef).trimmingCharacters(in: .whitespaces)
        return ReferencePosition(ref: ref, side: side, colOffset: colOffset, rowOffset: rowOffset)
    }

    // MARK: - Semantic sugar parsing

    private static func parseSemanticSugar(_ remaining: inout String) -> SemanticPosition? {
        let directions = ["right-of", "below", "left-of", "above"]
        for dir in directions {
            guard remaining.hasPrefix("\(dir) ") else { continue }
            var afterDir = String(remaining.dropFirst(dir.count + 1))
                .trimmingCharacters(in: .whitespaces)

            // Parse ref (quoted or unquoted)
            var ref: String
            if afterDir.hasPrefix("\"") {
                guard let (label, remainder) = parseQuotedStringAndRemainder(afterDir) else {
                    continue
                }
                ref = label
                afterDir = remainder.trimmingCharacters(in: .whitespaces)
            } else {
                let idStr = String(afterDir.prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" }))
                if idStr.isEmpty { continue }
                ref = idStr
                afterDir = String(afterDir.dropFirst(idStr.count))
                    .trimmingCharacters(in: .whitespaces)
            }

            // Optional gap override
            var gap: Int?
            if afterDir.hasPrefix("gap ") {
                let afterGap = String(afterDir.dropFirst(4))
                let numStr = String(afterGap.prefix(while: { $0.isNumber }))
                if let num = Int(numStr) {
                    gap = num
                    afterDir = String(afterGap.dropFirst(numStr.count))
                        .trimmingCharacters(in: .whitespaces)
                }
            }

            remaining = afterDir
            return SemanticPosition(direction: dir, ref: ref, gap: gap)
        }
        return nil
    }

    // MARK: - Pass 2: Resolve sizes and positions

    private struct ResolvedRect {
        var col: Int
        var row: Int
        var width: Int
        var height: Int
    }

    private static func resolveAutoSizes(_ lines: inout [ClassifiedLine]) {
        for i in 0..<lines.count {
            guard case .rect(var info) = lines[i].kind else { continue }
            if info.explicitSize == nil {
                let label = info.label
                let textLines = label.split(separator: "\n", omittingEmptySubsequences: false)
                let longestLine = textLines.map(\.count).max() ?? 0
                let width = max(longestLine + 4, 10)
                let height = textLines.count + 2
                info.resolvedSize = (width, height)
            }
            lines[i].kind = .rect(info)
        }
    }

    private static func buildRegistry(_ lines: [ClassifiedLine]) -> [String: (Int, ResolvedRect?)] {
        // Map ref key → (line index, resolved rect if available)
        var registry: [String: (Int, ResolvedRect?)] = [:]
        for (i, line) in lines.enumerated() {
            guard case .rect(let info) = line.kind else { continue }
            let rect: ResolvedRect?
            if let pos = info.resolvedPosition, let size = info.resolvedSize {
                rect = ResolvedRect(col: pos.0, row: pos.1, width: size.0, height: size.1)
            } else if let size = info.resolvedSize {
                rect = ResolvedRect(col: 0, row: 0, width: size.0, height: size.1)
            } else {
                rect = nil
            }

            // ID takes priority
            if let id = info.id {
                registry[id] = (i, rect)
            }
            if !info.label.isEmpty {
                // Only set label key if not already taken by an ID
                if registry[info.label] == nil {
                    registry[info.label] = (i, rect)
                }
            }
        }
        return registry
    }

    private static func topologicalOrder(
        _ lines: [ClassifiedLine], registry: [String: (Int, ResolvedRect?)]
    ) -> [Int] {
        // Build adjacency: line index → dependent line indices
        var inDegree = [Int: Int]()
        var dependents = [Int: [Int]]()

        // Collect all line indices that have position dependencies
        var lineIndicesWithDeps = Set<Int>()
        for (i, line) in lines.enumerated() {
            let deps = line.positionDependencies
            if !deps.isEmpty {
                lineIndicesWithDeps.insert(i)
            }
            for dep in deps {
                if let (depIdx, _) = registry[dep] {
                    inDegree[i, default: 0] += 1
                    dependents[depIdx, default: []].append(i)
                }
            }
        }

        // Kahn's algorithm
        var queue: [Int] = []
        for (i, line) in lines.enumerated() {
            guard case .rect = line.kind else { continue }
            if inDegree[i, default: 0] == 0 {
                queue.append(i)
            }
        }
        // Also add text/pencil lines with no dependencies
        for (i, line) in lines.enumerated() {
            switch line.kind {
            case .textLine, .pencilLine:
                if inDegree[i, default: 0] == 0 && lineIndicesWithDeps.contains(i) {
                    queue.append(i)
                }
            default: break
            }
        }

        var order: [Int] = []
        var visited = Set<Int>()
        while !queue.isEmpty {
            let idx = queue.removeFirst()
            if visited.contains(idx) { continue }
            visited.insert(idx)
            order.append(idx)
            for dep in dependents[idx, default: []] {
                inDegree[dep, default: 0] -= 1
                if inDegree[dep, default: 0] == 0 {
                    queue.append(dep)
                }
            }
        }

        return order
    }

    @discardableResult
    private static func resolvePositions(
        _ lines: inout [ClassifiedLine],
        registry: [String: (Int, ResolvedRect?)],
        order: [Int]
    ) -> [String: ResolvedRect] {
        // Mutable registry for resolved rects
        var resolved: [String: ResolvedRect] = [:]

        // Seed with already-positioned rects
        for (_, line) in lines.enumerated() {
            guard case .rect(let info) = line.kind else { continue }
            if let pos = info.resolvedPosition, let size = info.resolvedSize {
                let rect = ResolvedRect(col: pos.0, row: pos.1, width: size.0, height: size.1)
                if let id = info.id { resolved[id] = rect }
                if !info.label.isEmpty { resolved[info.label] = rect }
            }
        }

        // Default rects with no position at all to (0,0) if they have no deps
        for (i, line) in lines.enumerated() {
            guard case .rect(var info) = line.kind else { continue }
            if info.resolvedPosition == nil && info.referencePosition == nil
                && info.semanticPosition == nil
            {
                info.resolvedPosition = (0, 0)
                let size = info.resolvedSize ?? (10, 3)
                let rect = ResolvedRect(col: 0, row: 0, width: size.0, height: size.1)
                if let id = info.id { resolved[id] = rect }
                if !info.label.isEmpty { resolved[info.label] = rect }
                lines[i].kind = .rect(info)
            }
        }

        // Process in topological order
        for idx in order {
            switch lines[idx].kind {
            case .rect(var info):
                if info.resolvedPosition != nil {
                    // Already resolved, ensure it's in the resolved map
                    let size = info.resolvedSize ?? (10, 3)
                    let rect = ResolvedRect(
                        col: info.resolvedPosition!.0, row: info.resolvedPosition!.1,
                        width: size.0, height: size.1)
                    if let id = info.id { resolved[id] = rect }
                    if !info.label.isEmpty { resolved[info.label] = rect }
                    continue
                }

                if let refPos = info.referencePosition,
                    let refRect = resolved[refPos.ref]
                {
                    let pos = computeReferencePosition(refPos, refRect: refRect)
                    info.resolvedPosition = pos
                    lines[idx].kind = .rect(info)
                    let size = info.resolvedSize ?? (10, 3)
                    let rect = ResolvedRect(
                        col: pos.0, row: pos.1, width: size.0, height: size.1)
                    if let id = info.id { resolved[id] = rect }
                    if !info.label.isEmpty { resolved[info.label] = rect }
                }

                if let sem = info.semanticPosition,
                    let refRect = resolved[sem.ref]
                {
                    let selfSize = info.resolvedSize ?? (10, 3)
                    let pos = computeSemanticPosition(
                        sem, refRect: refRect, selfWidth: selfSize.0, selfHeight: selfSize.1)
                    info.resolvedPosition = pos
                    lines[idx].kind = .rect(info)
                    let rect = ResolvedRect(
                        col: pos.0, row: pos.1, width: selfSize.0, height: selfSize.1)
                    if let id = info.id { resolved[id] = rect }
                    if !info.label.isEmpty { resolved[info.label] = rect }
                }

            case .textLine(var info):
                if let refPos = info.referencePosition,
                    let refRect = resolved[refPos.ref]
                {
                    let pos = computeReferencePosition(refPos, refRect: refRect)
                    info.resolvedPosition = pos
                    lines[idx].kind = .textLine(info)
                }

            case .pencilLine(var info):
                if let refPos = info.referencePosition,
                    let refRect = resolved[refPos.ref]
                {
                    let pos = computeReferencePosition(refPos, refRect: refRect)
                    info.resolvedPosition = pos
                    lines[idx].kind = .pencilLine(info)
                }

            default:
                break
            }
        }

        // Pass 3: rewrite all lines
        for i in 0..<lines.count {
            lines[i].output = rewriteLine(lines[i], resolved: resolved)
        }

        return resolved
    }

    private static func computeReferencePosition(
        _ ref: ReferencePosition, refRect: ResolvedRect
    ) -> (Int, Int) {
        let baseCol: Int
        let baseRow: Int

        switch ref.side {
        case "right":
            baseCol = refRect.col + refRect.width
            baseRow = refRect.row
        case "bottom":
            baseCol = refRect.col
            baseRow = refRect.row + refRect.height
        case "left":
            baseCol = refRect.col
            baseRow = refRect.row
        case "top":
            baseCol = refRect.col
            baseRow = refRect.row
        case nil:
            // Origin reference
            baseCol = refRect.col
            baseRow = refRect.row
        default:
            baseCol = refRect.col
            baseRow = refRect.row
        }

        return (baseCol + ref.colOffset, baseRow + ref.rowOffset)
    }

    private static func computeSemanticPosition(
        _ sem: SemanticPosition, refRect: ResolvedRect, selfWidth: Int, selfHeight: Int
    ) -> (Int, Int) {
        switch sem.direction {
        case "right-of":
            let gap = sem.gap ?? 4
            return (refRect.col + refRect.width + gap, refRect.row)
        case "below":
            let gap = sem.gap ?? 2
            return (refRect.col, refRect.row + refRect.height + gap)
        case "left-of":
            let gap = sem.gap ?? 4
            return (refRect.col - selfWidth - gap, refRect.row)
        case "above":
            let gap = sem.gap ?? 2
            return (refRect.col, refRect.row - selfHeight - gap)
        default:
            return (refRect.col, refRect.row)
        }
    }

    // MARK: - Pass 3: Rewrite

    private static func rewriteLine(
        _ line: ClassifiedLine, resolved: [String: ResolvedRect]
    ) -> String {
        switch line.kind {
        case .rect(let info):
            return rewriteRectLine(info)
        case .textLine(let info):
            if let pos = info.resolvedPosition {
                return rewriteTextLine(info, at: pos)
            }
            return line.original
        case .pencilLine(let info):
            if let pos = info.resolvedPosition {
                return rewritePencilLine(info, at: pos)
            }
            return line.original
        case .arrow, .passthrough:
            return line.output
        }
    }

    private static func rewriteRectLine(_ info: RectInfo) -> String {
        guard let pos = info.resolvedPosition, let size = info.resolvedSize else {
            return "\(info.indent)\(info.keyword) \"\(info.label.replacingOccurrences(of: "\n", with: "\\n"))\"\(info.id.map { " id \($0)" } ?? "") at \(info.resolvedPosition.map { "\($0.0),\($0.1)" } ?? "0,0") size \(info.resolvedSize.map { "\($0.0)x\($0.1)" } ?? "10x3")\(info.remainingProps.isEmpty ? "" : " \(info.remainingProps)")"
        }

        let escapedLabel = info.label.replacingOccurrences(of: "\n", with: "\\n")
        var result = "\(info.indent)\(info.keyword) \"\(escapedLabel)\""
        if let id = info.id {
            result += " id \(id)"
        }
        result += " at \(pos.0),\(pos.1) size \(size.0)x\(size.1)"
        if !info.remainingProps.isEmpty {
            result += " \(info.remainingProps)"
        }
        return result
    }

    private static func rewriteTextLine(_ info: TextInfo, at pos: (Int, Int)) -> String {
        let trimmed = info.originalLine.trimmingCharacters(in: .whitespaces)
        // Replace the reference coordinate with absolute
        guard let atRange = trimmed.range(of: " at ") else { return info.indent + trimmed }
        let beforeAt = String(trimmed[..<atRange.lowerBound])
        let afterAt = String(trimmed[atRange.upperBound...])

        // Find end of reference coordinate (until next recognized keyword or end)
        let afterRef = skipReferenceCoordinate(afterAt)
        return "\(info.indent)\(beforeAt) at \(pos.0),\(pos.1)\(afterRef.isEmpty ? "" : " \(afterRef)")"
    }

    private static func rewritePencilLine(_ info: PencilInfo, at pos: (Int, Int)) -> String {
        let trimmed = info.originalLine.trimmingCharacters(in: .whitespaces)
        guard let atRange = trimmed.range(of: " at ") else { return info.indent + trimmed }
        let beforeAt = String(trimmed[..<atRange.lowerBound])
        let afterAt = String(trimmed[atRange.upperBound...])

        let afterRef = skipReferenceCoordinate(afterAt)
        return "\(info.indent)\(beforeAt) at \(pos.0),\(pos.1)\(afterRef.isEmpty ? "" : " \(afterRef)")"
    }

    /// Skip past a reference coordinate in text to find remaining properties
    private static func skipReferenceCoordinate(_ text: String) -> String {
        var s = Substring(text)

        // Skip quoted or unquoted ref
        if s.hasPrefix("\"") {
            guard let closeIdx = s.dropFirst().firstIndex(of: "\"") else { return String(s) }
            s = s[s.index(after: closeIdx)...]
        } else {
            s = s.drop(while: { $0.isLetter || $0.isNumber || $0 == "_" })
        }

        // Skip .side
        if s.hasPrefix(".") {
            s = s.dropFirst()
            s = s.drop(while: { $0.isLetter })
        }

        // Skip offset
        if s.hasPrefix("+") || s.hasPrefix("-") {
            s = s.dropFirst()
            s = s.drop(while: { $0.isNumber })
            if s.hasPrefix(",") {
                s = s.dropFirst()
                if s.hasPrefix("-") || s.hasPrefix("+") { s = s.dropFirst() }
                s = s.drop(while: { $0.isNumber })
            }
        }

        return String(s).trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Arrow inference

    private static func resolveArrows(
        _ lines: inout [ClassifiedLine], registry: [String: ResolvedRect]
    ) {
        for i in 0..<lines.count {
            guard case .arrow(let info) = lines[i].kind else { continue }
            lines[i].output = rewriteArrowLine(info, resolved: registry)
        }
    }

    private static func rewriteArrowLine(
        _ info: ArrowInfo, resolved: [String: ResolvedRect]
    ) -> String {
        var line = info.originalLine

        // Rewrite from endpoint
        if let fromRef = info.fromRef {
            line = rewriteArrowEndpoint(
                line, keyword: "from ", ref: fromRef, otherRef: info.toRef, resolved: resolved,
                isStart: true)
        }
        if let toRef = info.toRef {
            line = rewriteArrowEndpoint(
                line, keyword: " to ", ref: toRef, otherRef: info.fromRef, resolved: resolved,
                isStart: false)
        }

        // Handle unquoted ID references with explicit sides (e.g., srv1.right)
        line = expandUnquotedIdSides(line, keyword: "from ", resolved: resolved)
        line = expandUnquotedIdSides(line, keyword: " to ", resolved: resolved)

        return "\(info.indent)\(line)"
    }

    private static func rewriteArrowEndpoint(
        _ line: String, keyword: String, ref: EndpointRef, otherRef: EndpointRef?,
        resolved: [String: ResolvedRect], isStart: Bool
    ) -> String {
        guard case .bare(let label) = ref else { return line }

        // Find the referenced rect
        guard let rect = resolved[label] else { return line }

        // Determine other rect for side inference
        var otherRect: ResolvedRect?
        if let otherRef {
            switch otherRef {
            case .bare(let otherLabel):
                otherRect = resolved[otherLabel]
            case .explicit(let text):
                // Extract label from "Label".side or id.side
                let refName = extractRefName(text)
                otherRect = resolved[refName]
            }
        }

        let side: String
        if let other = otherRect {
            side = inferSide(thisRect: rect, otherRect: other)
        } else {
            side = isStart ? "right" : "left"
        }

        // Replace the bare reference with quoted reference + side
        guard let range = line.range(of: keyword) else { return line }
        let afterKeyword = line[range.upperBound...]
        let refText: String
        let refLength: Int

        if afterKeyword.hasPrefix("\"") {
            // Already quoted
            if let (_, remainder) = parseQuotedStringAndRemainder(String(afterKeyword)) {
                refLength = afterKeyword.count - remainder.count
                refText = "\"\(label)\".\(side)"
            } else {
                return line
            }
        } else {
            // Unquoted ID
            let token = String(afterKeyword.prefix(while: { !$0.isWhitespace }))
            refLength = token.count
            refText = "\"\(label)\".\(side)"
        }

        let startIdx = range.upperBound
        let endIdx = line.index(startIdx, offsetBy: refLength)
        return String(line[..<startIdx]) + refText + String(line[endIdx...])
    }

    private static func expandUnquotedIdSides(
        _ line: String, keyword: String, resolved: [String: ResolvedRect]
    ) -> String {
        guard let range = line.range(of: keyword) else { return line }
        let afterKeyword = String(line[range.upperBound...])
        let token = String(afterKeyword.prefix(while: { !$0.isWhitespace }))

        // Check for unquoted id.side pattern
        guard token.contains("."), !token.hasPrefix("\"") else { return line }
        let parts = token.split(separator: ".", maxSplits: 1)
        guard parts.count == 2 else { return line }
        let idPart = String(parts[0])
        let sidePart = String(parts[1])
        guard ["left", "right", "top", "bottom"].contains(sidePart) else { return line }

        // Look up by ID to find the label
        guard resolved[idPart] != nil else { return line }

        // Replace unquoted id.side with "id".side for the parser
        let replacement = "\"\(idPart)\".\(sidePart)"
        let tokenStart = range.upperBound
        let tokenEnd = line.index(tokenStart, offsetBy: token.count)
        return String(line[..<tokenStart]) + replacement + String(line[tokenEnd...])
    }

    /// Infer which side of `thisRect` should be used, given it connects to `otherRect`.
    /// The side always faces the other rect.
    private static func inferSide(
        thisRect: ResolvedRect, otherRect: ResolvedRect
    ) -> String {
        let thisCenterCol = thisRect.col + thisRect.width / 2
        let thisCenterRow = thisRect.row + thisRect.height / 2
        let otherCenterCol = otherRect.col + otherRect.width / 2
        let otherCenterRow = otherRect.row + otherRect.height / 2

        let deltaCol = otherCenterCol - thisCenterCol
        let deltaRow = otherCenterRow - thisCenterRow

        // Dominant axis wins, prefer horizontal on tie
        if abs(deltaCol) >= abs(deltaRow) {
            return deltaCol >= 0 ? "right" : "left"
        } else {
            return deltaRow >= 0 ? "bottom" : "top"
        }
    }

    private static func extractRefName(_ text: String) -> String {
        if text.hasPrefix("\"") {
            if let (label, _) = parseQuotedStringAndRemainder(text) {
                return label
            }
        }
        // Unquoted id.side
        let parts = text.split(separator: ".", maxSplits: 1)
        return String(parts[0])
    }

    // MARK: - Helpers

    private static func parseQuotedStringAndRemainder(_ text: String) -> (String, String)? {
        guard text.hasPrefix("\"") else { return nil }
        let afterOpen = text.index(after: text.startIndex)
        guard let closeQuote = text[afterOpen...].firstIndex(of: "\"") else { return nil }
        let label = String(text[afterOpen..<closeQuote])
        let remainder = String(text[text.index(after: closeQuote)...])
        return (label, remainder)
    }

    private static func parseAbsoluteCoordinate(_ text: String) -> (Int, Int, Int)? {
        // Parse "col,row" and return (col, row, characters consumed)
        let cleaned = text.prefix(while: { $0.isNumber || $0 == "," })
        let parts = cleaned.split(separator: ",")
        guard parts.count == 2, let col = Int(parts[0]), let row = Int(parts[1]) else {
            return nil
        }
        return (col, row, cleaned.count)
    }

    private static func parseDimensionToken(_ text: String) -> (Int, Int, Int)? {
        let cleaned = text.prefix(while: { $0.isNumber || $0 == "x" || $0 == "X" })
        let parts = cleaned.lowercased().split(separator: "x")
        guard parts.count == 2, let w = Int(parts[0]), let h = Int(parts[1]) else {
            return nil
        }
        return (w, h, cleaned.count)
    }

    private static func isValidIdentifier(_ text: String) -> Bool {
        guard let first = text.first, first.isLetter || first == "_" else { return false }
        let rest = text.dropFirst()
        guard rest.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) else { return false }
        // Not a keyword
        return !rectKeywords.contains(text)
    }

    private static func consumeToken(_ remaining: inout String) -> String {
        remaining = remaining.trimmingCharacters(in: .whitespaces)
        guard !remaining.isEmpty else { return "" }

        // Handle quoted strings
        if remaining.hasPrefix("\"") {
            if let (str, rest) = parseQuotedStringAndRemainder(remaining) {
                remaining = rest.trimmingCharacters(in: .whitespaces)
                return "\"\(str)\""
            }
        }

        // Handle bracket expressions (for pencil cells etc.)
        if remaining.hasPrefix("[") {
            if let closeIdx = remaining.firstIndex(of: "]") {
                let bracket = String(remaining[...closeIdx])
                remaining = String(remaining[remaining.index(after: closeIdx)...])
                    .trimmingCharacters(in: .whitespaces)
                return bracket
            }
        }

        let token = String(remaining.prefix(while: { !$0.isWhitespace }))
        remaining = String(remaining.dropFirst(token.count))
            .trimmingCharacters(in: .whitespaces)
        return token
    }
}
