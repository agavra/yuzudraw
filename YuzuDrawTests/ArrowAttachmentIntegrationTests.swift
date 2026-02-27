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
}
