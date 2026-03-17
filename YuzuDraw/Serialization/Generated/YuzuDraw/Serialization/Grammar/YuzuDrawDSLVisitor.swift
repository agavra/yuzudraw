// Generated from YuzuDraw/Serialization/Grammar/YuzuDrawDSL.g4 by ANTLR 4.13.2
import Antlr4

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link YuzuDrawDSLParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
open class YuzuDrawDSLVisitor<T>: ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#document}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitDocument(_ ctx: YuzuDrawDSLParser.DocumentContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#statement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStatement(_ ctx: YuzuDrawDSLParser.StatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#layerStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitLayerStatement(_ ctx: YuzuDrawDSLParser.LayerStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#groupStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitGroupStatement(_ ctx: YuzuDrawDSLParser.GroupStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#rectangleStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitRectangleStatement(_ ctx: YuzuDrawDSLParser.RectangleStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#rectKeyword}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitRectKeyword(_ ctx: YuzuDrawDSLParser.RectKeywordContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#rectangleClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitRectangleClause(_ ctx: YuzuDrawDSLParser.RectangleClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#arrowStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitArrowStatement(_ ctx: YuzuDrawDSLParser.ArrowStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#arrowClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitArrowClause(_ ctx: YuzuDrawDSLParser.ArrowClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#textStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitTextStatement(_ ctx: YuzuDrawDSLParser.TextStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#pencilStatement}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitPencilStatement(_ ctx: YuzuDrawDSLParser.PencilStatementContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#pencilCell}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitPencilCell(_ ctx: YuzuDrawDSLParser.PencilCellContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#idClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitIdClause(_ ctx: YuzuDrawDSLParser.IdClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#atClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitAtClause(_ ctx: YuzuDrawDSLParser.AtClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#sizeClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitSizeClause(_ ctx: YuzuDrawDSLParser.SizeClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#styleClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStyleClause(_ ctx: YuzuDrawDSLParser.StyleClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#strokeClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStrokeClause(_ ctx: YuzuDrawDSLParser.StrokeClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#fillClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitFillClause(_ ctx: YuzuDrawDSLParser.FillClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#borderClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitBorderClause(_ ctx: YuzuDrawDSLParser.BorderClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#noborderClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitNoborderClause(_ ctx: YuzuDrawDSLParser.NoborderClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#bordersClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitBordersClause(_ ctx: YuzuDrawDSLParser.BordersClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#lineClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitLineClause(_ ctx: YuzuDrawDSLParser.LineClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#dashClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitDashClause(_ ctx: YuzuDrawDSLParser.DashClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#gapClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitGapClause(_ ctx: YuzuDrawDSLParser.GapClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#halignClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitHalignClause(_ ctx: YuzuDrawDSLParser.HalignClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#valignClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitValignClause(_ ctx: YuzuDrawDSLParser.ValignClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#textOnBorderClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitTextOnBorderClause(_ ctx: YuzuDrawDSLParser.TextOnBorderClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#paddingClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitPaddingClause(_ ctx: YuzuDrawDSLParser.PaddingClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#shadowClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitShadowClause(_ ctx: YuzuDrawDSLParser.ShadowClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#shadowOffsetClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitShadowOffsetClause(_ ctx: YuzuDrawDSLParser.ShadowOffsetClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#borderColorClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitBorderColorClause(_ ctx: YuzuDrawDSLParser.BorderColorClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#fillColorClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitFillColorClause(_ ctx: YuzuDrawDSLParser.FillColorClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#textColorClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitTextColorClause(_ ctx: YuzuDrawDSLParser.TextColorClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#strokeColorClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStrokeColorClause(_ ctx: YuzuDrawDSLParser.StrokeColorClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#labelColorClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitLabelColorClause(_ ctx: YuzuDrawDSLParser.LabelColorClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#floatClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitFloatClause(_ ctx: YuzuDrawDSLParser.FloatClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#semanticPositionClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitSemanticPositionClause(_ ctx: YuzuDrawDSLParser.SemanticPositionClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#directionKeyword}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitDirectionKeyword(_ ctx: YuzuDrawDSLParser.DirectionKeywordContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#labelClause}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitLabelClause(_ ctx: YuzuDrawDSLParser.LabelClauseContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#positionExpr}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitPositionExpr(_ ctx: YuzuDrawDSLParser.PositionExprContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#endpointExpr}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitEndpointExpr(_ ctx: YuzuDrawDSLParser.EndpointExprContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#referenceExpr}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitReferenceExpr(_ ctx: YuzuDrawDSLParser.ReferenceExprContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#offsetExpr}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitOffsetExpr(_ ctx: YuzuDrawDSLParser.OffsetExprContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#referenceTarget}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitReferenceTarget(_ ctx: YuzuDrawDSLParser.ReferenceTargetContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#coordinate}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitCoordinate(_ ctx: YuzuDrawDSLParser.CoordinateContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#dimension}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitDimension(_ ctx: YuzuDrawDSLParser.DimensionContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#stringValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStringValue(_ ctx: YuzuDrawDSLParser.StringValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#identifier}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitIdentifier(_ ctx: YuzuDrawDSLParser.IdentifierContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#colorValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitColorValue(_ ctx: YuzuDrawDSLParser.ColorValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#strokeStyleValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitStrokeStyleValue(_ ctx: YuzuDrawDSLParser.StrokeStyleValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#fillModeValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitFillModeValue(_ ctx: YuzuDrawDSLParser.FillModeValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#borderLineStyleValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitBorderLineStyleValue(_ ctx: YuzuDrawDSLParser.BorderLineStyleValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#horizontalAlignValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitHorizontalAlignValue(_ ctx: YuzuDrawDSLParser.HorizontalAlignValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#verticalAlignValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitVerticalAlignValue(_ ctx: YuzuDrawDSLParser.VerticalAlignValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#shadowStyleValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitShadowStyleValue(_ ctx: YuzuDrawDSLParser.ShadowStyleValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#sideValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitSideValue(_ ctx: YuzuDrawDSLParser.SideValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#boolValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitBoolValue(_ ctx: YuzuDrawDSLParser.BoolValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#signedInt}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitSignedInt(_ ctx: YuzuDrawDSLParser.SignedIntContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#sign}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitSign(_ ctx: YuzuDrawDSLParser.SignContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

	/**
	 * Visit a parse tree produced by {@link YuzuDrawDSLParser#intValue}.
	- Parameters:
	  - ctx: the parse tree
	- returns: the visitor result
	 */
	open func visitIntValue(_ ctx: YuzuDrawDSLParser.IntValueContext) -> T {
	 	fatalError(#function + " must be overridden")
	}

}