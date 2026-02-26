import Testing

@testable import AsciiAI

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
            #expect(box.borderStyle == .single)
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_parse_arrow_with_label() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              arrow from 15,7 to 15,15 label "SQL"
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .arrow(let arrow) = doc.layers[0].shapes[0] {
            #expect(arrow.start == GridPoint(column: 15, row: 7))
            #expect(arrow.end == GridPoint(column: 15, row: 15))
            #expect(arrow.label == "SQL")
        } else {
            Issue.record("Expected arrow shape")
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

    @Test func should_round_trip_through_dsl() throws {
        // given
        var doc = Document(layers: [Layer(name: "Layer 1")])
        doc.addShape(
            .box(
                BoxShape(
                    origin: GridPoint(column: 5, row: 3),
                    size: GridSize(width: 20, height: 5),
                    borderStyle: .double,
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
