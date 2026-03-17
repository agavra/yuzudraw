grammar YuzuDrawDSL;

document
    : (statement? NEWLINE)* statement? EOF
    ;

statement
    : layerStatement
    | groupStatement
    | rectangleStatement
    | arrowStatement
    | textStatement
    | pencilStatement
    ;

layerStatement
    : LAYER stringValue (VISIBLE_KW | HIDDEN_KW)* LOCKED
    | LAYER stringValue (VISIBLE_KW | HIDDEN_KW)*
    ;

groupStatement
    : GROUP stringValue
    ;

rectangleStatement
    : rectKeyword stringValue rectangleClause*
    ;

rectKeyword
    : RECT
    | RECTANGLE
    | BOX
    ;

rectangleClause
    : idClause
    | atClause
    | sizeClause
    | styleClause
    | strokeClause
    | fillClause
    | borderClause
    | noborderClause
    | bordersClause
    | lineClause
    | dashClause
    | gapClause
    | halignClause
    | valignClause
    | textOnBorderClause
    | paddingClause
    | shadowClause
    | borderColorClause
    | fillColorClause
    | textColorClause
    | floatClause
    | semanticPositionClause
    ;

arrowStatement
    : ARROW FROM endpointExpr TO endpointExpr arrowClause*
    ;

arrowClause
    : styleClause
    | strokeClause
    | labelClause
    | strokeColorClause
    | labelColorClause
    | floatClause
    ;

textStatement
    : TEXT stringValue atClause? textColorClause?
    ;

pencilStatement
    : PENCIL AT positionExpr CELLS LBRACK pencilCell (SEMI pencilCell)* RBRACK
    ;

pencilCell
    : intValue COMMA intValue COMMA stringValue (COMMA colorValue)?
    ;

idClause
    : IDKW identifier
    ;

atClause
    : AT positionExpr
    ;

sizeClause
    : SIZE dimension
    ;

styleClause
    : STYLE strokeStyleValue
    ;

strokeClause
    : STROKE strokeStyleValue
    ;

fillClause
    : FILL fillModeValue (CHAR stringValue)?
    ;

borderClause
    : BORDER (VISIBLE_KW | HIDDEN_KW)
    ;

noborderClause
    : NOBORDER
    ;

bordersClause
    : BORDERS sideValue (COMMA sideValue)*
    ;

lineClause
    : LINE borderLineStyleValue
    ;

dashClause
    : DASH intValue
    ;

gapClause
    : GAP intValue
    ;

halignClause
    : HALIGN horizontalAlignValue
    ;

valignClause
    : VALIGN verticalAlignValue
    ;

textOnBorderClause
    : TEXTONBORDER boolValue?
    ;

paddingClause
    : PADDING intValue COMMA intValue COMMA intValue COMMA intValue
    ;

shadowClause
    : SHADOW shadowStyleValue shadowOffsetClause*
    ;

shadowOffsetClause
    : XKW signedInt
    | YKW signedInt
    ;

borderColorClause
    : BORDERCOLOR colorValue
    ;

fillColorClause
    : FILLCOLOR colorValue
    ;

textColorClause
    : TEXTCOLOR colorValue
    ;

strokeColorClause
    : STROKECOLOR colorValue
    ;

labelColorClause
    : LABELCOLOR colorValue
    ;

floatClause
    : FLOAT
    ;

semanticPositionClause
    : directionKeyword referenceTarget gapClause?
    ;

directionKeyword
    : RIGHT_OF
    | BELOW
    | LEFT_OF
    | ABOVE
    ;

labelClause
    : LABEL stringValue
    ;

positionExpr
    : coordinate
    | referenceExpr
    ;

endpointExpr
    : coordinate
    | referenceTarget (DOT sideValue)?
    ;

referenceExpr
    : referenceTarget (DOT sideValue)? offsetExpr?
    ;

offsetExpr
    : sign intValue (COMMA signedInt)?
    ;

