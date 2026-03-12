import Foundation

private enum CLIError: LocalizedError {
    case unknownCommand(String)
    case invalidUsage(String)
    case missingValue(String)
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .unknownCommand(let value):
            "Unknown command: \(value)"
        case .invalidUsage(let value):
            value
        case .missingValue(let flag):
            "Missing value for flag: \(flag)"
        case .invalidFormat(let value):
            value
        }
    }
}

private struct CLIContext {
    var args: [String]
    private(set) var index: Int = 0

    init(_ args: [String]) {
        self.args = args
    }

    var isAtEnd: Bool {
        index >= args.count
    }

    mutating func next() -> String? {
        guard !isAtEnd else { return nil }
        defer { index += 1 }
        return args[index]
    }
}

private enum CLI {
    static let service = DiagramAutomationService()

    static func run() -> Int32 {
        let argv = Array(CommandLine.arguments.dropFirst())

        do {
            guard let command = argv.first else {
                printUsage()
                return 0
            }

            let args = Array(argv.dropFirst())
            switch command {
            case "create-diagram":
                try createDiagram(args)
            case "update-diagram":
                try updateDiagram(args)
            case "get-diagram":
                try getDiagram(args)
            case "list-diagrams":
                try listDiagrams(args)
            case "render-ascii":
                try renderASCII(args)
            case "version", "--version", "-v":
                printVersion()
            case "update":
                try update()
            case "help", "--help", "-h":
                printUsage()
            default:
                throw CLIError.unknownCommand(command)
            }
            return 0
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
            printUsage()
            return 1
        }
    }

    private static func createDiagram(_ rawArgs: [String]) throws {
        var parser = CLIContext(rawArgs)
        var name: String?
        var projectPath: String?
        var dslPath: String?
        var useStdin = false

        while let arg = parser.next() {
            switch arg {
            case "--name":
                name = try parseRequiredValue("--name", parser: &parser)
            case "--project":
                projectPath = try parseRequiredValue("--project", parser: &parser)
            case "--dsl-file":
                dslPath = try parseRequiredValue("--dsl-file", parser: &parser)
            case "--dsl-stdin":
                useStdin = true
            default:
                throw CLIError.invalidUsage("Unknown flag for create-diagram: \(arg)")
            }
        }

        let diagramName = try require(name, flag: "--name")
        let dsl = try loadDSL(dslPath: dslPath, useStdin: useStdin)
        let outputURL = projectPath.map(URL.init(fileURLWithPath:))
        let result = try service.createDiagram(name: diagramName, dsl: dsl, outputURL: outputURL)

        print("Diagram '\(diagramName)' created at \(result.url.path)")
        print("")
        print("```")
        print(result.ascii)
        print("```")
    }

    private static func updateDiagram(_ rawArgs: [String]) throws {
        var parser = CLIContext(rawArgs)
        var name: String?
        var projectPath: String?
        var dslPath: String?
        var useStdin = false

        while let arg = parser.next() {
            switch arg {
            case "--name":
                name = try parseRequiredValue("--name", parser: &parser)
            case "--project":
                projectPath = try parseRequiredValue("--project", parser: &parser)
            case "--dsl-file":
                dslPath = try parseRequiredValue("--dsl-file", parser: &parser)
            case "--dsl-stdin":
                useStdin = true
            default:
                throw CLIError.invalidUsage("Unknown flag for update-diagram: \(arg)")
            }
        }

        let diagramName = try require(name, flag: "--name")
        let dsl = try loadDSL(dslPath: dslPath, useStdin: useStdin)
        let targetURL = projectPath.map(URL.init(fileURLWithPath:))
        let result = try service.updateDiagram(name: diagramName, dsl: dsl, projectURL: targetURL)

        print("Diagram '\(diagramName)' updated at \(result.url.path)")
        print("")
        print("```")
        print(result.ascii)
        print("```")
    }

    private static func getDiagram(_ rawArgs: [String]) throws {
        var parser = CLIContext(rawArgs)
        var name: String?
        var projectPath: String?
        var format = "both"

        while let arg = parser.next() {
            switch arg {
            case "--name":
                name = try parseRequiredValue("--name", parser: &parser)
            case "--project":
                projectPath = try parseRequiredValue("--project", parser: &parser)
            case "--format":
                format = try parseRequiredValue("--format", parser: &parser)
            default:
                throw CLIError.invalidUsage("Unknown flag for get-diagram: \(arg)")
            }
        }

        guard ["dsl", "ascii", "both"].contains(format) else {
            throw CLIError.invalidFormat("Invalid --format value '\(format)'. Use dsl|ascii|both.")
        }

        let diagramName = try require(name, flag: "--name")
        let targetURL = projectPath.map(URL.init(fileURLWithPath:))
        let result = try service.getDiagram(name: diagramName, projectURL: targetURL)

        print("Diagram '\(diagramName)' at \(result.url.path)")
        print("")

        if format == "dsl" || format == "both" {
            print("DSL:")
            print("```")
            print(result.dsl)
            print("```")
            if format == "both" {
                print("")
            }
        }

        if format == "ascii" || format == "both" {
            print("ASCII:")
            print("```")
            print(result.ascii)
            print("```")
        }
    }

