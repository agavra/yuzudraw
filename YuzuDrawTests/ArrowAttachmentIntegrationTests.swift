import Testing

@testable import YuzuDraw

struct ArrowAttachmentIntegrationTests {
    @MainActor
    @Test func should_reroute_attached_arrow_when_box_moves() {
        // given
        let vm = EditorViewModel()

        let leftBox = BoxShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        let rightBox = BoxShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        vm.document.addShape(.box(leftBox), toLayerAt: 0)
        vm.document.addShape(.box(rightBox), toLayerAt: 0)

        vm.activeToolType = .arrow
        vm.mouseDown(at: GridPoint(column: 5, row: 4))
        vm.mouseUp(at: GridPoint(column: 23, row: 4))

        // when
        vm.activeToolType = .select
        vm.mouseDown(at: GridPoint(column: 23, row: 4))
        vm.mouseDragged(to: GridPoint(column: 33, row: 4))
        vm.mouseUp(at: GridPoint(column: 33, row: 4))

        // then
        let arrows = vm.document.layers[0].shapes.compactMap { shape -> ArrowShape? in
            guard case .arrow(let arrow) = shape else { return nil }
            return arrow
        }

        #expect(arrows.count == 1)
        if let arrow = arrows.first {
            #expect(arrow.start == GridPoint(column: 9, row: 4))
            #expect(arrow.end == GridPoint(column: 30, row: 4))
            #expect(arrow.startAttachment == ArrowAttachment(shapeID: leftBox.id, side: .right))
            #expect(arrow.endAttachment == ArrowAttachment(shapeID: rightBox.id, side: .left))
        }
    }

    @MainActor
    @Test func should_move_attached_arrow_when_multiple_selected_boxes_move() {
        // given
        let vm = EditorViewModel()

        let leftBox = BoxShape(
            origin: GridPoint(column: 2, row: 2),
            size: GridSize(width: 8, height: 5)
        )
        let rightBox = BoxShape(
            origin: GridPoint(column: 20, row: 2),
            size: GridSize(width: 8, height: 5)
        )

        let arrow = ArrowShape(
            start: leftBox.attachmentPoint(for: .right),
            end: rightBox.attachmentPoint(for: .left),
            startAttachment: ArrowAttachment(shapeID: leftBox.id, side: .right),
            endAttachment: ArrowAttachment(shapeID: rightBox.id, side: .left)
        )

        vm.document.addShape(.box(leftBox), toLayerAt: 0)
        vm.document.addShape(.box(rightBox), toLayerAt: 0)
        vm.document.addShape(.arrow(arrow), toLayerAt: 0)
        vm.rerender()

        vm.activeToolType = .select
        vm.selectedShapeIDs = [leftBox.id, rightBox.id]

        // when
        vm.mouseDown(at: GridPoint(column: 5, row: 4))
        vm.mouseDragged(to: GridPoint(column: 8, row: 6))
        vm.mouseUp(at: GridPoint(column: 8, row: 6))

        // then
        let movedLeft = vm.document.findShape(id: leftBox.id)
        let movedRight = vm.document.findShape(id: rightBox.id)
        let movedArrow = vm.document.findShape(id: arrow.id)

        guard
            case .box(let left)? = movedLeft,
            case .box(let right)? = movedRight,
            case .arrow(let updatedArrow)? = movedArrow
        else {
            Issue.record("Expected moved boxes and arrow")
            return
        }

        #expect(left.origin == GridPoint(column: 5, row: 4))
        #expect(right.origin == GridPoint(column: 23, row: 4))
        #expect(updatedArrow.start == left.attachmentPoint(for: .right))
        #expect(updatedArrow.end == right.attachmentPoint(for: .left))
        #expect(updatedArrow.startAttachment == ArrowAttachment(shapeID: leftBox.id, side: .right))
        #expect(updatedArrow.endAttachment == ArrowAttachment(shapeID: rightBox.id, side: .left))
    }
}
