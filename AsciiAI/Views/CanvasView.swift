import SwiftUI

struct CanvasView: View {
    @Bindable var viewModel: EditorViewModel
    @State private var charSize: CGSize = CGSize(width: 8, height: 16)

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                canvasText
                selectionOverlay
                textEditOverlay
            }
            .gesture(dragGesture)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear {
            measureCharSize()
        }
    }

    private var canvasText: some View {
        Text(viewModel.canvas.render())
            .font(.system(size: 14, design: .monospaced))
            .textSelection(.disabled)
            .fixedSize()
            .contentShape(Rectangle())
    }

    private var selectionOverlay: some View {
        Group {
            if let shape = viewModel.selectedShape {
                let rect = shape.boundingRect
                Rectangle()
                    .stroke(Color.accentColor, lineWidth: 1)
                    .frame(
                        width: CGFloat(rect.size.width) * charSize.width,
                        height: CGFloat(rect.size.height) * charSize.height
                    )
                    .offset(
                        x: CGFloat(rect.origin.column) * charSize.width,
                        y: CGFloat(rect.origin.row) * charSize.height
                    )
            }
        }
    }

    @ViewBuilder
    private var textEditOverlay: some View {
        if viewModel.isEditingText, let point = viewModel.textEditPoint {
            TextField("Type text...", text: $viewModel.textEditContent)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .monospaced))
                .frame(width: 200)
                .padding(2)
                .background(Color(nsColor: .textBackgroundColor))
                .border(Color.accentColor)
                .offset(
                    x: CGFloat(point.column) * charSize.width,
                    y: CGFloat(point.row) * charSize.height
                )
                .onSubmit {
                    viewModel.commitTextEdit()
                }
                .onExitCommand {
                    viewModel.cancelTextEdit()
                }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let point = viewModel.gridPoint(from: value.location, charSize: charSize)
                if value.translation == .zero {
                    viewModel.mouseDown(at: point)
                } else {
                    viewModel.mouseDragged(to: point)
                }
            }
            .onEnded { value in
                let point = viewModel.gridPoint(from: value.location, charSize: charSize)
                viewModel.mouseUp(at: point)
            }
    }

    private func measureCharSize() {
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let sampleString = "M" as NSString
        let size = sampleString.size(withAttributes: [.font: font])
        charSize = size
    }
}

#Preview {
    CanvasView(viewModel: EditorViewModel())
}
