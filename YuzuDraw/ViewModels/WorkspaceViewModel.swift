import SwiftUI

@MainActor
@Observable
final class WorkspaceViewModel {
    var tabs: [ProjectTab] = []
    var activeTabID: UUID?
    var recentProjects: [RecentProject] = []

    private(set) var editors: [UUID: EditorViewModel] = [:]

    private static let recentProjectsKey = "recentProjects"

    var hasOpenProjects: Bool {
        !tabs.isEmpty
    }

    var activeTab: ProjectTab? {
        guard let activeTabID else { return nil }
        return tabs.first { $0.id == activeTabID }
    }

    var activeEditor: EditorViewModel? {
        guard let activeTabID else { return nil }
        return editors[activeTabID]
    }

    init() {
        loadRecentProjects()
        startAutoSave()
    }

    init(tabs: [ProjectTab], editors: [UUID: EditorViewModel], activeTabID: UUID?) {
        self.tabs = tabs
        self.editors = editors
        self.activeTabID = activeTabID
    }

    // MARK: - Tab lifecycle

    func newProject() {
        let name = nextUntitledName()
        let metadata = ProjectMetadata(name: name)
        let tab = ProjectTab(metadata: metadata, hasUnsavedChanges: false)
        let editor = EditorViewModel()

        tabs.append(tab)
        editors[tab.id] = editor
        activeTabID = tab.id
    }

    func openProject(from url: URL) {
        // If already open, just switch to it
        if let existing = tabs.first(where: { $0.metadata.fileURL == url }) {
            activeTabID = existing.id
            return
        }

        do {
            let document = try ProjectFileManager.load(from: url)
            let name = url.deletingPathExtension().lastPathComponent
            let metadata = ProjectMetadata(name: name, fileURL: url)
            let tab = ProjectTab(metadata: metadata)
            let editor = EditorViewModel(document: document)

            tabs.append(tab)
            editors[tab.id] = editor
            activeTabID = tab.id
            addToRecentProjects(metadata: metadata)
        } catch {
            print("Failed to open project: \(error)")
        }
    }

    func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .init(filenameExtension: ProjectFileManager.fileExtension)!
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = ProjectFileManager.projectsDirectory

