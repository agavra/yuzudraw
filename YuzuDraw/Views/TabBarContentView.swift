import SwiftUI

struct TabBarContentView: View {
    @Bindable var workspace: WorkspaceViewModel

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            editorArea
        }
        .ignoresSafeArea()
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            // Left padding for macOS traffic light buttons
            Color.clear.frame(width: 78)

            Text("YuzuDraw")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 12)

            // Scrollable tabs + new tab button together
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(workspace.tabs) { tab in
                        TabItemView(
                            tab: tab,
                            isActive: tab.id == workspace.activeTabID,
                            onSelect: { workspace.switchTab(to: tab.id) },
                            onClose: { workspace.closeTab(id: tab.id) },
                            onRename: { workspace.renameTab(id: tab.id, to: $0) }
                        )
                    }

                    // New tab button right after last tab
                    Button {
                        workspace.newProject()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(height: 36)
        .background {
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(nsColor: .separatorColor))
                    .frame(height: 1)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.6)
            .background(Color.black.opacity(0.06)))
    }

    // MARK: - Editor area

    @ViewBuilder
    private var editorArea: some View {
        if let activeTab = workspace.activeTab,
           let editor = workspace.editors[activeTab.id]
        {
            ContentView(viewModel: editor, onDocumentChange: {
                workspace.markDirty(tabID: activeTab.id)
            })
            .id(activeTab.id)
        } else {
            Color.clear
        }
    }
}

// MARK: - Tab item

private struct TabItemView: View {
    let tab: ProjectTab
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    let onRename: (String) -> Void

    @State private var isHovering = false
    @State private var isEditing = false
    @State private var editText = ""

    var body: some View {
        Group {
            if isEditing {
                editingContent
            } else {
                displayContent
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(tabBackground)
        .overlay(alignment: .trailing) {
            if !isActive {
                Rectangle()
                    .fill(Color(nsColor: .separatorColor).opacity(0.5))
                    .frame(width: 1, height: 18)
            }
        }
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Rename...") {
                beginEditing()
            }
            Divider()
            Button("Close Tab") {
                onClose()
            }
        }
    }

    private var displayContent: some View {
        Button(action: onSelect) {
            HStack(spacing: 5) {
                if tab.hasUnsavedChanges {
                    Circle()
                        .fill(Color.primary.opacity(0.45))
                        .frame(width: 6, height: 6)
                }

                Text(tab.metadata.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundStyle(isActive ? .primary : .secondary)

                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(isHovering ? 0.08 : 0))
                        )
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .opacity(isActive || isHovering ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .onTapGesture(count: 2) {
            beginEditing()
        }
        .onTapGesture(count: 1) {
            onSelect()
        }
    }

    private var editingContent: some View {
        TextField("", text: $editText, onCommit: {
            commitEditing()
        })
        .textFieldStyle(.plain)
        .font(.system(size: 12))
        .frame(minWidth: 60, maxWidth: 160)
        .onExitCommand {
            isEditing = false
        }
        .onAppear {
            // Select all text when editing begins
            DispatchQueue.main.async {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }

    private func beginEditing() {
        editText = tab.metadata.name
        isEditing = true
    }

    private func commitEditing() {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != tab.metadata.name {
            onRename(trimmed)
        }
        isEditing = false
    }

    private var tabShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 6,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 6
        )
    }

    @ViewBuilder
    private var tabBackground: some View {
        if isActive {
            tabShape
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay {
                    tabShape
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
                        .mask {
                            // Mask out the bottom edge so the border only appears on top/left/right
                            VStack(spacing: 0) {
                                Color.black
                                Color.clear.frame(height: 1)
                            }
                        }
                }
        } else if isHovering {
            tabShape
                .fill(Color.primary.opacity(0.04))
        }
    }
}

// MARK: - Preview

#Preview("Tab Bar") {
    @Previewable @State var workspace = WorkspaceViewModel.previewWithTabs()
    TabBarContentView(workspace: workspace)
        .frame(width: 900, height: 500)
}

extension WorkspaceViewModel {
    static func previewWithTabs() -> WorkspaceViewModel {
        let meta1 = ProjectMetadata(name: "Architecture", fileURL: URL(fileURLWithPath: "/tmp/p1"))
        let tab1 = ProjectTab(metadata: meta1)

        let meta2 = ProjectMetadata(name: "Flow Diagram", fileURL: URL(fileURLWithPath: "/tmp/p2"))
        let tab2 = ProjectTab(metadata: meta2, hasUnsavedChanges: true)

        let meta3 = ProjectMetadata(name: "Network Layout", fileURL: URL(fileURLWithPath: "/tmp/p3"))
        let tab3 = ProjectTab(metadata: meta3)

        let workspace = WorkspaceViewModel(
            tabs: [tab1, tab2, tab3],
            editors: [
                tab1.id: EditorViewModel(),
                tab2.id: EditorViewModel(),
                tab3.id: EditorViewModel(),
            ],
            activeTabID: tab1.id
        )
        return workspace
    }
}
