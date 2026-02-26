# AsciiAI

A macOS app for drawing ASCII diagrams (Monodraw/Figma-like).

## Build & Test

```bash
# Generate Xcode project (after modifying project.yml)
xcodegen generate

# Build
xcodebuild -project AsciiAI.xcodeproj -scheme AsciiAI -configuration Debug build

# Run tests
xcodebuild -project AsciiAI.xcodeproj -scheme AsciiAITests -configuration Debug test
```

## Project Structure

- `project.yml` — XcodeGen spec (source of truth for the Xcode project)
- `AsciiAI/App/` — App entry point
- `AsciiAI/Models/` — Data models (Canvas, elements, geometry)
- `AsciiAI/Views/` — SwiftUI views
- `AsciiAI/ViewModels/` — Observable view models
- `AsciiAI/Resources/` — Assets, Info.plist, entitlements
- `AsciiAITests/` — Unit tests

## Conventions

- Architecture: MVVM with `@Observable` view models
- UI: SwiftUI, targeting macOS 14+
- Swift version: 6.0 with strict concurrency
- Tests: Swift Testing framework (`import Testing`), use given/when/then pattern, name tests `should_xyz`
- Regenerate `AsciiAI.xcodeproj` with `xcodegen generate` after changing `project.yml` — the `.xcodeproj` is gitignored
