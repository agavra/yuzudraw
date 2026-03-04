import Foundation
import Testing

@testable import YuzuDraw

struct DocumentCodableTests {
    @Test func should_round_trip_document_with_rectangle() throws {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5),
            strokeStyle: .double,
            label: "Server"
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        #expect(decoded.layers.count == 1)
        #expect(decoded.layers[0].shapes.count == 1)
        if case .rectangle(let decodedRect) = decoded.layers[0].shapes[0] {
            #expect(decodedRect.origin == rectangle.origin)
            #expect(decodedRect.size == rectangle.size)
            #expect(decodedRect.strokeStyle == .double)
            #expect(decodedRect.label == "Server")
            #expect(decodedRect.hasBorder)
            #expect(decodedRect.visibleBorders == Set(RectangleBorderSide.allCases))
            #expect(decodedRect.borderLineStyle == .solid)
            #expect(decodedRect.borderDashLength == 1)
            #expect(decodedRect.borderGapLength == 1)
            #expect(decodedRect.textHorizontalAlignment == .center)
            #expect(decodedRect.textVerticalAlignment == .middle)
            #expect(decodedRect.allowTextOnBorder == false)
            #expect(decodedRect.hasShadow == false)
            #expect(decodedRect.shadowStyle == .light)
            #expect(decodedRect.shadowOffsetX == 1)
            #expect(decodedRect.shadowOffsetY == 1)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_round_trip_document_with_arrow() throws {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 10, row: 5),
            label: "HTTP",
            bendDirection: .verticalFirst,
            startAttachment: ArrowAttachment(shapeID: UUID(), side: .right),
            endAttachment: ArrowAttachment(shapeID: UUID(), side: .left)
        )
        doc.addShape(.arrow(arrow), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .arrow(let decodedArrow) = decoded.layers[0].shapes[0] {
            #expect(decodedArrow.start == arrow.start)
            #expect(decodedArrow.end == arrow.end)
            #expect(decodedArrow.label == "HTTP")
            #expect(decodedArrow.bendDirection == .verticalFirst)
            #expect(decodedArrow.startAttachment == arrow.startAttachment)
            #expect(decodedArrow.endAttachment == arrow.endAttachment)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_decode_legacy_arrow_json_without_attachment_fields() throws {
        // given
        let data = #"""
            {
              "canvasSize" : {
                "height" : 40,
                "width" : 80
              },
              "layers" : [
                {
                  "groups" : [],
                  "id" : "A8F4D27A-B62D-4752-9609-B01640D9A3E3",
                  "isLocked" : false,
                  "isVisible" : true,
                  "name" : "Layer 1",
                  "shapes" : [
                    {
                      "end" : {
                        "column" : 10,
                        "row" : 5
                      },
                      "id" : "B8F4D27A-B62D-4752-9609-B01640D9A3E3",
                      "label" : "HTTP",
                      "start" : {
                        "column" : 1,
                        "row" : 1
                      },
                      "type" : "arrow"
                    }
                  ]
                }
              ]
            }
            """#.data(using: .utf8)!

        // when
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .arrow(let arrow) = decoded.layers[0].shapes[0] {
            #expect(arrow.bendDirection == .horizontalFirst)
            #expect(arrow.strokeStyle == .single)
            #expect(arrow.startAttachment == nil)
            #expect(arrow.endAttachment == nil)
        } else {
            Issue.record("Expected arrow shape")
        }
    }

    @Test func should_decode_legacy_rectangle_json_with_borderStyle_key() throws {
        // given
        let data = #"""
            {
              "canvasSize": { "width": 80, "height": 24 },
              "layers": [
                {
                  "id": "A8F4D27A-B62D-4752-9609-B01640D9A3E3",
                  "name": "Layer 1",
                  "isVisible": true,
                  "isLocked": false,
                  "groups": [],
                  "shapes": [
                    {
                      "type": "box",
                      "id": "B8F4D27A-B62D-4752-9609-B01640D9A3E3",
                      "origin": { "column": 2, "row": 2 },
                      "size": { "width": 8, "height": 4 },
                      "borderStyle": "double",
                      "label": "Legacy"
                    }
                  ]
                }
              ]
            }
            """#.data(using: .utf8)!

        // when
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .rectangle(let rectangle) = decoded.layers[0].shapes[0] {
            #expect(rectangle.strokeStyle == .double)
            #expect(rectangle.hasBorder)
            #expect(rectangle.visibleBorders == Set(RectangleBorderSide.allCases))
            #expect(rectangle.borderLineStyle == .solid)
            #expect(rectangle.borderDashLength == 1)
            #expect(rectangle.borderGapLength == 1)
            #expect(rectangle.fillMode == .transparent)
            #expect(rectangle.fillCharacter == " ")
            #expect(rectangle.textHorizontalAlignment == .center)
            #expect(rectangle.textVerticalAlignment == .middle)
            #expect(rectangle.allowTextOnBorder == false)
            #expect(rectangle.textPaddingLeft == 0)
            #expect(rectangle.textPaddingRight == 0)
            #expect(rectangle.textPaddingTop == 0)
            #expect(rectangle.textPaddingBottom == 0)
            #expect(rectangle.hasShadow == false)
            #expect(rectangle.shadowStyle == .light)
            #expect(rectangle.shadowOffsetX == 1)
            #expect(rectangle.shadowOffsetY == 1)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_round_trip_document_with_text() throws {
        // given
        var doc = Document()
        let text = TextShape(
            origin: GridPoint(column: 0, row: 0),
            text: "Hello\nWorld"
        )
        doc.addShape(.text(text), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .text(let decodedText) = decoded.layers[0].shapes[0] {
            #expect(decodedText.origin == text.origin)
            #expect(decodedText.text == "Hello\nWorld")
        } else {
            Issue.record("Expected text shape")
        }
    }

    @Test func should_round_trip_rectangle_visible_borders() throws {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 4),
            visibleBorders: [.top, .right]
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .rectangle(let decodedRect) = decoded.layers[0].shapes[0] {
            #expect(decodedRect.visibleBorders == [.top, .right])
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_round_trip_rectangle_dashed_border_settings() throws {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 3, row: 3),
            size: GridSize(width: 10, height: 5),
            borderLineStyle: .dashed,
            borderDashLength: 3,
            borderGapLength: 2
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .rectangle(let decodedRect) = decoded.layers[0].shapes[0] {
            #expect(decodedRect.borderLineStyle == .dashed)
            #expect(decodedRect.borderDashLength == 3)
            #expect(decodedRect.borderGapLength == 2)
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_round_trip_shape_panel_names() throws {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            name: "Gateway",
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 6, height: 4),
            label: ""
        )
        doc.addShape(.rectangle(rectangle), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        if case .rectangle(let decodedRect) = decoded.layers[0].shapes[0] {
            #expect(decodedRect.name == "Gateway")
            #expect(decoded.layers[0].shapes[0].displayName == "Gateway")
            #expect(decodedRect.label == "")
        } else {
            Issue.record("Expected rectangle shape")
        }
    }

    @Test func should_round_trip_multi_layer_document() throws {
        // given
        var doc = Document(layers: [
            Layer(name: "Layer 1"),
            Layer(name: "Layer 2", isVisible: false, isLocked: true),
        ])
        doc.addShape(
            .rectangle(
                RectangleShape(
                    origin: GridPoint(column: 0, row: 0),
                    size: GridSize(width: 5, height: 3)
                )), toLayerAt: 0)
        doc.addShape(
            .text(TextShape(origin: GridPoint(column: 10, row: 10), text: "Hi")),
            toLayerAt: 1
        )

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        #expect(decoded.layers.count == 2)
        #expect(decoded.layers[0].name == "Layer 1")
        #expect(decoded.layers[1].name == "Layer 2")
        #expect(decoded.layers[1].isVisible == false)
        #expect(decoded.layers[1].isLocked == true)
        #expect(decoded.layers[0].shapes.count == 1)
        #expect(decoded.layers[1].shapes.count == 1)
    }
}
