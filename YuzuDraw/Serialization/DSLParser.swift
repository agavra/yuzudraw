import Antlr4
import Foundation

enum DSLParserError: Error, Equatable {
    case invalidSyntax(String)
    case unexpectedToken(String)
}

enum DSLParser {
    static func parse(_ input: String) throws -> Document {
        let errorListener = DSLSyntaxErrorListener()
        let lexer = YuzuDrawDSLLexer(ANTLRInputStream(input))
        lexer.removeErrorListeners()
        lexer.addErrorListener(errorListener)

        let parser = try YuzuDrawDSLParser(CommonTokenStream(lexer))
        parser.removeErrorListeners()
        parser.addErrorListener(errorListener)

        let tree = try parser.document()
        if let message = errorListener.messages.first {
            throw DSLParserError.invalidSyntax(message)
        }

        let ast = try DSLASTBuilder.build(from: tree, source: input)
        return try DSLSemanticAnalyzer.lower(ast)
    }
}

private final class DSLSyntaxErrorListener: BaseErrorListener, @unchecked Sendable {
    var messages: [String] = []

    override func syntaxError<T>(
        _ recognizer: Recognizer<T>,
        _ offendingSymbol: AnyObject?,
        _ line: Int,
        _ charPositionInLine: Int,
        _ msg: String,
        _ e: AnyObject?
    ) {
        messages.append("line \(line):\(charPositionInLine) \(msg)")
    }
}
