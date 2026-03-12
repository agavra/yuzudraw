import Testing

@testable import YuzuDraw

struct DSLSerializerTests {
    @Test func should_serialize_simple_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 20, height: 5),
            strokeStyle: .single,
            label: "Server"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — uses "rect", omits default style "single"
        #expect(dsl.contains("rect \"Server\" at 5,3 size 20x5"))
        #expect(!dsl.contains("rectangle "))
        #expect(!dsl.contains("style single"))
    }

    @Test func should_serialize_arrow_with_label() {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 15, row: 7),
            end: GridPoint(column: 15, row: 15),
            label: "SQL",
            strokeStyle: .heavy
        )
        doc.addShape(.arrow(arrow))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("arrow from 15,7 to 15,15 style heavy label \"SQL\""))
    }

    @Test func should_serialize_arrow_with_multiline_label() {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 10, row: 5),
            end: GridPoint(column: 10, row: 15),
            label: "compact\nwhen full"
        )
        doc.addShape(.arrow(arrow))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("label \"compact\\nwhen full\""))
    }

    @Test func should_omit_default_arrow_style() {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 0, row: 0),
            end: GridPoint(column: 10, row: 0),
            strokeStyle: .single
        )
        doc.addShape(.arrow(arrow))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — default style omitted
        #expect(dsl.contains("arrow from 0,0 to 10,0"))
        #expect(!dsl.contains("style"))
    }

    @Test func should_serialize_rectangle_fill() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            strokeStyle: .single,
            fillMode: .character,
            fillCharacter: ".",
            label: "Filled"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("rect \"Filled\" at 1,1 size 8x4 fill character char \".\""))
    }

    @Test func should_serialize_rectangle_text_layout_settings() {
        // given
        var doc = Document()
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
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — uses noborder, bare textOnBorder, omits default halign/valign
        #expect(dsl.contains("noborder"))
        #expect(!dsl.contains("border hidden"))
        #expect(dsl.contains("halign left"))
        #expect(dsl.contains("valign top"))
        #expect(dsl.contains(" textOnBorder"))
        #expect(!dsl.contains("textOnBorder true"))
        #expect(!dsl.contains("textOnBorder false"))
        #expect(dsl.contains("padding 1,2,0,1"))
    }

    @Test func should_omit_default_text_layout_settings() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 3),
            label: "Default"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — defaults omitted
        #expect(!dsl.contains("style"))
        #expect(!dsl.contains("fill"))
        #expect(!dsl.contains("border"))
        #expect(!dsl.contains("halign"))
        #expect(!dsl.contains("valign"))
        #expect(!dsl.contains("textOnBorder"))
        #expect(!dsl.contains("padding"))
    }

    @Test func should_serialize_rectangle_visible_borders() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            visibleBorders: [.top, .left],
            label: "Sides"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("borders top,left"))
    }

    @Test func should_serialize_rectangle_dashed_border_settings() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 4),
            borderLineStyle: .dashed,
            borderDashLength: 3,
            borderGapLength: 2,
            label: "Dash"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("line dashed"))
        #expect(dsl.contains("dash 3"))
        #expect(dsl.contains("gap 2"))
    }

    @Test func should_serialize_rectangle_shadow_settings() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            label: "Note",
            hasShadow: true,
            shadowStyle: .full,
            shadowOffsetX: -2,
            shadowOffsetY: -3
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("shadow full"))
        #expect(dsl.contains("x -2"))
        #expect(dsl.contains("y -3"))
    }

    @Test func should_serialize_text_shape() {
        // given
        var doc = Document()
        let text = TextShape(
            origin: GridPoint(column: 40, row: 3),
            text: "Client App"
        )
        doc.addShape(.text(text))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("text \"Client App\" at 40,3"))
    }

    @Test func should_serialize_nested_groups() {
        // given
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
        let innerGroup = ShapeGroup(name: "InnerGroup", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(
            name: "OuterGroup", shapeIDs: [rect2.id], children: [innerGroup])

        let doc = Document(
            shapes: [.rectangle(rect1), .rectangle(rect2)],
            groups: [outerGroup]
        )

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"OuterGroup\""))
        #expect(dsl.contains("group \"InnerGroup\""))
        #expect(dsl.contains("rect \"Inner\""))
        #expect(dsl.contains("rect \"Outer\""))
    }

    @Test func should_serialize_groups() {
        // given
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
        let doc = Document(
            shapes: [.rectangle(rect1), .rectangle(rect2)],
            groups: [ShapeGroup(name: "Backend", shapeIDs: [rect1.id, rect2.id])]
        )

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("group \"Backend\""))
        #expect(dsl.contains("rect \"A\""))
        #expect(dsl.contains("rect \"B\""))
    }

    @Test func should_serialize_rectangle_with_float() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: true
        )
        doc.shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains(" float"))
    }

    @Test func should_not_serialize_float_when_false() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: false
        )
        doc.shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(!dsl.contains(" float"))
    }

    @Test func should_roundtrip_float_property() throws {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            float: true
        )
        doc.shapes.append(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)
        let parsed = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let parsedRect) = parsed.shapes[0] {
            #expect(parsedRect.float == true)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_serialize_rectangle_with_id() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            name: "srv1",
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 20, height: 5),
            label: "Server"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then
        #expect(dsl.contains("rect \"Server\" id srv1 at 5,3 size 20x5"))
    }

    @Test func should_serialize_arrow_endpoint_with_id() {
        // given
        var doc = Document()
        let rect = RectangleShape(
            name: "srv1",
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 3),
            label: "Server"
        )
        doc.addShape(.rectangle(rect))
        let arrow = ArrowShape(
            start: rect.attachmentPoint(for: .right),
            end: GridPoint(column: 20, row: 1),
            startAttachment: ArrowAttachment(shapeID: rect.id, side: .right)
        )
        doc.addShape(.arrow(arrow))

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — uses name (ID) for arrow endpoint
        #expect(dsl.contains("from \"srv1\".right"))
    }
}
