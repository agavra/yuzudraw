import Testing

@testable import YuzuDraw

struct DSLSerializerTests {
    @Test func should_serialize_simple_document() {
        // given
        var doc = Document(layers: [Layer(name: "Infrastructure")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 20, height: 5),
            strokeStyle: .single,
            label: "Server"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("layer \"Infrastructure\" visible"))
        #expect(dsl.contains("rectangle \"Server\" at 5,3 size 20x5 style single"))
    }

    @Test func should_serialize_arrow_with_label() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let arrow = ArrowShape(
            start: GridPoint(column: 15, row: 7),
            end: GridPoint(column: 15, row: 15),
            label: "SQL",
            strokeStyle: .heavy
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("arrow from 15,7 to 15,15 style heavy label \"SQL\""))
    }

    @Test func should_serialize_rectangle_fill() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            strokeStyle: .single,
            fillMode: .solid,
            fillCharacter: ".",
            label: "Filled"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("rectangle \"Filled\" at 1,1 size 8x4 style single fill solid char \".\""))
    }

    @Test func should_serialize_rectangle_text_layout_settings() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            hasBorder: false,
            label: "Note",
            textHorizontalAlignment: .left,
            textVerticalAlignment: .top,
            allowTextOnBorder: true,
            textPaddingLeft: 1,
            textPaddingRight: 2,
            textPaddingTop: 0,
            textPaddingBottom: 1
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("border hidden"))
        #expect(dsl.contains("halign left valign top"))
        #expect(dsl.contains("textOnBorder true"))
        #expect(dsl.contains("padding 1,2,0,1"))
    }

    @Test func should_serialize_rectangle_visible_borders() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            visibleBorders: [.top, .left],
            label: "Sides"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("borders top,left"))
    }

    @Test func should_serialize_rectangle_dashed_border_settings() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 4),
            borderLineStyle: .dashed,
            borderDashLength: 3,
            borderGapLength: 2,
            label: "Dash"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("line dashed"))
        #expect(dsl.contains("dash 3"))
        #expect(dsl.contains("gap 2"))
    }

    @Test func should_serialize_rectangle_shadow_settings() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            label: "Note",
            hasShadow: true,
            shadowStyle: .full,
            shadowOffsetX: -2,
            shadowOffsetY: -3
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("shadow full"))
        #expect(dsl.contains("x -2"))
        #expect(dsl.contains("y -3"))
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
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Inner"
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Outer"
        )
        layer.addShape(.rectangle(rect1))
        layer.addShape(.rectangle(rect2))
        let innerGroup = ShapeGroup(name: "InnerGroup", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(
            name: "OuterGroup", shapeIDs: [rect2.id], children: [innerGroup])
        layer.groups.append(outerGroup)

        let doc = Document(layers: [layer])

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"OuterGroup\""))
        #expect(dsl.contains("group \"InnerGroup\""))
        #expect(dsl.contains("rectangle \"Inner\""))
        #expect(dsl.contains("rectangle \"Outer\""))
    }

    @Test func should_serialize_groups() {
        // given
        var layer = Layer(name: "Layer 1")
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "A"
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "B"
        )
        layer.addShape(.rectangle(rect1))
        layer.addShape(.rectangle(rect2))
        layer.groups.append(
            ShapeGroup(name: "Backend", shapeIDs: [rect1.id, rect2.id]))

        let doc = Document(layers: [layer])

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"Backend\""))
        #expect(dsl.contains("rectangle \"A\""))
        #expect(dsl.contains("rectangle \"B\""))
    }

    @Test func should_serialize_rectangle_with_float() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: true
        )
        doc.layers[0].shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains(" float"))
    }

    @Test func should_not_serialize_float_when_false() {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: false
        )
        doc.layers[0].shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(!dsl.contains(" float"))
    }

    @Test func should_roundtrip_float_property() throws {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: true
        )
        doc.layers[0].shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)
        let parsed = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let parsedRect) = parsed.layers[0].shapes[0] {
            #expect(parsedRect.float == true)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }
}
