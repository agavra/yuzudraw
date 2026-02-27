import Foundation

struct RecentProject: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var fileURL: URL
    var lastOpened: Date

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL,
        lastOpened: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.lastOpened = lastOpened
    }
}
