import Testing

@testable import YuzuDraw

struct DocumentTests {
    @Test func should_create_document_with_default_layer() {
        // given/when
        let doc = Document()

        // then
        #expect(doc.layers.count == 1)
        #expect(doc.layers[0].name == "Layer 1")
        #expect(doc.canvasSize == GridSize(width: 80, height: 24))
    }

    @Test func should_add_shape_to_specific_layer() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )

        // when
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // then
        #expect(doc.layers[0].shapes.count == 1)
    }

    @Test func should_find_shape_across_layers() {
        // given
        var doc = Document(layers: [
            Layer(name: "Layer 1"),
            Layer(name: "Layer 2"),
        ])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 1)

        // when
        let found = doc.findShape(id: rectangle.id)

        // then
        #expect(found != nil)
        #expect(found?.id == rectangle.id)
    }

    @Test func should_remove_shape_from_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        doc.removeShape(id: rectangle.id)

        // then
        #expect(doc.layers[0].shapes.isEmpty)
    }

    @Test func should_update_existing_shape() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Old"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let updated = RectangleShape(
            id: rectangle.id,
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            label: "New"
        )
        doc.updateShape(.rectangle(updated))

        // then
        if case .rectangle(let found) = doc.findShape(id: rectangle.id) {
            #expect(found.size.width == 10)
            #expect(found.label == "New")
        } else {
            Issue.record("Shape not found or wrong type")
        }
    }

    @Test func should_hit_test_topmost_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 2),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rect1), toLayerAt: 0)
        doc.addShape(.rectangle(rect2), toLayerAt: 0)

        // when - test overlap point
        let hit = doc.hitTest(at: GridPoint(column: 7, row: 3))

        // then - should hit the topmost (last added) shape
        #expect(hit?.id == rect2.id)
    }

    @Test func should_skip_hidden_layers_in_hit_test() {
        // given
        var doc = Document(layers: [
            Layer(name: "Layer 1"),
            Layer(name: "Layer 2", isVisible: false),
        ])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 1)

        // when
        let hit = doc.hitTest(at: GridPoint(column: 5, row: 3))

        // then
        #expect(hit == nil)
    }

    @Test func should_hit_nearby_arrow_when_not_exactly_on_line() {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 12, row: 2)
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        let hit = doc.hitTest(at: GridPoint(column: 7, row: 3))

        // then
        #expect(hit?.id == arrow.id)
    }

    @Test func should_add_and_remove_layers() {
        // given
        var doc = Document()

        // when
        doc.addLayer(name: "Layer 2")

        // then
        #expect(doc.layers.count == 2)

        // when - remove first layer
        doc.removeLayer(at: 0)

        // then
        #expect(doc.layers.count == 1)
        #expect(doc.layers[0].name == "Layer 2")
    }

    @Test func should_not_remove_last_layer() {
        // given
        var doc = Document()

        // when
        doc.removeLayer(at: 0)

        // then - should still have one layer
        #expect(doc.layers.count == 1)
    }

    @Test func should_move_layers_up_and_down() {
        // given
        var doc = Document(layers: [
            Layer(name: "Bottom"),
            Layer(name: "Top"),
        ])

        // when
        let movedDown = doc.moveLayerDown(at: 1)
        let movedUp = doc.moveLayerUp(at: 0)

        // then
        #expect(movedDown)
        #expect(movedUp)
        #expect(doc.layers[0].name == "Bottom")
        #expect(doc.layers[1].name == "Top")
    }

    @Test func should_move_shape_forward_and_backward_within_layer() {
        // given
        var doc = Document()
        let back = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Back"
        )
        let front = RectangleShape(
            origin: GridPoint(column: 2, row: 1),
            size: GridSize(width: 6, height: 4),
            label: "Front"
        )
        doc.addShape(.rectangle(back), toLayerAt: 0)
        doc.addShape(.rectangle(front), toLayerAt: 0)

        // when
        let movedBackward = doc.moveShapeBackward(id: front.id)
        let movedForward = doc.moveShapeForward(id: front.id)

        // then
        #expect(movedBackward)
        #expect(movedForward)
        #expect(doc.layers[0].shapes[1].id == front.id)
    }

    @Test func should_bring_shape_to_front_and_back_within_layer() {
        // given
        var doc = Document()
        let back = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Back"
        )
        let middle = RectangleShape(
            origin: GridPoint(column: 2, row: 1),
            size: GridSize(width: 6, height: 4),
            label: "Middle"
        )
        let front = RectangleShape(
            origin: GridPoint(column: 4, row: 2),
            size: GridSize(width: 6, height: 4),
            label: "Front"
        )
        doc.addShape(.rectangle(back), toLayerAt: 0)
        doc.addShape(.rectangle(middle), toLayerAt: 0)
        doc.addShape(.rectangle(front), toLayerAt: 0)

        // when
        let movedToFront = doc.moveShapeToFront(id: back.id)
        let movedToBack = doc.moveShapeToBack(id: front.id)

        // then
        #expect(movedToFront)
        #expect(movedToBack)
        #expect(doc.layers[0].shapes[0].id == front.id)
        #expect(doc.layers[0].shapes[2].id == back.id)
    }

    @Test func should_occlude_lower_layer_when_top_rectangle_fill_is_solid() {
        // given
        var doc = Document(layers: [
            Layer(name: "Bottom"),
            Layer(name: "Top"),
        ], canvasSize: GridSize(width: 10, height: 6))
        let bottom = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            strokeStyle: .single
        )
        let top = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single,
            fillMode: .opaque
        )
        doc.addShape(.rectangle(bottom), toLayerAt: 0)
        doc.addShape(.rectangle(top), toLayerAt: 1)
        var canvas = Canvas(size: doc.canvasSize)

        // when
        doc.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 3, row: 3) == " ")
    }

    @Test func should_render_all_visible_shapes() {
        // given
        var doc = Document(
            canvasSize: GridSize(width: 20, height: 5)
        )
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)
        var canvas = Canvas(size: doc.canvasSize)

        // when
        doc.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 0, row: 0) == "┌")
        #expect(canvas.character(atColumn: 5, row: 0) == "┐")
        #expect(canvas.character(atColumn: 0, row: 2) == "└")
    }

    @Test func should_move_shape_before_target_across_layers() {
        // given
        var doc = Document(layers: [
            Layer(name: "Layer 1"),
            Layer(name: "Layer 2"),
        ])
        let source = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let targetA = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let targetB = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        doc.addShape(.rectangle(source), toLayerAt: 0)
        doc.addShape(.rectangle(targetA), toLayerAt: 1)
        doc.addShape(.rectangle(targetB), toLayerAt: 1)

        // when
        let moved = doc.moveShape(id: source.id, before: targetB.id, in: doc.layers[1].id)

        // then
        #expect(moved)
        #expect(doc.layers[0].shapes.isEmpty)
        #expect(doc.layers[1].shapes.map(\.id) == [targetA.id, source.id, targetB.id])
    }

    @Test func should_not_move_shape_to_or_from_locked_layer() {
        // given
        var doc = Document(layers: [
            Layer(name: "Source"),
            Layer(name: "Unlocked Target"),
            Layer(name: "Locked Target", isLocked: true),
        ])
        let fromLocked = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let fromUnlocked = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        doc.addShape(.rectangle(fromLocked), toLayerAt: 0)
        doc.layers[0].isLocked = true
        doc.addShape(.rectangle(fromUnlocked), toLayerAt: 1)

        // when
        let movedFromLocked = doc.moveShape(id: fromLocked.id, toLayer: doc.layers[1].id)
        let movedToLocked = doc.moveShape(id: fromUnlocked.id, toLayer: doc.layers[2].id)

        // then
        #expect(!movedFromLocked)
        #expect(!movedToLocked)
        #expect(doc.layerIndex(containingShape: fromLocked.id) == 0)
        #expect(doc.layerIndex(containingShape: fromUnlocked.id) == 1)
    }
}
