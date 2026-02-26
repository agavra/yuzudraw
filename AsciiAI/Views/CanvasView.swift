import SwiftUI

struct CanvasView: View {
    @Bindable var viewModel: CanvasViewModel

    var body: some View {
        let canvas = viewModel.canvas
        VStack(spacing: 0) {
            Text(canvas.render())
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor))
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    CanvasView(viewModel: CanvasViewModel())
}
