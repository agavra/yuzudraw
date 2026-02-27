import Testing

@testable import AsciiAI

struct DSLSerializerTests {
    @Test func should_serialize_simple_document() {
        // given
        var doc = Document(layers: [Layer(name: "Infrastructure")])
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 20, height: 5),
            borderStyle: .single,
            label: "Server"
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("layer \"Infrastructure\" visible"))
        #expect(dsl.contains("box \"Server\" at 5,3 size 20x5 style single"))
    }

    @Test func should_serialize_arrow_with_label() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let arrow = ArrowShape(
            start: GridPoint(column: 15, row: 7),
            end: GridPoint(column: 15, row: 15),
            label: "SQL"
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("arrow from 15,7 to 15,15 label \"SQL\""))
    }

    @Test func should_serialize_text_shape() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let text = TextShape(
            origin: GridPoint(column: 40, row: 3),
            text: "Client App"
        )
        doc.addShape(.text(text), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("text \"Client App\" at 40,3"))
    }

    @Test func should_serialize_hidden_locked_layer() {
        // given
        let doc = Document(layers: [
            Layer(name: "Background", isVisible: false, isLocked: true)
        ])

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("layer \"Background\" hidden locked"))
    }

    @Test func should_serialize_nested_groups() {
        // given
        var layer = Layer(name: "Layer 1")
        let box1 = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Inner"
        )
        let box2 = BoxShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Outer"
        )
        layer.addShape(.box(box1))
        layer.addShape(.box(box2))
        let innerGroup = ShapeGroup(name: "InnerGroup", shapeIDs: [box1.id])
        let outerGroup = ShapeGroup(
            name: "OuterGroup", shapeIDs: [box2.id], children: [innerGroup])
        layer.groups.append(outerGroup)

        let doc = Document(layers: [layer])

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"OuterGroup\""))
        #expect(dsl.contains("group \"InnerGroup\""))
        #expect(dsl.contains("box \"Inner\""))
        #expect(dsl.contains("box \"Outer\""))
    }

    @Test func should_serialize_groups() {
        // given
        var layer = Layer(name: "Layer 1")
        let box1 = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "A"
        )
        let box2 = BoxShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "B"
        )
        layer.addShape(.box(box1))
        layer.addShape(.box(box2))
        layer.groups.append(
            ShapeGroup(name: "Backend", shapeIDs: [box1.id, box2.id]))

        let doc = Document(layers: [layer])

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"Backend\""))
        #expect(dsl.contains("box \"A\""))
        #expect(dsl.contains("box \"B\""))
    }
}
