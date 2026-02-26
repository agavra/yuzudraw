import SwiftUI

struct ContentView: View {
    @State private var viewModel = CanvasViewModel()

    var body: some View {
        CanvasView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
