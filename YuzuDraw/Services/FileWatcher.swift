import Foundation

/// Monitors individual files for external changes using GCD file-system sources.
final class SingleFileWatcher: @unchecked Sendable {
    private let url: URL
    private let queue: DispatchQueue
    private let onChange: @Sendable () -> Void

    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1
    private var debounceWorkItem: DispatchWorkItem?
    private var isSuppressed = false

    init(url: URL, queue: DispatchQueue, onChange: @escaping @Sendable () -> Void) {
        self.url = url
        self.queue = queue
        self.onChange = onChange
        startMonitoring()
    }

    func suppress() {
        queue.async { [weak self] in
            self?.isSuppressed = true
        }
    }

    func stop() {
        queue.async { [weak self] in
            self?.teardown()
        }
    }

    // MARK: - Private

    private func startMonitoring() {
        queue.async { [weak self] in
            self?.attach()
        }
    }

    private func attach() {
        let fd = open(url.path, O_EVTONLY)
        guard fd >= 0 else { return }
        fileDescriptor = fd

        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete],
            queue: queue
        )

        src.setEventHandler { [weak self] in
            guard let self else { return }
            let flags = src.data
            if flags.contains(.rename) || flags.contains(.delete) {
                self.reattach()
                return
            }
            self.debounceAndNotify()
        }

        src.setCancelHandler { [fd] in
            close(fd)
        }

        source = src
        src.resume()
    }

    private func reattach() {
        source?.cancel()
        source = nil
        fileDescriptor = -1

        // Small delay to let the atomic write settle
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.attach()
            self.debounceAndNotify()
        }
        queue.asyncAfter(deadline: .now() + 0.1, execute: work)
    }

    private func debounceAndNotify() {
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if self.isSuppressed {
                self.isSuppressed = false
                return
            }
            self.onChange()
        }
        debounceWorkItem = work
        queue.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    private func teardown() {
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        source?.cancel()
        source = nil
        fileDescriptor = -1
    }
}

/// Manages per-tab file watchers and integrates with WorkspaceViewModel.
@MainActor
final class FileWatcher {
    private var watchers: [UUID: SingleFileWatcher] = [:]
    private let queue = DispatchQueue(label: "com.yuzudraw.filewatcher")

    func watch(tabID: UUID, url: URL, onChange: @escaping @MainActor () -> Void) {
        watchers[tabID]?.stop()
        let watcher = SingleFileWatcher(url: url, queue: queue) {
            Task { @MainActor in
                onChange()
            }
        }
        watchers[tabID] = watcher
    }

    func stopWatching(tabID: UUID) {
        watchers[tabID]?.stop()
        watchers.removeValue(forKey: tabID)
    }

    func stopAll() {
        for watcher in watchers.values {
            watcher.stop()
        }
        watchers.removeAll()
    }

    func suppressNextReload(tabID: UUID) {
        watchers[tabID]?.suppress()
    }
}
