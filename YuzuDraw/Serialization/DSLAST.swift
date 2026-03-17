import Foundation

struct DSLDocumentNode: Sendable {
    var statements: [DSLStatementNode]
}

enum DSLStatementNode: Sendable {
    case layer(DSLLayerNode)
    case group(DSLGroupNode)
    case rectangle(DSLRectangleNode)
    case arrow(DSLArrowNode)
    case text(DSLTextNode)
    case pencil(DSLPencilNode)

    var indent: Int {
        switch self {
        case .layer(let node): return node.indent
        case .group(let node): return node.indent
        case .rectangle(let node): return node.indent
        case .arrow(let node): return node.indent
        case .text(let node): return node.indent
        case .pencil(let node): return node.indent
        }
    }
}

struct DSLLayerNode: Sendable {
    var name: String
    var indent: Int
}

struct DSLGroupNode: Sendable {
    var name: String
    var indent: Int
}

struct DSLRectangleNode: Sendable {
    var keyword: String
    var label: String
    var indent: Int
    var id: String?
    var position: DSLPositionSpec?
    var semanticPosition: DSLSemanticPositionSpec?
    var size: GridSize?
    var strokeStyle: StrokeStyle?
    var fillMode: RectangleFillMode?
    var fillCharacter: Character?
    var hasBorder: Bool?
    var visibleBorders: Set<RectangleBorderSide>?
    var borderLineStyle: RectangleBorderLineStyle?
    var borderDashLength: Int?
    var borderGapLength: Int?
    var textHorizontalAlignment: RectangleTextHorizontalAlignment?
    var textVerticalAlignment: RectangleTextVerticalAlignment?
    var allowTextOnBorder: Bool?
    var padding: (left: Int, right: Int, top: Int, bottom: Int)?
    var shadow: DSLShadowSpec?
    var borderColor: ShapeColor?
    var fillColor: ShapeColor?
    var textColor: ShapeColor?
    var float: Bool
}

struct DSLArrowNode: Sendable {
    var indent: Int
    var start: DSLEndpointSpec
    var end: DSLEndpointSpec
    var label: String
    var strokeStyle: StrokeStyle?
    var strokeColor: ShapeColor?
    var labelColor: ShapeColor?
    var float: Bool
}

struct DSLTextNode: Sendable {
    var indent: Int
    var text: String
    var position: DSLPositionSpec?
    var textColor: ShapeColor?
}

struct DSLPencilNode: Sendable {
    var indent: Int
    var position: DSLPositionSpec
    var cells: [DSLPencilCellNode]
}

struct DSLPencilCellNode: Sendable {
    var column: Int
    var row: Int
    var character: Character
    var color: ShapeColor?
}

enum DSLPositionSpec: Sendable {
    case absolute(GridPoint)
    case reference(DSLReferencePosition)
}

struct DSLReferencePosition: Sendable {
    var target: String
    var side: ArrowAttachmentSide?
    var columnOffset: Int
    var rowOffset: Int
}

struct DSLSemanticPositionSpec: Sendable {
    var direction: DSLSemanticDirection
    var target: String
    var gap: Int?
}

enum DSLSemanticDirection: String, Sendable {
    case rightOf = "right-of"
    case below
    case leftOf = "left-of"
    case above
}

enum DSLEndpointSpec: Sendable {
    case absolute(GridPoint)
    case reference(target: String, side: ArrowAttachmentSide?)
}

struct DSLShadowSpec: Sendable {
    var style: RectangleShadowStyle
    var offsetX: Int
    var offsetY: Int
}
