import Foundation

enum DocumentCodable {
    static func encode(_ document: Document) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(document)
    }

    static func decode(from data: Data) throws -> Document {
        let decoder = JSONDecoder()
        return try decoder.decode(Document.self, from: data)
    }
}
