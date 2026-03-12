import Foundation
import Testing

@testable import YuzuDraw

@MainActor
struct WorkspaceViewModelTests {
    @Test func should_open_start_tab_on_launch() {
        // given/when
        let workspace = WorkspaceViewModel()

        // then
        #expect(workspace.tabs.count == 1)
        #expect(workspace.tabs[0].isStartPage)
        #expect(workspace.activeTabID == workspace.tabs[0].id)
        #expect(workspace.activeEditor == nil)
    }

    @Test func should_open_new_start_tab_from_toolbar_action() {
        // given
        let workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)

        // when
        workspace.openStartPageTab()
        workspace.openStartPageTab()

        // then
        #expect(workspace.tabs.count == 1)
        #expect(workspace.tabs[0].isStartPage)
        #expect(workspace.activeTabID == workspace.tabs[0].id)
    }

    @Test func should_replace_active_start_tab_when_creating_new_project() {
        // given
        let workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
        workspace.openStartPageTab()
        let startTabID = workspace.activeTabID

        // when
        workspace.newProject()

        // then
        #expect(workspace.tabs.count == 1)
        #expect(workspace.activeTabID == startTabID)
        #expect(workspace.activeTab?.isStartPage == false)
        #expect(workspace.activeEditor != nil)
    }

    @Test func should_restore_start_tab_when_closing_last_tab() {
        // given
        let workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
        workspace.newProject()
        guard let tabID = workspace.activeTabID else {
            Issue.record("Expected active tab ID")
            return
        }

        // when
        workspace.closeTab(id: tabID)

        // then
        #expect(workspace.tabs.count == 1)
        #expect(workspace.activeTab?.isStartPage == true)
        #expect(workspace.activeEditor == nil)
    }

    @Test func should_delete_recent_project_from_disk_and_close_open_tabs() throws {
        // given
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let fileURL = tempDirectory
            .appendingPathComponent("Delete Me")
            .appendingPathExtension(ProjectFileManager.fileExtension)
        try Data("{}".utf8).write(to: fileURL)

        let metadata = ProjectMetadata(name: "Delete Me", fileURL: fileURL)
        let tab = ProjectTab(metadata: metadata)
        let workspace = WorkspaceViewModel(
            tabs: [tab],
            editors: [tab.id: EditorViewModel()],
            activeTabID: tab.id
        )
        workspace.recentProjects = [RecentProject(name: "Delete Me", fileURL: fileURL)]

        // when
        workspace.deleteRecentProjectFromDisk(workspace.recentProjects[0])

        // then
        #expect(FileManager.default.fileExists(atPath: fileURL.path) == false)
        #expect(workspace.recentProjects.isEmpty)
        #expect(workspace.tabs.count == 1)
        #expect(workspace.tabs[0].isStartPage)
    }

    @Test func should_recover_recent_projects_from_disk_when_defaults_are_empty() throws {
        // given
        let defaultsKey = "recentProjects"
        let originalData = UserDefaults.standard.data(forKey: defaultsKey)
        defer {
            if let originalData {
                UserDefaults.standard.set(originalData, forKey: defaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: defaultsKey)
            }
        }

        let emptyRecentData = try JSONEncoder().encode([RecentProject]())
        UserDefaults.standard.set(emptyRecentData, forKey: defaultsKey)

        try ProjectFileManager.ensureProjectsDirectoryExists()
        let fileURL = ProjectFileManager.projectsDirectory
            .appendingPathComponent("Recovery Test \(UUID().uuidString)")
            .appendingPathExtension(ProjectFileManager.fileExtension)
        try Data("{}".utf8).write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        // when
        let workspace = WorkspaceViewModel()

        // then
        #expect(workspace.recentProjects.contains { $0.fileURL == fileURL })
    }

    @Test func should_enable_reload_only_for_file_backed_tabs() {
        // given
        let workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
        workspace.openStartPageTab()

        // then
        #expect(workspace.canReloadFromDisk == false)

        // when
        workspace.newProject()

        // then
        #expect(workspace.canReloadFromDisk == false)
    }

    @Test func should_reload_active_tab_document_from_disk() throws {
        // given
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let projectURL = tempDirectory
            .appendingPathComponent("Reload Test")
            .appendingPathExtension(ProjectFileManager.fileExtension)

        let onDiskDocument = Document()
        try ProjectFileManager.save(document: onDiskDocument, to: projectURL)

        var inMemoryDocument = Document()
        inMemoryDocument.addShape(
            .rectangle(
                RectangleShape(
                    origin: GridPoint(column: 0, row: 0),
                    size: GridSize(width: 4, height: 3)
                )
            )
        )

        let metadata = ProjectMetadata(name: "Reload Test", fileURL: projectURL)
        let tab = ProjectTab(metadata: metadata, hasUnsavedChanges: false)
        let editor = EditorViewModel(document: inMemoryDocument)
        let workspace = WorkspaceViewModel(
            tabs: [tab],
            editors: [tab.id: editor],
            activeTabID: tab.id
        )

        // when
        workspace.reloadFromDisk()

        // then
        #expect(workspace.activeEditor?.document == onDiskDocument)
        #expect(workspace.tabs[0].hasUnsavedChanges == false)
    }
}
