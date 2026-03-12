import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var pendingFileURLs: [URL] = []
    private weak var workspace: WorkspaceViewModel?

    func attach(workspace: WorkspaceViewModel) {
        self.workspace = workspace
        flushPendingFileURLs()
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        // Prevent opening a blank window when the app is reactivated with no files
        false
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map(URL.init(fileURLWithPath:))
        handleOpenFiles(urls)
        sender.reply(toOpenOrPrint: .success)
    }

    private func handleOpenFiles(_ urls: [URL]) {
        let normalizedURLs = urls.filter {
            $0.pathExtension.compare(ProjectFileManager.fileExtension, options: .caseInsensitive) == .orderedSame
        }

        guard !normalizedURLs.isEmpty else { return }

        guard let workspace else {
            pendingFileURLs.append(contentsOf: normalizedURLs)
            return
        }

        for url in normalizedURLs {
            workspace.openProject(from: url)
        }

        // Bring existing window to front instead of creating a new one
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first { $0.isVisible }?.makeKeyAndOrderFront(nil)
    }

    private func flushPendingFileURLs() {
        guard let workspace else { return }
        guard !pendingFileURLs.isEmpty else { return }

        for url in pendingFileURLs {
            workspace.openProject(from: url)
        }
        pendingFileURLs.removeAll()
    }
}
