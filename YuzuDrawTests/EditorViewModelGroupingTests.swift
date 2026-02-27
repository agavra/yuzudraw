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

    @Test func should_rename_shape_without_changing_label() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Rendered"
        )
        document.addShape(.box(box), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)

        // when
        viewModel.renameShapeFromPanel(box.id, to: "Node A")

        // then
        guard case .box(let renamedBox) = viewModel.document.layers[0].shapes[0] else {
            Issue.record("Expected box shape")
            return
        }
        #expect(renamedBox.name == "Node A")
        #expect(renamedBox.label == "Rendered")
        #expect(viewModel.document.layers[0].shapes[0].displayName == "Node A")
    }

    @Test func should_clear_custom_shape_name_when_empty_string_is_submitted() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let arrow = ArrowShape(
            name: "Flow",
            start: GridPoint(column: 0, row: 0),
            end: GridPoint(column: 5, row: 0),
            label: ""
        )
        document.addShape(.arrow(arrow), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)

        // when
        viewModel.renameShapeFromPanel(arrow.id, to: "   ")

        // then
        guard case .arrow(let renamedArrow) = viewModel.document.layers[0].shapes[0] else {
            Issue.record("Expected arrow shape")
            return
        }
        #expect(renamedArrow.name == nil)
        #expect(viewModel.document.layers[0].shapes[0].displayName == "Arrow")
    }

    @Test func should_rename_nested_group_from_panel() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let nestedGroup = ShapeGroup(name: "Inner", shapeIDs: [])
        let parentGroup = ShapeGroup(name: "Outer", shapeIDs: [], children: [nestedGroup])
        document.layers[0].groups = [parentGroup]
        let viewModel = EditorViewModel(document: document)

        // when
        viewModel.renameGroupFromPanel(nestedGroup.id, to: "Database")

        // then
        #expect(viewModel.document.layers[0].groups[0].children[0].name == "Database")
    }

    @Test func should_expand_canvas_width_when_scrolling_right_near_edge() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 100, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 97,
            visibleMaxRow: 10,
            deltaX: 5,
            deltaY: 0
        )

        // then
        #expect(viewModel.document.canvasSize.width == 120)
        #expect(viewModel.document.canvasSize.height == 40)
    }

    @Test func should_expand_canvas_height_when_scrolling_down_near_edge() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 100, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 10,
            visibleMaxRow: 38,
            deltaX: 0,
            deltaY: 4
        )

        // then
        #expect(viewModel.document.canvasSize.width == 100)
        #expect(viewModel.document.canvasSize.height == 50)
    }

    @Test func should_not_expand_canvas_when_scrolling_left_or_up() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 100, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 99,
            visibleMaxRow: 39,
            deltaX: -5,
            deltaY: -4
        )

        // then
        #expect(viewModel.document.canvasSize == GridSize(width: 100, height: 40))
    }

    @Test func should_not_expand_canvas_when_not_near_edge() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 100, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 70,
            visibleMaxRow: 20,
            deltaX: 5,
            deltaY: 5
        )

        // then
        #expect(viewModel.document.canvasSize == GridSize(width: 100, height: 40))
    }

    @Test func should_shrink_canvas_width_when_scrolling_left_away_from_empty_right_space() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 140, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 90,
            visibleMaxRow: 20,
            deltaX: -8,
            deltaY: 0
        )

        // then
        #expect(viewModel.document.canvasSize.width == 120)
        #expect(viewModel.document.canvasSize.height == 40)
    }

    @Test func should_shrink_canvas_height_when_scrolling_up_away_from_empty_bottom_space() {
        // given
        let viewModel = EditorViewModel()
        viewModel.document.canvasSize = GridSize(width: 100, height: 60)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 60,
            visibleMaxRow: 30,
            deltaX: 0,
            deltaY: -6
        )

        // then
        #expect(viewModel.document.canvasSize.width == 100)
        #expect(viewModel.document.canvasSize.height == 50)
    }

    @Test func should_not_shrink_canvas_below_shape_bounds_plus_padding() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let box = BoxShape(origin: GridPoint(column: 95, row: 5), size: GridSize(width: 10, height: 4))
        document.addShape(.box(box), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.document.canvasSize = GridSize(width: 140, height: 40)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 80,
            visibleMaxRow: 20,
            deltaX: -8,
            deltaY: 0
        )

        // then
        // box max col is 104 -> minimum width with padding is 115
        #expect(viewModel.document.canvasSize.width == 120)

        // when
        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: 80,
            visibleMaxRow: 20,
            deltaX: -8,
            deltaY: 0
        )

        // then
        #expect(viewModel.document.canvasSize.width == 120)
    }
}
