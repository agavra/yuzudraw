import SwiftUI

struct CanvasView: View {
    @Bindable var viewModel: EditorViewModel
    @State private var charSize: CGSize = {
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let size = ("M" as NSString).size(withAttributes: [.font: font])
        return size
    }()

    private let rulerGutterLeft: CGFloat = 30
    private let rulerGutterTop: CGFloat = 16
    private static let diagonalNWSECursor = NSCursor(
        image: NSImage(
            systemSymbolName: "arrow.up.left.and.arrow.down.right",
            accessibilityDescription: "Diagonal Resize"
        ) ?? NSImage(),
        hotSpot: CGPoint(x: 8, y: 8)
    )
    private static let diagonalNESWCursor = NSCursor(
        image: NSImage(
            systemSymbolName: "arrow.up.right.and.arrow.down.left",
            accessibilityDescription: "Diagonal Resize"
        ) ?? NSImage(),
        hotSpot: CGPoint(x: 8, y: 8)
    )

    var body: some View {
        GeometryReader { geo in
            let _ = updateViewportSize(geo.size)
            let contentWidth = max(gridWidth(for: geo.size), CGFloat(viewModel.canvas.columns) * charSize.width)
            let contentHeight = max(gridHeight(for: geo.size), CGFloat(viewModel.canvas.rows) * charSize.height)

            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    gridBackground(width: contentWidth, height: contentHeight)
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    canvasText
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    columnRuler(width: contentWidth)
                        .offset(x: rulerGutterLeft, y: 0)

                    rowRuler(height: contentHeight)
                        .offset(x: 0, y: rulerGutterTop)

                    Rectangle()
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .frame(width: rulerGutterLeft, height: rulerGutterTop)

                    selectionOverlay
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    textEditOverlay
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)
                }
                .frame(
                    width: rulerGutterLeft + contentWidth,
                    height: rulerGutterTop + contentHeight
                )
                .gesture(dragGesture)
            }
            .background(Color(nsColor: .textBackgroundColor))
        }
    }

    private func gridWidth(for viewportSize: CGSize) -> CGFloat {
        max(0, viewportSize.width - rulerGutterLeft)
    }

    private func gridHeight(for viewportSize: CGSize) -> CGFloat {
        max(0, viewportSize.height - rulerGutterTop)
    }

    private func updateViewportSize(_ size: CGSize) {
        let newSize = CGSize(
            width: max(0, size.width - rulerGutterLeft),
            height: max(0, size.height - rulerGutterTop)
        )
        if viewModel.viewportSize != newSize {
            DispatchQueue.main.async {
                viewModel.viewportSize = newSize
                viewModel.rerender()
            }
        }
    }

    // MARK: - Column ruler

    private func columnRuler(width: CGFloat) -> some View {
        SwiftUI.Canvas { context, size in
            let cols = Int(ceil(width / charSize.width))
            let rulerFont = Font.system(size: 9, design: .monospaced)
            for col in stride(from: 0, through: cols, by: 5) {
                let x = CGFloat(col) * charSize.width
                let text = Text("\(col)").font(rulerFont).foregroundColor(.secondary)
                context.draw(
                    text, at: CGPoint(x: x + 1, y: size.height / 2), anchor: .leading)
            }
        }
        .frame(width: width, height: rulerGutterTop)
    }

    // MARK: - Row ruler

    private func rowRuler(height: CGFloat) -> some View {
        SwiftUI.Canvas { context, size in
            let rows = Int(ceil(height / charSize.height))
            let rulerFont = Font.system(size: 9, design: .monospaced)
            for row in stride(from: 0, through: rows, by: 5) {
                let y = CGFloat(row) * charSize.height
                let text = Text("\(row)").font(rulerFont).foregroundColor(.secondary)
                context.draw(
                    text, at: CGPoint(x: size.width - 4, y: y + charSize.height / 2),
                    anchor: .trailing)
            }
        }
        .frame(width: rulerGutterLeft, height: height)
    }

    // MARK: - Grid background

    private func gridBackground(width: CGFloat, height: CGFloat) -> some View {
        SwiftUI.Canvas { context, _ in
            let cols = Int(ceil(width / charSize.width))
            let rows = Int(ceil(height / charSize.height))

            let gridColor = Color.gray.opacity(0.15)

            for col in 0...cols {
                let x = CGFloat(col) * charSize.width
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    },
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }

            for row in 0...rows {
                let y = CGFloat(row) * charSize.height
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    },
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Canvas text

    private var canvasText: some View {
        Text(viewModel.canvas.render())
            .font(.system(size: 14, design: .monospaced))
            .textSelection(.disabled)
            .fixedSize()
            .contentShape(Rectangle())
    }

    // MARK: - Selection overlay

    private var selectionOverlay: some View {
        ZStack(alignment: .topLeading) {
            ForEach(viewModel.selectedShapes) { shape in
                let rect = shape.boundingRect
                ZStack(alignment: .topLeading) {
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

                    ForEach(shape.resizeHandlePlacements, id: \.self) { placement in
                        Circle()
                            .fill(Color.accentColor)
                            .overlay(
                                Circle()
                                    .stroke(Color(nsColor: .textBackgroundColor), lineWidth: 1)
                            )
                            .frame(width: 8, height: 8)
                            .offset(
                                x: CGFloat(placement.point.column) * charSize.width - 4,
                                y: CGFloat(placement.point.row) * charSize.height - 4
                            )
                            .onHover { hovering in
                                if hovering {
                                    cursor(for: placement.handle).set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                    }
                }
            }
            marqueeOverlay
        }
    }

    // MARK: - Marquee overlay

    @ViewBuilder
    private var marqueeOverlay: some View {
        if let rect = (viewModel.activeTool as? SelectionTool)?.marqueeRect {
            Rectangle()
                .fill(Color.accentColor.opacity(0.1))
                .overlay(
                    Rectangle()
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                        )
                        .foregroundStyle(Color.accentColor)
                )
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

    // MARK: - Text edit overlay

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

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let adjusted = CGPoint(
                    x: value.location.x - rulerGutterLeft,
                    y: value.location.y - rulerGutterTop
                )
                let point = viewModel.gridPoint(from: adjusted, charSize: charSize)
                if value.translation == .zero {
                    viewModel.mouseDown(at: point)
                } else {
                    viewModel.mouseDragged(to: point)
                }
            }
            .onEnded { value in
                let adjusted = CGPoint(
                    x: value.location.x - rulerGutterLeft,
                    y: value.location.y - rulerGutterTop
                )
                let point = viewModel.gridPoint(from: adjusted, charSize: charSize)
                viewModel.mouseUp(at: point)
            }
    }

    private func cursor(for handle: ResizeHandle) -> NSCursor {
        switch handle {
        case .top, .bottom:
            return .resizeUpDown
        case .left, .right:
            return .resizeLeftRight
        case .topLeft, .bottomRight:
            return Self.diagonalNWSECursor
        case .topRight, .bottomLeft:
            return Self.diagonalNESWCursor
        case .start, .end:
            return .openHand
        }
    }

}

#Preview {
    let vm = EditorViewModel()
    vm.document.addShape(
        .box(BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 14, height: 5),
            borderStyle: .single,
            label: "Server"
        )),
        toLayerAt: 0
    )
    vm.document.addShape(
        .box(BoxShape(
            origin: GridPoint(column: 30, row: 3),
            size: GridSize(width: 14, height: 5),
            borderStyle: .double,
            label: "Database"
        )),
        toLayerAt: 0
    )
    vm.document.addShape(
        .arrow(ArrowShape(
            start: GridPoint(column: 19, row: 5),
            end: GridPoint(column: 30, row: 5)
        )),
        toLayerAt: 0
    )
    vm.rerender()
    return CanvasView(viewModel: vm)
        .frame(width: 600, height: 400)
}
