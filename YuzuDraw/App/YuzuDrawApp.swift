import SwiftUI

@main
struct YuzuDrawApp: App {
    @State private var viewModel = EditorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 700)
        .commands {
            CommandGroup(after: .pasteboard) {
                Button("Group") {
                    viewModel.groupSelectedShapes()
                }
                .keyboardShortcut("g", modifiers: .command)
                .disabled(!viewModel.canGroupSelectedShapes())
            }
        }
    }
}
