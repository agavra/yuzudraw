import Foundation
import Testing

@testable import AsciiAI

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
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )

        // when
        layer.addShape(.box(box))

        // then
        #expect(layer.shapes.count == 1)
        #expect(layer.shapes[0].id == box.id)
    }

    @Test func should_remove_shape_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.box(box))

        // when
        layer.removeShape(id: box.id)

        // then
        #expect(layer.shapes.isEmpty)
    }

    @Test func should_remove_shape_from_groups_when_removed_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.box(box))
        layer.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [box.id]))

        // when
        layer.removeShape(id: box.id)

        // then
        #expect(layer.groups[0].shapeIDs.isEmpty)
    }

    @Test func should_remove_shape_from_nested_groups_when_removed_from_layer() {
        // given
        var layer = Layer(name: "Layer 1")
        let box1 = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let box2 = BoxShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.box(box1))
        layer.addShape(.box(box2))
        let innerGroup = ShapeGroup(name: "Inner", shapeIDs: [box1.id])
        let outerGroup = ShapeGroup(
            name: "Outer", shapeIDs: [box2.id], children: [innerGroup])
        layer.groups.append(outerGroup)

        // when
        layer.removeShape(id: box1.id)

        // then
        #expect(layer.shapes.count == 1)
        #expect(layer.groups[0].children[0].shapeIDs.isEmpty)
        #expect(layer.groups[0].shapeIDs == [box2.id])
    }

    @Test func should_compute_ungrouped_shapes() {
        // given
        var layer = Layer(name: "Layer 1")
        let box1 = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let box2 = BoxShape(
            origin: GridPoint(column: 10, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        let box3 = BoxShape(
            origin: GridPoint(column: 20, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.box(box1))
        layer.addShape(.box(box2))
        layer.addShape(.box(box3))
        layer.groups.append(ShapeGroup(name: "Group 1", shapeIDs: [box1.id, box2.id]))

        // when
        let ungrouped = layer.ungroupedShapes

        // then
        #expect(ungrouped.count == 1)
        #expect(ungrouped[0].id == box3.id)
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
        let box = BoxShape(
            origin: GridPoint(column: 0, row: 0),
            size: GridSize(width: 5, height: 3)
        )
        layer.addShape(.box(box))

        // when
        let found = layer.findShape(id: box.id)

        // then
        #expect(found != nil)
        #expect(found?.id == box.id)
    }
}
