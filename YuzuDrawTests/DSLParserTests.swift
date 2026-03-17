import Testing

@testable import YuzuDraw

struct DSLParserTests {
    @Test func should_parse_basic_rectangle() throws {
        let dsl = """
            layer "Main" visible
              rectangle "Server" at 5,3 size 20x5 style double
            """

        let doc = try DSLParser.parse(dsl)

        #expect(doc.shapes.count == 1)
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.label == "Server")
            #expect(rectangle.origin == GridPoint(column: 5, row: 3))
            #expect(rectangle.size == GridSize(width: 20, height: 5))
            #expect(rectangle.strokeStyle == .double)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_treat_keywords_inside_labels_as_string_content() throws {
        let dsl = """
            rect "append new SSTs at the start" id append at 5,1 size 16x5
            """

        let doc = try DSLParser.parse(dsl)

        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.label == "append new SSTs at the start")
            #expect(rectangle.name == "append")
            #expect(rectangle.origin == GridPoint(column: 5, row: 1))
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_auto_size_and_resolve_semantic_positions() throws {
        let dsl = """
            rect "Frontend" at 0,0
            rect "API" right-of "Frontend"
            rect "DB" below "API"
            """

        let doc = try DSLParser.parse(dsl)

        #expect(doc.shapes.count == 3)
        guard case .rectangle(let frontend) = doc.shapes[0],
              case .rectangle(let api) = doc.shapes[1],
              case .rectangle(let db) = doc.shapes[2]
        else {
            Issue.record("Expected rectangle shapes")
            return
        }

        #expect(frontend.size.width >= 10)
        #expect(api.origin.column == frontend.origin.column + frontend.size.width + 4)
        #expect(db.origin.row == api.origin.row + api.size.height + 2)
    }

    @Test func should_infer_arrow_attachments_from_rectangle_references() throws {
        let dsl = """
            rect "Frontend" at 0,0 size 14x3
            rect "API" at 20,0 size 14x3
            arrow from "Frontend" to "API" label "HTTP"
            """

        let doc = try DSLParser.parse(dsl)

        #expect(doc.shapes.count == 3)
        if case .arrow(let arrow) = doc.shapes[2] {
            #expect(arrow.label == "HTTP")
            #expect(arrow.startAttachment != nil)
            #expect(arrow.endAttachment != nil)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_groups_by_indentation() throws {
        let dsl = """
            group "Backend"
              rect "API" at 0,0 size 10x3
              rect "DB" at 20,0 size 10x3
            """

        let doc = try DSLParser.parse(dsl)

        #expect(doc.groups.count == 1)
        #expect(doc.groups[0].name == "Backend")
        #expect(doc.groups[0].shapeIDs.count == 2)
    }

    @Test func should_parse_text_and_pencil_shapes() throws {
        let dsl = """
            text "Client" at 40,3 textColor #FF0000
            pencil at 2,2 cells [0,0,"*";1,0,"*",#00FF00]
            """

        let doc = try DSLParser.parse(dsl)

        #expect(doc.shapes.count == 2)
        if case .text(let text) = doc.shapes[0] {
            #expect(text.text == "Client")
            #expect(text.origin == GridPoint(column: 40, row: 3))
        } else {
            Issue.record("Expected text shape")
        }

        if case .pencil(let pencil) = doc.shapes[1] {
            #expect(pencil.origin == GridPoint(column: 2, row: 2))
            #expect(pencil.cells.count == 2)
        } else {
            Issue.record("Expected pencil shape")
        }
    }

    @Test func should_round_trip_serializer_output() throws {
        var doc = Document()
        doc.addShape(
            .rectangle(
                RectangleShape(
                    name: "srv1",
                    origin: GridPoint(column: 5, row: 3),
                    size: GridSize(width: 20, height: 5),
                    strokeStyle: .double,
                    fillMode: .character,
                    fillCharacter: ".",
                    label: "DB",
                    float: true
                )))
        doc.addShape(
            .arrow(
                ArrowShape(
                    start: GridPoint(column: 10, row: 1),
                    end: GridPoint(column: 10, row: 3),
                    label: "SQL",
                    float: true
                )))

        let dsl = DSLSerializer.serialize(doc)
        let parsed = try DSLParser.parse(dsl)

        #expect(parsed.shapes.count == 2)
    }
}
