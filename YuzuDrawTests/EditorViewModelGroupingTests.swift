import Testing

@testable import YuzuDraw

@MainActor
struct EditorViewModelGroupingTests {
    @Test func should_group_single_selected_shape() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rect), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rect.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.count == 1)
        #expect(viewModel.document.layers[0].groups[0].shapeIDs == [rect.id])
    }

    @Test func should_group_selected_shapes_in_same_layer() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let rect3 = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        document.addShape(.rectangle(rect3), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rect3.id, rect1.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.count == 1)
        #expect(viewModel.document.layers[0].groups[0].shapeIDs == [rect1.id, rect3.id])
    }

    @Test func should_preserve_multi_selection_when_drag_starts_on_selected_shape() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select
        viewModel.selectedShapeIDs = [rect1.id, rect2.id]

        // when
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))

        // then
        #expect(viewModel.selectedShapeIDs == [rect1.id, rect2.id])
    }

    @Test func should_not_group_selected_shapes_across_layers() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1"), Layer(name: "Layer 2")])
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 1)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rect1.id, rect2.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.isEmpty)
        #expect(viewModel.document.layers[1].groups.isEmpty)
    }

    @Test func should_remove_shapes_from_existing_groups_before_creating_new_group() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let rect3 = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        document.addShape(.rectangle(rect3), toLayerAt: 0)
        document.layers[0].groups.append(ShapeGroup(name: "Existing", shapeIDs: [rect1.id, rect2.id]))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rect2.id, rect3.id]

        // when
        viewModel.groupSelectedShapes()

        // then
        #expect(viewModel.document.layers[0].groups.count == 2)
        #expect(viewModel.document.layers[0].groups[0].shapeIDs == [rect1.id])
        #expect(viewModel.document.layers[0].groups[1].shapeIDs == [rect2.id, rect3.id])
    }

    @Test func should_rename_shape_without_changing_label() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Rendered"
        )
        document.addShape(.rectangle(rectangle), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)

        // when
        viewModel.renameShapeFromPanel(rectangle.id, to: "Node A")

        // then
        guard case .rectangle(let renamedRect) = viewModel.document.layers[0].shapes[0] else {
            Issue.record("Expected rectangle shape")
            return
        }
        #expect(renamedRect.name == "Node A")
        #expect(renamedRect.label == "Rendered")
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

    // MARK: - Group selection behavior

    @Test func should_select_entire_group_when_clicking_grouped_shape() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        let rect3 = RectangleShape(origin: GridPoint(column: 40, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        document.addShape(.rectangle(rect3), toLayerAt: 0)
        document.layers[0].groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id]))
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // when — click on rect1 which is in the group
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))

        // then — entire group should be selected
        #expect(viewModel.selectedShapeIDs == [rect1.id, rect2.id])
        #expect(viewModel.enteredGroupID == nil)
    }

    @Test func should_enter_group_on_second_click() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id])
        document.layers[0].groups.append(group)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // First click — select group
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))
        #expect(viewModel.selectedShapeIDs == [rect1.id, rect2.id])

        // when — second click on rect1 (group already selected)
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))

        // then — entered group, individual shape selected
        #expect(viewModel.enteredGroupID == group.id)
        #expect(viewModel.selectedShapeIDs == [rect1.id])
    }

    @Test func should_drill_into_nested_groups_progressively() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(name: "Outer", shapeIDs: [rect2.id], children: [innerGroup])
        document.layers[0].groups.append(outerGroup)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // First click — select outer group
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))
        #expect(viewModel.selectedShapeIDs == [rect1.id, rect2.id])
        #expect(viewModel.enteredGroupID == nil)

        // Second click — enter outer group, select inner group
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))
        #expect(viewModel.enteredGroupID == outerGroup.id)
        #expect(viewModel.selectedShapeIDs == [rect1.id])

        // Third click — enter inner group, select individual shape
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))
        #expect(viewModel.enteredGroupID == innerGroup.id)
        #expect(viewModel.selectedShapeIDs == [rect1.id])
    }

    @Test func should_exit_group_on_escape_and_reselect_parent() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id])
        document.layers[0].groups.append(group)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // Enter group: select group then click again
        viewModel.selectedShapeIDs = [rect1.id, rect2.id]
        viewModel.enteredGroupID = group.id
        viewModel.selectedShapeIDs = [rect1.id]

        // when — press escape
        let handled = viewModel.handleEscape()

        // then — exit group, re-select group
        #expect(handled)
        #expect(viewModel.enteredGroupID == nil)
        #expect(viewModel.selectedShapeIDs == [rect1.id, rect2.id])
    }

    @Test func should_deselect_on_empty_canvas_click() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id])
        document.layers[0].groups.append(group)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select
        viewModel.selectedShapeIDs = [rect1.id]
        viewModel.enteredGroupID = group.id

        // when — click on empty canvas
        viewModel.mouseDown(at: GridPoint(column: 60, row: 60))
        viewModel.mouseUp(at: GridPoint(column: 60, row: 60))

        // then
        #expect(viewModel.selectedShapeIDs.isEmpty)
        #expect(viewModel.enteredGroupID == nil)
    }

    @Test func should_add_entire_group_on_shift_click() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        let rect3 = RectangleShape(origin: GridPoint(column: 40, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        document.addShape(.rectangle(rect3), toLayerAt: 0)
        document.layers[0].groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id]))
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select
        viewModel.selectedShapeIDs = [rect3.id]

        // when — shift+click on rect1 (in group)
        viewModel.isShiftKeyPressed = true
        viewModel.mouseDown(at: GridPoint(column: 4, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 4, row: 4))

        // then — entire group should be added to selection
        #expect(viewModel.selectedShapeIDs.contains(rect1.id))
        #expect(viewModel.selectedShapeIDs.contains(rect2.id))
        #expect(viewModel.selectedShapeIDs.contains(rect3.id))
    }

    @Test func should_select_another_shape_within_entered_group() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(origin: GridPoint(column: 2, row: 2), size: GridSize(width: 8, height: 5))
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id])
        document.layers[0].groups.append(group)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // Enter group and select rect1
        viewModel.enteredGroupID = group.id
        viewModel.selectedShapeIDs = [rect1.id]

        // when — click on rect2 (also in the entered group)
        viewModel.mouseDown(at: GridPoint(column: 22, row: 4))
        viewModel.mouseUp(at: GridPoint(column: 22, row: 4))

        // then — should select rect2 individually, not the whole group
        #expect(viewModel.selectedShapeIDs == [rect2.id])
        #expect(viewModel.enteredGroupID == group.id)
    }

    @Test func should_double_click_enter_group() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rect1 = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 5),
            label: "Hello"
        )
        let rect2 = RectangleShape(origin: GridPoint(column: 20, row: 2), size: GridSize(width: 8, height: 5))
        document.addShape(.rectangle(rect1), toLayerAt: 0)
        document.addShape(.rectangle(rect2), toLayerAt: 0)
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id])
        document.layers[0].groups.append(group)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeToolType = .select

        // when — double-click on rect1
        viewModel.handleDoubleClick(at: GridPoint(column: 4, row: 4))

        // then — should enter group and start text editing
        #expect(viewModel.enteredGroupID == group.id)
        #expect(viewModel.selectedShapeIDs == [rect1.id])
        #expect(viewModel.isEditingText)
    }

    @Test func should_not_shrink_canvas_below_shape_bounds_plus_padding() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(origin: GridPoint(column: 95, row: 5), size: GridSize(width: 10, height: 4))
        document.addShape(.rectangle(rectangle), toLayerAt: 0)
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
        // rectangle max col is 104 -> minimum width with padding is 115
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

    @Test func should_select_shapes_from_top_layer_down_to_selected_layer() {
        // given
        var document = Document(layers: [Layer(name: "Bottom"), Layer(name: "Middle"), Layer(name: "Top")])
        let bottomRect = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let middleRect = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let topRect = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(bottomRect), toLayerAt: 0)
        document.addShape(.rectangle(middleRect), toLayerAt: 1)
        document.addShape(.rectangle(topRect), toLayerAt: 2)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeLayerIndex = 1
        viewModel.selectedShapeIDs = [middleRect.id]
        viewModel.selectedLayerID = viewModel.document.layers[1].id

        // when
        viewModel.selectAllShapes()

        // then
        #expect(viewModel.selectedShapeIDs == [middleRect.id, topRect.id])
    }

    @Test func should_select_only_members_of_group_when_selecting_shape_in_group() {
        // given
        var document = Document(layers: [Layer(name: "Main"), Layer(name: "Top")])
        let bottomRect = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let groupedRectA = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let groupedRectB = RectangleShape(origin: GridPoint(column: 15, row: 0), size: GridSize(width: 4, height: 3))
        let topOfLayerRect = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        let topLayerRect = RectangleShape(origin: GridPoint(column: 30, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(bottomRect), toLayerAt: 0)
        document.addShape(.rectangle(groupedRectA), toLayerAt: 0)
        document.addShape(.rectangle(groupedRectB), toLayerAt: 0)
        document.addShape(.rectangle(topOfLayerRect), toLayerAt: 0)
        document.layers[0].groups = [ShapeGroup(name: "Middle Group", shapeIDs: [groupedRectA.id, groupedRectB.id])]
        document.addShape(.rectangle(topLayerRect), toLayerAt: 1)
        let viewModel = EditorViewModel(document: document)
        viewModel.activeLayerIndex = 0
        viewModel.selectedShapeIDs = [groupedRectA.id]

        // when
        viewModel.selectAllShapes()

        // then
        #expect(viewModel.selectedShapeIDs == [groupedRectA.id, groupedRectB.id])
    }
}
