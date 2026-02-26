import Foundation
import Testing

@testable import AsciiAI

struct DocumentCodableTests {
    @Test func should_round_trip_document_with_box() throws {
        // given
        var doc = Document()
        let box = BoxShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 5),
            borderStyle: .double,
            label: "Server"
        )
        doc.addShape(.box(box), toLayerAt: 0)

        // when
        let data = try DocumentCodable.encode(doc)
        let decoded = try DocumentCodable.decode(from: data)

        // then
        #expect(decoded.layers.count == 1)
        #expect(decoded.layers[0].shapes.count == 1)
        if case .box(let decodedBox) = decoded.layers[0].shapes[0] {
            #expect(decodedBox.origin == box.origin)
            #expect(decodedBox.size == box.size)
            #expect(decodedBox.borderStyle == .double)
            #expect(decodedBox.label == "Server")
        } else {
            Issue.record("Expected box shape")
        }
    }

    @Test func should_round_trip_document_with_arrow() throws {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 1, row: 1),
            end: GridPoint(column: 10, row: 5),
            label: "HTTP"
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
        } else {
            Issue.record("Expected arrow shape")
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

    @Test func should_round_trip_multi_layer_document() throws {
        // given
        var doc = Document(layers: [
            Layer(name: "Layer 1"),
            Layer(name: "Layer 2", isVisible: false, isLocked: true),
        ])
        doc.addShape(
            .box(
                BoxShape(
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
