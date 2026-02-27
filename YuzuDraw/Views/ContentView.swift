    import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        HSplitView {
            LayerPanel(viewModel: viewModel)
            CanvasView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            InspectorPanel(viewModel: viewModel)
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
            label: "Data Center",
            hasShadow: true,
            shadowStyle: .light,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )
        let api = BoxShape(
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
        let workers = BoxShape(
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
        let db = BoxShape(
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

        document.addShape(.box(datacenter), toLayerAt: 0)
        document.addShape(.box(api), toLayerAt: 1)
        document.addShape(.box(workers), toLayerAt: 1)
        document.addShape(.box(db), toLayerAt: 1)
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
