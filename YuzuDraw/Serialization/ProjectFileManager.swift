import Foundation

enum ProjectFileManager {
    static let fileExtension = "yuzudraw"

    static var projectsDirectory: URL {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/YuzuDraw", isDirectory: true)
    }

    static func ensureProjectsDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: projectsDirectory,
            withIntermediateDirectories: true
        )
    }

    static func save(document: Document, to url: URL) throws {
        let data = try DocumentCodable.encode(document)
        try data.write(to: url, options: .atomic)
    }

    static func load(from url: URL) throws -> Document {
        let data = try Data(contentsOf: url)
        return try DocumentCodable.decode(from: data)
    }

    static func newFileURL(name: String) throws -> URL {
        try ensureProjectsDirectoryExists()
        let sanitized = name.replacingOccurrences(of: "/", with: "-")
        let url = projectsDirectory
            .appendingPathComponent(sanitized)
            .appendingPathExtension(fileExtension)
        return url
    }

    static func uniqueFileURL(name: String) throws -> URL {
        try ensureProjectsDirectoryExists()
        let sanitized = name.replacingOccurrences(of: "/", with: "-")
        var candidate = projectsDirectory
            .appendingPathComponent(sanitized)
            .appendingPathExtension(fileExtension)

        var counter = 1
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = projectsDirectory
                .appendingPathComponent("\(sanitized) \(counter)")
                .appendingPathExtension(fileExtension)
            counter += 1
        }
        return candidate
    }

    static func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    static func listProjectFiles() throws -> [URL] {
        try ensureProjectsDirectoryExists()
        let contents = try FileManager.default.contentsOfDirectory(
            at: projectsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        return contents.filter { $0.pathExtension == fileExtension }
    }

    static func delete(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
