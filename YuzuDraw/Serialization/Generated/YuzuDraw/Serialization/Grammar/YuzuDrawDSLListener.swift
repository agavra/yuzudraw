// Generated from YuzuDraw/Serialization/Grammar/YuzuDrawDSL.g4 by ANTLR 4.13.2
import Antlr4

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link YuzuDrawDSLParser}.
 */
public protocol YuzuDrawDSLListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#document}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDocument(_ ctx: YuzuDrawDSLParser.DocumentContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#document}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDocument(_ ctx: YuzuDrawDSLParser.DocumentContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#statement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStatement(_ ctx: YuzuDrawDSLParser.StatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#statement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStatement(_ ctx: YuzuDrawDSLParser.StatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#layerStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLayerStatement(_ ctx: YuzuDrawDSLParser.LayerStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#layerStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLayerStatement(_ ctx: YuzuDrawDSLParser.LayerStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#groupStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterGroupStatement(_ ctx: YuzuDrawDSLParser.GroupStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#groupStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitGroupStatement(_ ctx: YuzuDrawDSLParser.GroupStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#rectangleStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRectangleStatement(_ ctx: YuzuDrawDSLParser.RectangleStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#rectangleStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRectangleStatement(_ ctx: YuzuDrawDSLParser.RectangleStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#rectKeyword}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRectKeyword(_ ctx: YuzuDrawDSLParser.RectKeywordContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#rectKeyword}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRectKeyword(_ ctx: YuzuDrawDSLParser.RectKeywordContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#rectangleClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRectangleClause(_ ctx: YuzuDrawDSLParser.RectangleClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#rectangleClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRectangleClause(_ ctx: YuzuDrawDSLParser.RectangleClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#arrowStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterArrowStatement(_ ctx: YuzuDrawDSLParser.ArrowStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#arrowStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitArrowStatement(_ ctx: YuzuDrawDSLParser.ArrowStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#arrowClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterArrowClause(_ ctx: YuzuDrawDSLParser.ArrowClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#arrowClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitArrowClause(_ ctx: YuzuDrawDSLParser.ArrowClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#textStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTextStatement(_ ctx: YuzuDrawDSLParser.TextStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#textStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTextStatement(_ ctx: YuzuDrawDSLParser.TextStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#pencilStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPencilStatement(_ ctx: YuzuDrawDSLParser.PencilStatementContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#pencilStatement}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPencilStatement(_ ctx: YuzuDrawDSLParser.PencilStatementContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#pencilCell}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPencilCell(_ ctx: YuzuDrawDSLParser.PencilCellContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#pencilCell}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPencilCell(_ ctx: YuzuDrawDSLParser.PencilCellContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#idClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIdClause(_ ctx: YuzuDrawDSLParser.IdClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#idClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIdClause(_ ctx: YuzuDrawDSLParser.IdClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#atClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterAtClause(_ ctx: YuzuDrawDSLParser.AtClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#atClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitAtClause(_ ctx: YuzuDrawDSLParser.AtClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#sizeClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSizeClause(_ ctx: YuzuDrawDSLParser.SizeClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#sizeClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSizeClause(_ ctx: YuzuDrawDSLParser.SizeClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#styleClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStyleClause(_ ctx: YuzuDrawDSLParser.StyleClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#styleClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStyleClause(_ ctx: YuzuDrawDSLParser.StyleClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#strokeClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStrokeClause(_ ctx: YuzuDrawDSLParser.StrokeClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#strokeClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStrokeClause(_ ctx: YuzuDrawDSLParser.StrokeClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#fillClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFillClause(_ ctx: YuzuDrawDSLParser.FillClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#fillClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFillClause(_ ctx: YuzuDrawDSLParser.FillClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#borderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBorderClause(_ ctx: YuzuDrawDSLParser.BorderClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#borderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBorderClause(_ ctx: YuzuDrawDSLParser.BorderClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#noborderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNoborderClause(_ ctx: YuzuDrawDSLParser.NoborderClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#noborderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNoborderClause(_ ctx: YuzuDrawDSLParser.NoborderClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#bordersClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBordersClause(_ ctx: YuzuDrawDSLParser.BordersClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#bordersClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBordersClause(_ ctx: YuzuDrawDSLParser.BordersClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#lineClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLineClause(_ ctx: YuzuDrawDSLParser.LineClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#lineClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLineClause(_ ctx: YuzuDrawDSLParser.LineClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#dashClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDashClause(_ ctx: YuzuDrawDSLParser.DashClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#dashClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDashClause(_ ctx: YuzuDrawDSLParser.DashClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#gapClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterGapClause(_ ctx: YuzuDrawDSLParser.GapClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#gapClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitGapClause(_ ctx: YuzuDrawDSLParser.GapClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#halignClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterHalignClause(_ ctx: YuzuDrawDSLParser.HalignClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#halignClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitHalignClause(_ ctx: YuzuDrawDSLParser.HalignClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#valignClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterValignClause(_ ctx: YuzuDrawDSLParser.ValignClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#valignClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitValignClause(_ ctx: YuzuDrawDSLParser.ValignClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#textOnBorderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTextOnBorderClause(_ ctx: YuzuDrawDSLParser.TextOnBorderClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#textOnBorderClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTextOnBorderClause(_ ctx: YuzuDrawDSLParser.TextOnBorderClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#paddingClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPaddingClause(_ ctx: YuzuDrawDSLParser.PaddingClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#paddingClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPaddingClause(_ ctx: YuzuDrawDSLParser.PaddingClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#shadowClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterShadowClause(_ ctx: YuzuDrawDSLParser.ShadowClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#shadowClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitShadowClause(_ ctx: YuzuDrawDSLParser.ShadowClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#shadowOffsetClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterShadowOffsetClause(_ ctx: YuzuDrawDSLParser.ShadowOffsetClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#shadowOffsetClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitShadowOffsetClause(_ ctx: YuzuDrawDSLParser.ShadowOffsetClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#borderColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBorderColorClause(_ ctx: YuzuDrawDSLParser.BorderColorClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#borderColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBorderColorClause(_ ctx: YuzuDrawDSLParser.BorderColorClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#fillColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFillColorClause(_ ctx: YuzuDrawDSLParser.FillColorClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#fillColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFillColorClause(_ ctx: YuzuDrawDSLParser.FillColorClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#textColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTextColorClause(_ ctx: YuzuDrawDSLParser.TextColorClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#textColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTextColorClause(_ ctx: YuzuDrawDSLParser.TextColorClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#strokeColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStrokeColorClause(_ ctx: YuzuDrawDSLParser.StrokeColorClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#strokeColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStrokeColorClause(_ ctx: YuzuDrawDSLParser.StrokeColorClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#labelColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLabelColorClause(_ ctx: YuzuDrawDSLParser.LabelColorClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#labelColorClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLabelColorClause(_ ctx: YuzuDrawDSLParser.LabelColorClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#floatClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFloatClause(_ ctx: YuzuDrawDSLParser.FloatClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#floatClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFloatClause(_ ctx: YuzuDrawDSLParser.FloatClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#semanticPositionClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSemanticPositionClause(_ ctx: YuzuDrawDSLParser.SemanticPositionClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#semanticPositionClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSemanticPositionClause(_ ctx: YuzuDrawDSLParser.SemanticPositionClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#directionKeyword}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDirectionKeyword(_ ctx: YuzuDrawDSLParser.DirectionKeywordContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#directionKeyword}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDirectionKeyword(_ ctx: YuzuDrawDSLParser.DirectionKeywordContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#labelClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLabelClause(_ ctx: YuzuDrawDSLParser.LabelClauseContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#labelClause}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLabelClause(_ ctx: YuzuDrawDSLParser.LabelClauseContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#positionExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPositionExpr(_ ctx: YuzuDrawDSLParser.PositionExprContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#positionExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPositionExpr(_ ctx: YuzuDrawDSLParser.PositionExprContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#endpointExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterEndpointExpr(_ ctx: YuzuDrawDSLParser.EndpointExprContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#endpointExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitEndpointExpr(_ ctx: YuzuDrawDSLParser.EndpointExprContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#referenceExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterReferenceExpr(_ ctx: YuzuDrawDSLParser.ReferenceExprContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#referenceExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitReferenceExpr(_ ctx: YuzuDrawDSLParser.ReferenceExprContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#offsetExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterOffsetExpr(_ ctx: YuzuDrawDSLParser.OffsetExprContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#offsetExpr}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitOffsetExpr(_ ctx: YuzuDrawDSLParser.OffsetExprContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#referenceTarget}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterReferenceTarget(_ ctx: YuzuDrawDSLParser.ReferenceTargetContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#referenceTarget}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitReferenceTarget(_ ctx: YuzuDrawDSLParser.ReferenceTargetContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#coordinate}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterCoordinate(_ ctx: YuzuDrawDSLParser.CoordinateContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#coordinate}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitCoordinate(_ ctx: YuzuDrawDSLParser.CoordinateContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#dimension}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterDimension(_ ctx: YuzuDrawDSLParser.DimensionContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#dimension}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitDimension(_ ctx: YuzuDrawDSLParser.DimensionContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#stringValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStringValue(_ ctx: YuzuDrawDSLParser.StringValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#stringValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStringValue(_ ctx: YuzuDrawDSLParser.StringValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#identifier}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIdentifier(_ ctx: YuzuDrawDSLParser.IdentifierContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#identifier}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIdentifier(_ ctx: YuzuDrawDSLParser.IdentifierContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#colorValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterColorValue(_ ctx: YuzuDrawDSLParser.ColorValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#colorValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitColorValue(_ ctx: YuzuDrawDSLParser.ColorValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#strokeStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterStrokeStyleValue(_ ctx: YuzuDrawDSLParser.StrokeStyleValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#strokeStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitStrokeStyleValue(_ ctx: YuzuDrawDSLParser.StrokeStyleValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#fillModeValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterFillModeValue(_ ctx: YuzuDrawDSLParser.FillModeValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#fillModeValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitFillModeValue(_ ctx: YuzuDrawDSLParser.FillModeValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#borderLineStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBorderLineStyleValue(_ ctx: YuzuDrawDSLParser.BorderLineStyleValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#borderLineStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBorderLineStyleValue(_ ctx: YuzuDrawDSLParser.BorderLineStyleValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#horizontalAlignValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterHorizontalAlignValue(_ ctx: YuzuDrawDSLParser.HorizontalAlignValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#horizontalAlignValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitHorizontalAlignValue(_ ctx: YuzuDrawDSLParser.HorizontalAlignValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#verticalAlignValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterVerticalAlignValue(_ ctx: YuzuDrawDSLParser.VerticalAlignValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#verticalAlignValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitVerticalAlignValue(_ ctx: YuzuDrawDSLParser.VerticalAlignValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#shadowStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterShadowStyleValue(_ ctx: YuzuDrawDSLParser.ShadowStyleValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#shadowStyleValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitShadowStyleValue(_ ctx: YuzuDrawDSLParser.ShadowStyleValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#sideValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSideValue(_ ctx: YuzuDrawDSLParser.SideValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#sideValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSideValue(_ ctx: YuzuDrawDSLParser.SideValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#boolValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBoolValue(_ ctx: YuzuDrawDSLParser.BoolValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#boolValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBoolValue(_ ctx: YuzuDrawDSLParser.BoolValueContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#signedInt}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSignedInt(_ ctx: YuzuDrawDSLParser.SignedIntContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#signedInt}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSignedInt(_ ctx: YuzuDrawDSLParser.SignedIntContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#sign}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSign(_ ctx: YuzuDrawDSLParser.SignContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#sign}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSign(_ ctx: YuzuDrawDSLParser.SignContext)
	/**
	 * Enter a parse tree produced by {@link YuzuDrawDSLParser#intValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterIntValue(_ ctx: YuzuDrawDSLParser.IntValueContext)
	/**
	 * Exit a parse tree produced by {@link YuzuDrawDSLParser#intValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitIntValue(_ ctx: YuzuDrawDSLParser.IntValueContext)
}