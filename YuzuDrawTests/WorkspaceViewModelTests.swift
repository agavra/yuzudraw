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
}
