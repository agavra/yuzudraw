import Foundation

struct ProjectMetadata: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var fileURL: URL?
    var lastModified: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL? = nil,
        lastModified: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.lastModified = lastModified
        self.createdAt = createdAt
    }
}
