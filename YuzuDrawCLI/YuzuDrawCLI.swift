import ArgumentParser
import Foundation

@main
struct YuzuDrawCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "yuzudraw-cli",
        abstract: "YuzuDraw CLI — ASCII diagram editor",
        version: CLIVersion.current,
        subcommands: [
            CreateDiagram.self,
            UpdateDiagram.self,
            MergeDiagram.self,
            GetDiagram.self,
            ListDiagrams.self,
            RenderASCII.self,
            Update.self,
        ]
    )
}

// MARK: - Shared Helpers

enum DSLInput {
    static func load(file: String?, stdin useStdin: Bool) throws -> String {
        if let file {
            return try String(contentsOfFile: file, encoding: .utf8)
        }
        if useStdin {
            let data = FileHandle.standardInput.readDataToEndOfFile()
            guard let dsl = String(data: data, encoding: .utf8) else {
                throw ValidationError("Failed to decode stdin as UTF-8")
            }
            return dsl
        }
        throw ValidationError("Provide either --dsl-file <path> or --dsl-stdin.")
    }
}

enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
    case dsl, ascii, both
}

// MARK: - Commands

struct CreateDiagram: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-diagram",
        abstract: "Create a new diagram from DSL"
    )

    @Option(name: .long, help: "Diagram name")
    var name: String

    @Option(name: .long, help: "Output project path")
    var project: String?

    @Option(name: .customLong("dsl-file"), help: "Path to DSL file")
    var dslFile: String?

    @Flag(name: .customLong("dsl-stdin"), help: "Read DSL from stdin")
    var dslStdin: Bool = false

    func validate() throws {
        if dslFile != nil && dslStdin {
            throw ValidationError("Cannot use both --dsl-file and --dsl-stdin.")
        }
        if dslFile == nil && !dslStdin {
            throw ValidationError("Provide either --dsl-file <path> or --dsl-stdin.")
        }
    }

    func run() throws {
        let service = DiagramAutomationService()
        let dsl = try DSLInput.load(file: dslFile, stdin: dslStdin)
        let outputURL = project.map(URL.init(fileURLWithPath:))
        let result = try service.createDiagram(name: name, dsl: dsl, outputURL: outputURL)
        print("Diagram '\(name)' created at \(result.url.path)")
        print("")
        print("```")
        print(result.ascii)
        print("```")
    }
}

struct UpdateDiagram: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update-diagram",
        abstract: "Update an existing diagram with new DSL"
    )

    @Option(name: .long, help: "Diagram name")
    var name: String

    @Option(name: .long, help: "Project path")
    var project: String?

    @Option(name: .customLong("dsl-file"), help: "Path to DSL file")
    var dslFile: String?

    @Flag(name: .customLong("dsl-stdin"), help: "Read DSL from stdin")
    var dslStdin: Bool = false

    func validate() throws {
        if dslFile != nil && dslStdin {
            throw ValidationError("Cannot use both --dsl-file and --dsl-stdin.")
        }
        if dslFile == nil && !dslStdin {
            throw ValidationError("Provide either --dsl-file <path> or --dsl-stdin.")
        }
    }

    func run() throws {
        let service = DiagramAutomationService()
        let dsl = try DSLInput.load(file: dslFile, stdin: dslStdin)
        let targetURL = project.map(URL.init(fileURLWithPath:))
        let result = try service.updateDiagram(name: name, dsl: dsl, projectURL: targetURL)
        print("Diagram '\(name)' updated at \(result.url.path)")
        print("")
        print("```")
        print(result.ascii)
        print("```")
    }
}

struct MergeDiagram: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "merge-diagram",
        abstract: "Merge a DSL snippet into an existing diagram"
    )

    @Option(name: .long, help: "Diagram name")
    var name: String

    @Option(name: .long, help: "Project path")
    var project: String?

    @Option(name: .customLong("into-group"), help: "Existing group identifier to merge into")
    var intoGroup: String?

    @Option(name: .long, help: "Offset applied to the incoming snippet as col,row")
    var at: String?

    @Option(name: .customLong("dsl-file"), help: "Path to DSL file")
    var dslFile: String?

    @Flag(name: .customLong("dsl-stdin"), help: "Read DSL from stdin")
    var dslStdin: Bool = false

    func validate() throws {
        if dslFile != nil && dslStdin {
            throw ValidationError("Cannot use both --dsl-file and --dsl-stdin.")
        }
        if dslFile == nil && !dslStdin {
            throw ValidationError("Provide either --dsl-file <path> or --dsl-stdin.")
        }
        if let at {
            _ = try parseGridPoint(at)
        }
    }

    func run() throws {
        let service = DiagramAutomationService()
        let dsl = try DSLInput.load(file: dslFile, stdin: dslStdin)
        let targetURL = project.map(URL.init(fileURLWithPath:))
        let result = try service.mergeDiagram(
            name: name,
            dsl: dsl,
            projectURL: targetURL,
            intoGroupIdentifier: intoGroup,
            offset: try at.map(parseGridPoint(_:))
        )
        print("Diagram '\(name)' merged at \(result.url.path)")
        print("")
        print("```")
        print(result.ascii)
        print("```")
    }

    private func parseGridPoint(_ rawValue: String) throws -> GridPoint {
        let parts = rawValue.split(separator: ",", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let column = Int(parts[0]),
              let row = Int(parts[1])
        else {
            throw ValidationError("Expected --at in the form <col,row>.")
        }
        return GridPoint(column: column, row: row)
    }
}

