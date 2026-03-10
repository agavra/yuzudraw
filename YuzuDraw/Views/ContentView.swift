import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: EditorViewModel
    var onDocumentChange: (() -> Void)?

    @State private var colorPickerOffset: CGSize = .zero
    @GestureState private var colorPickerDrag: CGSize = .zero
    @State private var canvasSize: CGSize = .zero

    private let pickerWidth: CGFloat = 220
    private let pickerTopPad: CGFloat = 40
    private let pickerTrailingPad: CGFloat = 8
    private let pickerHeight: CGFloat = 420

    var body: some View {
        HSplitView {
            LayerPanel(viewModel: viewModel)
            CanvasView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    GeometryReader { geo in
                        Color.clear.onChange(of: geo.size, initial: true) { _, newSize in
                            canvasSize = newSize
                        }
                    }
                )
                .overlay(alignment: .topTrailing) {
                    if viewModel.activeColorTarget != nil {
                        let clampedX = clampedDragX(colorPickerOffset.width + colorPickerDrag.width)
                        let clampedY = clampedDragY(colorPickerOffset.height + colorPickerDrag.height)
                        colorPickerPanel
                            .offset(x: clampedX, y: clampedY)
                            .padding(.top, pickerTopPad)
                            .padding(.trailing, pickerTrailingPad)
                    }
                }
            InspectorPanel(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: viewModel.activeColorTarget) { _, newValue in
            if newValue != nil {
                colorPickerOffset = .zero
            }
        }
        .onChange(of: viewModel.document) {
            onDocumentChange?()
        }
    }

    // The picker is anchored at top-trailing with padding.
    // Offset x < 0 moves left, x > 0 moves right (off-screen).
    // Offset y < 0 moves up, y > 0 moves down.
    private func clampedDragX(_ x: CGFloat) -> CGFloat {
        let maxLeft = -(canvasSize.width - pickerWidth - pickerTrailingPad)
        let maxRight: CGFloat = 0
        return min(max(x, maxLeft), maxRight)
    }

    private func clampedDragY(_ y: CGFloat) -> CGFloat {
        let maxUp = -pickerTopPad
        let maxDown = max(canvasSize.height - pickerHeight - pickerTopPad, 0)
        return min(max(y, maxUp), maxDown)
    }

    private var colorPickerPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — draggable
            HStack(spacing: 8) {
                Text("Color")
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.closeColorPicker()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($colorPickerDrag) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        colorPickerOffset.width = clampedDragX(
                            colorPickerOffset.width + value.translation.width
                        )
                        colorPickerOffset.height = clampedDragY(
                            colorPickerOffset.height + value.translation.height
                        )
                    }
            )

            Divider()

            ColorPickerPopover(
                customPalette: viewModel.document.palette,
                pageColors: viewModel.documentColors,
                currentColor: viewModel.colorPickerCurrentColor,
                allowsNone: viewModel.colorPickerAllowsNone,
                onColorSelected: { color in
                    viewModel.colorPickerOnColorSelected?(color)
                },
                onDismiss: {
                    viewModel.closeColorPicker()
                },
                onAddToPalette: { color in
                    viewModel.addPaletteColor(name: color.hexString, color: color)
                },
                onRemoveFromPalette: { id in
                    viewModel.removePaletteColor(id: id)
                },
                onDragStarted: {
                    viewModel.beginColorPickerDrag()
                },
                onDragEnded: {
                    viewModel.endColorPickerDrag()
                }
            )
        }
        .frame(width: 220)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
}

#Preview {
    ContentView(viewModel: .previewSeeded())
        .frame(width: 1100, height: 570)
}

private extension EditorViewModel {
    static func previewSeeded() -> EditorViewModel {
        var document = Document(layers: [
            Layer(name: "Background"),
            Layer(name: "Service Mesh"),
            Layer(name: "Annotations"),
        ], canvasSize: GridSize(width: 120, height: 40))

        let datacenter = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 90, height: 24),
            strokeStyle: .double,
            fillMode: .solid,
            fillCharacter: ".",
            label: "Data Center",
            hasShadow: true,
            shadowStyle: .light,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )
        let api = RectangleShape(
            origin: GridPoint(column: 10, row: 6),
            size: GridSize(width: 24, height: 8),
            strokeStyle: .single,
            fillMode: .solid,
            fillCharacter: " ",
            label: "API",
            hasShadow: true,
            shadowStyle: .medium,
            shadowOffsetX: 2,
            shadowOffsetY: 1
        )
        let workers = RectangleShape(
            origin: GridPoint(column: 46, row: 8),
            size: GridSize(width: 28, height: 10),
            strokeStyle: .heavy,
            fillMode: .solid,
            fillCharacter: "·",
            label: "Workers",
            hasShadow: true,
            shadowStyle: .dark,
            shadowOffsetX: 2,
            shadowOffsetY: 1
        )
        let db = RectangleShape(
            origin: GridPoint(column: 78, row: 5),
            size: GridSize(width: 12, height: 7),
            strokeStyle: .rounded,
            fillMode: .solid,
            fillCharacter: " ",
            label: "DB",
            hasShadow: true,
            shadowStyle: .medium,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )
        let note = TextShape(
            origin: GridPoint(column: 8, row: 30),
            text: "Drag layers and shapes in the left pane.\nDrop line shows exact insertion."
        )

        let flow1 = ArrowShape(
            start: api.attachmentPoint(for: .right),
            end: workers.attachmentPoint(for: .left),
            label: "jobs",
            strokeStyle: .heavy,
            startAttachment: ArrowAttachment(shapeID: api.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: workers.id, side: .left)
        )
        let flow2 = ArrowShape(
            start: workers.attachmentPoint(for: .right),
            end: db.attachmentPoint(for: .left),
            label: "write",
            strokeStyle: .double,
            startAttachment: ArrowAttachment(shapeID: workers.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: db.id, side: .left)
        )
        let flow3 = ArrowShape(
            start: db.attachmentPoint(for: .bottom),
            end: workers.attachmentPoint(for: .top),
            label: "acks",
            strokeStyle: .single,
            bendDirection: .verticalFirst,
            startAttachment: ArrowAttachment(shapeID: db.id, side: .bottom),
            endAttachment: ArrowAttachment(shapeID: workers.id, side: .top),
            startHeadStyle: .dot,
            endHeadStyle: .openDiamond
        )

        document.addShape(.rectangle(datacenter), toLayerAt: 0)
        document.addShape(.rectangle(api), toLayerAt: 1)
        document.addShape(.rectangle(workers), toLayerAt: 1)
        document.addShape(.rectangle(db), toLayerAt: 1)
        document.addShape(.arrow(flow1), toLayerAt: 1)
        document.addShape(.arrow(flow2), toLayerAt: 1)
        document.addShape(.arrow(flow3), toLayerAt: 1)
        document.addShape(.text(note), toLayerAt: 2)
        document.layers[1].groups.append(
            ShapeGroup(
                name: "Backend",
                shapeIDs: [api.id, workers.id, db.id],
                children: [
                    ShapeGroup(name: "Flows", shapeIDs: [flow1.id, flow2.id, flow3.id])
                ]
            )
        )

        let vm = EditorViewModel(document: document)
        vm.activeLayerIndex = 1
        vm.expandedItemIDs = Set(vm.document.layers.map(\.id))
        vm.selectedShapeIDs = [workers.id]
        vm.rerender()
        return vm
    }
}
