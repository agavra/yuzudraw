import Testing

@testable import YuzuDraw

struct GroupZOrderTests {
    // MARK: - Contiguity

    @Test func should_consolidate_group_shapes_to_be_contiguous() {
        // given
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s3.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when
        doc.consolidateGroup(group.id)

        // then — s1 and s3 should be contiguous, preserving relative order
        let ids = doc.shapes.map(\.id)
        let s1Idx = ids.firstIndex(of: s1.id)!
        let s3Idx = ids.firstIndex(of: s3.id)!
        #expect(s3Idx == s1Idx + 1)
        // s2 should be before the group block
        let s2Idx = ids.firstIndex(of: s2.id)!
        #expect(s2Idx < s1Idx)
    }

    @Test func should_not_change_already_contiguous_group() {
        // given
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )
        let originalIDs = doc.shapes.map(\.id)

        // when
        doc.consolidateGroup(group.id)

        // then — no change
        #expect(doc.shapes.map(\.id) == originalIDs)
    }

    // MARK: - Group index range

    @Test func should_return_group_shape_index_range() {
        // given
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when
        let range = doc.groupShapeIndexRange(for: group.id)

        // then
        #expect(range == 0..<2)
    }

    // MARK: - Group moves

    @Test func should_move_group_forward_past_ungrouped_shape() {
        // given — [A(g), B(g), C]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when
        let result = doc.moveGroupForward(groupID: group.id)

        // then — [C, A(g), B(g)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s3.id, s1.id, s2.id])
    }

    @Test func should_move_group_backward_past_ungrouped_shape() {
        // given — [C, A(g), B(g)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s3), .rectangle(s1), .rectangle(s2)],
            groups: [group]
        )

        // when
        let result = doc.moveGroupBackward(groupID: group.id)

        // then — [A(g), B(g), C]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s1.id, s2.id, s3.id])
    }

    @Test func should_move_group_to_front() {
        // given — [A(g), B(g), C, D]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let s4 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "D")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3), .rectangle(s4)],
            groups: [group]
        )

        // when
        let result = doc.moveGroupToFront(groupID: group.id)

        // then — [C, D, A(g), B(g)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s3.id, s4.id, s1.id, s2.id])
    }

    @Test func should_move_group_to_back() {
        // given — [C, D, A(g), B(g)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let s4 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "D")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s3), .rectangle(s4), .rectangle(s1), .rectangle(s2)],
            groups: [group]
        )

        // when
        let result = doc.moveGroupToBack(groupID: group.id)

        // then — [A(g), B(g), C, D]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s1.id, s2.id, s3.id, s4.id])
    }

    @Test func should_move_group_forward_past_another_group() {
        // given — [A(g1), B(g1), C(g2), D(g2)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let s4 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "D")
        let g1 = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let g2 = ShapeGroup(name: "G2", shapeIDs: [s3.id, s4.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3), .rectangle(s4)],
            groups: [g1, g2]
        )

        // when
        let result = doc.moveGroupForward(groupID: g1.id)

        // then — [C(g2), D(g2), A(g1), B(g1)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s3.id, s4.id, s1.id, s2.id])
    }

    // MARK: - Within-group moves

    @Test func should_move_shape_forward_within_group() {
        // given — [A(g), B(g), C(g)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id, s3.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when
        let result = doc.moveShapeWithinGroup(
            id: s1.id, forward: true, groupID: group.id)

        // then — [B(g), A(g), C(g)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s2.id, s1.id, s3.id])
    }

    @Test func should_not_move_shape_past_group_boundary() {
        // given — [A(g), B(g), C]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when — try to move B forward (it's at the end of the group)
        let result = doc.moveShapeWithinGroup(
            id: s2.id, forward: true, groupID: group.id)

        // then — should not move
        #expect(!result)
    }

    // MARK: - canMove predicates

    @Test func should_report_cannot_move_group_forward_at_end() {
        // given — [C, A(g), B(g)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let doc = Document(
            shapes: [.rectangle(s3), .rectangle(s1), .rectangle(s2)],
            groups: [group]
        )

        // when/then
        #expect(!doc.canMoveGroupForward(groupID: group.id))
        #expect(doc.canMoveGroupBackward(groupID: group.id))
    }

    @Test func should_report_cannot_move_group_backward_at_start() {
        // given — [A(g), B(g), C]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when/then
        #expect(doc.canMoveGroupForward(groupID: group.id))
        #expect(!doc.canMoveGroupBackward(groupID: group.id))
    }

    // MARK: - Positional group moves (drag-and-drop)

    @Test func should_move_group_before_another_group() {
        // given — [A(g1), B(g1), C(g2), D(g2)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let s4 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "D")
        let g1 = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let g2 = ShapeGroup(name: "G2", shapeIDs: [s3.id, s4.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3), .rectangle(s4)],
            groups: [g1, g2]
        )

        // when — move g2 before g1
        let result = doc.moveGroup(groupID: g2.id, beforeGroup: g1.id)

        // then — [C(g2), D(g2), A(g1), B(g1)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s3.id, s4.id, s1.id, s2.id])
    }

    @Test func should_move_group_after_another_group() {
        // given — [C(g2), D(g2), A(g1), B(g1)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let s4 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "D")
        let g1 = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let g2 = ShapeGroup(name: "G2", shapeIDs: [s3.id, s4.id])
        var doc = Document(
            shapes: [.rectangle(s3), .rectangle(s4), .rectangle(s1), .rectangle(s2)],
            groups: [g1, g2]
        )

        // when — move g2 after g1
        let result = doc.moveGroup(groupID: g2.id, afterGroup: g1.id)

        // then — [A(g1), B(g1), C(g2), D(g2)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s1.id, s2.id, s3.id, s4.id])
    }

    @Test func should_move_group_before_ungrouped_shape() {
        // given — [C, A(g), B(g)]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s3), .rectangle(s1), .rectangle(s2)],
            groups: [group]
        )

        // when — move group before C
        let result = doc.moveGroup(groupID: group.id, beforeShape: s3.id)

        // then — [A(g), B(g), C]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s1.id, s2.id, s3.id])
    }

    @Test func should_move_group_after_ungrouped_shape() {
        // given — [A(g), B(g), C]
        let s1 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(origin: .zero, size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        var doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when — move group after C (to end)
        let result = doc.moveGroup(groupID: group.id, afterShape: s3.id)

        // then — [C, A(g), B(g)]
        #expect(result)
        let ids = doc.shapes.map(\.id)
        #expect(ids == [s3.id, s1.id, s2.id])
    }

    // MARK: - Serialization z-order

    @Test func should_serialize_preserving_interleaved_z_order() {
        // given — [C, A(g), B(g)] — ungrouped shape C is below the group
        let s1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0), size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(
            origin: GridPoint(column: 20, row: 0), size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let doc = Document(
            shapes: [.rectangle(s3), .rectangle(s1), .rectangle(s2)],
            groups: [group]
        )

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — C should appear before the group block
        let lines = dsl.components(separatedBy: "\n")
        let cLine = lines.firstIndex(where: { $0.contains("\"C\"") })!
        let groupLine = lines.firstIndex(where: { $0.contains("group \"G1\"") })!
        #expect(cLine < groupLine)
    }

    @Test func should_serialize_group_after_ungrouped_when_group_is_on_top() {
        // given — [C, A(g), B(g)] vs [A(g), B(g), C]
        let s1 = RectangleShape(
            origin: GridPoint(column: 0, row: 0), size: GridSize(width: 5, height: 3), label: "A")
        let s2 = RectangleShape(
            origin: GridPoint(column: 10, row: 0), size: GridSize(width: 5, height: 3), label: "B")
        let s3 = RectangleShape(
            origin: GridPoint(column: 20, row: 0), size: GridSize(width: 5, height: 3), label: "C")
        let group = ShapeGroup(name: "G1", shapeIDs: [s1.id, s2.id])
        let doc = Document(
            shapes: [.rectangle(s1), .rectangle(s2), .rectangle(s3)],
            groups: [group]
        )

        // when
        let dsl = DSLSerializer.serialize(doc)

        // then — group should appear before C
        let lines = dsl.components(separatedBy: "\n")
        let cLine = lines.firstIndex(where: { $0.contains("\"C\"") })!
        let groupLine = lines.firstIndex(where: { $0.contains("group \"G1\"") })!
        #expect(groupLine < cLine)
    }
}