struct GetDiagram: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get-diagram",
        abstract: "Get a diagram in DSL and/or ASCII format"
    )

    @Option(name: .long, help: "Diagram name")
    var name: String

    @Option(name: .long, help: "Project path")
    var project: String?

    @Option(name: .long, help: "Output format: dsl, ascii, or both")
    var format: OutputFormat = .both

    func run() throws {
        let service = DiagramAutomationService()
        let targetURL = project.map(URL.init(fileURLWithPath:))
        let result = try service.getDiagram(name: name, projectURL: targetURL)

        print("Diagram '\(name)' at \(result.url.path)")
        print("")

        if format == .dsl || format == .both {
            print("DSL:")
            print("```")
            print(result.dsl)
            print("```")
            if format == .both {
                print("")
            }
        }

        if format == .ascii || format == .both {
            print("ASCII:")
            print("```")
            print(result.ascii)
            print("```")
        }
    }
}

struct ListDiagrams: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-diagrams",
        abstract: "List all diagrams in a directory"
    )

    @Option(name: .customLong("workspace-dir"), help: "Directory to search for diagrams")
    var workspaceDir: String?

    func run() throws {
        let service = DiagramAutomationService()
        let directoryURL = workspaceDir.map(URL.init(fileURLWithPath:))
        let files = try service.listDiagrams(in: directoryURL)

        if files.isEmpty {
            print("No diagrams found.")
            return
        }

        print("Diagrams:")
        for file in files {
            print("- \(file.deletingPathExtension().lastPathComponent) (\(file.path))")
        }
    }
}

struct RenderASCII: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "render-ascii",
        abstract: "Render DSL to ASCII art"
    )

    @Option(name: .customLong("dsl-file"), help: "Path to DSL file")
    var dslFile: String?

    @Flag(name: .customLong("dsl-stdin"), help: "Read DSL from stdin")
    var dslStdin: Bool = false

    func validate() throws {
        if dslFile != nil && dslStdin {
            throw ValidationError("Cannot use both --dsl-file and --dsl-stdin.")
        }
        if dslFile == nil && !dslStdin {
            throw ValidationError("Provide either --dsl-file <path> or --dsl-stdin.")
        }
    }

    func run() throws {
        let service = DiagramAutomationService()
        let dsl = try DSLInput.load(file: dslFile, stdin: dslStdin)
        let ascii = try service.renderASCII(from: dsl)
        print(ascii)
    }
}

struct Update: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update to the latest version"
    )

    func run() throws {
        let currentVersion = CLIVersion.current

        let releaseJSON = try shellOutput(
            "/usr/bin/curl", "-fsSL",
            "-H", "Accept: application/vnd.github+json",
            "https://api.github.com/repos/agavra/yuzudraw/releases/latest"
        )

        guard let data = releaseJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String else {
            throw ValidationError("Failed to parse release information from GitHub.")
        }

        let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

        if latestVersion == currentVersion {
            print("Already up to date (v\(currentVersion)).")
            return
        }

        print("Updating yuzudraw-cli v\(currentVersion) → v\(latestVersion)...")

        let arch = try shellOutput("/usr/bin/uname", "-m").trimmingCharacters(in: .whitespacesAndNewlines)
        let assetArch = arch == "arm64" ? "aarch64" : "x86_64"

        guard let assets = json["assets"] as? [[String: Any]] else {
            throw ValidationError("No assets found in latest release.")
        }

        let assetName = "yuzudraw-cli-\(latestVersion)-\(assetArch)-apple-darwin.tar.gz"
        guard let asset = assets.first(where: { ($0["name"] as? String) == assetName }),
              let downloadURLString = asset["browser_download_url"] as? String else {
            throw ValidationError("No matching asset found: \(assetName)")
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("yuzudraw-update-\(ProcessInfo.processInfo.globallyUniqueString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let tarPath = tempDir.appendingPathComponent(assetName)

        try shellRun("/usr/bin/curl", "-fSL", "--progress-bar", "-o", tarPath.path, downloadURLString)
        try shellRun("/usr/bin/tar", "-xzf", tarPath.path, "-C", tempDir.path)

        let newBinary = tempDir.appendingPathComponent("yuzudraw-cli")
        guard FileManager.default.fileExists(atPath: newBinary.path) else {
            throw ValidationError("Extracted archive does not contain yuzudraw-cli binary.")
        }

        let currentBinary = URL(fileURLWithPath: CommandLine.arguments[0])
        let resolvedBinary: URL
        if let resolved = try? FileManager.default.destinationOfSymbolicLink(atPath: currentBinary.path) {
            resolvedBinary = URL(fileURLWithPath: resolved)
        } else {
            resolvedBinary = currentBinary
        }

        let backupPath = resolvedBinary.appendingPathExtension("bak")
        try? FileManager.default.removeItem(at: backupPath)
        try FileManager.default.moveItem(at: resolvedBinary, to: backupPath)

        do {
            try FileManager.default.moveItem(at: newBinary, to: resolvedBinary)
            try? FileManager.default.removeItem(at: backupPath)
        } catch {
            try? FileManager.default.moveItem(at: backupPath, to: resolvedBinary)
            throw ValidationError("Failed to install update: \(error.localizedDescription)")
        }

        print("Updated to v\(latestVersion).")
    }

    @discardableResult
    private func shellOutput(_ args: String...) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ValidationError("Command failed: \(args.joined(separator: " "))")
        }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    private func shellRun(_ args: String...) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ValidationError("Command failed: \(args.joined(separator: " "))")
        }
    }
}
