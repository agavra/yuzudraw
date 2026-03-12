import Testing

@testable import YuzuDraw

struct DSLParserTests {
    @Test func should_parse_simple_document() throws {
        // given
        let dsl = """
            layer "Infrastructure" visible
              rectangle "Server" at 5,3 size 20x5 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.shapes.count == 1)
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.label == "Server")
            #expect(rectangle.origin == GridPoint(column: 5, row: 3))
            #expect(rectangle.size == GridSize(width: 20, height: 5))
            #expect(rectangle.strokeStyle == .single)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rect_prefix() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rect "Server" at 5,3 size 20x5
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.label == "Server")
            #expect(rectangle.origin == GridPoint(column: 5, row: 3))
            #expect(rectangle.size == GridSize(width: 20, height: 5))
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rect_with_id() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rect "Server" id srv1 at 5,3 size 20x5
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.name == "srv1")
            #expect(rectangle.label == "Server")
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_noborder() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rect "Server" at 5,3 size 20x5 noborder
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.hasBorder == false)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_bare_textOnBorder() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rect "Server" at 5,3 size 20x5 textOnBorder
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.allowTextOnBorder == true)
        } else {
            Issue.record("Expected rectangle shape")
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
        if case .arrow(let arrow) = doc.shapes[0] {
            #expect(arrow.start == GridPoint(column: 15, row: 7))
            #expect(arrow.end == GridPoint(column: 15, row: 15))
            #expect(arrow.label == "SQL")
            #expect(arrow.strokeStyle == .double)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_arrow_with_multiline_label() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              arrow from 10,5 to 10,15 label "compact\\nwhen full"
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .arrow(let arrow) = doc.shapes[0] {
            #expect(arrow.label == "compact\nwhen full")
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_rectangle_with_solid_fill() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Server" at 5,3 size 20x5 style single fill solid char "."
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.fillMode == .character)
            #expect(rectangle.fillCharacter == ".")
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rectangle_text_layout_settings() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Server" at 5,3 size 20x5 style single fill transparent border hidden halign right valign bottom textOnBorder true padding 1,2,3,4
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.hasBorder == false)
            #expect(rectangle.textHorizontalAlignment == .right)
            #expect(rectangle.textVerticalAlignment == .bottom)
            #expect(rectangle.allowTextOnBorder)
            #expect(rectangle.textPaddingLeft == 1)
            #expect(rectangle.textPaddingRight == 2)
            #expect(rectangle.textPaddingTop == 3)
            #expect(rectangle.textPaddingBottom == 4)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rectangle_shadow_settings() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Server" at 5,3 size 20x5 style single fill transparent border visible halign center valign middle textOnBorder false padding 0,0,0,0 shadow dark x 2 y -3
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.hasShadow)
            #expect(rectangle.shadowStyle == .dark)
            #expect(rectangle.shadowOffsetX == 2)
            #expect(rectangle.shadowOffsetY == -3)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rectangle_visible_borders() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Server" at 5,3 size 20x5 style single border visible borders top,left
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.visibleBorders == [.top, .left])
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rectangle_dashed_border_settings() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Server" at 5,3 size 20x5 style single border visible line dashed dash 3 gap 2
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.borderLineStyle == .dashed)
            #expect(rectangle.borderDashLength == 3)
            #expect(rectangle.borderGapLength == 2)
        } else {
            Issue.record("Expected rectangle shape")
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
        if case .text(let text) = doc.shapes[0] {
            #expect(text.text == "Client App")
            #expect(text.origin == GridPoint(column: 40, row: 3))
        } else {
            Issue.record("Expected text shape")
        }
    }

    @Test func should_parse_hidden_locked_layer_line() throws {
        // given — layer lines are now ignored by the parser, but should not cause errors
        let dsl = """
            layer "Background" hidden locked
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.shapes.isEmpty)
    }

    @Test func should_parse_groups() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              group "Backend"
                rectangle "A" at 0,0 size 5x3 style single
                rectangle "B" at 10,0 size 5x3 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.groups.count == 1)
        #expect(doc.groups[0].name == "Backend")
        #expect(doc.groups[0].shapeIDs.count == 2)
        #expect(doc.shapes.count == 2)
    }

    @Test func should_parse_nested_groups() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              group "Outer"
                group "Inner"
                  rectangle "A" at 0,0 size 5x3 style single
                rectangle "B" at 10,0 size 5x3 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.groups.count == 1)
        #expect(doc.groups[0].name == "Outer")
        #expect(doc.groups[0].children.count == 1)
        #expect(doc.groups[0].children[0].name == "Inner")
        #expect(doc.groups[0].children[0].shapeIDs.count == 1)
        #expect(doc.groups[0].shapeIDs.count == 1)
        #expect(doc.shapes.count == 2)
    }

    @Test func should_round_trip_through_dsl() throws {
        // given
        var doc = Document()
        doc.addShape(
            .rectangle(
                RectangleShape(
                    origin: GridPoint(column: 5, row: 3),
                    size: GridSize(width: 20, height: 5),
                    strokeStyle: .double,
                    label: "DB"
                )))
        doc.addShape(
            .arrow(
                ArrowShape(
                    start: GridPoint(column: 10, row: 1),
                    end: GridPoint(column: 10, row: 3),
                    label: "SQL"
                )))

        // when
        let dsl = DSLSerializer.serialize(doc)
        let parsed = try DSLParser.parse(dsl)

        // then
        #expect(parsed.shapes.count == 2)
    }

    @Test func should_return_default_document_for_empty_input() throws {
        // given
        let dsl = ""

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.shapes.isEmpty)
    }

    @Test func should_parse_rectangle_with_float() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Box" at 5,3 size 20x5 style single float
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.float == true)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_rectangle_without_float_defaults_false() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rectangle "Box" at 5,3 size 20x5 style single
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .rectangle(let rectangle) = doc.shapes[0] {
            #expect(rectangle.float == false)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_parse_arrow_with_float() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              arrow from 0,0 to 10,0 style single float
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .arrow(let arrow) = doc.shapes[0] {
            #expect(arrow.float == true)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_compact_syntax_end_to_end() throws {
        // given — compact syntax with auto-sizing, relative positions, arrow inference
        let dsl = """
            layer "Diagram" visible
              rect "Frontend" style rounded
              rect "API" below "Frontend"
              rect "Database" below "API" style double
              arrow from "Frontend" to "API" label "HTTP"
              arrow from "API" to "Database" label "SQL"
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        #expect(doc.shapes.count == 5)
        if case .rectangle(let frontend) = doc.shapes[0] {
            #expect(frontend.label == "Frontend")
            #expect(frontend.strokeStyle == .rounded)
        } else {
            Issue.record("Expected rectangle shape")
        }
        if case .rectangle(let api) = doc.shapes[1] {
            #expect(api.label == "API")
            #expect(api.origin.row > 0)  // should be below Frontend
        } else {
            Issue.record("Expected rectangle shape")
        }
        if case .arrow(let arrow) = doc.shapes[3] {
            #expect(arrow.label == "HTTP")
            #expect(arrow.startAttachment != nil)
            #expect(arrow.endAttachment != nil)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_parse_rect_with_id_and_find_by_name() throws {
        // given
        let dsl = """
            layer "Layer 1" visible
              rect "Server" id srv1 at 0,0 size 14x3
              rect "Server" id srv2 at 20,0 size 14x3
              arrow from "srv1".right to "srv2".left
            """

        // when
        let doc = try DSLParser.parse(dsl)

        // then
        if case .arrow(let arrow) = doc.shapes[2] {
            #expect(arrow.startAttachment != nil)
            #expect(arrow.endAttachment != nil)
        } else {
            Issue.record("Expected arrow shape")
        }
    }
}