    private static func listDiagrams(_ rawArgs: [String]) throws {
        var parser = CLIContext(rawArgs)
        var directoryPath: String?

        while let arg = parser.next() {
            switch arg {
            case "--workspace-dir":
                directoryPath = try parseRequiredValue("--workspace-dir", parser: &parser)
            default:
                throw CLIError.invalidUsage("Unknown flag for list-diagrams: \(arg)")
            }
        }

        let directoryURL = directoryPath.map(URL.init(fileURLWithPath:))
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

    private static func renderASCII(_ rawArgs: [String]) throws {
        var parser = CLIContext(rawArgs)
        var dslPath: String?
        var useStdin = false

        while let arg = parser.next() {
            switch arg {
            case "--dsl-file":
                dslPath = try parseRequiredValue("--dsl-file", parser: &parser)
            case "--dsl-stdin":
                useStdin = true
            default:
                throw CLIError.invalidUsage("Unknown flag for render-ascii: \(arg)")
            }
        }

        let dsl = try loadDSL(dslPath: dslPath, useStdin: useStdin)
        let ascii = try service.renderASCII(from: dsl)
        print(ascii)
    }

    private static func loadDSL(dslPath: String?, useStdin: Bool) throws -> String {
        if let dslPath {
            return try String(contentsOfFile: dslPath, encoding: .utf8)
        }
        if useStdin {
            let data = FileHandle.standardInput.readDataToEndOfFile()
            guard let dsl = String(data: data, encoding: .utf8) else {
                throw CLIError.invalidUsage("Failed to decode stdin as UTF-8")
            }
            return dsl
        }
        throw CLIError.invalidUsage("Provide either --dsl-file <path> or --dsl-stdin.")
    }

    private static func parseRequiredValue(_ flag: String, parser: inout CLIContext) throws -> String {
        guard let value = parser.next() else {
            throw CLIError.missingValue(flag)
        }
        return value
    }

    private static func require(_ value: String?, flag: String) throws -> String {
        guard let value, !value.isEmpty else {
            throw DiagramAutomationError.missingArgument(flag)
        }
        return value
    }

    private static func printVersion() {
        print("yuzudraw-cli \(CLIVersion.current)")
    }

    private static func update() throws {
        let currentVersion = CLIVersion.current

        // Fetch latest release from GitHub API
        let releaseJSON = try shellOutput(
            "/usr/bin/curl", "-fsSL",
            "-H", "Accept: application/vnd.github+json",
            "https://api.github.com/repos/agavra/yuzudraw/releases/latest"
        )

        guard let data = releaseJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String else {
            throw CLIError.invalidUsage("Failed to parse release information from GitHub.")
        }

        let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

        if latestVersion == currentVersion {
            print("Already up to date (v\(currentVersion)).")
            return
        }

        print("Updating yuzudraw-cli v\(currentVersion) → v\(latestVersion)...")

        // Determine architecture
        let arch = try shellOutput("/usr/bin/uname", "-m").trimmingCharacters(in: .whitespacesAndNewlines)
        let assetArch = arch == "arm64" ? "aarch64" : "x86_64"

        // Find the matching asset
        guard let assets = json["assets"] as? [[String: Any]] else {
            throw CLIError.invalidUsage("No assets found in latest release.")
        }

        let assetName = "yuzudraw-cli-\(latestVersion)-\(assetArch)-apple-darwin.tar.gz"
        guard let asset = assets.first(where: { ($0["name"] as? String) == assetName }),
              let downloadURLString = asset["browser_download_url"] as? String else {
            throw CLIError.invalidUsage("No matching asset found: \(assetName)")
        }

        // Download and extract to temp directory
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("yuzudraw-update-\(ProcessInfo.processInfo.globallyUniqueString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let tarPath = tempDir.appendingPathComponent(assetName)

        try shellRun("/usr/bin/curl", "-fSL", "--progress-bar", "-o", tarPath.path, downloadURLString)
        try shellRun("/usr/bin/tar", "-xzf", tarPath.path, "-C", tempDir.path)

        let newBinary = tempDir.appendingPathComponent("yuzudraw-cli")
        guard FileManager.default.fileExists(atPath: newBinary.path) else {
            throw CLIError.invalidUsage("Extracted archive does not contain yuzudraw-cli binary.")
        }

        // Replace current binary
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
            // Restore backup on failure
            try? FileManager.default.moveItem(at: backupPath, to: resolvedBinary)
            throw CLIError.invalidUsage("Failed to install update: \(error.localizedDescription)")
        }

        print("Updated to v\(latestVersion).")
    }

    @discardableResult
    private static func shellOutput(_ args: String...) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw CLIError.invalidUsage("Command failed: \(args.joined(separator: " "))")
        }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    private static func shellRun(_ args: String...) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw CLIError.invalidUsage("Command failed: \(args.joined(separator: " "))")
        }
    }

    private static func printUsage() {
        let text = """
        YuzuDraw CLI

        Commands:
          create-diagram --name <name> [--project <path>] (--dsl-file <path> | --dsl-stdin)
          update-diagram --name <name> [--project <path>] (--dsl-file <path> | --dsl-stdin)
          get-diagram --name <name> [--project <path>] [--format dsl|ascii|both]
          list-diagrams [--workspace-dir <path>]
          render-ascii (--dsl-file <path> | --dsl-stdin)
          update            Update to the latest version
          version           Print the current version
        """
        print(text)
    }
}

exit(CLI.run())
