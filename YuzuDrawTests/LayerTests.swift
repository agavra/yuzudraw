import Foundation
import Testing

@testable import YuzuDraw

struct LayerTests {
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
        #expect(doc.shapes[0].id == rectangle.id)
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

    @Test func should_remove_shape_from_groups_when_removed_from_document() {
        // given
        var doc = Document()
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rectangle))
        doc.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rectangle.id]))

        // when
        doc.removeShape(id: rectangle.id)

        // then
        #expect(doc.groups.isEmpty)
    }

    @Test func should_remove_shape_from_nested_groups_when_removed_from_document() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(
            name: "Outer", shapeIDs: [rect2.id], children: [innerGroup])
        doc.groups.append(outerGroup)

        // when
        doc.removeShape(id: rect1.id)

        // then
        #expect(doc.shapes.count == 1)
        #expect(doc.groups[0].children.isEmpty)
        #expect(doc.groups[0].shapeIDs == [rect2.id])
    }

    @Test func should_remove_group_when_all_nested_shapes_are_removed() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rect1))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(name: "Outer", shapeIDs: [], children: [innerGroup])
        doc.groups.append(outerGroup)

        // when
        doc.removeShape(id: rect1.id)

        // then
        #expect(doc.shapes.isEmpty)
        #expect(doc.groups.isEmpty)
    }

    @Test func should_compute_ungrouped_shapes() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let rect3 = RectangleShape(
            origin: GridPoint(column: 20, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        doc.addShape(.rectangle(rect3))
        doc.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id]))

        // when
        let ungrouped = doc.ungroupedShapes

        // then
        #expect(ungrouped.count == 1)
        #expect(ungrouped[0].id == rect3.id)
    }

    @Test func should_remove_group_when_removeShapesFromGroups_removes_all_members() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        doc.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id]))

        // when
        doc.removeShapesFromGroups(ids: [rect1.id, rect2.id])

        // then
        #expect(doc.groups.isEmpty)
    }

    @Test func should_compute_allShapeIDs_recursively() {
        // given
        let innerGroup = ShapeGroup(
            name: "Inner",
            shapeIDs: [UUID(), UUID()]
        )
        let outerGroup = ShapeGroup(
            name: "Outer",
            shapeIDs: [UUID()],
            children: [innerGroup]
        )

        // when
        let allIDs = outerGroup.allShapeIDs

        // then
        #expect(allIDs.count == 3)
        #expect(allIDs.isSuperset(of: innerGroup.shapeIDs))
        #expect(allIDs.isSuperset(of: outerGroup.shapeIDs))
    }

    @Test func should_find_shape_by_id() {
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

    @Test func should_find_root_group_containing_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 5, height: 3))
        let rect3 = RectangleShape(origin: GridPoint(column: 20, row: 0), size: GridSize(width: 5, height: 3))
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        doc.addShape(.rectangle(rect3))
        let group = ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id])
        doc.groups.append(group)

        // when/then
        #expect(doc.findRootGroup(containingShape: rect1.id)?.id == group.id)
        #expect(doc.findRootGroup(containingShape: rect2.id)?.id == group.id)
        #expect(doc.findRootGroup(containingShape: rect3.id) == nil)
    }

    @Test func should_find_root_group_for_nested_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 5, height: 3))
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(name: "Outer", shapeIDs: [rect2.id], children: [innerGroup])
        doc.groups.append(outerGroup)

        // when/then
        #expect(doc.findRootGroup(containingShape: rect1.id)?.id == outerGroup.id)
    }

    @Test func should_find_group_ancestry_for_nested_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3))
        let rect2 = RectangleShape(origin: GridPoint(column: 10, row: 0), size: GridSize(width: 5, height: 3))
        doc.addShape(.rectangle(rect1))
        doc.addShape(.rectangle(rect2))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(name: "Outer", shapeIDs: [rect2.id], children: [innerGroup])
        doc.groups.append(outerGroup)

        // when
        let ancestry = doc.findGroupAncestry(containingShape: rect1.id)

        // then
        #expect(ancestry.count == 2)
        #expect(ancestry[0].id == outerGroup.id)
        #expect(ancestry[1].id == innerGroup.id)
    }

    @Test func should_return_empty_ancestry_for_ungrouped_shape() {
        // given
        var doc = Document()
        let rect1 = RectangleShape(origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3))
        doc.addShape(.rectangle(rect1))

        // when
        let ancestry = doc.findGroupAncestry(containingShape: rect1.id)

        // then
        #expect(ancestry.isEmpty)
    }
}
