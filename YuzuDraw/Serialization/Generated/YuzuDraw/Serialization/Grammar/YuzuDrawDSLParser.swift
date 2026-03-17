// Generated from YuzuDraw/Serialization/Grammar/YuzuDrawDSL.g4 by ANTLR 4.13.2
@preconcurrency import Antlr4

open class YuzuDrawDSLParser: Parser {

	nonisolated(unsafe) internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = YuzuDrawDSLParser._ATN.getNumberOfDecisions()
          for i in 0..<length {
            decisionToDFA.append(DFA(YuzuDrawDSLParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()

	nonisolated(unsafe) internal static let _sharedContextCache = PredictionContextCache()

	public
	enum Tokens: Int {
		case EOF = -1, LAYER = 1, GROUP = 2, RECTANGLE = 3, RECT = 4, BOX = 5, 
                 ARROW = 6, TEXT = 7, PENCIL = 8, FROM = 9, TO = 10, AT = 11, 
                 SIZE = 12, STYLE = 13, STROKE = 14, FILL = 15, BORDER = 16, 
                 NOBORDER = 17, BORDERS = 18, LINE = 19, DASH = 20, GAP = 21, 
                 HALIGN = 22, VALIGN = 23, TEXTONBORDER = 24, PADDING = 25, 
                 SHADOW = 26, BORDERCOLOR = 27, FILLCOLOR = 28, TEXTCOLOR = 29, 
                 STROKECOLOR = 30, LABELCOLOR = 31, FLOAT = 32, LABEL = 33, 
                 CHAR = 34, IDKW = 35, VISIBLE_KW = 36, HIDDEN_KW = 37, 
                 LOCKED = 38, SINGLE = 39, DOUBLE = 40, ROUNDED = 41, HEAVY = 42, 
                 OPAQUE = 43, BLOCK = 44, CHARACTER = 45, SOLID = 46, TRANSPARENT = 47, 
                 NONE = 48, DASHED = 49, LEFT = 50, RIGHT = 51, TOP = 52, 
                 BOTTOM = 53, CENTER = 54, MIDDLE = 55, LIGHT = 56, DARK = 57, 
                 TRUE = 58, FALSE = 59, RIGHT_OF = 60, BELOW = 61, LEFT_OF = 62, 
                 ABOVE = 63, CELLS = 64, XKW = 65, YKW = 66, COMMA = 67, 
                 DOT = 68, SEMI = 69, LBRACK = 70, RBRACK = 71, PLUS = 72, 
                 MINUS = 73, STRING = 74, COLORHEX = 75, DIMENSION_LITERAL = 76, 
                 INTEGER = 77, IDENTIFIER = 78, NEWLINE = 79, WS = 80, LINE_COMMENT = 81
	}

	public
	static let RULE_document = 0, RULE_statement = 1, RULE_layerStatement = 2, 
            RULE_groupStatement = 3, RULE_rectangleStatement = 4, RULE_rectKeyword = 5, 
            RULE_rectangleClause = 6, RULE_arrowStatement = 7, RULE_arrowClause = 8, 
            RULE_textStatement = 9, RULE_pencilStatement = 10, RULE_pencilCell = 11, 
            RULE_idClause = 12, RULE_atClause = 13, RULE_sizeClause = 14, 
            RULE_styleClause = 15, RULE_strokeClause = 16, RULE_fillClause = 17, 
            RULE_borderClause = 18, RULE_noborderClause = 19, RULE_bordersClause = 20, 
            RULE_lineClause = 21, RULE_dashClause = 22, RULE_gapClause = 23, 
            RULE_halignClause = 24, RULE_valignClause = 25, RULE_textOnBorderClause = 26, 
            RULE_paddingClause = 27, RULE_shadowClause = 28, RULE_shadowOffsetClause = 29, 
            RULE_borderColorClause = 30, RULE_fillColorClause = 31, RULE_textColorClause = 32, 
            RULE_strokeColorClause = 33, RULE_labelColorClause = 34, RULE_floatClause = 35, 
            RULE_semanticPositionClause = 36, RULE_directionKeyword = 37, 
            RULE_labelClause = 38, RULE_positionExpr = 39, RULE_endpointExpr = 40, 
            RULE_referenceExpr = 41, RULE_offsetExpr = 42, RULE_referenceTarget = 43, 
            RULE_coordinate = 44, RULE_dimension = 45, RULE_stringValue = 46, 
            RULE_identifier = 47, RULE_colorValue = 48, RULE_strokeStyleValue = 49, 
            RULE_fillModeValue = 50, RULE_borderLineStyleValue = 51, RULE_horizontalAlignValue = 52, 
            RULE_verticalAlignValue = 53, RULE_shadowStyleValue = 54, RULE_sideValue = 55, 
            RULE_boolValue = 56, RULE_signedInt = 57, RULE_sign = 58, RULE_intValue = 59

	public
	static let ruleNames: [String] = [
		"document", "statement", "layerStatement", "groupStatement", "rectangleStatement", 
		"rectKeyword", "rectangleClause", "arrowStatement", "arrowClause", "textStatement", 
		"pencilStatement", "pencilCell", "idClause", "atClause", "sizeClause", 
		"styleClause", "strokeClause", "fillClause", "borderClause", "noborderClause", 
		"bordersClause", "lineClause", "dashClause", "gapClause", "halignClause", 
		"valignClause", "textOnBorderClause", "paddingClause", "shadowClause", 
		"shadowOffsetClause", "borderColorClause", "fillColorClause", "textColorClause", 
		"strokeColorClause", "labelColorClause", "floatClause", "semanticPositionClause", 
		"directionKeyword", "labelClause", "positionExpr", "endpointExpr", "referenceExpr", 
		"offsetExpr", "referenceTarget", "coordinate", "dimension", "stringValue", 
		"identifier", "colorValue", "strokeStyleValue", "fillModeValue", "borderLineStyleValue", 
		"horizontalAlignValue", "verticalAlignValue", "shadowStyleValue", "sideValue", 
		"boolValue", "signedInt", "sign", "intValue"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'layer'", "'group'", "'rectangle'", "'rect'", "'box'", "'arrow'", 
		"'text'", "'pencil'", "'from'", "'to'", "'at'", "'size'", "'style'", "'stroke'", 
		"'fill'", "'border'", "'noborder'", "'borders'", "'line'", "'dash'", "'gap'", 
		"'halign'", "'valign'", "'textOnBorder'", "'padding'", "'shadow'", "'borderColor'", 
		"'fillColor'", "'textColor'", "'strokeColor'", "'labelColor'", "'float'", 
		"'label'", "'char'", "'id'", "'visible'", "'hidden'", "'locked'", "'single'", 
		"'double'", "'rounded'", "'heavy'", "'opaque'", "'block'", "'character'", 
		"'solid'", "'transparent'", "'none'", "'dashed'", "'left'", "'right'", 
		"'top'", "'bottom'", "'center'", "'middle'", "'light'", "'dark'", "'true'", 
		"'false'", "'right-of'", "'below'", "'left-of'", "'above'", "'cells'", 
		nil, "'y'", "','", "'.'", "';'", "'['", "']'", "'+'", "'-'"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, "LAYER", "GROUP", "RECTANGLE", "RECT", "BOX", "ARROW", "TEXT", "PENCIL", 
		"FROM", "TO", "AT", "SIZE", "STYLE", "STROKE", "FILL", "BORDER", "NOBORDER", 
		"BORDERS", "LINE", "DASH", "GAP", "HALIGN", "VALIGN", "TEXTONBORDER", 
		"PADDING", "SHADOW", "BORDERCOLOR", "FILLCOLOR", "TEXTCOLOR", "STROKECOLOR", 
		"LABELCOLOR", "FLOAT", "LABEL", "CHAR", "IDKW", "VISIBLE_KW", "HIDDEN_KW", 
		"LOCKED", "SINGLE", "DOUBLE", "ROUNDED", "HEAVY", "OPAQUE", "BLOCK", "CHARACTER", 
		"SOLID", "TRANSPARENT", "NONE", "DASHED", "LEFT", "RIGHT", "TOP", "BOTTOM", 
		"CENTER", "MIDDLE", "LIGHT", "DARK", "TRUE", "FALSE", "RIGHT_OF", "BELOW", 
		"LEFT_OF", "ABOVE", "CELLS", "XKW", "YKW", "COMMA", "DOT", "SEMI", "LBRACK", 
		"RBRACK", "PLUS", "MINUS", "STRING", "COLORHEX", "DIMENSION_LITERAL", 
		"INTEGER", "IDENTIFIER", "NEWLINE", "WS", "LINE_COMMENT"
	]
	public
	nonisolated(unsafe) static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

	override open
	func getGrammarFileName() -> String { return "YuzuDrawDSL.g4" }

	override open
	func getRuleNames() -> [String] { return YuzuDrawDSLParser.ruleNames }

	override open
	func getSerializedATN() -> [Int] { return YuzuDrawDSLParser._serializedATN }

	override open
	func getATN() -> ATN { return YuzuDrawDSLParser._ATN }


	override open
	func getVocabulary() -> Vocabulary {
	    return YuzuDrawDSLParser.VOCABULARY
	}

	override public
	init(_ input:TokenStream) throws {
	    RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self,YuzuDrawDSLParser._ATN,YuzuDrawDSLParser._decisionToDFA, YuzuDrawDSLParser._sharedContextCache)
	}


	public class DocumentContext: ParserRuleContext {
			open
			func EOF() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.EOF.rawValue, 0)
			}
			open
			func NEWLINE() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.NEWLINE.rawValue)
			}
			open
			func NEWLINE(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.NEWLINE.rawValue, i)
			}
			open
			func statement() -> [StatementContext] {
				return getRuleContexts(StatementContext.self)
			}
			open
			func statement(_ i: Int) -> StatementContext? {
				return getRuleContext(StatementContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_document
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterDocument(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitDocument(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitDocument(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitDocument(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func document() throws -> DocumentContext {
		var _localctx: DocumentContext
		_localctx = DocumentContext(_ctx, getState())
		try enterRule(_localctx, 0, YuzuDrawDSLParser.RULE_document)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(126)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input,1,_ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt==1 ) {
		 			setState(121)
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 			if (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 510) != 0)) {
		 				setState(120)
		 				try statement()

		 			}

		 			setState(123)
		 			try match(YuzuDrawDSLParser.Tokens.NEWLINE.rawValue)

		 	 
		 		}
		 		setState(128)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,1,_ctx)
		 	}
		 	setState(130)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 510) != 0)) {
		 		setState(129)
		 		try statement()

		 	}

		 	setState(132)
		 	try match(YuzuDrawDSLParser.Tokens.EOF.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StatementContext: ParserRuleContext {
			open
			func layerStatement() -> LayerStatementContext? {
				return getRuleContext(LayerStatementContext.self, 0)
			}
			open
			func groupStatement() -> GroupStatementContext? {
				return getRuleContext(GroupStatementContext.self, 0)
			}
			open
			func rectangleStatement() -> RectangleStatementContext? {
				return getRuleContext(RectangleStatementContext.self, 0)
			}
			open
			func arrowStatement() -> ArrowStatementContext? {
				return getRuleContext(ArrowStatementContext.self, 0)
			}
			open
			func textStatement() -> TextStatementContext? {
				return getRuleContext(TextStatementContext.self, 0)
			}
			open
			func pencilStatement() -> PencilStatementContext? {
				return getRuleContext(PencilStatementContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_statement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func statement() throws -> StatementContext {
		var _localctx: StatementContext
		_localctx = StatementContext(_ctx, getState())
		try enterRule(_localctx, 2, YuzuDrawDSLParser.RULE_statement)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(140)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .LAYER:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(134)
		 		try layerStatement()

		 		break

		 	case .GROUP:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(135)
		 		try groupStatement()

		 		break
		 	case .RECTANGLE:fallthrough
		 	case .RECT:fallthrough
		 	case .BOX:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(136)
		 		try rectangleStatement()

		 		break

		 	case .ARROW:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(137)
		 		try arrowStatement()

		 		break

		 	case .TEXT:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(138)
		 		try textStatement()

		 		break

		 	case .PENCIL:
		 		try enterOuterAlt(_localctx, 6)
		 		setState(139)
		 		try pencilStatement()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LayerStatementContext: ParserRuleContext {
			open
			func LAYER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LAYER.rawValue, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
			open
			func LOCKED() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LOCKED.rawValue, 0)
			}
			open
			func VISIBLE_KW() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue)
			}
			open
			func VISIBLE_KW(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue, i)
			}
			open
			func HIDDEN_KW() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue)
			}
			open
			func HIDDEN_KW(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_layerStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterLayerStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitLayerStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitLayerStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitLayerStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func layerStatement() throws -> LayerStatementContext {
		var _localctx: LayerStatementContext
		_localctx = LayerStatementContext(_ctx, getState())
		try enterRule(_localctx, 4, YuzuDrawDSLParser.RULE_layerStatement)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(160)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,6, _ctx)) {
		 	case 1:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(142)
		 		try match(YuzuDrawDSLParser.Tokens.LAYER.rawValue)
		 		setState(143)
		 		try stringValue()
		 		setState(147)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		while (_la == YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue || _la == YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue) {
		 			setState(144)
		 			_la = try _input.LA(1)
		 			if (!(_la == YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue || _la == YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue)) {
		 			try _errHandler.recoverInline(self)
		 			}
		 			else {
		 				_errHandler.reportMatch(self)
		 				try consume()
		 			}


		 			setState(149)
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 		}
		 		setState(150)
		 		try match(YuzuDrawDSLParser.Tokens.LOCKED.rawValue)

		 		break
		 	case 2:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(152)
		 		try match(YuzuDrawDSLParser.Tokens.LAYER.rawValue)
		 		setState(153)
		 		try stringValue()
		 		setState(157)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		while (_la == YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue || _la == YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue) {
		 			setState(154)
		 			_la = try _input.LA(1)
		 			if (!(_la == YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue || _la == YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue)) {
		 			try _errHandler.recoverInline(self)
		 			}
		 			else {
		 				_errHandler.reportMatch(self)
		 				try consume()
		 			}


		 			setState(159)
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 		}

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class GroupStatementContext: ParserRuleContext {
			open
			func GROUP() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.GROUP.rawValue, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_groupStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterGroupStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitGroupStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitGroupStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitGroupStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func groupStatement() throws -> GroupStatementContext {
		var _localctx: GroupStatementContext
		_localctx = GroupStatementContext(_ctx, getState())
		try enterRule(_localctx, 6, YuzuDrawDSLParser.RULE_groupStatement)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(162)
		 	try match(YuzuDrawDSLParser.Tokens.GROUP.rawValue)
		 	setState(163)
		 	try stringValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class RectangleStatementContext: ParserRuleContext {
			open
			func rectKeyword() -> RectKeywordContext? {
				return getRuleContext(RectKeywordContext.self, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
			open
			func rectangleClause() -> [RectangleClauseContext] {
				return getRuleContexts(RectangleClauseContext.self)
			}
			open
			func rectangleClause(_ i: Int) -> RectangleClauseContext? {
				return getRuleContext(RectangleClauseContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_rectangleStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterRectangleStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitRectangleStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitRectangleStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitRectangleStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func rectangleStatement() throws -> RectangleStatementContext {
		var _localctx: RectangleStatementContext
		_localctx = RectangleStatementContext(_ctx, getState())
		try enterRule(_localctx, 8, YuzuDrawDSLParser.RULE_rectangleStatement)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(165)
		 	try rectKeyword()
		 	setState(166)
		 	try stringValue()
		 	setState(170)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & -1152921464878401536) != 0)) {
		 		setState(167)
		 		try rectangleClause()


		 		setState(172)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class RectKeywordContext: ParserRuleContext {
			open
			func RECT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RECT.rawValue, 0)
			}
			open
			func RECTANGLE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RECTANGLE.rawValue, 0)
			}
			open
			func BOX() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BOX.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_rectKeyword
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterRectKeyword(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitRectKeyword(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitRectKeyword(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitRectKeyword(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func rectKeyword() throws -> RectKeywordContext {
		var _localctx: RectKeywordContext
		_localctx = RectKeywordContext(_ctx, getState())
		try enterRule(_localctx, 10, YuzuDrawDSLParser.RULE_rectKeyword)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(173)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 56) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class RectangleClauseContext: ParserRuleContext {
			open
			func idClause() -> IdClauseContext? {
				return getRuleContext(IdClauseContext.self, 0)
			}
			open
			func atClause() -> AtClauseContext? {
				return getRuleContext(AtClauseContext.self, 0)
			}
			open
			func sizeClause() -> SizeClauseContext? {
				return getRuleContext(SizeClauseContext.self, 0)
			}
			open
			func styleClause() -> StyleClauseContext? {
				return getRuleContext(StyleClauseContext.self, 0)
			}
			open
			func strokeClause() -> StrokeClauseContext? {
				return getRuleContext(StrokeClauseContext.self, 0)
			}
			open
			func fillClause() -> FillClauseContext? {
				return getRuleContext(FillClauseContext.self, 0)
			}
			open
			func borderClause() -> BorderClauseContext? {
				return getRuleContext(BorderClauseContext.self, 0)
			}
			open
			func noborderClause() -> NoborderClauseContext? {
				return getRuleContext(NoborderClauseContext.self, 0)
			}
			open
			func bordersClause() -> BordersClauseContext? {
				return getRuleContext(BordersClauseContext.self, 0)
			}
			open
			func lineClause() -> LineClauseContext? {
				return getRuleContext(LineClauseContext.self, 0)
			}
			open
			func dashClause() -> DashClauseContext? {
				return getRuleContext(DashClauseContext.self, 0)
			}
			open
			func gapClause() -> GapClauseContext? {
				return getRuleContext(GapClauseContext.self, 0)
			}
			open
			func halignClause() -> HalignClauseContext? {
				return getRuleContext(HalignClauseContext.self, 0)
			}
			open
			func valignClause() -> ValignClauseContext? {
				return getRuleContext(ValignClauseContext.self, 0)
			}
			open
			func textOnBorderClause() -> TextOnBorderClauseContext? {
				return getRuleContext(TextOnBorderClauseContext.self, 0)
			}
			open
			func paddingClause() -> PaddingClauseContext? {
				return getRuleContext(PaddingClauseContext.self, 0)
			}
			open
			func shadowClause() -> ShadowClauseContext? {
				return getRuleContext(ShadowClauseContext.self, 0)
			}
			open
			func borderColorClause() -> BorderColorClauseContext? {
				return getRuleContext(BorderColorClauseContext.self, 0)
			}
			open
			func fillColorClause() -> FillColorClauseContext? {
				return getRuleContext(FillColorClauseContext.self, 0)
			}
			open
			func textColorClause() -> TextColorClauseContext? {
				return getRuleContext(TextColorClauseContext.self, 0)
			}
			open
			func floatClause() -> FloatClauseContext? {
				return getRuleContext(FloatClauseContext.self, 0)
			}
			open
			func semanticPositionClause() -> SemanticPositionClauseContext? {
				return getRuleContext(SemanticPositionClauseContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_rectangleClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterRectangleClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitRectangleClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitRectangleClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitRectangleClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func rectangleClause() throws -> RectangleClauseContext {
		var _localctx: RectangleClauseContext
		_localctx = RectangleClauseContext(_ctx, getState())
		try enterRule(_localctx, 12, YuzuDrawDSLParser.RULE_rectangleClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(197)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .IDKW:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(175)
		 		try idClause()

		 		break

		 	case .AT:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(176)
		 		try atClause()

		 		break

		 	case .SIZE:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(177)
		 		try sizeClause()

		 		break

		 	case .STYLE:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(178)
		 		try styleClause()

		 		break

		 	case .STROKE:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(179)
		 		try strokeClause()

		 		break

		 	case .FILL:
		 		try enterOuterAlt(_localctx, 6)
		 		setState(180)
		 		try fillClause()

		 		break

		 	case .BORDER:
		 		try enterOuterAlt(_localctx, 7)
		 		setState(181)
		 		try borderClause()

		 		break

		 	case .NOBORDER:
		 		try enterOuterAlt(_localctx, 8)
		 		setState(182)
		 		try noborderClause()

		 		break

		 	case .BORDERS:
		 		try enterOuterAlt(_localctx, 9)
		 		setState(183)
		 		try bordersClause()

		 		break

		 	case .LINE:
		 		try enterOuterAlt(_localctx, 10)
		 		setState(184)
		 		try lineClause()

		 		break

		 	case .DASH:
		 		try enterOuterAlt(_localctx, 11)
		 		setState(185)
		 		try dashClause()

		 		break

		 	case .GAP:
		 		try enterOuterAlt(_localctx, 12)
		 		setState(186)
		 		try gapClause()

		 		break

		 	case .HALIGN:
		 		try enterOuterAlt(_localctx, 13)
		 		setState(187)
		 		try halignClause()

		 		break

		 	case .VALIGN:
		 		try enterOuterAlt(_localctx, 14)
		 		setState(188)
		 		try valignClause()

		 		break

		 	case .TEXTONBORDER:
		 		try enterOuterAlt(_localctx, 15)
		 		setState(189)
		 		try textOnBorderClause()

		 		break

		 	case .PADDING:
		 		try enterOuterAlt(_localctx, 16)
		 		setState(190)
		 		try paddingClause()

		 		break

		 	case .SHADOW:
		 		try enterOuterAlt(_localctx, 17)
		 		setState(191)
		 		try shadowClause()

		 		break

		 	case .BORDERCOLOR:
		 		try enterOuterAlt(_localctx, 18)
		 		setState(192)
		 		try borderColorClause()

		 		break

		 	case .FILLCOLOR:
		 		try enterOuterAlt(_localctx, 19)
		 		setState(193)
		 		try fillColorClause()

		 		break

		 	case .TEXTCOLOR:
		 		try enterOuterAlt(_localctx, 20)
		 		setState(194)
		 		try textColorClause()

		 		break

		 	case .FLOAT:
		 		try enterOuterAlt(_localctx, 21)
		 		setState(195)
		 		try floatClause()

		 		break
		 	case .RIGHT_OF:fallthrough
		 	case .BELOW:fallthrough
		 	case .LEFT_OF:fallthrough
		 	case .ABOVE:
		 		try enterOuterAlt(_localctx, 22)
		 		setState(196)
		 		try semanticPositionClause()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ArrowStatementContext: ParserRuleContext {
			open
			func ARROW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.ARROW.rawValue, 0)
			}
			open
			func FROM() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.FROM.rawValue, 0)
			}
			open
			func endpointExpr() -> [EndpointExprContext] {
				return getRuleContexts(EndpointExprContext.self)
			}
			open
			func endpointExpr(_ i: Int) -> EndpointExprContext? {
				return getRuleContext(EndpointExprContext.self, i)
			}
			open
			func TO() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TO.rawValue, 0)
			}
			open
			func arrowClause() -> [ArrowClauseContext] {
				return getRuleContexts(ArrowClauseContext.self)
			}
			open
			func arrowClause(_ i: Int) -> ArrowClauseContext? {
				return getRuleContext(ArrowClauseContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_arrowStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterArrowStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitArrowStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitArrowStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitArrowStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func arrowStatement() throws -> ArrowStatementContext {
		var _localctx: ArrowStatementContext
		_localctx = ArrowStatementContext(_ctx, getState())
		try enterRule(_localctx, 14, YuzuDrawDSLParser.RULE_arrowStatement)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(199)
		 	try match(YuzuDrawDSLParser.Tokens.ARROW.rawValue)
		 	setState(200)
		 	try match(YuzuDrawDSLParser.Tokens.FROM.rawValue)
		 	setState(201)
		 	try endpointExpr()
		 	setState(202)
		 	try match(YuzuDrawDSLParser.Tokens.TO.rawValue)
		 	setState(203)
		 	try endpointExpr()
		 	setState(207)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 16106151936) != 0)) {
		 		setState(204)
		 		try arrowClause()


		 		setState(209)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ArrowClauseContext: ParserRuleContext {
			open
			func styleClause() -> StyleClauseContext? {
				return getRuleContext(StyleClauseContext.self, 0)
			}
			open
			func strokeClause() -> StrokeClauseContext? {
				return getRuleContext(StrokeClauseContext.self, 0)
			}
			open
			func labelClause() -> LabelClauseContext? {
				return getRuleContext(LabelClauseContext.self, 0)
			}
			open
			func strokeColorClause() -> StrokeColorClauseContext? {
				return getRuleContext(StrokeColorClauseContext.self, 0)
			}
			open
			func labelColorClause() -> LabelColorClauseContext? {
				return getRuleContext(LabelColorClauseContext.self, 0)
			}
			open
			func floatClause() -> FloatClauseContext? {
				return getRuleContext(FloatClauseContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_arrowClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterArrowClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitArrowClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitArrowClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitArrowClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func arrowClause() throws -> ArrowClauseContext {
		var _localctx: ArrowClauseContext
		_localctx = ArrowClauseContext(_ctx, getState())
		try enterRule(_localctx, 16, YuzuDrawDSLParser.RULE_arrowClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(216)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .STYLE:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(210)
		 		try styleClause()

		 		break

		 	case .STROKE:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(211)
		 		try strokeClause()

		 		break

		 	case .LABEL:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(212)
		 		try labelClause()

		 		break

		 	case .STROKECOLOR:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(213)
		 		try strokeColorClause()

		 		break

		 	case .LABELCOLOR:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(214)
		 		try labelColorClause()

		 		break

		 	case .FLOAT:
		 		try enterOuterAlt(_localctx, 6)
		 		setState(215)
		 		try floatClause()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class TextStatementContext: ParserRuleContext {
			open
			func TEXT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TEXT.rawValue, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
			open
			func atClause() -> AtClauseContext? {
				return getRuleContext(AtClauseContext.self, 0)
			}
			open
			func textColorClause() -> TextColorClauseContext? {
				return getRuleContext(TextColorClauseContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_textStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterTextStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitTextStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitTextStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitTextStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func textStatement() throws -> TextStatementContext {
		var _localctx: TextStatementContext
		_localctx = TextStatementContext(_ctx, getState())
		try enterRule(_localctx, 18, YuzuDrawDSLParser.RULE_textStatement)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(218)
		 	try match(YuzuDrawDSLParser.Tokens.TEXT.rawValue)
		 	setState(219)
		 	try stringValue()
		 	setState(221)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.AT.rawValue) {
		 		setState(220)
		 		try atClause()

		 	}

		 	setState(224)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.TEXTCOLOR.rawValue) {
		 		setState(223)
		 		try textColorClause()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class PencilStatementContext: ParserRuleContext {
			open
			func PENCIL() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.PENCIL.rawValue, 0)
			}
			open
			func AT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.AT.rawValue, 0)
			}
			open
			func positionExpr() -> PositionExprContext? {
				return getRuleContext(PositionExprContext.self, 0)
			}
			open
			func CELLS() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.CELLS.rawValue, 0)
			}
			open
			func LBRACK() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LBRACK.rawValue, 0)
			}
			open
			func pencilCell() -> [PencilCellContext] {
				return getRuleContexts(PencilCellContext.self)
			}
			open
			func pencilCell(_ i: Int) -> PencilCellContext? {
				return getRuleContext(PencilCellContext.self, i)
			}
			open
			func RBRACK() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RBRACK.rawValue, 0)
			}
			open
			func SEMI() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.SEMI.rawValue)
			}
			open
			func SEMI(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SEMI.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_pencilStatement
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterPencilStatement(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitPencilStatement(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitPencilStatement(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitPencilStatement(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func pencilStatement() throws -> PencilStatementContext {
		var _localctx: PencilStatementContext
		_localctx = PencilStatementContext(_ctx, getState())
		try enterRule(_localctx, 20, YuzuDrawDSLParser.RULE_pencilStatement)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(226)
		 	try match(YuzuDrawDSLParser.Tokens.PENCIL.rawValue)
		 	setState(227)
		 	try match(YuzuDrawDSLParser.Tokens.AT.rawValue)
		 	setState(228)
		 	try positionExpr()
		 	setState(229)
		 	try match(YuzuDrawDSLParser.Tokens.CELLS.rawValue)
		 	setState(230)
		 	try match(YuzuDrawDSLParser.Tokens.LBRACK.rawValue)
		 	setState(231)
		 	try pencilCell()
		 	setState(236)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.SEMI.rawValue) {
		 		setState(232)
		 		try match(YuzuDrawDSLParser.Tokens.SEMI.rawValue)
		 		setState(233)
		 		try pencilCell()


		 		setState(238)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(239)
		 	try match(YuzuDrawDSLParser.Tokens.RBRACK.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class PencilCellContext: ParserRuleContext {
			open
			func intValue() -> [IntValueContext] {
				return getRuleContexts(IntValueContext.self)
			}
			open
			func intValue(_ i: Int) -> IntValueContext? {
				return getRuleContext(IntValueContext.self, i)
			}
			open
			func COMMA() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
			}
			open
			func COMMA(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COMMA.rawValue, i)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_pencilCell
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterPencilCell(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitPencilCell(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitPencilCell(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitPencilCell(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func pencilCell() throws -> PencilCellContext {
		var _localctx: PencilCellContext
		_localctx = PencilCellContext(_ctx, getState())
		try enterRule(_localctx, 22, YuzuDrawDSLParser.RULE_pencilCell)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(241)
		 	try intValue()
		 	setState(242)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(243)
		 	try intValue()
		 	setState(244)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(245)
		 	try stringValue()
		 	setState(248)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(246)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(247)
		 		try colorValue()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IdClauseContext: ParserRuleContext {
			open
			func IDKW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.IDKW.rawValue, 0)
			}
			open
			func identifier() -> IdentifierContext? {
				return getRuleContext(IdentifierContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_idClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterIdClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitIdClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitIdClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitIdClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func idClause() throws -> IdClauseContext {
		var _localctx: IdClauseContext
		_localctx = IdClauseContext(_ctx, getState())
		try enterRule(_localctx, 24, YuzuDrawDSLParser.RULE_idClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(250)
		 	try match(YuzuDrawDSLParser.Tokens.IDKW.rawValue)
		 	setState(251)
		 	try identifier()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class AtClauseContext: ParserRuleContext {
			open
			func AT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.AT.rawValue, 0)
			}
			open
			func positionExpr() -> PositionExprContext? {
				return getRuleContext(PositionExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_atClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterAtClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitAtClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitAtClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitAtClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func atClause() throws -> AtClauseContext {
		var _localctx: AtClauseContext
		_localctx = AtClauseContext(_ctx, getState())
		try enterRule(_localctx, 26, YuzuDrawDSLParser.RULE_atClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(253)
		 	try match(YuzuDrawDSLParser.Tokens.AT.rawValue)
		 	setState(254)
		 	try positionExpr()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SizeClauseContext: ParserRuleContext {
			open
			func SIZE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SIZE.rawValue, 0)
			}
			open
			func dimension() -> DimensionContext? {
				return getRuleContext(DimensionContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_sizeClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterSizeClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitSizeClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitSizeClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitSizeClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func sizeClause() throws -> SizeClauseContext {
		var _localctx: SizeClauseContext
		_localctx = SizeClauseContext(_ctx, getState())
		try enterRule(_localctx, 28, YuzuDrawDSLParser.RULE_sizeClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(256)
		 	try match(YuzuDrawDSLParser.Tokens.SIZE.rawValue)
		 	setState(257)
		 	try dimension()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StyleClauseContext: ParserRuleContext {
			open
			func STYLE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.STYLE.rawValue, 0)
			}
			open
			func strokeStyleValue() -> StrokeStyleValueContext? {
				return getRuleContext(StrokeStyleValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_styleClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStyleClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStyleClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStyleClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStyleClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func styleClause() throws -> StyleClauseContext {
		var _localctx: StyleClauseContext
		_localctx = StyleClauseContext(_ctx, getState())
		try enterRule(_localctx, 30, YuzuDrawDSLParser.RULE_styleClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(259)
		 	try match(YuzuDrawDSLParser.Tokens.STYLE.rawValue)
		 	setState(260)
		 	try strokeStyleValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StrokeClauseContext: ParserRuleContext {
			open
			func STROKE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.STROKE.rawValue, 0)
			}
			open
			func strokeStyleValue() -> StrokeStyleValueContext? {
				return getRuleContext(StrokeStyleValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_strokeClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStrokeClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStrokeClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStrokeClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStrokeClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func strokeClause() throws -> StrokeClauseContext {
		var _localctx: StrokeClauseContext
		_localctx = StrokeClauseContext(_ctx, getState())
		try enterRule(_localctx, 32, YuzuDrawDSLParser.RULE_strokeClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(262)
		 	try match(YuzuDrawDSLParser.Tokens.STROKE.rawValue)
		 	setState(263)
		 	try strokeStyleValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FillClauseContext: ParserRuleContext {
			open
			func FILL() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.FILL.rawValue, 0)
			}
			open
			func fillModeValue() -> FillModeValueContext? {
				return getRuleContext(FillModeValueContext.self, 0)
			}
			open
			func CHAR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.CHAR.rawValue, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_fillClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterFillClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitFillClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitFillClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitFillClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func fillClause() throws -> FillClauseContext {
		var _localctx: FillClauseContext
		_localctx = FillClauseContext(_ctx, getState())
		try enterRule(_localctx, 34, YuzuDrawDSLParser.RULE_fillClause)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(265)
		 	try match(YuzuDrawDSLParser.Tokens.FILL.rawValue)
		 	setState(266)
		 	try fillModeValue()
		 	setState(269)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.CHAR.rawValue) {
		 		setState(267)
		 		try match(YuzuDrawDSLParser.Tokens.CHAR.rawValue)
		 		setState(268)
		 		try stringValue()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BorderClauseContext: ParserRuleContext {
			open
			func BORDER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BORDER.rawValue, 0)
			}
			open
			func VISIBLE_KW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue, 0)
			}
			open
			func HIDDEN_KW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_borderClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterBorderClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitBorderClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitBorderClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitBorderClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func borderClause() throws -> BorderClauseContext {
		var _localctx: BorderClauseContext
		_localctx = BorderClauseContext(_ctx, getState())
		try enterRule(_localctx, 36, YuzuDrawDSLParser.RULE_borderClause)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(271)
		 	try match(YuzuDrawDSLParser.Tokens.BORDER.rawValue)
		 	setState(272)
		 	_la = try _input.LA(1)
		 	if (!(_la == YuzuDrawDSLParser.Tokens.VISIBLE_KW.rawValue || _la == YuzuDrawDSLParser.Tokens.HIDDEN_KW.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class NoborderClauseContext: ParserRuleContext {
			open
			func NOBORDER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.NOBORDER.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_noborderClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterNoborderClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitNoborderClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitNoborderClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitNoborderClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func noborderClause() throws -> NoborderClauseContext {
		var _localctx: NoborderClauseContext
		_localctx = NoborderClauseContext(_ctx, getState())
		try enterRule(_localctx, 38, YuzuDrawDSLParser.RULE_noborderClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(274)
		 	try match(YuzuDrawDSLParser.Tokens.NOBORDER.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BordersClauseContext: ParserRuleContext {
			open
			func BORDERS() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BORDERS.rawValue, 0)
			}
			open
			func sideValue() -> [SideValueContext] {
				return getRuleContexts(SideValueContext.self)
			}
			open
			func sideValue(_ i: Int) -> SideValueContext? {
				return getRuleContext(SideValueContext.self, i)
			}
			open
			func COMMA() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
			}
			open
			func COMMA(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COMMA.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_bordersClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterBordersClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitBordersClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitBordersClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitBordersClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func bordersClause() throws -> BordersClauseContext {
		var _localctx: BordersClauseContext
		_localctx = BordersClauseContext(_ctx, getState())
		try enterRule(_localctx, 40, YuzuDrawDSLParser.RULE_bordersClause)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(276)
		 	try match(YuzuDrawDSLParser.Tokens.BORDERS.rawValue)
		 	setState(277)
		 	try sideValue()
		 	setState(282)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(278)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(279)
		 		try sideValue()


		 		setState(284)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LineClauseContext: ParserRuleContext {
			open
			func LINE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LINE.rawValue, 0)
			}
			open
			func borderLineStyleValue() -> BorderLineStyleValueContext? {
				return getRuleContext(BorderLineStyleValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_lineClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterLineClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitLineClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitLineClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitLineClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func lineClause() throws -> LineClauseContext {
		var _localctx: LineClauseContext
		_localctx = LineClauseContext(_ctx, getState())
		try enterRule(_localctx, 42, YuzuDrawDSLParser.RULE_lineClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(285)
		 	try match(YuzuDrawDSLParser.Tokens.LINE.rawValue)
		 	setState(286)
		 	try borderLineStyleValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class DashClauseContext: ParserRuleContext {
			open
			func DASH() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DASH.rawValue, 0)
			}
			open
			func intValue() -> IntValueContext? {
				return getRuleContext(IntValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_dashClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterDashClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitDashClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitDashClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitDashClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func dashClause() throws -> DashClauseContext {
		var _localctx: DashClauseContext
		_localctx = DashClauseContext(_ctx, getState())
		try enterRule(_localctx, 44, YuzuDrawDSLParser.RULE_dashClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(288)
		 	try match(YuzuDrawDSLParser.Tokens.DASH.rawValue)
		 	setState(289)
		 	try intValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class GapClauseContext: ParserRuleContext {
			open
			func GAP() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.GAP.rawValue, 0)
			}
			open
			func intValue() -> IntValueContext? {
				return getRuleContext(IntValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_gapClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterGapClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitGapClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitGapClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitGapClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func gapClause() throws -> GapClauseContext {
		var _localctx: GapClauseContext
		_localctx = GapClauseContext(_ctx, getState())
		try enterRule(_localctx, 46, YuzuDrawDSLParser.RULE_gapClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(291)
		 	try match(YuzuDrawDSLParser.Tokens.GAP.rawValue)
		 	setState(292)
		 	try intValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class HalignClauseContext: ParserRuleContext {
			open
			func HALIGN() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.HALIGN.rawValue, 0)
			}
			open
			func horizontalAlignValue() -> HorizontalAlignValueContext? {
				return getRuleContext(HorizontalAlignValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_halignClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterHalignClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitHalignClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitHalignClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitHalignClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func halignClause() throws -> HalignClauseContext {
		var _localctx: HalignClauseContext
		_localctx = HalignClauseContext(_ctx, getState())
		try enterRule(_localctx, 48, YuzuDrawDSLParser.RULE_halignClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(294)
		 	try match(YuzuDrawDSLParser.Tokens.HALIGN.rawValue)
		 	setState(295)
		 	try horizontalAlignValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ValignClauseContext: ParserRuleContext {
			open
			func VALIGN() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.VALIGN.rawValue, 0)
			}
			open
			func verticalAlignValue() -> VerticalAlignValueContext? {
				return getRuleContext(VerticalAlignValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_valignClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterValignClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitValignClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitValignClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitValignClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func valignClause() throws -> ValignClauseContext {
		var _localctx: ValignClauseContext
		_localctx = ValignClauseContext(_ctx, getState())
		try enterRule(_localctx, 50, YuzuDrawDSLParser.RULE_valignClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(297)
		 	try match(YuzuDrawDSLParser.Tokens.VALIGN.rawValue)
		 	setState(298)
		 	try verticalAlignValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class TextOnBorderClauseContext: ParserRuleContext {
			open
			func TEXTONBORDER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TEXTONBORDER.rawValue, 0)
			}
			open
			func boolValue() -> BoolValueContext? {
				return getRuleContext(BoolValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_textOnBorderClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterTextOnBorderClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitTextOnBorderClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitTextOnBorderClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitTextOnBorderClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func textOnBorderClause() throws -> TextOnBorderClauseContext {
		var _localctx: TextOnBorderClauseContext
		_localctx = TextOnBorderClauseContext(_ctx, getState())
		try enterRule(_localctx, 52, YuzuDrawDSLParser.RULE_textOnBorderClause)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(300)
		 	try match(YuzuDrawDSLParser.Tokens.TEXTONBORDER.rawValue)
		 	setState(302)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.TRUE.rawValue || _la == YuzuDrawDSLParser.Tokens.FALSE.rawValue) {
		 		setState(301)
		 		try boolValue()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class PaddingClauseContext: ParserRuleContext {
			open
			func PADDING() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.PADDING.rawValue, 0)
			}
			open
			func intValue() -> [IntValueContext] {
				return getRuleContexts(IntValueContext.self)
			}
			open
			func intValue(_ i: Int) -> IntValueContext? {
				return getRuleContext(IntValueContext.self, i)
			}
			open
			func COMMA() -> [TerminalNode] {
				return getTokens(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
			}
			open
			func COMMA(_ i:Int) -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COMMA.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_paddingClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterPaddingClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitPaddingClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitPaddingClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitPaddingClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func paddingClause() throws -> PaddingClauseContext {
		var _localctx: PaddingClauseContext
		_localctx = PaddingClauseContext(_ctx, getState())
		try enterRule(_localctx, 54, YuzuDrawDSLParser.RULE_paddingClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(304)
		 	try match(YuzuDrawDSLParser.Tokens.PADDING.rawValue)
		 	setState(305)
		 	try intValue()
		 	setState(306)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(307)
		 	try intValue()
		 	setState(308)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(309)
		 	try intValue()
		 	setState(310)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(311)
		 	try intValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ShadowClauseContext: ParserRuleContext {
			open
			func SHADOW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SHADOW.rawValue, 0)
			}
			open
			func shadowStyleValue() -> ShadowStyleValueContext? {
				return getRuleContext(ShadowStyleValueContext.self, 0)
			}
			open
			func shadowOffsetClause() -> [ShadowOffsetClauseContext] {
				return getRuleContexts(ShadowOffsetClauseContext.self)
			}
			open
			func shadowOffsetClause(_ i: Int) -> ShadowOffsetClauseContext? {
				return getRuleContext(ShadowOffsetClauseContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_shadowClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterShadowClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitShadowClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitShadowClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitShadowClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func shadowClause() throws -> ShadowClauseContext {
		var _localctx: ShadowClauseContext
		_localctx = ShadowClauseContext(_ctx, getState())
		try enterRule(_localctx, 56, YuzuDrawDSLParser.RULE_shadowClause)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(313)
		 	try match(YuzuDrawDSLParser.Tokens.SHADOW.rawValue)
		 	setState(314)
		 	try shadowStyleValue()
		 	setState(318)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.XKW.rawValue || _la == YuzuDrawDSLParser.Tokens.YKW.rawValue) {
		 		setState(315)
		 		try shadowOffsetClause()


		 		setState(320)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ShadowOffsetClauseContext: ParserRuleContext {
			open
			func XKW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.XKW.rawValue, 0)
			}
			open
			func signedInt() -> SignedIntContext? {
				return getRuleContext(SignedIntContext.self, 0)
			}
			open
			func YKW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.YKW.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_shadowOffsetClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterShadowOffsetClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitShadowOffsetClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitShadowOffsetClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitShadowOffsetClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func shadowOffsetClause() throws -> ShadowOffsetClauseContext {
		var _localctx: ShadowOffsetClauseContext
		_localctx = ShadowOffsetClauseContext(_ctx, getState())
		try enterRule(_localctx, 58, YuzuDrawDSLParser.RULE_shadowOffsetClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(325)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .XKW:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(321)
		 		try match(YuzuDrawDSLParser.Tokens.XKW.rawValue)
		 		setState(322)
		 		try signedInt()

		 		break

		 	case .YKW:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(323)
		 		try match(YuzuDrawDSLParser.Tokens.YKW.rawValue)
		 		setState(324)
		 		try signedInt()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BorderColorClauseContext: ParserRuleContext {
			open
			func BORDERCOLOR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BORDERCOLOR.rawValue, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_borderColorClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterBorderColorClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitBorderColorClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitBorderColorClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitBorderColorClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func borderColorClause() throws -> BorderColorClauseContext {
		var _localctx: BorderColorClauseContext
		_localctx = BorderColorClauseContext(_ctx, getState())
		try enterRule(_localctx, 60, YuzuDrawDSLParser.RULE_borderColorClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(327)
		 	try match(YuzuDrawDSLParser.Tokens.BORDERCOLOR.rawValue)
		 	setState(328)
		 	try colorValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FillColorClauseContext: ParserRuleContext {
			open
			func FILLCOLOR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.FILLCOLOR.rawValue, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_fillColorClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterFillColorClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitFillColorClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitFillColorClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitFillColorClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func fillColorClause() throws -> FillColorClauseContext {
		var _localctx: FillColorClauseContext
		_localctx = FillColorClauseContext(_ctx, getState())
		try enterRule(_localctx, 62, YuzuDrawDSLParser.RULE_fillColorClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(330)
		 	try match(YuzuDrawDSLParser.Tokens.FILLCOLOR.rawValue)
		 	setState(331)
		 	try colorValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class TextColorClauseContext: ParserRuleContext {
			open
			func TEXTCOLOR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TEXTCOLOR.rawValue, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_textColorClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterTextColorClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitTextColorClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitTextColorClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitTextColorClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func textColorClause() throws -> TextColorClauseContext {
		var _localctx: TextColorClauseContext
		_localctx = TextColorClauseContext(_ctx, getState())
		try enterRule(_localctx, 64, YuzuDrawDSLParser.RULE_textColorClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(333)
		 	try match(YuzuDrawDSLParser.Tokens.TEXTCOLOR.rawValue)
		 	setState(334)
		 	try colorValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StrokeColorClauseContext: ParserRuleContext {
			open
			func STROKECOLOR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.STROKECOLOR.rawValue, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_strokeColorClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStrokeColorClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStrokeColorClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStrokeColorClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStrokeColorClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func strokeColorClause() throws -> StrokeColorClauseContext {
		var _localctx: StrokeColorClauseContext
		_localctx = StrokeColorClauseContext(_ctx, getState())
		try enterRule(_localctx, 66, YuzuDrawDSLParser.RULE_strokeColorClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(336)
		 	try match(YuzuDrawDSLParser.Tokens.STROKECOLOR.rawValue)
		 	setState(337)
		 	try colorValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LabelColorClauseContext: ParserRuleContext {
			open
			func LABELCOLOR() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LABELCOLOR.rawValue, 0)
			}
			open
			func colorValue() -> ColorValueContext? {
				return getRuleContext(ColorValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_labelColorClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterLabelColorClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitLabelColorClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitLabelColorClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitLabelColorClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func labelColorClause() throws -> LabelColorClauseContext {
		var _localctx: LabelColorClauseContext
		_localctx = LabelColorClauseContext(_ctx, getState())
		try enterRule(_localctx, 68, YuzuDrawDSLParser.RULE_labelColorClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(339)
		 	try match(YuzuDrawDSLParser.Tokens.LABELCOLOR.rawValue)
		 	setState(340)
		 	try colorValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FloatClauseContext: ParserRuleContext {
			open
			func FLOAT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.FLOAT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_floatClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterFloatClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitFloatClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitFloatClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitFloatClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func floatClause() throws -> FloatClauseContext {
		var _localctx: FloatClauseContext
		_localctx = FloatClauseContext(_ctx, getState())
		try enterRule(_localctx, 70, YuzuDrawDSLParser.RULE_floatClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(342)
		 	try match(YuzuDrawDSLParser.Tokens.FLOAT.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SemanticPositionClauseContext: ParserRuleContext {
			open
			func directionKeyword() -> DirectionKeywordContext? {
				return getRuleContext(DirectionKeywordContext.self, 0)
			}
			open
			func referenceTarget() -> ReferenceTargetContext? {
				return getRuleContext(ReferenceTargetContext.self, 0)
			}
			open
			func gapClause() -> GapClauseContext? {
				return getRuleContext(GapClauseContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_semanticPositionClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterSemanticPositionClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitSemanticPositionClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitSemanticPositionClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitSemanticPositionClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func semanticPositionClause() throws -> SemanticPositionClauseContext {
		var _localctx: SemanticPositionClauseContext
		_localctx = SemanticPositionClauseContext(_ctx, getState())
		try enterRule(_localctx, 72, YuzuDrawDSLParser.RULE_semanticPositionClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(344)
		 	try directionKeyword()
		 	setState(345)
		 	try referenceTarget()
		 	setState(347)
		 	try _errHandler.sync(self)
		 	switch (try getInterpreter().adaptivePredict(_input,20,_ctx)) {
		 	case 1:
		 		setState(346)
		 		try gapClause()

		 		break
		 	default: break
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class DirectionKeywordContext: ParserRuleContext {
			open
			func RIGHT_OF() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RIGHT_OF.rawValue, 0)
			}
			open
			func BELOW() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BELOW.rawValue, 0)
			}
			open
			func LEFT_OF() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LEFT_OF.rawValue, 0)
			}
			open
			func ABOVE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.ABOVE.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_directionKeyword
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterDirectionKeyword(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitDirectionKeyword(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitDirectionKeyword(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitDirectionKeyword(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func directionKeyword() throws -> DirectionKeywordContext {
		var _localctx: DirectionKeywordContext
		_localctx = DirectionKeywordContext(_ctx, getState())
		try enterRule(_localctx, 74, YuzuDrawDSLParser.RULE_directionKeyword)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(349)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & -1152921504606846976) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class LabelClauseContext: ParserRuleContext {
			open
			func LABEL() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LABEL.rawValue, 0)
			}
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_labelClause
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterLabelClause(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitLabelClause(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitLabelClause(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitLabelClause(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func labelClause() throws -> LabelClauseContext {
		var _localctx: LabelClauseContext
		_localctx = LabelClauseContext(_ctx, getState())
		try enterRule(_localctx, 76, YuzuDrawDSLParser.RULE_labelClause)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(351)
		 	try match(YuzuDrawDSLParser.Tokens.LABEL.rawValue)
		 	setState(352)
		 	try stringValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class PositionExprContext: ParserRuleContext {
			open
			func coordinate() -> CoordinateContext? {
				return getRuleContext(CoordinateContext.self, 0)
			}
			open
			func referenceExpr() -> ReferenceExprContext? {
				return getRuleContext(ReferenceExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_positionExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterPositionExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitPositionExpr(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitPositionExpr(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitPositionExpr(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func positionExpr() throws -> PositionExprContext {
		var _localctx: PositionExprContext
		_localctx = PositionExprContext(_ctx, getState())
		try enterRule(_localctx, 78, YuzuDrawDSLParser.RULE_positionExpr)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(356)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .PLUS:fallthrough
		 	case .MINUS:fallthrough
		 	case .INTEGER:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(354)
		 		try coordinate()

		 		break
		 	case .STRING:fallthrough
		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(355)
		 		try referenceExpr()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class EndpointExprContext: ParserRuleContext {
			open
			func coordinate() -> CoordinateContext? {
				return getRuleContext(CoordinateContext.self, 0)
			}
			open
			func referenceTarget() -> ReferenceTargetContext? {
				return getRuleContext(ReferenceTargetContext.self, 0)
			}
			open
			func DOT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DOT.rawValue, 0)
			}
			open
			func sideValue() -> SideValueContext? {
				return getRuleContext(SideValueContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_endpointExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterEndpointExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitEndpointExpr(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitEndpointExpr(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitEndpointExpr(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func endpointExpr() throws -> EndpointExprContext {
		var _localctx: EndpointExprContext
		_localctx = EndpointExprContext(_ctx, getState())
		try enterRule(_localctx, 80, YuzuDrawDSLParser.RULE_endpointExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(364)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .PLUS:fallthrough
		 	case .MINUS:fallthrough
		 	case .INTEGER:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(358)
		 		try coordinate()

		 		break
		 	case .STRING:fallthrough
		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(359)
		 		try referenceTarget()
		 		setState(362)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		if (_la == YuzuDrawDSLParser.Tokens.DOT.rawValue) {
		 			setState(360)
		 			try match(YuzuDrawDSLParser.Tokens.DOT.rawValue)
		 			setState(361)
		 			try sideValue()

		 		}


		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ReferenceExprContext: ParserRuleContext {
			open
			func referenceTarget() -> ReferenceTargetContext? {
				return getRuleContext(ReferenceTargetContext.self, 0)
			}
			open
			func DOT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DOT.rawValue, 0)
			}
			open
			func sideValue() -> SideValueContext? {
				return getRuleContext(SideValueContext.self, 0)
			}
			open
			func offsetExpr() -> OffsetExprContext? {
				return getRuleContext(OffsetExprContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_referenceExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterReferenceExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitReferenceExpr(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitReferenceExpr(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitReferenceExpr(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func referenceExpr() throws -> ReferenceExprContext {
		var _localctx: ReferenceExprContext
		_localctx = ReferenceExprContext(_ctx, getState())
		try enterRule(_localctx, 82, YuzuDrawDSLParser.RULE_referenceExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(366)
		 	try referenceTarget()
		 	setState(369)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.DOT.rawValue) {
		 		setState(367)
		 		try match(YuzuDrawDSLParser.Tokens.DOT.rawValue)
		 		setState(368)
		 		try sideValue()

		 	}

		 	setState(372)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.PLUS.rawValue || _la == YuzuDrawDSLParser.Tokens.MINUS.rawValue) {
		 		setState(371)
		 		try offsetExpr()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class OffsetExprContext: ParserRuleContext {
			open
			func sign() -> SignContext? {
				return getRuleContext(SignContext.self, 0)
			}
			open
			func intValue() -> IntValueContext? {
				return getRuleContext(IntValueContext.self, 0)
			}
			open
			func COMMA() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COMMA.rawValue, 0)
			}
			open
			func signedInt() -> SignedIntContext? {
				return getRuleContext(SignedIntContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_offsetExpr
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterOffsetExpr(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitOffsetExpr(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitOffsetExpr(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitOffsetExpr(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func offsetExpr() throws -> OffsetExprContext {
		var _localctx: OffsetExprContext
		_localctx = OffsetExprContext(_ctx, getState())
		try enterRule(_localctx, 84, YuzuDrawDSLParser.RULE_offsetExpr)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(374)
		 	try sign()
		 	setState(375)
		 	try intValue()
		 	setState(378)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(376)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(377)
		 		try signedInt()

		 	}


		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ReferenceTargetContext: ParserRuleContext {
			open
			func stringValue() -> StringValueContext? {
				return getRuleContext(StringValueContext.self, 0)
			}
			open
			func identifier() -> IdentifierContext? {
				return getRuleContext(IdentifierContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_referenceTarget
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterReferenceTarget(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitReferenceTarget(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitReferenceTarget(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitReferenceTarget(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func referenceTarget() throws -> ReferenceTargetContext {
		var _localctx: ReferenceTargetContext
		_localctx = ReferenceTargetContext(_ctx, getState())
		try enterRule(_localctx, 86, YuzuDrawDSLParser.RULE_referenceTarget)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(382)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .STRING:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(380)
		 		try stringValue()

		 		break

		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(381)
		 		try identifier()

		 		break
		 	default:
		 		throw ANTLRException.recognition(e: NoViableAltException(self))
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class CoordinateContext: ParserRuleContext {
			open
			func signedInt() -> [SignedIntContext] {
				return getRuleContexts(SignedIntContext.self)
			}
			open
			func signedInt(_ i: Int) -> SignedIntContext? {
				return getRuleContext(SignedIntContext.self, i)
			}
			open
			func COMMA() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COMMA.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_coordinate
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterCoordinate(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitCoordinate(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitCoordinate(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitCoordinate(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func coordinate() throws -> CoordinateContext {
		var _localctx: CoordinateContext
		_localctx = CoordinateContext(_ctx, getState())
		try enterRule(_localctx, 88, YuzuDrawDSLParser.RULE_coordinate)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(384)
		 	try signedInt()
		 	setState(385)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(386)
		 	try signedInt()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class DimensionContext: ParserRuleContext {
			open
			func DIMENSION_LITERAL() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DIMENSION_LITERAL.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_dimension
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterDimension(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitDimension(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitDimension(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitDimension(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func dimension() throws -> DimensionContext {
		var _localctx: DimensionContext
		_localctx = DimensionContext(_ctx, getState())
		try enterRule(_localctx, 90, YuzuDrawDSLParser.RULE_dimension)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(388)
		 	try match(YuzuDrawDSLParser.Tokens.DIMENSION_LITERAL.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StringValueContext: ParserRuleContext {
			open
			func STRING() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.STRING.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_stringValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStringValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStringValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStringValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStringValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func stringValue() throws -> StringValueContext {
		var _localctx: StringValueContext
		_localctx = StringValueContext(_ctx, getState())
		try enterRule(_localctx, 92, YuzuDrawDSLParser.RULE_stringValue)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(390)
		 	try match(YuzuDrawDSLParser.Tokens.STRING.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IdentifierContext: ParserRuleContext {
			open
			func IDENTIFIER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.IDENTIFIER.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_identifier
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterIdentifier(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitIdentifier(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitIdentifier(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitIdentifier(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func identifier() throws -> IdentifierContext {
		var _localctx: IdentifierContext
		_localctx = IdentifierContext(_ctx, getState())
		try enterRule(_localctx, 94, YuzuDrawDSLParser.RULE_identifier)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(392)
		 	try match(YuzuDrawDSLParser.Tokens.IDENTIFIER.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ColorValueContext: ParserRuleContext {
			open
			func COLORHEX() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.COLORHEX.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_colorValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterColorValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitColorValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitColorValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitColorValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func colorValue() throws -> ColorValueContext {
		var _localctx: ColorValueContext
		_localctx = ColorValueContext(_ctx, getState())
		try enterRule(_localctx, 96, YuzuDrawDSLParser.RULE_colorValue)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(394)
		 	try match(YuzuDrawDSLParser.Tokens.COLORHEX.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class StrokeStyleValueContext: ParserRuleContext {
			open
			func SINGLE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SINGLE.rawValue, 0)
			}
			open
			func DOUBLE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DOUBLE.rawValue, 0)
			}
			open
			func ROUNDED() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.ROUNDED.rawValue, 0)
			}
			open
			func HEAVY() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.HEAVY.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_strokeStyleValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterStrokeStyleValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitStrokeStyleValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitStrokeStyleValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitStrokeStyleValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func strokeStyleValue() throws -> StrokeStyleValueContext {
		var _localctx: StrokeStyleValueContext
		_localctx = StrokeStyleValueContext(_ctx, getState())
		try enterRule(_localctx, 98, YuzuDrawDSLParser.RULE_strokeStyleValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(396)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 8246337208320) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class FillModeValueContext: ParserRuleContext {
			open
			func OPAQUE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.OPAQUE.rawValue, 0)
			}
			open
			func BLOCK() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BLOCK.rawValue, 0)
			}
			open
			func CHARACTER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.CHARACTER.rawValue, 0)
			}
			open
			func SOLID() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SOLID.rawValue, 0)
			}
			open
			func TRANSPARENT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TRANSPARENT.rawValue, 0)
			}
			open
			func NONE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.NONE.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_fillModeValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterFillModeValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitFillModeValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitFillModeValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitFillModeValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func fillModeValue() throws -> FillModeValueContext {
		var _localctx: FillModeValueContext
		_localctx = FillModeValueContext(_ctx, getState())
		try enterRule(_localctx, 100, YuzuDrawDSLParser.RULE_fillModeValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(398)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 554153860399104) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BorderLineStyleValueContext: ParserRuleContext {
			open
			func DASHED() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DASHED.rawValue, 0)
			}
			open
			func SOLID() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.SOLID.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_borderLineStyleValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterBorderLineStyleValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitBorderLineStyleValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitBorderLineStyleValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitBorderLineStyleValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func borderLineStyleValue() throws -> BorderLineStyleValueContext {
		var _localctx: BorderLineStyleValueContext
		_localctx = BorderLineStyleValueContext(_ctx, getState())
		try enterRule(_localctx, 102, YuzuDrawDSLParser.RULE_borderLineStyleValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(400)
		 	_la = try _input.LA(1)
		 	if (!(_la == YuzuDrawDSLParser.Tokens.SOLID.rawValue || _la == YuzuDrawDSLParser.Tokens.DASHED.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class HorizontalAlignValueContext: ParserRuleContext {
			open
			func LEFT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LEFT.rawValue, 0)
			}
			open
			func CENTER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.CENTER.rawValue, 0)
			}
			open
			func RIGHT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RIGHT.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_horizontalAlignValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterHorizontalAlignValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitHorizontalAlignValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitHorizontalAlignValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitHorizontalAlignValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func horizontalAlignValue() throws -> HorizontalAlignValueContext {
		var _localctx: HorizontalAlignValueContext
		_localctx = HorizontalAlignValueContext(_ctx, getState())
		try enterRule(_localctx, 104, YuzuDrawDSLParser.RULE_horizontalAlignValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(402)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 21392098230009856) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class VerticalAlignValueContext: ParserRuleContext {
			open
			func TOP() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TOP.rawValue, 0)
			}
			open
			func MIDDLE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.MIDDLE.rawValue, 0)
			}
			open
			func BOTTOM() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BOTTOM.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_verticalAlignValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterVerticalAlignValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitVerticalAlignValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitVerticalAlignValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitVerticalAlignValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func verticalAlignValue() throws -> VerticalAlignValueContext {
		var _localctx: VerticalAlignValueContext
		_localctx = VerticalAlignValueContext(_ctx, getState())
		try enterRule(_localctx, 106, YuzuDrawDSLParser.RULE_verticalAlignValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(404)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 49539595901075456) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class ShadowStyleValueContext: ParserRuleContext {
			open
			func LIGHT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LIGHT.rawValue, 0)
			}
			open
			func DARK() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.DARK.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_shadowStyleValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterShadowStyleValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitShadowStyleValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitShadowStyleValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitShadowStyleValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func shadowStyleValue() throws -> ShadowStyleValueContext {
		var _localctx: ShadowStyleValueContext
		_localctx = ShadowStyleValueContext(_ctx, getState())
		try enterRule(_localctx, 108, YuzuDrawDSLParser.RULE_shadowStyleValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(406)
		 	_la = try _input.LA(1)
		 	if (!(_la == YuzuDrawDSLParser.Tokens.LIGHT.rawValue || _la == YuzuDrawDSLParser.Tokens.DARK.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SideValueContext: ParserRuleContext {
			open
			func LEFT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.LEFT.rawValue, 0)
			}
			open
			func RIGHT() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.RIGHT.rawValue, 0)
			}
			open
			func TOP() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TOP.rawValue, 0)
			}
			open
			func BOTTOM() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.BOTTOM.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_sideValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterSideValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitSideValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitSideValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitSideValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func sideValue() throws -> SideValueContext {
		var _localctx: SideValueContext
		_localctx = SideValueContext(_ctx, getState())
		try enterRule(_localctx, 110, YuzuDrawDSLParser.RULE_sideValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(408)
		 	_la = try _input.LA(1)
		 	if (!(((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 16888498602639360) != 0))) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class BoolValueContext: ParserRuleContext {
			open
			func TRUE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.TRUE.rawValue, 0)
			}
			open
			func FALSE() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.FALSE.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_boolValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterBoolValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitBoolValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitBoolValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitBoolValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func boolValue() throws -> BoolValueContext {
		var _localctx: BoolValueContext
		_localctx = BoolValueContext(_ctx, getState())
		try enterRule(_localctx, 112, YuzuDrawDSLParser.RULE_boolValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(410)
		 	_la = try _input.LA(1)
		 	if (!(_la == YuzuDrawDSLParser.Tokens.TRUE.rawValue || _la == YuzuDrawDSLParser.Tokens.FALSE.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SignedIntContext: ParserRuleContext {
			open
			func intValue() -> IntValueContext? {
				return getRuleContext(IntValueContext.self, 0)
			}
			open
			func sign() -> SignContext? {
				return getRuleContext(SignContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_signedInt
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterSignedInt(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitSignedInt(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitSignedInt(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitSignedInt(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func signedInt() throws -> SignedIntContext {
		var _localctx: SignedIntContext
		_localctx = SignedIntContext(_ctx, getState())
		try enterRule(_localctx, 114, YuzuDrawDSLParser.RULE_signedInt)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(413)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.PLUS.rawValue || _la == YuzuDrawDSLParser.Tokens.MINUS.rawValue) {
		 		setState(412)
		 		try sign()

		 	}

		 	setState(415)
		 	try intValue()

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class SignContext: ParserRuleContext {
			open
			func PLUS() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.PLUS.rawValue, 0)
			}
			open
			func MINUS() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.MINUS.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_sign
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterSign(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitSign(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitSign(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitSign(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func sign() throws -> SignContext {
		var _localctx: SignContext
		_localctx = SignContext(_ctx, getState())
		try enterRule(_localctx, 116, YuzuDrawDSLParser.RULE_sign)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(417)
		 	_la = try _input.LA(1)
		 	if (!(_la == YuzuDrawDSLParser.Tokens.PLUS.rawValue || _la == YuzuDrawDSLParser.Tokens.MINUS.rawValue)) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public class IntValueContext: ParserRuleContext {
			open
			func INTEGER() -> TerminalNode? {
				return getToken(YuzuDrawDSLParser.Tokens.INTEGER.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return YuzuDrawDSLParser.RULE_intValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.enterIntValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? YuzuDrawDSLListener {
				listener.exitIntValue(self)
			}
		}
		override open
		func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
			if let visitor = visitor as? YuzuDrawDSLVisitor {
			    return visitor.visitIntValue(self)
			}
			else if let visitor = visitor as? YuzuDrawDSLBaseVisitor {
			    return visitor.visitIntValue(self)
			}
			else {
			     return visitor.visitChildren(self)
			}
		}
	}
	@discardableResult
	 open func intValue() throws -> IntValueContext {
		var _localctx: IntValueContext
		_localctx = IntValueContext(_ctx, getState())
		try enterRule(_localctx, 118, YuzuDrawDSLParser.RULE_intValue)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(419)
		 	try match(YuzuDrawDSLParser.Tokens.INTEGER.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	static let _serializedATN:[Int] = [
		4,1,81,422,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,2,7,
		7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,2,13,7,13,2,14,7,14,
		2,15,7,15,2,16,7,16,2,17,7,17,2,18,7,18,2,19,7,19,2,20,7,20,2,21,7,21,
		2,22,7,22,2,23,7,23,2,24,7,24,2,25,7,25,2,26,7,26,2,27,7,27,2,28,7,28,
		2,29,7,29,2,30,7,30,2,31,7,31,2,32,7,32,2,33,7,33,2,34,7,34,2,35,7,35,
		2,36,7,36,2,37,7,37,2,38,7,38,2,39,7,39,2,40,7,40,2,41,7,41,2,42,7,42,
		2,43,7,43,2,44,7,44,2,45,7,45,2,46,7,46,2,47,7,47,2,48,7,48,2,49,7,49,
		2,50,7,50,2,51,7,51,2,52,7,52,2,53,7,53,2,54,7,54,2,55,7,55,2,56,7,56,
		2,57,7,57,2,58,7,58,2,59,7,59,1,0,3,0,122,8,0,1,0,5,0,125,8,0,10,0,12,
		0,128,9,0,1,0,3,0,131,8,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,3,1,141,8,1,
		1,2,1,2,1,2,5,2,146,8,2,10,2,12,2,149,9,2,1,2,1,2,1,2,1,2,1,2,5,2,156,
		8,2,10,2,12,2,159,9,2,3,2,161,8,2,1,3,1,3,1,3,1,4,1,4,1,4,5,4,169,8,4,
		10,4,12,4,172,9,4,1,5,1,5,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,
		1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,3,6,198,8,6,1,7,1,7,1,7,1,
		7,1,7,1,7,5,7,206,8,7,10,7,12,7,209,9,7,1,8,1,8,1,8,1,8,1,8,1,8,3,8,217,
		8,8,1,9,1,9,1,9,3,9,222,8,9,1,9,3,9,225,8,9,1,10,1,10,1,10,1,10,1,10,1,
		10,1,10,1,10,5,10,235,8,10,10,10,12,10,238,9,10,1,10,1,10,1,11,1,11,1,
		11,1,11,1,11,1,11,1,11,3,11,249,8,11,1,12,1,12,1,12,1,13,1,13,1,13,1,14,
		1,14,1,14,1,15,1,15,1,15,1,16,1,16,1,16,1,17,1,17,1,17,1,17,3,17,270,8,
		17,1,18,1,18,1,18,1,19,1,19,1,20,1,20,1,20,1,20,5,20,281,8,20,10,20,12,
		20,284,9,20,1,21,1,21,1,21,1,22,1,22,1,22,1,23,1,23,1,23,1,24,1,24,1,24,
		1,25,1,25,1,25,1,26,1,26,3,26,303,8,26,1,27,1,27,1,27,1,27,1,27,1,27,1,
		27,1,27,1,27,1,28,1,28,1,28,5,28,317,8,28,10,28,12,28,320,9,28,1,29,1,
		29,1,29,1,29,3,29,326,8,29,1,30,1,30,1,30,1,31,1,31,1,31,1,32,1,32,1,32,
		1,33,1,33,1,33,1,34,1,34,1,34,1,35,1,35,1,36,1,36,1,36,3,36,348,8,36,1,
		37,1,37,1,38,1,38,1,38,1,39,1,39,3,39,357,8,39,1,40,1,40,1,40,1,40,3,40,
		363,8,40,3,40,365,8,40,1,41,1,41,1,41,3,41,370,8,41,1,41,3,41,373,8,41,
		1,42,1,42,1,42,1,42,3,42,379,8,42,1,43,1,43,3,43,383,8,43,1,44,1,44,1,
		44,1,44,1,45,1,45,1,46,1,46,1,47,1,47,1,48,1,48,1,49,1,49,1,50,1,50,1,
		51,1,51,1,52,1,52,1,53,1,53,1,54,1,54,1,55,1,55,1,56,1,56,1,57,3,57,414,
		8,57,1,57,1,57,1,58,1,58,1,59,1,59,1,59,0,0,60,0,2,4,6,8,10,12,14,16,18,
		20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,
		68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,
		112,114,116,118,0,12,1,0,36,37,1,0,3,5,1,0,60,63,1,0,39,42,1,0,43,48,2,
		0,46,46,49,49,2,0,50,51,54,54,2,0,52,53,55,55,1,0,56,57,1,0,50,53,1,0,
		58,59,1,0,72,73,418,0,126,1,0,0,0,2,140,1,0,0,0,4,160,1,0,0,0,6,162,1,
		0,0,0,8,165,1,0,0,0,10,173,1,0,0,0,12,197,1,0,0,0,14,199,1,0,0,0,16,216,
		1,0,0,0,18,218,1,0,0,0,20,226,1,0,0,0,22,241,1,0,0,0,24,250,1,0,0,0,26,
		253,1,0,0,0,28,256,1,0,0,0,30,259,1,0,0,0,32,262,1,0,0,0,34,265,1,0,0,
		0,36,271,1,0,0,0,38,274,1,0,0,0,40,276,1,0,0,0,42,285,1,0,0,0,44,288,1,
		0,0,0,46,291,1,0,0,0,48,294,1,0,0,0,50,297,1,0,0,0,52,300,1,0,0,0,54,304,
		1,0,0,0,56,313,1,0,0,0,58,325,1,0,0,0,60,327,1,0,0,0,62,330,1,0,0,0,64,
		333,1,0,0,0,66,336,1,0,0,0,68,339,1,0,0,0,70,342,1,0,0,0,72,344,1,0,0,
		0,74,349,1,0,0,0,76,351,1,0,0,0,78,356,1,0,0,0,80,364,1,0,0,0,82,366,1,
		0,0,0,84,374,1,0,0,0,86,382,1,0,0,0,88,384,1,0,0,0,90,388,1,0,0,0,92,390,
		1,0,0,0,94,392,1,0,0,0,96,394,1,0,0,0,98,396,1,0,0,0,100,398,1,0,0,0,102,
		400,1,0,0,0,104,402,1,0,0,0,106,404,1,0,0,0,108,406,1,0,0,0,110,408,1,
		0,0,0,112,410,1,0,0,0,114,413,1,0,0,0,116,417,1,0,0,0,118,419,1,0,0,0,
		120,122,3,2,1,0,121,120,1,0,0,0,121,122,1,0,0,0,122,123,1,0,0,0,123,125,
		5,79,0,0,124,121,1,0,0,0,125,128,1,0,0,0,126,124,1,0,0,0,126,127,1,0,0,
		0,127,130,1,0,0,0,128,126,1,0,0,0,129,131,3,2,1,0,130,129,1,0,0,0,130,
		131,1,0,0,0,131,132,1,0,0,0,132,133,5,0,0,1,133,1,1,0,0,0,134,141,3,4,
		2,0,135,141,3,6,3,0,136,141,3,8,4,0,137,141,3,14,7,0,138,141,3,18,9,0,
		139,141,3,20,10,0,140,134,1,0,0,0,140,135,1,0,0,0,140,136,1,0,0,0,140,
		137,1,0,0,0,140,138,1,0,0,0,140,139,1,0,0,0,141,3,1,0,0,0,142,143,5,1,
		0,0,143,147,3,92,46,0,144,146,7,0,0,0,145,144,1,0,0,0,146,149,1,0,0,0,
		147,145,1,0,0,0,147,148,1,0,0,0,148,150,1,0,0,0,149,147,1,0,0,0,150,151,
		5,38,0,0,151,161,1,0,0,0,152,153,5,1,0,0,153,157,3,92,46,0,154,156,7,0,
		0,0,155,154,1,0,0,0,156,159,1,0,0,0,157,155,1,0,0,0,157,158,1,0,0,0,158,
		161,1,0,0,0,159,157,1,0,0,0,160,142,1,0,0,0,160,152,1,0,0,0,161,5,1,0,
		0,0,162,163,5,2,0,0,163,164,3,92,46,0,164,7,1,0,0,0,165,166,3,10,5,0,166,
		170,3,92,46,0,167,169,3,12,6,0,168,167,1,0,0,0,169,172,1,0,0,0,170,168,
		1,0,0,0,170,171,1,0,0,0,171,9,1,0,0,0,172,170,1,0,0,0,173,174,7,1,0,0,
		174,11,1,0,0,0,175,198,3,24,12,0,176,198,3,26,13,0,177,198,3,28,14,0,178,
		198,3,30,15,0,179,198,3,32,16,0,180,198,3,34,17,0,181,198,3,36,18,0,182,
		198,3,38,19,0,183,198,3,40,20,0,184,198,3,42,21,0,185,198,3,44,22,0,186,
		198,3,46,23,0,187,198,3,48,24,0,188,198,3,50,25,0,189,198,3,52,26,0,190,
		198,3,54,27,0,191,198,3,56,28,0,192,198,3,60,30,0,193,198,3,62,31,0,194,
		198,3,64,32,0,195,198,3,70,35,0,196,198,3,72,36,0,197,175,1,0,0,0,197,
		176,1,0,0,0,197,177,1,0,0,0,197,178,1,0,0,0,197,179,1,0,0,0,197,180,1,
		0,0,0,197,181,1,0,0,0,197,182,1,0,0,0,197,183,1,0,0,0,197,184,1,0,0,0,
		197,185,1,0,0,0,197,186,1,0,0,0,197,187,1,0,0,0,197,188,1,0,0,0,197,189,
		1,0,0,0,197,190,1,0,0,0,197,191,1,0,0,0,197,192,1,0,0,0,197,193,1,0,0,
		0,197,194,1,0,0,0,197,195,1,0,0,0,197,196,1,0,0,0,198,13,1,0,0,0,199,200,
		5,6,0,0,200,201,5,9,0,0,201,202,3,80,40,0,202,203,5,10,0,0,203,207,3,80,
		40,0,204,206,3,16,8,0,205,204,1,0,0,0,206,209,1,0,0,0,207,205,1,0,0,0,
		207,208,1,0,0,0,208,15,1,0,0,0,209,207,1,0,0,0,210,217,3,30,15,0,211,217,
		3,32,16,0,212,217,3,76,38,0,213,217,3,66,33,0,214,217,3,68,34,0,215,217,
		3,70,35,0,216,210,1,0,0,0,216,211,1,0,0,0,216,212,1,0,0,0,216,213,1,0,
		0,0,216,214,1,0,0,0,216,215,1,0,0,0,217,17,1,0,0,0,218,219,5,7,0,0,219,
		221,3,92,46,0,220,222,3,26,13,0,221,220,1,0,0,0,221,222,1,0,0,0,222,224,
		1,0,0,0,223,225,3,64,32,0,224,223,1,0,0,0,224,225,1,0,0,0,225,19,1,0,0,
		0,226,227,5,8,0,0,227,228,5,11,0,0,228,229,3,78,39,0,229,230,5,64,0,0,
		230,231,5,70,0,0,231,236,3,22,11,0,232,233,5,69,0,0,233,235,3,22,11,0,
		234,232,1,0,0,0,235,238,1,0,0,0,236,234,1,0,0,0,236,237,1,0,0,0,237,239,
		1,0,0,0,238,236,1,0,0,0,239,240,5,71,0,0,240,21,1,0,0,0,241,242,3,118,
		59,0,242,243,5,67,0,0,243,244,3,118,59,0,244,245,5,67,0,0,245,248,3,92,
		46,0,246,247,5,67,0,0,247,249,3,96,48,0,248,246,1,0,0,0,248,249,1,0,0,
		0,249,23,1,0,0,0,250,251,5,35,0,0,251,252,3,94,47,0,252,25,1,0,0,0,253,
		254,5,11,0,0,254,255,3,78,39,0,255,27,1,0,0,0,256,257,5,12,0,0,257,258,
		3,90,45,0,258,29,1,0,0,0,259,260,5,13,0,0,260,261,3,98,49,0,261,31,1,0,
		0,0,262,263,5,14,0,0,263,264,3,98,49,0,264,33,1,0,0,0,265,266,5,15,0,0,
		266,269,3,100,50,0,267,268,5,34,0,0,268,270,3,92,46,0,269,267,1,0,0,0,
		269,270,1,0,0,0,270,35,1,0,0,0,271,272,5,16,0,0,272,273,7,0,0,0,273,37,
		1,0,0,0,274,275,5,17,0,0,275,39,1,0,0,0,276,277,5,18,0,0,277,282,3,110,
		55,0,278,279,5,67,0,0,279,281,3,110,55,0,280,278,1,0,0,0,281,284,1,0,0,
		0,282,280,1,0,0,0,282,283,1,0,0,0,283,41,1,0,0,0,284,282,1,0,0,0,285,286,
		5,19,0,0,286,287,3,102,51,0,287,43,1,0,0,0,288,289,5,20,0,0,289,290,3,
		118,59,0,290,45,1,0,0,0,291,292,5,21,0,0,292,293,3,118,59,0,293,47,1,0,
		0,0,294,295,5,22,0,0,295,296,3,104,52,0,296,49,1,0,0,0,297,298,5,23,0,
		0,298,299,3,106,53,0,299,51,1,0,0,0,300,302,5,24,0,0,301,303,3,112,56,
		0,302,301,1,0,0,0,302,303,1,0,0,0,303,53,1,0,0,0,304,305,5,25,0,0,305,
		306,3,118,59,0,306,307,5,67,0,0,307,308,3,118,59,0,308,309,5,67,0,0,309,
		310,3,118,59,0,310,311,5,67,0,0,311,312,3,118,59,0,312,55,1,0,0,0,313,
		314,5,26,0,0,314,318,3,108,54,0,315,317,3,58,29,0,316,315,1,0,0,0,317,
		320,1,0,0,0,318,316,1,0,0,0,318,319,1,0,0,0,319,57,1,0,0,0,320,318,1,0,
		0,0,321,322,5,65,0,0,322,326,3,114,57,0,323,324,5,66,0,0,324,326,3,114,
		57,0,325,321,1,0,0,0,325,323,1,0,0,0,326,59,1,0,0,0,327,328,5,27,0,0,328,
		329,3,96,48,0,329,61,1,0,0,0,330,331,5,28,0,0,331,332,3,96,48,0,332,63,
		1,0,0,0,333,334,5,29,0,0,334,335,3,96,48,0,335,65,1,0,0,0,336,337,5,30,
		0,0,337,338,3,96,48,0,338,67,1,0,0,0,339,340,5,31,0,0,340,341,3,96,48,
		0,341,69,1,0,0,0,342,343,5,32,0,0,343,71,1,0,0,0,344,345,3,74,37,0,345,
		347,3,86,43,0,346,348,3,46,23,0,347,346,1,0,0,0,347,348,1,0,0,0,348,73,
		1,0,0,0,349,350,7,2,0,0,350,75,1,0,0,0,351,352,5,33,0,0,352,353,3,92,46,
		0,353,77,1,0,0,0,354,357,3,88,44,0,355,357,3,82,41,0,356,354,1,0,0,0,356,
		355,1,0,0,0,357,79,1,0,0,0,358,365,3,88,44,0,359,362,3,86,43,0,360,361,
		5,68,0,0,361,363,3,110,55,0,362,360,1,0,0,0,362,363,1,0,0,0,363,365,1,
		0,0,0,364,358,1,0,0,0,364,359,1,0,0,0,365,81,1,0,0,0,366,369,3,86,43,0,
		367,368,5,68,0,0,368,370,3,110,55,0,369,367,1,0,0,0,369,370,1,0,0,0,370,
		372,1,0,0,0,371,373,3,84,42,0,372,371,1,0,0,0,372,373,1,0,0,0,373,83,1,
		0,0,0,374,375,3,116,58,0,375,378,3,118,59,0,376,377,5,67,0,0,377,379,3,
		114,57,0,378,376,1,0,0,0,378,379,1,0,0,0,379,85,1,0,0,0,380,383,3,92,46,
		0,381,383,3,94,47,0,382,380,1,0,0,0,382,381,1,0,0,0,383,87,1,0,0,0,384,
		385,3,114,57,0,385,386,5,67,0,0,386,387,3,114,57,0,387,89,1,0,0,0,388,
		389,5,76,0,0,389,91,1,0,0,0,390,391,5,74,0,0,391,93,1,0,0,0,392,393,5,
		78,0,0,393,95,1,0,0,0,394,395,5,75,0,0,395,97,1,0,0,0,396,397,7,3,0,0,
		397,99,1,0,0,0,398,399,7,4,0,0,399,101,1,0,0,0,400,401,7,5,0,0,401,103,
		1,0,0,0,402,403,7,6,0,0,403,105,1,0,0,0,404,405,7,7,0,0,405,107,1,0,0,
		0,406,407,7,8,0,0,407,109,1,0,0,0,408,409,7,9,0,0,409,111,1,0,0,0,410,
		411,7,10,0,0,411,113,1,0,0,0,412,414,3,116,58,0,413,412,1,0,0,0,413,414,
		1,0,0,0,414,415,1,0,0,0,415,416,3,118,59,0,416,115,1,0,0,0,417,418,7,11,
		0,0,418,117,1,0,0,0,419,420,5,77,0,0,420,119,1,0,0,0,29,121,126,130,140,
		147,157,160,170,197,207,216,221,224,236,248,269,282,302,318,325,347,356,
		362,364,369,372,378,382,413
	]

	public
	nonisolated(unsafe) static let _ATN = try! ATNDeserializer().deserialize(_serializedATN)
}
