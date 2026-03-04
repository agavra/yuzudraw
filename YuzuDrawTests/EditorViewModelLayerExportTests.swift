import Foundation
import Testing

@testable import YuzuDraw

@MainActor
struct EditorViewModelLayerExportTests {
    @Test func should_export_selected_layer_as_normalized_text() {
        // given
        let layer = Layer(
            name: "Layer 1",
            shapes: [
                .box(BoxShape(origin: GridPoint(column: 8, row: 6), size: GridSize(width: 4, height: 3)))
            ]
        )
        let viewModel = EditorViewModel(document: Document(layers: [layer]))
        viewModel.selectedLayerID = layer.id

        // when
        let exported = viewModel.selectedLayerPlainText()

        // then
        #expect(exported == "┌──┐\n│  │\n└──┘")
    }

    @Test func should_return_nil_when_selected_layer_has_no_shapes() {
        // given
        let layer = Layer(name: "Empty Layer")
        let viewModel = EditorViewModel(document: Document(layers: [layer]))
        viewModel.selectedLayerID = layer.id

        // when
        let exported = viewModel.selectedLayerPlainText()

        // then
        #expect(exported == nil)
    }

    @Test func should_paste_shapes_with_new_ids_offset_and_remapped_arrow_attachments() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let boxA = BoxShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let boxB = BoxShape(origin: GridPoint(column: 9, row: 0), size: GridSize(width: 4, height: 3))
        let arrow = ArrowShape(
            start: GridPoint(column: 3, row: 1),
            end: GridPoint(column: 9, row: 1),
            startAttachment: ArrowAttachment(shapeID: boxA.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: boxB.id, side: .left)
        )
        document.addShape(.box(boxA), toLayerAt: 0)
        document.addShape(.box(boxB), toLayerAt: 0)
        document.addShape(.arrow(arrow), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [boxA.id, boxB.id, arrow.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.layers[0].shapes.count == 6)

        let originalIDs: Set<UUID> = [boxA.id, boxB.id, arrow.id]
        let pastedShapes = viewModel.document.layers[0].shapes.filter { !originalIDs.contains($0.id) }
        #expect(pastedShapes.count == 3)

        let pastedBoxes = pastedShapes.compactMap { shape -> BoxShape? in
            guard case .box(let box) = shape else { return nil }
            return box
        }
        #expect(pastedBoxes.count == 2)
        let pastedBoxIDs = Set(pastedBoxes.map { $0.id })
        #expect(pastedBoxIDs.count == 2)
        #expect(pastedBoxIDs.isDisjoint(with: [boxA.id, boxB.id]))
        #expect(pastedBoxes.contains { $0.origin == GridPoint(column: 2, row: 1) })
        #expect(pastedBoxes.contains { $0.origin == GridPoint(column: 11, row: 1) })

        guard
            let pastedArrow = pastedShapes.compactMap({ shape -> ArrowShape? in
                guard case .arrow(let arrow) = shape else { return nil }
                return arrow
            }).first
        else {
            Issue.record("Expected pasted arrow")
            return
        }

        #expect(pastedArrow.start == GridPoint(column: 5, row: 2))
        #expect(pastedArrow.end == GridPoint(column: 11, row: 2))
        #expect(pastedArrow.startAttachment != nil)
        #expect(pastedArrow.endAttachment != nil)
        #expect(pastedArrow.startAttachment?.shapeID != boxA.id)
        #expect(pastedArrow.endAttachment?.shapeID != boxB.id)
        #expect(pastedArrow.startAttachment.map { pastedBoxIDs.contains($0.shapeID) } == true)
        #expect(pastedArrow.endAttachment.map { pastedBoxIDs.contains($0.shapeID) } == true)
    }

    @Test func should_increase_offset_on_consecutive_pastes_of_same_payload() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let text = TextShape(origin: GridPoint(column: 5, row: 5), text: "A")
        document.addShape(.text(text), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [text.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        _ = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)
        _ = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        let pastedTexts = viewModel.document.layers[0].shapes.compactMap { shape -> TextShape? in
            guard case .text(let pasted) = shape, pasted.id != text.id else { return nil }
            return pasted
        }
        #expect(pastedTexts.count == 2)
        #expect(pastedTexts.contains { $0.origin == GridPoint(column: 7, row: 6) })
        #expect(pastedTexts.contains { $0.origin == GridPoint(column: 9, row: 7) })
    }

    @Test func should_copy_selected_shapes_as_normalized_plain_text() {
        // given
        var document = Document(layers: [Layer(name: "Layer 1")])
        let box = BoxShape(origin: GridPoint(column: 8, row: 6), size: GridSize(width: 4, height: 3))
        document.addShape(.box(box), toLayerAt: 0)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [box.id]

        // when
        let text = viewModel.selectionOrCanvasPlainText()

        // then
        #expect(text == "┌──┐\n│  │\n└──┘")
    }
}
