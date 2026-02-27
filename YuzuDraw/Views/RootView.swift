import SwiftUI

struct RootView: View {
    @Bindable var workspace: WorkspaceViewModel

    var body: some View {
        Group {
            if workspace.hasOpenProjects {
                TabBarContentView(workspace: workspace)
            } else {
                WelcomeView(workspace: workspace)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Root - Welcome") {
    @Previewable @State var workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
    RootView(workspace: workspace)
        .frame(width: 900, height: 600)
}

#Preview("Root - With Tabs") {
    @Previewable @State var workspace = WorkspaceViewModel.previewWithTabs()
    RootView(workspace: workspace)
        .frame(width: 900, height: 600)
}