        guard panel.runModal() == .OK, let url = panel.url else { return }
        openProject(from: url)
    }

    func closeTab(id tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }

        // Save before closing if dirty and has a file
        if tabs[index].hasUnsavedChanges && tabs[index].metadata.fileURL != nil {
            saveTab(id: tabID)
        }

        tabs.remove(at: index)
        editors.removeValue(forKey: tabID)

        if activeTabID == tabID {
            if tabs.isEmpty {
                activeTabID = nil
            } else {
                let newIndex = min(index, tabs.count - 1)
                activeTabID = tabs[newIndex].id
            }
        }
    }

    func switchTab(to tabID: UUID) {
        guard tabs.contains(where: { $0.id == tabID }) else { return }
        activeTabID = tabID
    }

    // MARK: - Save

    func save() {
        guard let activeTabID else { return }
        saveTab(id: activeTabID)
    }

    func saveAs() {
        guard let activeTabID,
              let editor = editors[activeTabID],
              let tabIndex = tabs.firstIndex(where: { $0.id == activeTabID })
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [
            .init(filenameExtension: ProjectFileManager.fileExtension)!
        ]
        panel.nameFieldStringValue = tabs[tabIndex].metadata.name
        panel.directoryURL = ProjectFileManager.projectsDirectory

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try ProjectFileManager.save(document: editor.document, to: url)
            let name = url.deletingPathExtension().lastPathComponent
            tabs[tabIndex].metadata.fileURL = url
            tabs[tabIndex].metadata.name = name
            tabs[tabIndex].metadata.lastModified = Date()
            tabs[tabIndex].hasUnsavedChanges = false
            addToRecentProjects(metadata: tabs[tabIndex].metadata)
        } catch {
            print("Failed to save as: \(error)")
        }
    }

    func saveTab(id tabID: UUID) {
        guard let editor = editors[tabID],
              let tabIndex = tabs.firstIndex(where: { $0.id == tabID })
        else { return }

        // If no file URL yet, assign one on first save
        if tabs[tabIndex].metadata.fileURL == nil {
            do {
                let url = try ProjectFileManager.uniqueFileURL(name: tabs[tabIndex].metadata.name)
                tabs[tabIndex].metadata.fileURL = url
            } catch {
                print("Failed to create file URL: \(error)")
                return
            }
        }

        guard let fileURL = tabs[tabIndex].metadata.fileURL else { return }

        do {
            try ProjectFileManager.save(document: editor.document, to: fileURL)
            tabs[tabIndex].metadata.lastModified = Date()
            tabs[tabIndex].hasUnsavedChanges = false
            addToRecentProjects(metadata: tabs[tabIndex].metadata)
        } catch {
            print("Failed to save: \(error)")
        }
    }

    func markDirty(tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[index].hasUnsavedChanges = true
    }

    func markClean(tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[index].hasUnsavedChanges = false
    }

    // MARK: - Auto-save

    private func startAutoSave() {
        Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                guard let self else { break }
                self.autoSaveDirtyTabs()
            }
        }
    }

    private func autoSaveDirtyTabs() {
        for tab in tabs where tab.hasUnsavedChanges {
            // Only auto-save unsaved projects if the user has drawn something
            if tab.metadata.fileURL == nil {
                guard let editor = editors[tab.id],
                      editor.document.hasContent
                else { continue }
            }
            saveTab(id: tab.id)
        }
    }

    // MARK: - Recent projects

    private func loadRecentProjects() {
        guard let data = UserDefaults.standard.data(forKey: Self.recentProjectsKey),
              let projects = try? JSONDecoder().decode([RecentProject].self, from: data)
        else { return }

        recentProjects = projects.filter { ProjectFileManager.fileExists(at: $0.fileURL) }
    }

    private func persistRecentProjects() {
        guard let data = try? JSONEncoder().encode(recentProjects) else { return }
        UserDefaults.standard.set(data, forKey: Self.recentProjectsKey)
    }

    private func addToRecentProjects(metadata: ProjectMetadata) {
        guard let fileURL = metadata.fileURL else { return }
        recentProjects.removeAll { $0.fileURL == fileURL }
        let recent = RecentProject(
            name: metadata.name,
            fileURL: fileURL,
            lastOpened: Date()
        )
        recentProjects.insert(recent, at: 0)
        if recentProjects.count > 20 {
            recentProjects = Array(recentProjects.prefix(20))
        }
        persistRecentProjects()
    }

    func removeFromRecentProjects(_ project: RecentProject) {
        recentProjects.removeAll { $0.id == project.id }
        persistRecentProjects()
    }

    // MARK: - Rename

    func renameTab(id tabID: UUID, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = tabs.firstIndex(where: { $0.id == tabID })
        else { return }

        let oldURL = tabs[index].metadata.fileURL
        tabs[index].metadata.name = trimmed

        // Only rename the file on disk if it exists
        guard let oldURL else { return }

        do {
            let newURL = try ProjectFileManager.newFileURL(name: trimmed)
            if oldURL != newURL {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                tabs[index].metadata.fileURL = newURL
                if let recentIndex = recentProjects.firstIndex(where: { $0.fileURL == oldURL }) {
                    recentProjects[recentIndex].name = trimmed
                    recentProjects[recentIndex].fileURL = newURL
                    persistRecentProjects()
                }
            }
        } catch {
            print("Failed to rename file: \(error)")
        }
    }

    // MARK: - Helpers

    private func nextUntitledName() -> String {
        let existingNames = Set(tabs.map(\.metadata.name))
        if !existingNames.contains("Untitled") {
            return "Untitled"
        }
        var counter = 2
        while existingNames.contains("Untitled \(counter)") {
            counter += 1
        }
        return "Untitled \(counter)"
    }
}
