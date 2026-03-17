import Foundation
import Testing

@testable import YuzuDraw

@MainActor
struct EditorViewModelExportTests {
    @Test func should_export_selected_shapes_as_normalized_text() {
        // given
        var document = Document()
        let rectangle = RectangleShape(origin: GridPoint(column: 8, row: 6), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        let exported = viewModel.selectionOrCanvasPlainText()

        // then
        #expect(exported == "┌──┐\n│  │\n└──┘")
    }

    @Test func should_return_nil_when_no_shapes_selected_and_canvas_empty() {
        // given
        let viewModel = EditorViewModel(document: Document())

        // when
        let exported = viewModel.selectionOrCanvasPlainText()

        // then
        #expect(exported == nil)
    }

    @Test func should_paste_shapes_with_new_ids_offset_and_remapped_arrow_attachments() {
        // given
        var document = Document()
        let rectA = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rectB = RectangleShape(origin: GridPoint(column: 9, row: 0), size: GridSize(width: 4, height: 3))
        let arrow = ArrowShape(
            start: GridPoint(column: 3, row: 1),
            end: GridPoint(column: 9, row: 1),
            startAttachment: ArrowAttachment(shapeID: rectA.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: rectB.id, side: .left)
        )
        document.addShape(.rectangle(rectA))
        document.addShape(.rectangle(rectB))
        document.addShape(.arrow(arrow))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectA.id, rectB.id, arrow.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 6)

        let originalIDs: Set<UUID> = [rectA.id, rectB.id, arrow.id]
        let pastedShapes = viewModel.document.shapes.filter { !originalIDs.contains($0.id) }
        #expect(pastedShapes.count == 3)

        let pastedRects = pastedShapes.compactMap { shape -> RectangleShape? in
            guard case .rectangle(let rectangle) = shape else { return nil }
            return rectangle
        }
        #expect(pastedRects.count == 2)
        let pastedRectIDs = Set(pastedRects.map { $0.id })
        #expect(pastedRectIDs.count == 2)
        #expect(pastedRectIDs.isDisjoint(with: [rectA.id, rectB.id]))
        #expect(pastedRects.contains { $0.origin == GridPoint(column: 2, row: 1) })
        #expect(pastedRects.contains { $0.origin == GridPoint(column: 11, row: 1) })

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
        #expect(pastedArrow.startAttachment?.shapeID != rectA.id)
        #expect(pastedArrow.endAttachment?.shapeID != rectB.id)
        #expect(pastedArrow.startAttachment.map { pastedRectIDs.contains($0.shapeID) } == true)
        #expect(pastedArrow.endAttachment.map { pastedRectIDs.contains($0.shapeID) } == true)
    }

    @Test func should_increase_offset_on_consecutive_pastes_of_same_payload() {
        // given
        var document = Document()
        let text = TextShape(origin: GridPoint(column: 5, row: 5), text: "A")
        document.addShape(.text(text))
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
        let pastedTexts = viewModel.document.shapes.compactMap { shape -> TextShape? in
            guard case .text(let pasted) = shape, pasted.id != text.id else { return nil }
            return pasted
        }
        #expect(pastedTexts.count == 2)
        #expect(pastedTexts.contains { $0.origin == GridPoint(column: 7, row: 6) })
        #expect(pastedTexts.contains { $0.origin == GridPoint(column: 9, row: 7) })
    }

