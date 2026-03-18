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
			open
			func idClause() -> IdClauseContext? {
				return getRuleContext(IdClauseContext.self, 0)
			}
			open
			func atClause() -> AtClauseContext? {
				return getRuleContext(AtClauseContext.self, 0)
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
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(162)
		 	try match(YuzuDrawDSLParser.Tokens.GROUP.rawValue)
		 	setState(163)
		 	try stringValue()
		 	setState(165)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.IDKW.rawValue) {
		 		setState(164)
		 		try idClause()

		 	}

		 	setState(168)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.AT.rawValue) {
		 		setState(167)
		 		try atClause()

		 	}


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
		 	setState(170)
		 	try rectKeyword()
		 	setState(171)
		 	try stringValue()
		 	setState(175)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & -1152921464878401536) != 0)) {
		 		setState(172)
		 		try rectangleClause()


		 		setState(177)
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
		 	setState(178)
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
		 	setState(202)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .IDKW:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(180)
		 		try idClause()

		 		break

		 	case .AT:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(181)
		 		try atClause()

		 		break

		 	case .SIZE:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(182)
		 		try sizeClause()

		 		break

		 	case .STYLE:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(183)
		 		try styleClause()

		 		break

		 	case .STROKE:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(184)
		 		try strokeClause()

		 		break

		 	case .FILL:
		 		try enterOuterAlt(_localctx, 6)
		 		setState(185)
		 		try fillClause()

		 		break

		 	case .BORDER:
		 		try enterOuterAlt(_localctx, 7)
		 		setState(186)
		 		try borderClause()

		 		break

		 	case .NOBORDER:
		 		try enterOuterAlt(_localctx, 8)
		 		setState(187)
		 		try noborderClause()

		 		break

		 	case .BORDERS:
		 		try enterOuterAlt(_localctx, 9)
		 		setState(188)
		 		try bordersClause()

		 		break

		 	case .LINE:
		 		try enterOuterAlt(_localctx, 10)
		 		setState(189)
		 		try lineClause()

		 		break

		 	case .DASH:
		 		try enterOuterAlt(_localctx, 11)
		 		setState(190)
		 		try dashClause()

		 		break

		 	case .GAP:
		 		try enterOuterAlt(_localctx, 12)
		 		setState(191)
		 		try gapClause()

		 		break

		 	case .HALIGN:
		 		try enterOuterAlt(_localctx, 13)
		 		setState(192)
		 		try halignClause()

		 		break

		 	case .VALIGN:
		 		try enterOuterAlt(_localctx, 14)
		 		setState(193)
		 		try valignClause()

		 		break

		 	case .TEXTONBORDER:
		 		try enterOuterAlt(_localctx, 15)
		 		setState(194)
		 		try textOnBorderClause()

		 		break

		 	case .PADDING:
		 		try enterOuterAlt(_localctx, 16)
		 		setState(195)
		 		try paddingClause()

		 		break

		 	case .SHADOW:
		 		try enterOuterAlt(_localctx, 17)
		 		setState(196)
		 		try shadowClause()

		 		break

		 	case .BORDERCOLOR:
		 		try enterOuterAlt(_localctx, 18)
		 		setState(197)
		 		try borderColorClause()

		 		break

		 	case .FILLCOLOR:
		 		try enterOuterAlt(_localctx, 19)
		 		setState(198)
		 		try fillColorClause()

		 		break

		 	case .TEXTCOLOR:
		 		try enterOuterAlt(_localctx, 20)
		 		setState(199)
		 		try textColorClause()

		 		break

		 	case .FLOAT:
		 		try enterOuterAlt(_localctx, 21)
		 		setState(200)
		 		try floatClause()

		 		break
		 	case .RIGHT_OF:fallthrough
		 	case .BELOW:fallthrough
		 	case .LEFT_OF:fallthrough
		 	case .ABOVE:
		 		try enterOuterAlt(_localctx, 22)
		 		setState(201)
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
		 	setState(204)
		 	try match(YuzuDrawDSLParser.Tokens.ARROW.rawValue)
		 	setState(205)
		 	try match(YuzuDrawDSLParser.Tokens.FROM.rawValue)
		 	setState(206)
		 	try endpointExpr()
		 	setState(207)
		 	try match(YuzuDrawDSLParser.Tokens.TO.rawValue)
		 	setState(208)
		 	try endpointExpr()
		 	setState(212)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (((Int64(_la) & ~0x3f) == 0 && ((Int64(1) << _la) & 16106151936) != 0)) {
		 		setState(209)
		 		try arrowClause()


		 		setState(214)
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
		 	setState(221)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .STYLE:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(215)
		 		try styleClause()

		 		break

		 	case .STROKE:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(216)
		 		try strokeClause()

		 		break

		 	case .LABEL:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(217)
		 		try labelClause()

		 		break

		 	case .STROKECOLOR:
		 		try enterOuterAlt(_localctx, 4)
		 		setState(218)
		 		try strokeColorClause()

		 		break

		 	case .LABELCOLOR:
		 		try enterOuterAlt(_localctx, 5)
		 		setState(219)
		 		try labelColorClause()

		 		break

		 	case .FLOAT:
		 		try enterOuterAlt(_localctx, 6)
		 		setState(220)
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
		 	setState(223)
		 	try match(YuzuDrawDSLParser.Tokens.TEXT.rawValue)
		 	setState(224)
		 	try stringValue()
		 	setState(226)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.AT.rawValue) {
		 		setState(225)
		 		try atClause()

		 	}

		 	setState(229)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.TEXTCOLOR.rawValue) {
		 		setState(228)
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
		 	setState(231)
		 	try match(YuzuDrawDSLParser.Tokens.PENCIL.rawValue)
		 	setState(232)
		 	try match(YuzuDrawDSLParser.Tokens.AT.rawValue)
		 	setState(233)
		 	try positionExpr()
		 	setState(234)
		 	try match(YuzuDrawDSLParser.Tokens.CELLS.rawValue)
		 	setState(235)
		 	try match(YuzuDrawDSLParser.Tokens.LBRACK.rawValue)
		 	setState(236)
		 	try pencilCell()
		 	setState(241)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.SEMI.rawValue) {
		 		setState(237)
		 		try match(YuzuDrawDSLParser.Tokens.SEMI.rawValue)
		 		setState(238)
		 		try pencilCell()


		 		setState(243)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(244)
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
		 	setState(246)
		 	try intValue()
		 	setState(247)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(248)
		 	try intValue()
		 	setState(249)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(250)
		 	try stringValue()
		 	setState(253)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(251)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(252)
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
		 	setState(255)
		 	try match(YuzuDrawDSLParser.Tokens.IDKW.rawValue)
		 	setState(256)
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
		 	setState(258)
		 	try match(YuzuDrawDSLParser.Tokens.AT.rawValue)
		 	setState(259)
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
		 	setState(261)
		 	try match(YuzuDrawDSLParser.Tokens.SIZE.rawValue)
		 	setState(262)
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
		 	setState(264)
		 	try match(YuzuDrawDSLParser.Tokens.STYLE.rawValue)
		 	setState(265)
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
		 	setState(267)
		 	try match(YuzuDrawDSLParser.Tokens.STROKE.rawValue)
		 	setState(268)
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
		 	setState(270)
		 	try match(YuzuDrawDSLParser.Tokens.FILL.rawValue)
		 	setState(271)
		 	try fillModeValue()
		 	setState(274)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.CHAR.rawValue) {
		 		setState(272)
		 		try match(YuzuDrawDSLParser.Tokens.CHAR.rawValue)
		 		setState(273)
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
		 	setState(276)
		 	try match(YuzuDrawDSLParser.Tokens.BORDER.rawValue)
		 	setState(277)
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
		 	setState(279)
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
		 	setState(281)
		 	try match(YuzuDrawDSLParser.Tokens.BORDERS.rawValue)
		 	setState(282)
		 	try sideValue()
		 	setState(287)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(283)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(284)
		 		try sideValue()


		 		setState(289)
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
		 	setState(290)
		 	try match(YuzuDrawDSLParser.Tokens.LINE.rawValue)
		 	setState(291)
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
		 	setState(293)
		 	try match(YuzuDrawDSLParser.Tokens.DASH.rawValue)
		 	setState(294)
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
		 	setState(296)
		 	try match(YuzuDrawDSLParser.Tokens.GAP.rawValue)
		 	setState(297)
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
		 	setState(299)
		 	try match(YuzuDrawDSLParser.Tokens.HALIGN.rawValue)
		 	setState(300)
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
		 	setState(302)
		 	try match(YuzuDrawDSLParser.Tokens.VALIGN.rawValue)
		 	setState(303)
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
		 	setState(305)
		 	try match(YuzuDrawDSLParser.Tokens.TEXTONBORDER.rawValue)
		 	setState(307)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.TRUE.rawValue || _la == YuzuDrawDSLParser.Tokens.FALSE.rawValue) {
		 		setState(306)
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
		 	setState(309)
		 	try match(YuzuDrawDSLParser.Tokens.PADDING.rawValue)
		 	setState(310)
		 	try intValue()
		 	setState(311)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(312)
		 	try intValue()
		 	setState(313)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(314)
		 	try intValue()
		 	setState(315)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(316)
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
		 	setState(318)
		 	try match(YuzuDrawDSLParser.Tokens.SHADOW.rawValue)
		 	setState(319)
		 	try shadowStyleValue()
		 	setState(323)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (_la == YuzuDrawDSLParser.Tokens.XKW.rawValue || _la == YuzuDrawDSLParser.Tokens.YKW.rawValue) {
		 		setState(320)
		 		try shadowOffsetClause()


		 		setState(325)
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
		 	setState(330)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .XKW:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(326)
		 		try match(YuzuDrawDSLParser.Tokens.XKW.rawValue)
		 		setState(327)
		 		try signedInt()

		 		break

		 	case .YKW:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(328)
		 		try match(YuzuDrawDSLParser.Tokens.YKW.rawValue)
		 		setState(329)
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
		 	setState(332)
		 	try match(YuzuDrawDSLParser.Tokens.BORDERCOLOR.rawValue)
		 	setState(333)
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
		 	setState(335)
		 	try match(YuzuDrawDSLParser.Tokens.FILLCOLOR.rawValue)
		 	setState(336)
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
		 	setState(338)
		 	try match(YuzuDrawDSLParser.Tokens.TEXTCOLOR.rawValue)
		 	setState(339)
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
		 	setState(341)
		 	try match(YuzuDrawDSLParser.Tokens.STROKECOLOR.rawValue)
		 	setState(342)
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
		 	setState(344)
		 	try match(YuzuDrawDSLParser.Tokens.LABELCOLOR.rawValue)
		 	setState(345)
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
		 	setState(347)
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
		 	setState(349)
		 	try directionKeyword()
		 	setState(350)
		 	try referenceTarget()
		 	setState(352)
		 	try _errHandler.sync(self)
		 	switch (try getInterpreter().adaptivePredict(_input,22,_ctx)) {
		 	case 1:
		 		setState(351)
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
		 	setState(354)
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
		 	setState(356)
		 	try match(YuzuDrawDSLParser.Tokens.LABEL.rawValue)
		 	setState(357)
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
		 	setState(361)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .PLUS:fallthrough
		 	case .MINUS:fallthrough
		 	case .INTEGER:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(359)
		 		try coordinate()

		 		break
		 	case .STRING:fallthrough
		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(360)
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
		 	setState(369)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .PLUS:fallthrough
		 	case .MINUS:fallthrough
		 	case .INTEGER:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(363)
		 		try coordinate()

		 		break
		 	case .STRING:fallthrough
		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(364)
		 		try referenceTarget()
		 		setState(367)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		if (_la == YuzuDrawDSLParser.Tokens.DOT.rawValue) {
		 			setState(365)
		 			try match(YuzuDrawDSLParser.Tokens.DOT.rawValue)
		 			setState(366)
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
		 	setState(371)
		 	try referenceTarget()
		 	setState(374)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.DOT.rawValue) {
		 		setState(372)
		 		try match(YuzuDrawDSLParser.Tokens.DOT.rawValue)
		 		setState(373)
		 		try sideValue()

		 	}

		 	setState(377)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.PLUS.rawValue || _la == YuzuDrawDSLParser.Tokens.MINUS.rawValue) {
		 		setState(376)
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
		 	setState(379)
		 	try sign()
		 	setState(380)
		 	try intValue()
		 	setState(383)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.COMMA.rawValue) {
		 		setState(381)
		 		try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 		setState(382)
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
		 	setState(387)
		 	try _errHandler.sync(self)
		 	switch (YuzuDrawDSLParser.Tokens(rawValue: try _input.LA(1))!) {
		 	case .STRING:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(385)
		 		try stringValue()

		 		break

		 	case .IDENTIFIER:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(386)
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
		 	setState(389)
		 	try signedInt()
		 	setState(390)
		 	try match(YuzuDrawDSLParser.Tokens.COMMA.rawValue)
		 	setState(391)
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
		 	setState(393)
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
		 	setState(395)
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
		 	setState(397)
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
		 	setState(399)
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
		 	setState(401)
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
		 	setState(403)
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
		 	setState(405)
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
		 	setState(407)
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
		 	setState(409)
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
		 	setState(411)
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
		 	setState(413)
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
		 	setState(415)
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
		 	setState(418)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (_la == YuzuDrawDSLParser.Tokens.PLUS.rawValue || _la == YuzuDrawDSLParser.Tokens.MINUS.rawValue) {
		 		setState(417)
		 		try sign()

		 	}

		 	setState(420)
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
		 	setState(422)
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
		 	setState(424)
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
		4,1,81,427,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,2,7,
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
		8,2,10,2,12,2,159,9,2,3,2,161,8,2,1,3,1,3,1,3,3,3,166,8,3,1,3,3,3,169,
		8,3,1,4,1,4,1,4,5,4,174,8,4,10,4,12,4,177,9,4,1,5,1,5,1,6,1,6,1,6,1,6,
		1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,6,1,
		6,3,6,203,8,6,1,7,1,7,1,7,1,7,1,7,1,7,5,7,211,8,7,10,7,12,7,214,9,7,1,
		8,1,8,1,8,1,8,1,8,1,8,3,8,222,8,8,1,9,1,9,1,9,3,9,227,8,9,1,9,3,9,230,
		8,9,1,10,1,10,1,10,1,10,1,10,1,10,1,10,1,10,5,10,240,8,10,10,10,12,10,
		243,9,10,1,10,1,10,1,11,1,11,1,11,1,11,1,11,1,11,1,11,3,11,254,8,11,1,
		12,1,12,1,12,1,13,1,13,1,13,1,14,1,14,1,14,1,15,1,15,1,15,1,16,1,16,1,
		16,1,17,1,17,1,17,1,17,3,17,275,8,17,1,18,1,18,1,18,1,19,1,19,1,20,1,20,
		1,20,1,20,5,20,286,8,20,10,20,12,20,289,9,20,1,21,1,21,1,21,1,22,1,22,
		1,22,1,23,1,23,1,23,1,24,1,24,1,24,1,25,1,25,1,25,1,26,1,26,3,26,308,8,
		26,1,27,1,27,1,27,1,27,1,27,1,27,1,27,1,27,1,27,1,28,1,28,1,28,5,28,322,
		8,28,10,28,12,28,325,9,28,1,29,1,29,1,29,1,29,3,29,331,8,29,1,30,1,30,
		1,30,1,31,1,31,1,31,1,32,1,32,1,32,1,33,1,33,1,33,1,34,1,34,1,34,1,35,
		1,35,1,36,1,36,1,36,3,36,353,8,36,1,37,1,37,1,38,1,38,1,38,1,39,1,39,3,
		39,362,8,39,1,40,1,40,1,40,1,40,3,40,368,8,40,3,40,370,8,40,1,41,1,41,
		1,41,3,41,375,8,41,1,41,3,41,378,8,41,1,42,1,42,1,42,1,42,3,42,384,8,42,
		1,43,1,43,3,43,388,8,43,1,44,1,44,1,44,1,44,1,45,1,45,1,46,1,46,1,47,1,
		47,1,48,1,48,1,49,1,49,1,50,1,50,1,51,1,51,1,52,1,52,1,53,1,53,1,54,1,
		54,1,55,1,55,1,56,1,56,1,57,3,57,419,8,57,1,57,1,57,1,58,1,58,1,59,1,59,
		1,59,0,0,60,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,
		42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,
		90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,0,12,1,0,36,37,
		1,0,3,5,1,0,60,63,1,0,39,42,1,0,43,48,2,0,46,46,49,49,2,0,50,51,54,54,
		2,0,52,53,55,55,1,0,56,57,1,0,50,53,1,0,58,59,1,0,72,73,425,0,126,1,0,
		0,0,2,140,1,0,0,0,4,160,1,0,0,0,6,162,1,0,0,0,8,170,1,0,0,0,10,178,1,0,
		0,0,12,202,1,0,0,0,14,204,1,0,0,0,16,221,1,0,0,0,18,223,1,0,0,0,20,231,
		1,0,0,0,22,246,1,0,0,0,24,255,1,0,0,0,26,258,1,0,0,0,28,261,1,0,0,0,30,
		264,1,0,0,0,32,267,1,0,0,0,34,270,1,0,0,0,36,276,1,0,0,0,38,279,1,0,0,
		0,40,281,1,0,0,0,42,290,1,0,0,0,44,293,1,0,0,0,46,296,1,0,0,0,48,299,1,
		0,0,0,50,302,1,0,0,0,52,305,1,0,0,0,54,309,1,0,0,0,56,318,1,0,0,0,58,330,
		1,0,0,0,60,332,1,0,0,0,62,335,1,0,0,0,64,338,1,0,0,0,66,341,1,0,0,0,68,
		344,1,0,0,0,70,347,1,0,0,0,72,349,1,0,0,0,74,354,1,0,0,0,76,356,1,0,0,
		0,78,361,1,0,0,0,80,369,1,0,0,0,82,371,1,0,0,0,84,379,1,0,0,0,86,387,1,
		0,0,0,88,389,1,0,0,0,90,393,1,0,0,0,92,395,1,0,0,0,94,397,1,0,0,0,96,399,
		1,0,0,0,98,401,1,0,0,0,100,403,1,0,0,0,102,405,1,0,0,0,104,407,1,0,0,0,
		106,409,1,0,0,0,108,411,1,0,0,0,110,413,1,0,0,0,112,415,1,0,0,0,114,418,
		1,0,0,0,116,422,1,0,0,0,118,424,1,0,0,0,120,122,3,2,1,0,121,120,1,0,0,
		0,121,122,1,0,0,0,122,123,1,0,0,0,123,125,5,79,0,0,124,121,1,0,0,0,125,
		128,1,0,0,0,126,124,1,0,0,0,126,127,1,0,0,0,127,130,1,0,0,0,128,126,1,
		0,0,0,129,131,3,2,1,0,130,129,1,0,0,0,130,131,1,0,0,0,131,132,1,0,0,0,
		132,133,5,0,0,1,133,1,1,0,0,0,134,141,3,4,2,0,135,141,3,6,3,0,136,141,
		3,8,4,0,137,141,3,14,7,0,138,141,3,18,9,0,139,141,3,20,10,0,140,134,1,
		0,0,0,140,135,1,0,0,0,140,136,1,0,0,0,140,137,1,0,0,0,140,138,1,0,0,0,
		140,139,1,0,0,0,141,3,1,0,0,0,142,143,5,1,0,0,143,147,3,92,46,0,144,146,
		7,0,0,0,145,144,1,0,0,0,146,149,1,0,0,0,147,145,1,0,0,0,147,148,1,0,0,
		0,148,150,1,0,0,0,149,147,1,0,0,0,150,151,5,38,0,0,151,161,1,0,0,0,152,
		153,5,1,0,0,153,157,3,92,46,0,154,156,7,0,0,0,155,154,1,0,0,0,156,159,
		1,0,0,0,157,155,1,0,0,0,157,158,1,0,0,0,158,161,1,0,0,0,159,157,1,0,0,
		0,160,142,1,0,0,0,160,152,1,0,0,0,161,5,1,0,0,0,162,163,5,2,0,0,163,165,
		3,92,46,0,164,166,3,24,12,0,165,164,1,0,0,0,165,166,1,0,0,0,166,168,1,
		0,0,0,167,169,3,26,13,0,168,167,1,0,0,0,168,169,1,0,0,0,169,7,1,0,0,0,
		170,171,3,10,5,0,171,175,3,92,46,0,172,174,3,12,6,0,173,172,1,0,0,0,174,
		177,1,0,0,0,175,173,1,0,0,0,175,176,1,0,0,0,176,9,1,0,0,0,177,175,1,0,
		0,0,178,179,7,1,0,0,179,11,1,0,0,0,180,203,3,24,12,0,181,203,3,26,13,0,
		182,203,3,28,14,0,183,203,3,30,15,0,184,203,3,32,16,0,185,203,3,34,17,
		0,186,203,3,36,18,0,187,203,3,38,19,0,188,203,3,40,20,0,189,203,3,42,21,
		0,190,203,3,44,22,0,191,203,3,46,23,0,192,203,3,48,24,0,193,203,3,50,25,
		0,194,203,3,52,26,0,195,203,3,54,27,0,196,203,3,56,28,0,197,203,3,60,30,
		0,198,203,3,62,31,0,199,203,3,64,32,0,200,203,3,70,35,0,201,203,3,72,36,
		0,202,180,1,0,0,0,202,181,1,0,0,0,202,182,1,0,0,0,202,183,1,0,0,0,202,
		184,1,0,0,0,202,185,1,0,0,0,202,186,1,0,0,0,202,187,1,0,0,0,202,188,1,
		0,0,0,202,189,1,0,0,0,202,190,1,0,0,0,202,191,1,0,0,0,202,192,1,0,0,0,
		202,193,1,0,0,0,202,194,1,0,0,0,202,195,1,0,0,0,202,196,1,0,0,0,202,197,
		1,0,0,0,202,198,1,0,0,0,202,199,1,0,0,0,202,200,1,0,0,0,202,201,1,0,0,
		0,203,13,1,0,0,0,204,205,5,6,0,0,205,206,5,9,0,0,206,207,3,80,40,0,207,
		208,5,10,0,0,208,212,3,80,40,0,209,211,3,16,8,0,210,209,1,0,0,0,211,214,
		1,0,0,0,212,210,1,0,0,0,212,213,1,0,0,0,213,15,1,0,0,0,214,212,1,0,0,0,
		215,222,3,30,15,0,216,222,3,32,16,0,217,222,3,76,38,0,218,222,3,66,33,
		0,219,222,3,68,34,0,220,222,3,70,35,0,221,215,1,0,0,0,221,216,1,0,0,0,
		221,217,1,0,0,0,221,218,1,0,0,0,221,219,1,0,0,0,221,220,1,0,0,0,222,17,
		1,0,0,0,223,224,5,7,0,0,224,226,3,92,46,0,225,227,3,26,13,0,226,225,1,
		0,0,0,226,227,1,0,0,0,227,229,1,0,0,0,228,230,3,64,32,0,229,228,1,0,0,
		0,229,230,1,0,0,0,230,19,1,0,0,0,231,232,5,8,0,0,232,233,5,11,0,0,233,
		234,3,78,39,0,234,235,5,64,0,0,235,236,5,70,0,0,236,241,3,22,11,0,237,
		238,5,69,0,0,238,240,3,22,11,0,239,237,1,0,0,0,240,243,1,0,0,0,241,239,
		1,0,0,0,241,242,1,0,0,0,242,244,1,0,0,0,243,241,1,0,0,0,244,245,5,71,0,
		0,245,21,1,0,0,0,246,247,3,118,59,0,247,248,5,67,0,0,248,249,3,118,59,
		0,249,250,5,67,0,0,250,253,3,92,46,0,251,252,5,67,0,0,252,254,3,96,48,
		0,253,251,1,0,0,0,253,254,1,0,0,0,254,23,1,0,0,0,255,256,5,35,0,0,256,
		257,3,94,47,0,257,25,1,0,0,0,258,259,5,11,0,0,259,260,3,78,39,0,260,27,
		1,0,0,0,261,262,5,12,0,0,262,263,3,90,45,0,263,29,1,0,0,0,264,265,5,13,
		0,0,265,266,3,98,49,0,266,31,1,0,0,0,267,268,5,14,0,0,268,269,3,98,49,
		0,269,33,1,0,0,0,270,271,5,15,0,0,271,274,3,100,50,0,272,273,5,34,0,0,
		273,275,3,92,46,0,274,272,1,0,0,0,274,275,1,0,0,0,275,35,1,0,0,0,276,277,
		5,16,0,0,277,278,7,0,0,0,278,37,1,0,0,0,279,280,5,17,0,0,280,39,1,0,0,
		0,281,282,5,18,0,0,282,287,3,110,55,0,283,284,5,67,0,0,284,286,3,110,55,
		0,285,283,1,0,0,0,286,289,1,0,0,0,287,285,1,0,0,0,287,288,1,0,0,0,288,
		41,1,0,0,0,289,287,1,0,0,0,290,291,5,19,0,0,291,292,3,102,51,0,292,43,
		1,0,0,0,293,294,5,20,0,0,294,295,3,118,59,0,295,45,1,0,0,0,296,297,5,21,
		0,0,297,298,3,118,59,0,298,47,1,0,0,0,299,300,5,22,0,0,300,301,3,104,52,
		0,301,49,1,0,0,0,302,303,5,23,0,0,303,304,3,106,53,0,304,51,1,0,0,0,305,
		307,5,24,0,0,306,308,3,112,56,0,307,306,1,0,0,0,307,308,1,0,0,0,308,53,
		1,0,0,0,309,310,5,25,0,0,310,311,3,118,59,0,311,312,5,67,0,0,312,313,3,
		118,59,0,313,314,5,67,0,0,314,315,3,118,59,0,315,316,5,67,0,0,316,317,
		3,118,59,0,317,55,1,0,0,0,318,319,5,26,0,0,319,323,3,108,54,0,320,322,
		3,58,29,0,321,320,1,0,0,0,322,325,1,0,0,0,323,321,1,0,0,0,323,324,1,0,
		0,0,324,57,1,0,0,0,325,323,1,0,0,0,326,327,5,65,0,0,327,331,3,114,57,0,
		328,329,5,66,0,0,329,331,3,114,57,0,330,326,1,0,0,0,330,328,1,0,0,0,331,
		59,1,0,0,0,332,333,5,27,0,0,333,334,3,96,48,0,334,61,1,0,0,0,335,336,5,
		28,0,0,336,337,3,96,48,0,337,63,1,0,0,0,338,339,5,29,0,0,339,340,3,96,
		48,0,340,65,1,0,0,0,341,342,5,30,0,0,342,343,3,96,48,0,343,67,1,0,0,0,
		344,345,5,31,0,0,345,346,3,96,48,0,346,69,1,0,0,0,347,348,5,32,0,0,348,
		71,1,0,0,0,349,350,3,74,37,0,350,352,3,86,43,0,351,353,3,46,23,0,352,351,
		1,0,0,0,352,353,1,0,0,0,353,73,1,0,0,0,354,355,7,2,0,0,355,75,1,0,0,0,
		356,357,5,33,0,0,357,358,3,92,46,0,358,77,1,0,0,0,359,362,3,88,44,0,360,
		362,3,82,41,0,361,359,1,0,0,0,361,360,1,0,0,0,362,79,1,0,0,0,363,370,3,
		88,44,0,364,367,3,86,43,0,365,366,5,68,0,0,366,368,3,110,55,0,367,365,
		1,0,0,0,367,368,1,0,0,0,368,370,1,0,0,0,369,363,1,0,0,0,369,364,1,0,0,
		0,370,81,1,0,0,0,371,374,3,86,43,0,372,373,5,68,0,0,373,375,3,110,55,0,
		374,372,1,0,0,0,374,375,1,0,0,0,375,377,1,0,0,0,376,378,3,84,42,0,377,
		376,1,0,0,0,377,378,1,0,0,0,378,83,1,0,0,0,379,380,3,116,58,0,380,383,
		3,118,59,0,381,382,5,67,0,0,382,384,3,114,57,0,383,381,1,0,0,0,383,384,
		1,0,0,0,384,85,1,0,0,0,385,388,3,92,46,0,386,388,3,94,47,0,387,385,1,0,
		0,0,387,386,1,0,0,0,388,87,1,0,0,0,389,390,3,114,57,0,390,391,5,67,0,0,
		391,392,3,114,57,0,392,89,1,0,0,0,393,394,5,76,0,0,394,91,1,0,0,0,395,
		396,5,74,0,0,396,93,1,0,0,0,397,398,5,78,0,0,398,95,1,0,0,0,399,400,5,
		75,0,0,400,97,1,0,0,0,401,402,7,3,0,0,402,99,1,0,0,0,403,404,7,4,0,0,404,
		101,1,0,0,0,405,406,7,5,0,0,406,103,1,0,0,0,407,408,7,6,0,0,408,105,1,
		0,0,0,409,410,7,7,0,0,410,107,1,0,0,0,411,412,7,8,0,0,412,109,1,0,0,0,
		413,414,7,9,0,0,414,111,1,0,0,0,415,416,7,10,0,0,416,113,1,0,0,0,417,419,
		3,116,58,0,418,417,1,0,0,0,418,419,1,0,0,0,419,420,1,0,0,0,420,421,3,118,
		59,0,421,115,1,0,0,0,422,423,7,11,0,0,423,117,1,0,0,0,424,425,5,77,0,0,
		425,119,1,0,0,0,31,121,126,130,140,147,157,160,165,168,175,202,212,221,
		226,229,241,253,274,287,307,323,330,352,361,367,369,374,377,383,387,418
	]

	public
	nonisolated(unsafe) static let _ATN = try! ATNDeserializer().deserialize(_serializedATN)
}
