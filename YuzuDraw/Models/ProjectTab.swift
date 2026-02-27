import Foundation

struct ProjectTab: Identifiable, Equatable {
    let id: UUID
    var metadata: ProjectMetadata
    var hasUnsavedChanges: Bool
    var isStartPage: Bool

    init(metadata: ProjectMetadata, hasUnsavedChanges: Bool = false, isStartPage: Bool = false) {
        self.id = metadata.id
        self.metadata = metadata
        self.hasUnsavedChanges = hasUnsavedChanges
        self.isStartPage = isStartPage
    }
}