    @Test func should_paste_shapes_into_same_group_they_were_copied_from() {
        // given
        let rectA = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rectB = RectangleShape(origin: GridPoint(column: 8, row: 0), size: GridSize(width: 4, height: 3))
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rectA.id, rectB.id])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB)],
            groups: [group]
        )

        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectA.id, rectB.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 4)

        let pastedIDs = Set(viewModel.selectedShapeIDs)
        #expect(pastedIDs.count == 2)
        #expect(pastedIDs.isDisjoint(with: [rectA.id, rectB.id]))

        guard let pastedIntoGroup = viewModel.document.groups.first(where: { $0.id == group.id }) else {
            Issue.record("Expected original group to exist")
            return
        }
        #expect(Set(pastedIntoGroup.shapeIDs).isSuperset(of: pastedIDs))
    }

    @Test func should_paste_shapes_into_top_most_selected_group_when_multiple_groups_selected() {
        // given
        let rectA = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rectB = RectangleShape(origin: GridPoint(column: 8, row: 0), size: GridSize(width: 4, height: 3))
        let topGroup = ShapeGroup(name: "Group 1", shapeIDs: [rectA.id])
        let secondGroup = ShapeGroup(name: "Group 2", shapeIDs: [rectB.id])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB)],
            groups: [topGroup, secondGroup]
        )

        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectA.id, rectB.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 4)

        let pastedIDs = Set(viewModel.selectedShapeIDs)
        #expect(pastedIDs.count == 2)

        guard let pastedTopGroup = viewModel.document.groups.first(where: { $0.id == topGroup.id }) else {
            Issue.record("Expected top-most group to exist")
            return
        }
        guard let untouchedSecondGroup = viewModel.document.groups.first(where: { $0.id == secondGroup.id }) else {
            Issue.record("Expected second group to exist")
            return
        }

        #expect(Set(pastedTopGroup.shapeIDs).isSuperset(of: pastedIDs))
        #expect(Set(untouchedSecondGroup.shapeIDs).isDisjoint(with: pastedIDs))
    }

    @Test func should_copy_selected_shapes_as_normalized_plain_text() {
        // given
        var document = Document()
        let rectangle = RectangleShape(origin: GridPoint(column: 8, row: 6), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        let text = viewModel.selectionOrCanvasPlainText()

        // then
        #expect(text == "┌──┐\n│  │\n└──┘")
    }

    @Test func should_export_selected_shapes_as_dsl() {
        // given
        var document = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 8, row: 6),
            size: GridSize(width: 4, height: 3),
            label: "API"
        )
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        let dsl = viewModel.selectionDSL()

        // then
        #expect(dsl == #"  rect "API" at 8,6 size 4x3"#)
    }

    @Test func should_export_selected_shapes_as_dsl_preserving_selected_group_structure() {
        // given
        let rectA = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 4, height: 3),
            label: "A"
        )
        let rectB = RectangleShape(
            origin: GridPoint(column: 8, row: 0),
            size: GridSize(width: 4, height: 3),
            label: "B"
        )
        let rectC = RectangleShape(
            origin: GridPoint(column: 16, row: 0),
            size: GridSize(width: 4, height: 3),
            label: "C"
        )
        let nested = ShapeGroup(name: "Nested", shapeIDs: [rectB.id])
        let root = ShapeGroup(name: "Root", shapeIDs: [rectA.id], children: [nested])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB), .rectangle(rectC)],
            groups: [root]
        )
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectA.id, rectB.id]

        // when
        let dsl = viewModel.selectionDSL()

        // then
        #expect(
            dsl
                == """
                  group "Root"
                    group "Nested"
                      rect "B" at 8,0 size 4x3
                    rect "A" at 0,0 size 4x3
                """
        )
    }

    @Test func should_export_partial_group_selection_as_nested_dsl_subset() {
        // given
        let rectA = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 4, height: 3),
            label: "A"
        )
        let rectB = RectangleShape(
            origin: GridPoint(column: 8, row: 0),
            size: GridSize(width: 4, height: 3),
            label: "B"
        )
        let root = ShapeGroup(name: "Root", shapeIDs: [rectA.id, rectB.id])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB)],
            groups: [root]
        )
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectB.id]

        // when
        let dsl = viewModel.selectionDSL()

        // then
        #expect(
            dsl
                == """
                  group "Root"
                    rect "B" at 8,0 size 4x3
                """
        )
    }

    @Test func should_include_shadow_in_plain_text_copy() {
        // given
        var document = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 5),
            size: GridSize(width: 4, height: 3),
            hasShadow: true,
            shadowStyle: .light,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        let text = viewModel.selectionOrCanvasPlainText()

        // then
        #expect(text == "┌──┐ \n│  │░\n└──┘░\n ░░░░")
    }

    @Test func should_delete_selected_shapes() {
        // given
        var document = Document()
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 8, row: 0), size: GridSize(width: 4, height: 3))
        document.addShape(.rectangle(rect1))
        document.addShape(.rectangle(rect2))
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rect1.id]

        // when
        viewModel.deleteSelectedShapes()

        // then
        #expect(viewModel.document.findShape(id: rect1.id) == nil)
        #expect(viewModel.document.findShape(id: rect2.id) != nil)
        #expect(viewModel.selectedShapeIDs.isEmpty)
    }
}
