import Testing

@testable import YuzuDraw

struct DSLParserTests {
    @Test func should_parse_simple_document() throws {
        // given
        let dsl = """
            layer "Infrastructure" visible
              box "Server" at 5,3 size 20x5 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.layers.count == 1)
        #expect(doc.layers[0].name == "Infrastructure")
        #expect(doc.layers[0].isVisible)
        #expect(doc.layers[0].shapes.count == 1)
        if case .box(let box) = doc.layers[0].shapes[0] {
            #expect(box.label == "Server")
            #expect(box.origin == GridPoint(column: 5, row: 3))
            #expect(box.size == GridSize(width: 20, height: 5))
            #expect(box.strokeStyle == .single)
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_parse_arrow_with_label() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              arrow from 15,7 to 15,15 style double label "SQL"
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .arrow(let arrow) = doc.layers[0].shapes[0] {
            #expect(arrow.start == GridPoint(column: 15, row: 7))
            #expect(arrow.end == GridPoint(column: 15, row: 15))
            #expect(arrow.label == "SQL")
            #expect(arrow.strokeStyle == .double)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_box_with_solid_fill() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              box "Server" at 5,3 size 20x5 style single fill solid char "."
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .box(let box) = doc.layers[0].shapes[0] {
            #expect(box.fillMode == .solid)
            #expect(box.fillCharacter == ".")
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_parse_box_text_layout_settings() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              box "Server" at 5,3 size 20x5 style single fill transparent border hidden halign right valign bottom textOnBorder true padding 1,2,3,4
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .box(let box) = doc.layers[0].shapes[0] {
            #expect(box.hasBorder == false)
            #expect(box.textHorizontalAlignment == .right)
            #expect(box.textVerticalAlignment == .bottom)
            #expect(box.allowTextOnBorder)
            #expect(box.textPaddingLeft == 1)
            #expect(box.textPaddingRight == 2)
            #expect(box.textPaddingTop == 3)
            #expect(box.textPaddingBottom == 4)
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_parse_box_shadow_settings() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              box "Server" at 5,3 size 20x5 style single fill transparent border visible halign center valign middle textOnBorder false padding 0,0,0,0 shadow dark x 2 y -3
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .box(let box) = doc.layers[0].shapes[0] {
            #expect(box.hasShadow)
            #expect(box.shadowStyle == .dark)
            #expect(box.shadowOffsetX == 2)
            #expect(box.shadowOffsetY == -3)
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_parse_text_shape() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              text "Client App" at 40,3
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .text(let text) = doc.layers[0].shapes[0] {
            #expect(text.text == "Client App")
            #expect(text.origin == GridPoint(column: 40, row: 3))
        } else {
            Issue.record("Expected text shape")
        }
    }

    @Test func should_parse_hidden_locked_layer() throws {
        // given
        let dsl = """
            layer "Background" hidden locked
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.layers[0].isVisible == false)
        #expect(doc.layers[0].isLocked == true)
    }

    @Test func should_parse_groups() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              group "Backend"
                box "A" at 0,0 size 5x3 style single
                box "B" at 10,0 size 5x3 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.layers[0].groups.count == 1)
        #expect(doc.layers[0].groups[0].name == "Backend")
        #expect(doc.layers[0].groups[0].shapeIDs.count == 2)
        #expect(doc.layers[0].shapes.count == 2)
    }

    @Test func should_parse_nested_groups() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              group "Outer"
                group "Inner"
                  box "A" at 0,0 size 5x3 style single
                box "B" at 10,0 size 5x3 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.layers[0].groups.count == 1)
        #expect(doc.layers[0].groups[0].name == "Outer")
        #expect(doc.layers[0].groups[0].children.count == 1)
        #expect(doc.layers[0].groups[0].children[0].name == "Inner")
        #expect(doc.layers[0].groups[0].children[0].shapeIDs.count == 1)
        #expect(doc.layers[0].groups[0].shapeIDs.count == 1)
        #expect(doc.layers[0].shapes.count == 2)
    }

    @Test func should_round_trip_through_dsl() throws {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        doc.addShape(
            .box(
                BoxShape(
                    origin: GridPoint(column: 5, row: 3),
                    size: GridSize(width: 20, height: 5),
                    strokeStyle: .double,
                    label: "DB"
                )), toLayerAt: 0)
        doc.addShape(
            .arrow(
                ArrowShape(
                    start: GridPoint(column: 10, row: 1),
                    end: GridPoint(column: 10, row: 3),
                    label: "SQL"
                )), toLayerAt: 0)

        // when
        let dsl = DSLSerializer.serialize(doc)
        let parsed = try DSLParser.parse(dsl)

        // then
        #expect(parsed.layers.count == 1)
        #expect(parsed.layers[0].shapes.count == 2)
    }

    @Test func should_return_default_document_for_empty_input() throws {
        // given
        let dsl = ""

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.layers.count == 1)
        #expect(doc.layers[0].name == "Layer 1")
    }
}
