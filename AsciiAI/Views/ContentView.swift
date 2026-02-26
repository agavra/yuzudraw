import SwiftUI

struct ContentView: View {
    @State private var viewModel = EditorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(viewModel: viewModel)
            Divider()
            HSplitView {
                LayerPanel(viewModel: viewModel)
                CanvasView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                InspectorPanel(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
