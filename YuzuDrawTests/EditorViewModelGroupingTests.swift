import Testing

@testable import YuzuDraw

@MainActor
struct EditorViewModelGroupingTests {
    @Test func should_group_selected_shapes_in_same_layer() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let box1 = BoxShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let box2 = BoxShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let box3 = BoxShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.box(box1), toLayerAt: 0)
        document.addShape(.box(box2), toLayerAt: 0)
        document.addShape(.box(box3), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [box3.id, box1.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.count == 1)
        #expect(viewModel.document.layers[0].groups[0].shapeIDs == [box1.id, box3.id])
    }

    @Test func should_not_group_selected_shapes_across_layers() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1"), Layer(name: "Layer 2")])
        let box1 = BoxShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let box2 = BoxShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.box(box1), toLayerAt: 0)
        document.addShape(.box(box2), toLayerAt: 1)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [box1.id, box2.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.isEmpty)
        #expect(viewModel.document.layers[1].groups.isEmpty)
    }

    @Test func should_remove_shapes_from_existing_groups_before_creating_new_group() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let box1 = BoxShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let box2 = BoxShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let box3 = BoxShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.box(box1), toLayerAt: 0)
        document.addShape(.box(box2), toLayerAt: 0)
        document.addShape(.box(box3), toLayerAt: 0)
        document.layers[0].groups.append(ShapeGroup(name: "Existing", shapeIDs: [box1.id, box2.id]))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [box2.id, box3.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.count == 2)
        #expect(viewModel.document.layers[0].groups[0].shapeIDs == [box1.id])
        #expect(viewModel.document.layers[0].groups[1].shapeIDs == [box2.id, box3.id])
    }
}
