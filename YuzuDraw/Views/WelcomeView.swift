import SwiftUI

struct WelcomeView: View {
    @Bindable var workspace: WorkspaceViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App icon and name
            VStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 96, height: 96)

                Text("YuzuDraw")
                    .font(.system(size: 32, weight: .bold))

                Text("ASCII diagram editor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer().frame(height: 32)

            // Action buttons
            HStack(spacing: 16) {
                Button {
                    workspace.newProject()
                } label: {
                    Label("New Project", systemImage: "plus.rectangle")
                        .frame(width: 140)
                }
                .controlSize(.large)

                Button {
                    workspace.showOpenPanel()
                } label: {
                    Label("Open...", systemImage: "folder")
                        .frame(width: 140)
                }
                .controlSize(.large)
            }

            Spacer().frame(height: 40)

            // Recent projects
            if !workspace.recentProjects.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Projects")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(workspace.recentProjects) { project in
                            RecentProjectCard(project: project) {
                                workspace.openProject(from: project.fileURL)
                            } onRemove: {
                                workspace.removeFromRecentProjects(project)
                            }
                        }
                    }
                }
                .frame(maxWidth: 600)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview("Welcome - Empty") {
    @Previewable @State var workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
    WelcomeView(workspace: workspace)
        .frame(width: 800, height: 600)
}

#Preview("Welcome - Recent Projects") {
    @Previewable @State var workspace = WorkspaceViewModel.previewWithRecents()
    WelcomeView(workspace: workspace)
        .frame(width: 800, height: 600)
}

extension WorkspaceViewModel {
    static func previewWithRecents() -> WorkspaceViewModel {
        let workspace = WorkspaceViewModel(tabs: [], editors: [:], activeTabID: nil)
        let dummyURL = URL(fileURLWithPath: "/tmp/preview")
        workspace.recentProjects = [
            RecentProject(name: "Architecture", fileURL: dummyURL,
                          lastOpened: Date().addingTimeInterval(-3600)),
            RecentProject(name: "Flow Diagram", fileURL: dummyURL,
                          lastOpened: Date().addingTimeInterval(-86400)),
            RecentProject(name: "Network Layout", fileURL: dummyURL,
                          lastOpened: Date().addingTimeInterval(-172_800)),
        ]
        return workspace
    }
}

private struct RecentProjectCard: View {
    let project: RecentProject
    let onOpen: () -> Void
    let onRemove: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.secondary)
                    Text(project.name)
                        .font(.system(.body, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    if isHovering {
                        Button {
                            onRemove()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text(project.lastOpened, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.accentColor.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
