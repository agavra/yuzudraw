import Foundation
import Testing

@testable import YuzuDraw

struct DocumentTests {
    @Test func should_create_document_with_defaults() {
        // given/when
        let doc = Document()

        // then
        #expect(doc.shapes.isEmpty)
        #expect(doc.groups.isEmpty)
        #expect(doc.canvasSize == GridSize(width: 80, height: 24))
    }

    @Test func should_add_shape_to_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )

        // when
        doc.addShape(.rectangle(rectangle))

        // then
        #expect(doc.shapes.count == 1)
    }

    @Test func should_find_shape_in_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let found = doc.findShape(id: rectangle.id)

        // then
        #expect(found != nil)
        #expect(found?.id == rectangle.id)
    }

    @Test func should_remove_shape_from_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rectangle))

        // when
        doc.removeShape(id: rectangle.id)

        // then
        #expect(doc.shapes.isEmpty)
    }

    @Test func should_update_existing_shape() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3),
            label: "Old"
        )
        doc.addShape(.rectangle(rectangle))

        // when
        let updated = RectangleShape(
            id: rectangle.id,
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5),
            label: "New"
        )
        doc.updateShape(.rectangle(updated))

        // then
        if case .rectangle(let found) = doc.findShape(id: rectangle.id) {
            #expect(found.size.width == 10)
            #expect(found.label == "New")
        } else {
            Issue.record("Shape not found or wrong type")
        }
    }

    @Test func should_hit_test_topmost_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 10, height: 5)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 5, row: 2),
            size: GridSize(width: 10, height: 5)
        )
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))

        // when - test overlap point
        let hit = doc.hitTest(at: GridPoint(column: 7, row: 3))

        // then - should hit the topmost (last added) shape
        #expect(hit?.id == rect2.id)
    }

    @Test func should_hit_nearby_arrow_when_not_exactly_on_line() {
        // given
        var doc = Document()
        let arrow = ArrowShape(
            start: GridPoint(column: 2, row: 2),
            end: GridPoint(column: 12, row: 2)
        )
        doc.addShape(.arrow(arrow))

        // when
        let hit = doc.hitTest(at: GridPoint(column: 7, row: 3))

        // then
        #expect(hit?.id == arrow.id)
    }

    @Test func should_move_shape_forward_and_backward() {
        // given
        var doc = Document()
        let back = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Back"
        )
        let front = RectangleShape(
            origin: GridPoint(column: 2, row: 1),
            size: GridSize(width: 6, height: 4),
            label: "Front"
        )
        doc.addShape(.rectangle(back))
        doc.addShape(.rectangle(front))

        // when
        let movedBackward = doc.moveShapeBackward(id: front.id)
        let movedForward = doc.moveShapeForward(id: front.id)

        // then
        #expect(movedBackward)
        #expect(movedForward)
        #expect(doc.shapes[1].id == front.id)
    }

    @Test func should_bring_shape_to_front_and_back() {
        // given
        var doc = Document()
        let back = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 4),
            label: "Back"
        )
        let middle = RectangleShape(
            origin: GridPoint(column: 2, row: 1),
            size: GridSize(width: 6, height: 4),
            label: "Middle"
        )
        let front = RectangleShape(
            origin: GridPoint(column: 4, row: 2),
            size: GridSize(width: 6, height: 4),
            label: "Front"
        )
        doc.addShape(.rectangle(back))
        doc.addShape(.rectangle(middle))
        doc.addShape(.rectangle(front))

        // when
        let movedToFront = doc.moveShapeToFront(id: back.id)
        let movedToBack = doc.moveShapeToBack(id: front.id)

        // then
        #expect(movedToFront)
        #expect(movedToBack)
        #expect(doc.shapes[0].id == front.id)
        #expect(doc.shapes[2].id == back.id)
    }

    @Test func should_occlude_lower_shape_when_top_rectangle_fill_is_solid() {
        // given
        var doc = Document(
            canvasSize: GridSize(width: 10, height: 6)
        )
        let bottom = RectangleShape(
            origin: GridPoint(column: 1, row: 1),
            size: GridSize(width: 8, height: 4),
            strokeStyle: .single
        )
        let top = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single,
            fillMode: .opaque
        )
        doc.addShape(.rectangle(bottom))
        doc.addShape(.rectangle(top))
        var canvas = Canvas(size: doc.canvasSize)

        // when
        doc.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 3, row: 3) == " ")
    }

    @Test func should_render_all_visible_shapes() {
        // given
        var doc = Document(
            canvasSize: GridSize(width: 20, height: 5)
        )
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single
        )
        doc.addShape(.rectangle(rectangle))
        var canvas = Canvas(size: doc.canvasSize)

        // when
        doc.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 0, row: 0) == "┌")
        #expect(canvas.character(atColumn: 5, row: 0) == "┐")
        #expect(canvas.character(atColumn: 0, row: 2) == "└")
    }

    @Test func should_not_render_hidden_shape() {
        // given
        var doc = Document(canvasSize: GridSize(width: 20, height: 5))
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 6, height: 3),
            strokeStyle: .single
        )
        doc.addShape(.rectangle(rectangle))
        doc.setShapeHidden(rectangle.id, isHidden: true)
        var canvas = Canvas(size: doc.canvasSize)

        // when
        doc.render(into: &canvas)

        // then
        #expect(canvas.character(atColumn: 0, row: 0) == " ")
    }

    @Test func should_not_hit_test_locked_shape() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 4)
        )
        doc.addShape(.rectangle(rectangle))
        doc.setShapeLocked(rectangle.id, isLocked: true)

        // when
        let hit = doc.hitTest(at: GridPoint(column: 3, row: 3))

        // then
        #expect(hit == nil)
    }

    @Test func should_move_shape_before_target() {
        // given
        var doc = Document()
        let source = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 4, height: 3))
        let targetA = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 4, height: 3))
        let targetB = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 4, height: 3))
        doc.addShape(.rectangle(source))
        doc.addShape(.rectangle(targetA))
        doc.addShape(.rectangle(targetB))

        // when
        let moved = doc.moveShape(id: source.id, before: targetB.id)

        // then
        #expect(moved)
        #expect(doc.shapes.map(\.id) == [targetA.id, source.id, targetB.id])
    }

    @Test func should_merge_diagram_with_offset_into_existing_group() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let service = DiagramAutomationService()
        let targetURL = tempDirectory.appendingPathComponent("system").appendingPathExtension("yuzudraw")

        _ = try service.createDiagram(
            name: "system",
            dsl: """
                group "Platform" id platform at 2,1
                  rect "Shell" id shell at 0,0 size 20x5
                """,
            outputURL: targetURL
        )

        _ = try service.mergeDiagram(
            name: "system",
            dsl: """
                group "Payments" id payments at 0,0
                  rect "API" id api at 0,0 size 10x3
                rect "Ungrouped" id loose at 2,5 size 10x3
                """,
            projectURL: targetURL,
            intoGroupIdentifier: "platform",
            offset: GridPoint(column: 30, row: 4)
        )

        let merged = try ProjectFileManager.load(from: targetURL)
        #expect(merged.groups.count == 1)
        #expect(merged.groups[0].children.count == 1)
        #expect(merged.groups[0].children[0].identifier == "payments")
        #expect(merged.groups[0].children[0].origin == GridPoint(column: 30, row: 4))

        let childShapeIDs = Set(merged.groups[0].children[0].allShapeIDs)
        let directPlatformShapeIDs = Set(merged.groups[0].shapeIDs)
        let childShapes = merged.shapes.filter { childShapeIDs.contains($0.id) }
        let directShapes = merged.shapes.filter { directPlatformShapeIDs.contains($0.id) }

        #expect(childShapes.count == 1)
        #expect(directShapes.count == 2)

        guard case .rectangle(let nestedRect) = childShapes[0] else {
            Issue.record("Expected nested rectangle")
            return
        }
        #expect(nestedRect.origin == GridPoint(column: 30, row: 4))
    }
}
