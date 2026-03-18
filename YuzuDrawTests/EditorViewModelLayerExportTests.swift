import AppKit
import Foundation
import Testing

@testable import YuzuDraw

@MainActor
private final class TestClipboardClient: ClipboardClient {
    var dataValues: [NSPasteboard.PasteboardType: Data] = [:]
    var stringValues: [NSPasteboard.PasteboardType: String] = [:]

    func clearContents() {
        dataValues.removeAll()
        stringValues.removeAll()
    }

    func setData(_ data: Data, forType type: NSPasteboard.PasteboardType) {
        dataValues[type] = data
    }

    func data(forType type: NSPasteboard.PasteboardType) -> Data? {
        dataValues[type]
    }

    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) {
        stringValues[type] = string
    }

    func string(forType type: NSPasteboard.PasteboardType) -> String? {
        stringValues[type]
    }

    func writeItem(data: Data, dataType: NSPasteboard.PasteboardType, string: String, stringType: NSPasteboard.PasteboardType) {
        clearContents()
        dataValues[dataType] = data
        stringValues[stringType] = string
    }
}

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

    @Test func should_copy_complex_grouped_selection_with_fake_clipboard_and_paste_with_remapped_ids_and_offsets() {
        // given
        let clipboard = TestClipboardClient()
        let service = RectangleShape(
            origin: GridPoint(column: 10, row: 5),
            size: GridSize(width: 14, height: 5),
            strokeStyle: .double,
            label: "Service",
            hasShadow: true,
            shadowStyle: .light,
            shadowOffsetX: 1,
            shadowOffsetY: 1
        )
        let database = RectangleShape(
            origin: GridPoint(column: 34, row: 6),
            size: GridSize(width: 12, height: 5),
            strokeStyle: .rounded,
            label: "DB"
        )
        let note = TextShape(
            origin: GridPoint(column: 13, row: 14),
            text: "sync\nnightly"
        )
        let arrow = ArrowShape(
            start: service.attachmentPoint(for: .right),
            end: database.attachmentPoint(for: .left),
            label: "events",
            strokeStyle: .heavy,
            startAttachment: ArrowAttachment(shapeID: service.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: database.id, side: .left)
        )
        let outside = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            label: "Outside"
        )
        let copiedGroup = ShapeGroup(
            name: "Subsystem",
            shapeIDs: [service.id, database.id, arrow.id, note.id]
        )
        let rootGroup = ShapeGroup(
            name: "Root",
            shapeIDs: [outside.id],
            children: [copiedGroup]
        )
        let document = Document(
            shapes: [
                .rectangle(outside),
                .rectangle(service),
                .rectangle(database),
                .arrow(arrow),
                .text(note),
            ],
            groups: [rootGroup]
        )
        let viewModel = EditorViewModel(document: document, clipboardClient: clipboard)
        viewModel.selectedShapeIDs = [service.id, database.id, arrow.id, note.id]

        let originalSelectionText = viewModel.selectionOrCanvasPlainText()

        // when
        viewModel.copySelectedShapesToClipboard()

        let clipboardString = clipboard.string(forType: .string)
        let clipboardData = clipboard.data(forType: NSPasteboard.PasteboardType("com.yuzudraw.shapes"))
        let canPasteAfterCopy = viewModel.canPasteShapesFromClipboard()

        let shapeIDsBeforeFirstPaste = Set(viewModel.document.shapes.map(\.id))
        let didPasteFirst = viewModel.pasteShapesFromClipboard()
        let firstPasteIDs = Set(viewModel.selectedShapeIDs)
        let shapeIDsAfterFirstPaste = Set(viewModel.document.shapes.map(\.id))

        let didPasteSecond = viewModel.pasteShapesFromClipboard()
        let secondPasteIDs = Set(viewModel.selectedShapeIDs)

        // then
        #expect(clipboardData != nil)
        #expect(canPasteAfterCopy)
        #expect(didPasteFirst)
        #expect(didPasteSecond)

        guard let clipboardString else {
            Issue.record("Expected clipboard plain text string")
            return
        }
        // Cmd+C writes ASCII art to .string pasteboard type
        #expect(clipboardString.contains("Service"))
        #expect(clipboardString.contains("DB"))
        #expect(clipboardString.contains("events"))
        #expect(viewModel.document.shapes.count == 13)
        #expect(firstPasteIDs.count == 4)
        #expect(secondPasteIDs.count == 4)
        #expect(firstPasteIDs.isDisjoint(with: [service.id, database.id, arrow.id, note.id]))
        #expect(secondPasteIDs.isDisjoint(with: [service.id, database.id, arrow.id, note.id]))
        #expect(firstPasteIDs.isDisjoint(with: secondPasteIDs))
        #expect(firstPasteIDs == shapeIDsAfterFirstPaste.subtracting(shapeIDsBeforeFirstPaste))
        #expect(secondPasteIDs == Set(viewModel.document.shapes.map(\.id)).subtracting(shapeIDsAfterFirstPaste))

        let firstPastedShapes = viewModel.document.shapes.filter { firstPasteIDs.contains($0.id) }
        let secondPastedShapes = viewModel.document.shapes.filter { secondPasteIDs.contains($0.id) }

        guard
            let firstService = firstPastedShapes.compactMap({ shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape, rectangle.label == "Service" else { return nil }
                return rectangle
            }).first,
            let firstDatabase = firstPastedShapes.compactMap({ shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape, rectangle.label == "DB" else { return nil }
                return rectangle
            }).first,
            let firstArrow = firstPastedShapes.compactMap({ shape -> ArrowShape? in
                guard case .arrow(let arrow) = shape else { return nil }
                return arrow
            }).first,
            let firstNote = firstPastedShapes.compactMap({ shape -> TextShape? in
                guard case .text(let text) = shape else { return nil }
                return text
            }).first,
            let secondService = secondPastedShapes.compactMap({ shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape, rectangle.label == "Service" else { return nil }
                return rectangle
            }).first,
            let secondDatabase = secondPastedShapes.compactMap({ shape -> RectangleShape? in
                guard case .rectangle(let rectangle) = shape, rectangle.label == "DB" else { return nil }
                return rectangle
            }).first,
            let secondArrow = secondPastedShapes.compactMap({ shape -> ArrowShape? in
                guard case .arrow(let arrow) = shape else { return nil }
                return arrow
            }).first,
            let secondNote = secondPastedShapes.compactMap({ shape -> TextShape? in
                guard case .text(let text) = shape else { return nil }
                return text
            }).first
        else {
            Issue.record("Expected pasted rectangles, arrow, and text")
            return
        }

        #expect(firstService.origin == GridPoint(column: 12, row: 6))
        #expect(firstDatabase.origin == GridPoint(column: 36, row: 7))
        #expect(firstNote.origin == GridPoint(column: 15, row: 15))
        #expect(firstArrow.start == GridPoint(column: arrow.start.column + 2, row: arrow.start.row + 1))
        #expect(firstArrow.end == GridPoint(column: arrow.end.column + 2, row: arrow.end.row + 1))
        #expect(firstArrow.startAttachment?.shapeID == firstService.id)
        #expect(firstArrow.endAttachment?.shapeID == firstDatabase.id)

        #expect(secondService.origin == GridPoint(column: 14, row: 7))
        #expect(secondDatabase.origin == GridPoint(column: 38, row: 8))
        #expect(secondNote.origin == GridPoint(column: 17, row: 16))
        #expect(secondArrow.start == GridPoint(column: arrow.start.column + 4, row: arrow.start.row + 2))
        #expect(secondArrow.end == GridPoint(column: arrow.end.column + 4, row: arrow.end.row + 2))
        #expect(secondArrow.startAttachment?.shapeID == secondService.id)
        #expect(secondArrow.endAttachment?.shapeID == secondDatabase.id)

        viewModel.selectedShapeIDs = firstPasteIDs
        #expect(viewModel.selectionOrCanvasPlainText() == originalSelectionText)

        viewModel.selectedShapeIDs = secondPasteIDs
        #expect(viewModel.selectionOrCanvasPlainText() == originalSelectionText)

        guard
            let updatedRoot = viewModel.document.groups.first(where: { $0.id == rootGroup.id })
        else {
            Issue.record("Expected original group hierarchy to be preserved")
            return
        }

        // Original child group should be unchanged
        let updatedCopiedGroup = updatedRoot.children.first(where: { $0.id == copiedGroup.id })
        #expect(updatedCopiedGroup != nil)
        #expect(Set(updatedCopiedGroup!.shapeIDs) == Set([service.id, database.id, arrow.id, note.id]))

        // The first whole-group paste should fall back to top level when the selected group is the source group.
        #expect(viewModel.document.groups.count == 2)
        let topLevelPastedGroups = viewModel.document.groups.filter { $0.id != rootGroup.id }
        #expect(topLevelPastedGroups.count == 1)
        let firstPastedGroup = topLevelPastedGroups.first
        #expect(Set(firstPastedGroup?.shapeIDs ?? []) == firstPasteIDs)
        #expect(firstPastedGroup?.children.count == 1)
        #expect(Set(firstPastedGroup?.children.first?.shapeIDs ?? []) == secondPasteIDs)
    }

    @Test func should_preserve_left_routed_attached_arrow_when_copy_pasting_selection() throws {
        // given
        let dsl = """
            group "Group 1"
              rect "Title" id title at 15,12 size 20x5
            rect "Callout" id callout at 12,24 size 30x5 line dashed dash 1 gap 1
            arrow from "Callout".left to "Title".left
            """
        let document = try DSLParser.parse(dsl)
        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = Set(document.shapes.map(\.id))

        let originalText = viewModel.selectionOrCanvasPlainText()
        let originalWidth = originalText?
            .components(separatedBy: "\n")
            .map(\.count)
            .max()

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 6)

        let pastedText = viewModel.selectionOrCanvasPlainText()
        let pastedWidth = pastedText?
            .components(separatedBy: "\n")
            .map(\.count)
            .max()

        #expect(originalWidth == 31)
        #expect(pastedWidth == 31)
        #expect(pastedText == originalText)
    }

    @Test func should_paste_whole_group_at_top_level_when_selected_group_is_source_group() {
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

        // Original group should still exist
        guard let originalGroup = viewModel.document.groups.first(where: { $0.id == group.id }) else {
            Issue.record("Expected original group to exist")
            return
        }
        #expect(Set(originalGroup.shapeIDs) == Set([rectA.id, rectB.id]))

        // Pasted whole-group content should be added at the top level, not nested into itself.
        #expect(viewModel.document.groups.count == 2)
        #expect(originalGroup.children.isEmpty)
        let newGroup = viewModel.document.groups.first(where: { $0.id != group.id })
        #expect(Set(newGroup?.shapeIDs ?? []) == pastedIDs)
        #expect(newGroup?.name == "Group 1")
    }

    @Test func should_paste_partial_group_selection_at_top_level_when_not_entered() {
        // given
        let rectA = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rectB = RectangleShape(origin: GridPoint(column: 8, row: 0), size: GridSize(width: 4, height: 3))
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rectA.id, rectB.id])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB)],
            groups: [group]
        )

        let viewModel = EditorViewModel(document: document)
        // Only select one shape from the group (partial selection)
        viewModel.selectedShapeIDs = [rectA.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 3)

        let pastedIDs = Set(viewModel.selectedShapeIDs)
        #expect(pastedIDs.count == 1)

        // Pasted shape should remain at the top level.
        guard let updatedGroup = viewModel.document.groups.first(where: { $0.id == group.id }) else {
            Issue.record("Expected original group to exist")
            return
        }
        #expect(Set(updatedGroup.shapeIDs) == Set([rectA.id, rectB.id]))
        #expect(updatedGroup.shapeIDs.allSatisfy { !pastedIDs.contains($0) })
    }

    @Test func should_paste_partial_group_selection_into_entered_group() {
        // given
        let rectA = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let rectB = RectangleShape(origin: GridPoint(column: 8, row: 0), size: GridSize(width: 4, height: 3))
        let rectC = RectangleShape(origin: GridPoint(column: 16, row: 0), size: GridSize(width: 4, height: 3))
        let rectD = RectangleShape(origin: GridPoint(column: 24, row: 0), size: GridSize(width: 4, height: 3))
        let sourceGroup = ShapeGroup(name: "Source", shapeIDs: [rectA.id, rectB.id])
        let destinationGroup = ShapeGroup(name: "Destination", shapeIDs: [rectC.id, rectD.id])
        let document = Document(
            shapes: [.rectangle(rectA), .rectangle(rectB), .rectangle(rectC), .rectangle(rectD)],
            groups: [sourceGroup, destinationGroup]
        )

        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [rectA.id]
        viewModel.enteredGroupID = destinationGroup.id

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 5)

        let pastedIDs = Set(viewModel.selectedShapeIDs)
        #expect(pastedIDs.count == 1)

        guard let updatedSourceGroup = viewModel.document.groups.first(where: { $0.id == sourceGroup.id }) else {
            Issue.record("Expected source group to exist")
            return
        }
        guard let updatedDestinationGroup = viewModel.document.groups.first(where: { $0.id == destinationGroup.id }) else {
            Issue.record("Expected destination group to exist")
            return
        }

        #expect(Set(updatedSourceGroup.shapeIDs) == Set([rectA.id, rectB.id]))
        #expect(Set(updatedDestinationGroup.shapeIDs).isSuperset(of: pastedIDs))
    }

    @Test func should_paste_shapes_at_top_level_when_multiple_groups_selected() {
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

        #expect(Set(pastedTopGroup.shapeIDs) == Set([rectA.id]))
        #expect(Set(untouchedSecondGroup.shapeIDs).isDisjoint(with: pastedIDs))
        #expect(Set(untouchedSecondGroup.shapeIDs) == Set([rectB.id]))
    }

    @Test func should_paste_whole_group_into_entered_nested_group() {
        // given
        let sourceRect = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let nestedRect = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        let copiedGroup = ShapeGroup(name: "Copied", shapeIDs: [sourceRect.id])
        let nestedDestination = ShapeGroup(name: "Nested", shapeIDs: [nestedRect.id])
        let rootDestination = ShapeGroup(name: "Root", shapeIDs: [], children: [nestedDestination])
        let document = Document(
            shapes: [.rectangle(sourceRect), .rectangle(nestedRect)],
            groups: [copiedGroup, rootDestination]
        )

        let viewModel = EditorViewModel(document: document)
        viewModel.selectedShapeIDs = [sourceRect.id]

        guard let payloadData = viewModel.selectedShapesClipboardPayloadData() else {
            Issue.record("Expected payload data")
            return
        }

        viewModel.enteredGroupID = nestedDestination.id

        // when
        let didPaste = viewModel.pasteShapes(fromClipboardPayloadData: payloadData)

        // then
        #expect(didPaste)
        #expect(viewModel.document.groups.count == 2)

        guard let updatedRootDestination = viewModel.document.groups.first(where: { $0.id == rootDestination.id }) else {
            Issue.record("Expected root destination group to exist")
            return
        }

        #expect(updatedRootDestination.children.count == 1)
        let pastedGroup = updatedRootDestination.children.first?.children.first
        #expect(pastedGroup?.name == "Copied")
        #expect(Set(pastedGroup?.shapeIDs ?? []).count == 1)
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

    @Test func should_paste_shapes_from_dsl_string_on_clipboard() {
        // given
        let clipboard = TestClipboardClient()
        let viewModel = EditorViewModel(document: Document(), clipboardClient: clipboard)
        let dsl = """
            rect "Box" at 5,3 size 10x4
            text "Hello" at 20,3
            """
        clipboard.setString(dsl, forType: .string)

        // when
        let didPaste = viewModel.pasteShapesFromClipboard()

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 2)

        let rects = viewModel.document.shapes.compactMap { shape -> RectangleShape? in
            guard case .rectangle(let r) = shape else { return nil }
            return r
        }
        #expect(rects.count == 1)
        #expect(rects.first?.label == "Box")
        #expect(rects.first?.origin == GridPoint(column: 7, row: 4))

        let texts = viewModel.document.shapes.compactMap { shape -> TextShape? in
            guard case .text(let t) = shape else { return nil }
            return t
        }
        #expect(texts.count == 1)
        #expect(texts.first?.text == "Hello")
    }

    @Test func should_paste_grouped_shapes_from_dsl_string() {
        // given
        let clipboard = TestClipboardClient()
        let viewModel = EditorViewModel(document: Document(), clipboardClient: clipboard)
        let dsl = """
            group "MyGroup"
              rect "A" at 0,0 size 4x3
              rect "B" at 8,0 size 4x3
            """
        clipboard.setString(dsl, forType: .string)

        // when
        let didPaste = viewModel.pasteShapesFromClipboard()

        // then
        #expect(didPaste)
        #expect(viewModel.document.shapes.count == 2)
        #expect(viewModel.document.groups.count == 1)
        #expect(viewModel.document.groups.first?.name == "MyGroup")
        #expect(viewModel.document.groups.first?.shapeIDs.count == 2)
    }

    @Test func should_copy_ascii_art_not_json_to_string_pasteboard() {
        // given
        let clipboard = TestClipboardClient()
        var document = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4),
            label: "Test"
        )
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document, clipboardClient: clipboard)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        viewModel.copySelectedShapesToClipboard()

        // then
        let clipboardString = clipboard.string(forType: .string)
        #expect(clipboardString != nil)
        // Should be ASCII art, not JSON
        #expect(clipboardString?.contains("┌") == true)
        #expect(clipboardString?.contains("Test") == true)
        #expect(clipboardString?.hasPrefix("{") != true)
    }

    @Test func should_copy_dsl_to_clipboard_with_shift_c() {
        // given
        let clipboard = TestClipboardClient()
        var document = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 5, row: 3),
            size: GridSize(width: 10, height: 4),
            label: "Test"
        )
        document.addShape(.rectangle(rectangle))
        let viewModel = EditorViewModel(document: document, clipboardClient: clipboard)
        viewModel.selectedShapeIDs = [rectangle.id]

        // when
        viewModel.copySelectionAsPlainTextToClipboard()

        // then
        let clipboardString = clipboard.string(forType: .string)
        #expect(clipboardString != nil)
        #expect(clipboardString?.contains("rect \"Test\"") == true)
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
