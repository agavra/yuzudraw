import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var pendingFileURLs: [URL] = []
    private weak var workspace: WorkspaceViewModel?
    private weak var primaryWindow: NSWindow?

    func attach(workspace: WorkspaceViewModel) {
        self.workspace = workspace
        primaryWindow = NSApp.windows.first { $0.isVisible }
        flushPendingFileURLs()
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        handleOpenFiles(urls)

        // WindowGroup may spawn an extra window for this event — close it
        // on the next run-loop tick so the window has been created by then.
        DispatchQueue.main.async { [self] in
            closeExtraWindows()
        }
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

        NSApp.activate(ignoringOtherApps: true)
        primaryWindow?.makeKeyAndOrderFront(nil)
    }

    private func closeExtraWindows() {
        guard let primaryWindow else { return }
        for window in NSApp.windows where window !== primaryWindow && window.isVisible && !window.isMiniaturized {
            // Only close regular windows (not panels, sheets, popovers, etc.)
            guard type(of: window) == type(of: primaryWindow) else { continue }
            window.close()
        }
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
