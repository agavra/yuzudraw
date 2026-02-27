import SwiftUI

@main
struct YuzuDrawApp: App {
    @State private var workspace = WorkspaceViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(workspace: workspace)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    workspace.newProject()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Open...") {
                    workspace.showOpenPanel()
                }
                .keyboardShortcut("o", modifiers: .command)
            }

            CommandGroup(after: .newItem) {
                Button("Close Tab") {
                    if let activeTabID = workspace.activeTabID {
                        workspace.closeTab(id: activeTabID)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
                .disabled(!workspace.hasOpenProjects)

                Divider()

                Button("Save") {
                    workspace.save()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(workspace.activeEditor == nil)

                Button("Save As...") {
                    workspace.saveAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(workspace.activeEditor == nil)
            }

            CommandGroup(after: .pasteboard) {
                Button("Group") {
                    workspace.activeEditor?.groupSelectedShapes()
                }
                .keyboardShortcut("g", modifiers: .command)
                .disabled(workspace.activeEditor?.canGroupSelectedShapes() != true)

                Divider()

                Button("Move Back") {
                    workspace.activeEditor?.moveSelectedShapeBackward()
                }
                .keyboardShortcut("[", modifiers: [])
                .disabled(workspace.activeEditor?.canMoveSelectedShapeBackward() != true)

                Button("Move Front") {
                    workspace.activeEditor?.moveSelectedShapeForward()
                }
                .keyboardShortcut("]", modifiers: [])
                .disabled(workspace.activeEditor?.canMoveSelectedShapeForward() != true)

                Button("Bring to Back") {
                    workspace.activeEditor?.moveSelectedShapeToBack()
                }
                .keyboardShortcut("[", modifiers: .command)
                .disabled(workspace.activeEditor?.canMoveSelectedShapeBackward() != true)

                Button("Bring to Front") {
                    workspace.activeEditor?.moveSelectedShapeToFront()
                }
                .keyboardShortcut("]", modifiers: .command)
                .disabled(workspace.activeEditor?.canMoveSelectedShapeForward() != true)
            }
        }
    }
}
