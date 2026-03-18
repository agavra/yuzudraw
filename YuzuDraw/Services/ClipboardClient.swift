import AppKit
import Foundation

@MainActor
protocol ClipboardClient {
    func clearContents()
    func setData(_ data: Data, forType type: NSPasteboard.PasteboardType)
    func data(forType type: NSPasteboard.PasteboardType) -> Data?
    func setString(_ string: String, forType type: NSPasteboard.PasteboardType)
    func string(forType type: NSPasteboard.PasteboardType) -> String?
}

@MainActor
struct SystemClipboardClient: ClipboardClient {
    private let pasteboard: NSPasteboard

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func clearContents() {
        pasteboard.clearContents()
    }

    func setData(_ data: Data, forType type: NSPasteboard.PasteboardType) {
        pasteboard.setData(data, forType: type)
    }

    func data(forType type: NSPasteboard.PasteboardType) -> Data? {
        pasteboard.data(forType: type)
    }

    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) {
        pasteboard.setString(string, forType: type)
    }

    func string(forType type: NSPasteboard.PasteboardType) -> String? {
        pasteboard.string(forType: type)
    }
}
