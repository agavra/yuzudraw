import Foundation
import Testing

@testable import YuzuDraw

struct LayerTests {
    @Test func should_create_layer_with_defaults() {
        // given/when
        let layer = Layer(name: "Test Layer")

        // then
        #expect(layer.name == "Test Layer")
        #expect(layer.isVisible)
        #expect(!layer.isLocked)
        #expect(layer.shapes.isEmpty)
        #expect(layer.groups.isEmpty)
    }

    @Test func should_add_shape_to_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )

        // when
        layer.addShape(.rectangle(rectangle))

        // then
        #expect(layer.shapes.count == 1)
        #expect(layer.shapes[0].id == rectangle.id)
    }

    @Test func should_remove_shape_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.rectangle(rectangle))

        // when
        layer.removeShape(id: rectangle.id)

        // then
        #expect(layer.shapes.isEmpty)
    }

    @Test func should_remove_shape_from_groups_when_removed_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.rectangle(rectangle))
        layer.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rectangle.id]))

        // when
        layer.removeShape(id: rectangle.id)

        // then
        #expect(layer.groups[0].shapeIDs.isEmpty)
    }

    @Test func should_remove_shape_from_nested_groups_when_removed_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let rect1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let rect2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.rectangle(rect1))
        layer.addShape(.rectangle(rect2))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [rect1.id])
        let outerGroup = ShapeGroup(
            name: "Outer", shapeIDs: [rect2.id], children: [innerGroup])
        layer.groups.append(outerGroup)

        // when
        layer.removeShape(id: rect1.id)

        // then
        #expect(layer.shapes.count == 1)
        #expect(layer.groups[0].children[0].shapeIDs.isEmpty)
        #expect(layer.groups[0].shapeIDs == [rect2.id])
    }

    @Test func should_compute_ungrouped_shapes() {
        // given
        var layer = Layer(name: "Layer 1")
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
        layer.addShape(.rectangle(rect1))
        layer.addShape(.rectangle(rect2))
        layer.addShape(.rectangle(rect3))
        layer.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [rect1.id, rect2.id]))

        // when
        let ungrouped = layer.ungroupedShapes

        // then
        #expect(ungrouped.count == 1)
        #expect(ungrouped[0].id == rect3.id)
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
        var layer = Layer(name: "Layer 1")
        let rectangle = RectangleShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.rectangle(rectangle))

        // when
        let found = layer.findShape(id: rectangle.id)

        // then
        #expect(found != nil)
        #expect(found?.id == rectangle.id)
    }
}
