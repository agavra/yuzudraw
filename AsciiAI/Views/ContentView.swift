    import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: EditorViewModel

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

        let datacenter = BoxShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 90, height: 24),
            strokeStyle: .double,
            fillMode: .solid,
            fillCharacter: ".",
            label: "Data Center"
        )
        let api = BoxShape(
            origin: GridPoint(column: 10, row: 6),
            size: GridSize(width: 24, height: 8),
            strokeStyle: .single,
            fillMode: .solid,
            fillCharacter: " ",
            label: "API"
        )
        let workers = BoxShape(
            origin: GridPoint(column: 46, row: 8),
            size: GridSize(width: 28, height: 10),
            strokeStyle: .heavy,
            fillMode: .solid,
            fillCharacter: "·",
            label: "Workers"
        )
        let db = BoxShape(
            origin: GridPoint(column: 78, row: 5),
            size: GridSize(width: 12, height: 7),
            strokeStyle: .rounded,
            fillMode: .solid,
            fillCharacter: " ",
            label: "DB"
        )
        let note = TextShape(
            origin: GridPoint(column: 8, row: 30),
            text: "Drag layers and shapes in the left pane.\nDrop line shows exact insertion."
        )

        let flow1 = ArrowShape(
            start: GridPoint(column: 34, row: 10),
            end: GridPoint(column: 46, row: 10),
            label: "jobs",
            strokeStyle: .heavy
        )
        let flow2 = ArrowShape(
            start: GridPoint(column: 74, row: 10),
            end: GridPoint(column: 78, row: 8),
            label: "write",
            strokeStyle: .double
        )

        document.addShape(.box(datacenter), toLayerAt: 0)
        document.addShape(.box(api), toLayerAt: 1)
        document.addShape(.box(workers), toLayerAt: 1)
        document.addShape(.box(db), toLayerAt: 1)
        document.addShape(.arrow(flow1), toLayerAt: 1)
        document.addShape(.arrow(flow2), toLayerAt: 1)
        document.addShape(.text(note), toLayerAt: 2)
        document.layers[1].groups.append(
            ShapeGroup(
                name: "Backend",
                shapeIDs: [api.id, workers.id, db.id],
                children: [
                    ShapeGroup(name: "Flows", shapeIDs: [flow1.id, flow2.id])
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