referenceTarget
    : stringValue
    | identifier
    ;

coordinate
    : signedInt COMMA signedInt
    ;

dimension
    : DIMENSION_LITERAL
    ;

stringValue
    : STRING
    ;

identifier
    : IDENTIFIER
    ;

colorValue
    : COLORHEX
    ;

strokeStyleValue
    : SINGLE
    | DOUBLE
    | ROUNDED
    | HEAVY
    ;

fillModeValue
    : OPAQUE
    | BLOCK
    | CHARACTER
    | SOLID
    | TRANSPARENT
    | NONE
    ;

borderLineStyleValue
    : DASHED
    | SOLID
    ;

horizontalAlignValue
    : LEFT
    | CENTER
    | RIGHT
    ;

verticalAlignValue
    : TOP
    | MIDDLE
    | BOTTOM
    ;

shadowStyleValue
    : LIGHT
    | DARK
    ;

sideValue
    : LEFT
    | RIGHT
    | TOP
    | BOTTOM
    ;

boolValue
    : TRUE
    | FALSE
    ;

signedInt
    : sign? intValue
    ;

sign
    : PLUS
    | MINUS
    ;

intValue
    : INTEGER
    ;

LAYER: 'layer';
GROUP: 'group';
RECTANGLE: 'rectangle';
RECT: 'rect';
BOX: 'box';
ARROW: 'arrow';
TEXT: 'text';
PENCIL: 'pencil';
FROM: 'from';
TO: 'to';
AT: 'at';
SIZE: 'size';
STYLE: 'style';
STROKE: 'stroke';
FILL: 'fill';
BORDER: 'border';
NOBORDER: 'noborder';
BORDERS: 'borders';
LINE: 'line';
DASH: 'dash';
GAP: 'gap';
HALIGN: 'halign';
VALIGN: 'valign';
TEXTONBORDER: 'textOnBorder';
PADDING: 'padding';
SHADOW: 'shadow';
BORDERCOLOR: 'borderColor';
FILLCOLOR: 'fillColor';
TEXTCOLOR: 'textColor';
STROKECOLOR: 'strokeColor';
LABELCOLOR: 'labelColor';
FLOAT: 'float';
LABEL: 'label';
CHAR: 'char';
IDKW: 'id';
VISIBLE_KW: 'visible';
HIDDEN_KW: 'hidden';
LOCKED: 'locked';
SINGLE: 'single';
DOUBLE: 'double';
ROUNDED: 'rounded';
HEAVY: 'heavy';
OPAQUE: 'opaque';
BLOCK: 'block';
CHARACTER: 'character';
SOLID: 'solid';
TRANSPARENT: 'transparent';
NONE: 'none';
DASHED: 'dashed';
LEFT: 'left';
RIGHT: 'right';
TOP: 'top';
BOTTOM: 'bottom';
CENTER: 'center';
MIDDLE: 'middle';
LIGHT: 'light';
DARK: 'dark';
TRUE: 'true';
FALSE: 'false';
RIGHT_OF: 'right-of';
BELOW: 'below';
LEFT_OF: 'left-of';
ABOVE: 'above';
CELLS: 'cells';
XKW: [xX];
YKW: 'y';

COMMA: ',';
DOT: '.';
SEMI: ';';
LBRACK: '[';
RBRACK: ']';
PLUS: '+';
MINUS: '-';

STRING
    : '"' (~["\\\r\n] | '\\' .)* '"'
    ;

COLORHEX
    : '#' [0-9a-fA-F]+
    ;

DIMENSION_LITERAL
    : [0-9]+ [xX] [0-9]+
    ;

INTEGER
    : [0-9]+
    ;

IDENTIFIER
    : [a-zA-Z_] [a-zA-Z0-9_]*
    ;

NEWLINE
    : '\r'? '\n'
    ;

WS
    : [ \t]+ -> skip
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;
