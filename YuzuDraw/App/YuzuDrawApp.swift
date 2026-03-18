import SwiftUI

@main
struct YuzuDrawApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var workspace = WorkspaceViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(workspace: workspace)
                .onAppear {
                    appDelegate.attach(workspace: workspace)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 700)
        .commands {
            CommandGroup(replacing: .undoRedo) {
                Button("Undo") {
                    workspace.activeEditor?.undo()
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(workspace.activeEditor?.canUndo != true)

                Button("Redo") {
                    workspace.activeEditor?.redo()
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(workspace.activeEditor?.canRedo != true)
            }

            CommandGroup(replacing: .textEditing) {}
            CommandGroup(replacing: .textFormatting) {}

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
                Button("New Tab") {
                    workspace.openStartPageTab()
                }
                .keyboardShortcut("t", modifiers: .command)
                .disabled(workspace.activeTab?.isStartPage == true)

                Divider()

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

                Button("Reload from Disk") {
                    workspace.reloadFromDisk()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                .disabled(!workspace.canReloadFromDisk)
            }

            CommandGroup(replacing: .pasteboard) {
                Button("Cut") {
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil) {
                        return
                    }
                    workspace.activeEditor?.cutSelectedShapes()
                }
                .keyboardShortcut("x", modifiers: .command)
                .disabled(workspace.activeEditor == nil)

                Button("Copy") {
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil) {
                        return
                    }
                    workspace.activeEditor?.copySelectedShapesToClipboard()
                }
                .keyboardShortcut("c", modifiers: .command)
                .disabled(workspace.activeEditor == nil)

                Button("Paste") {
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil) {
                        return
                    }
                    _ = workspace.activeEditor?.pasteShapesFromClipboard()
                }
                .keyboardShortcut("v", modifiers: .command)
                .disabled(workspace.activeEditor == nil)

                Button("Duplicate") {
                    workspace.activeEditor?.duplicateSelectedShapes()
                }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(workspace.activeEditor?.canDuplicateSelectedShapes() != true)

                Divider()

                Button("Copy as DSL") {
                    workspace.activeEditor?.copySelectionAsPlainTextToClipboard()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(workspace.activeEditor?.canCopySelectionAsPlainText() != true)

                Divider()

                Button("Select All") {
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil) {
                        return
                    }
                    workspace.activeEditor?.selectAllShapes()
                }
                .keyboardShortcut("a", modifiers: .command)
                .disabled(workspace.activeEditor?.canSelectAllShapes() != true)
            }

            CommandGroup(after: .pasteboard) {
                Button("Delete") {
                    if NSApp.sendAction(#selector(NSResponder.deleteBackward(_:)), to: nil, from: nil) {
                        return
                    }
                    workspace.activeEditor?.deleteSelectedShapes()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(workspace.activeEditor?.canCutSelectedShapes() != true)

                Divider()

                Button("Group") {
                    workspace.activeEditor?.groupSelectedShapes()
                }
                .keyboardShortcut("g", modifiers: .command)
                .disabled(workspace.activeEditor?.canGroupSelectedShapes() != true)

                Button("Ungroup") {
                    workspace.activeEditor?.ungroupSelectedShapes()
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                .disabled(workspace.activeEditor?.canUngroupSelectedShapes() != true)

                Divider()

                Button("Bring to Front") {
                    workspace.activeEditor?.moveSelectedShapeToFront()
                }
                .keyboardShortcut("]", modifiers: [])
                .disabled(workspace.activeEditor?.canMoveSelectedShapeForward() != true)

                Button("Send to Back") {
                    workspace.activeEditor?.moveSelectedShapeToBack()
                }
                .keyboardShortcut("[", modifiers: [])
                .disabled(workspace.activeEditor?.canMoveSelectedShapeBackward() != true)

                Button("Bring Forward") {
                    workspace.activeEditor?.moveSelectedShapeForward()
                }
                .keyboardShortcut("]", modifiers: .command)
                .disabled(workspace.activeEditor?.canMoveSelectedShapeForward() != true)

                Button("Send Backward") {
                    workspace.activeEditor?.moveSelectedShapeBackward()
                }
                .keyboardShortcut("[", modifiers: .command)
                .disabled(workspace.activeEditor?.canMoveSelectedShapeBackward() != true)
            }
        }
    }
}
