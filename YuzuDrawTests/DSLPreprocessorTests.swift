import Testing

@testable import YuzuDraw

struct DSLPreprocessorTests {
    // MARK: - Auto-sizing

    @Test func should_auto_size_single_line_label() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Frontend" at 0,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — width = max(8+4, 10) = 12, height = 1+2 = 3
        #expect(output.contains("size 12x3"))
    }

    @Test func should_auto_size_multiline_label() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Load\\nBalancer" at 0,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — longest line "Balancer" = 8, width = max(8+4, 10) = 12, height = 2+2 = 4
        #expect(output.contains("size 12x4"))
    }

    @Test func should_auto_size_empty_label_to_minimum() {
        // given
        let input = """
            layer "Diagram" visible
              rect "" at 0,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — width = max(0+4, 10) = 10, height = 1+2 = 3
        #expect(output.contains("size 10x3"))
    }

    // MARK: - Reference coordinates

    @Test func should_resolve_reference_right_offset() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at "A".right+4,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A is at 0,0 with width 14, right = 14, + 4 = 18
        #expect(output.contains("rect \"B\" at 18,0"))
    }

    @Test func should_resolve_reference_bottom_offset() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at "A".bottom+0,2
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A is at 0,0 with height 3, bottom = 3, + 2 = 5
        #expect(output.contains("rect \"B\" at 0,5"))
    }

    @Test func should_resolve_reference_with_negative_offset() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 10,10 size 14x3
              rect "B" at "A".right-4,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A right = (10+14, 10), - 4,0 = (20, 10)
        #expect(output.contains("rect \"B\" at 20,10"))
    }

    @Test func should_resolve_reference_by_id() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Server" id srv1 at 5,5 size 14x3
              rect "Client" at srv1.right+4,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — srv1 right = (5+14, 5) = (19, 5), + 4,0 = (23, 5)
        #expect(output.contains("rect \"Client\" at 23,5"))
    }

    @Test func should_resolve_reference_by_label() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Server" at 5,5 size 14x3
              rect "Client" at "Server".right+4,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — Server right = (5+14, 5) = (19, 5), + 4,0 = (23, 5)
        #expect(output.contains("rect \"Client\" at 23,5"))
    }

    @Test func should_resolve_reference_with_origin_offset() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 10,5 size 14x3
              rect "B" at "A"+16,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A origin at 10,5, + 16,0 = 26,5
        #expect(output.contains("rect \"B\" at 26,5"))
    }

    @Test func should_resolve_reference_without_offset() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at "A".right
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A right = 14
        #expect(output.contains("rect \"B\" at 14,0"))
    }

    @Test func should_resolve_text_with_reference_coords() {
        // given
        let input = """
            layer "Diagram" visible
              rect "" id bar1 at 10,3 size 50x1
              text "$1.00" at bar1.right+1,0
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — bar1 right = 10+50 = 60, + 1 = 61
        #expect(output.contains("text \"$1.00\" at 61,3"))
    }

    // MARK: - Semantic sugar

    @Test func should_resolve_semantic_right_of() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" right-of "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A right = 14, + default gap 4 = 18
        #expect(output.contains("rect \"B\" at 18,0"))
    }

    @Test func should_resolve_semantic_below() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" below "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A bottom = 3, + default gap 2 = 5
        #expect(output.contains("rect \"B\" at 0,5"))
    }

    @Test func should_resolve_semantic_left_of() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 20,0 size 14x3
              rect "B" left-of "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — B auto-sizes to 10x3, A.left = 20, - 10 - 4 = 6
        #expect(output.contains("rect \"B\" at 6,0"))
    }

    @Test func should_resolve_semantic_above() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,10 size 14x3
              rect "B" above "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — B auto-sizes to 10x3, A.top = 10, - 3 - 2 = 5
        #expect(output.contains("rect \"B\" at 0,5"))
    }

    @Test func should_resolve_semantic_with_custom_gap() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" right-of "A" gap 8
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A right = 14, + custom gap 8 = 22
        #expect(output.contains("rect \"B\" at 22,0"))
    }

    @Test func should_resolve_semantic_by_id() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Server" id srv1 at 0,0 size 14x3
              rect "Client" right-of srv1
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — srv1 right = 14, + gap 4 = 18
        #expect(output.contains("rect \"Client\" at 18,0"))
    }

    // MARK: - Arrow inference

    @Test func should_infer_arrow_sides_horizontal() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at 20,0 size 14x3
              arrow from "A" to "B"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — B is to the right of A
        #expect(output.contains("from \"A\".right to \"B\".left"))
    }

    @Test func should_infer_arrow_sides_vertical() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at 0,10 size 14x3
              arrow from "A" to "B"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — B is below A
        #expect(output.contains("from \"A\".bottom to \"B\".top"))
    }

    @Test func should_infer_arrow_sides_by_id() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Server" id srv1 at 0,0 size 14x3
              rect "Client" id srv2 at 20,0 size 14x3
              arrow from srv1 to srv2
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — srv2 is to the right of srv1
        #expect(output.contains(".right to"))
        #expect(output.contains(".left"))
    }

    @Test func should_preserve_explicit_arrow_sides() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" at 20,0 size 14x3
              arrow from "A".bottom to "B".top
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — explicit sides preserved
        #expect(output.contains("from \"A\".bottom to \"B\".top"))
    }

    // MARK: - Mixed and edge cases

    @Test func should_preserve_explicit_size_with_relative_position() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" right-of "A" size 20x5
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — explicit size preserved, position resolved
        #expect(output.contains("size 20x5"))
        #expect(output.contains("rect \"B\" at 18,0"))
    }

    @Test func should_preserve_explicit_position_with_auto_size() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Frontend" at 5,10
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — auto-sized, position unchanged
        #expect(output.contains("at 5,10"))
        #expect(output.contains("size 12x3"))
    }

    @Test func should_pass_through_fully_specified_lines() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Server" at 5,3 size 20x5 style rounded
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — unchanged
        #expect(output.contains("rect \"Server\" at 5,3 size 20x5 style rounded"))
    }

    @Test func should_handle_mixed_absolute_and_relative() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 14x3
              rect "B" right-of "A"
              rect "C" at 50,0 size 14x3
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then
        #expect(output.contains("rect \"A\" at 0,0 size 14x3"))
        #expect(output.contains("rect \"B\" at 18,0"))
        #expect(output.contains("rect \"C\" at 50,0 size 14x3"))
    }

    @Test func should_handle_cross_layer_references() {
        // given
        let input = """
            layer "Layer 1" visible
              rect "A" at 0,0 size 14x3
            layer "Layer 2" visible
              rect "B" right-of "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — cross-layer ref resolved
        #expect(output.contains("rect \"B\" at 18,0"))
    }

    @Test func should_chain_relative_positions() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" at 0,0 size 10x3
              rect "B" right-of "A"
              rect "C" right-of "B"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — A at 0, B at 0+10+4=14, C at 14+10+4=28
        #expect(output.contains("rect \"B\" at 14,0"))
        #expect(output.contains("rect \"C\" at 28,0"))
    }

    @Test func should_handle_forward_references() {
        // given
        let input = """
            layer "Diagram" visible
              rect "B" right-of "A"
              rect "A" at 0,0 size 10x3
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — B should be resolved even though A comes after
        #expect(output.contains("rect \"B\" at 14,0"))
    }

    @Test func should_leave_circular_references_unresolved() {
        // given — A depends on B, B depends on A
        let input = """
            layer "Diagram" visible
              rect "A" right-of "B"
              rect "B" right-of "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — should not crash; positions default to 0,0 for unresolved
        #expect(output.contains("rect \"A\""))
        #expect(output.contains("rect \"B\""))
    }

    @Test func should_leave_missing_references_unresolved() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A" right-of "NonExistent"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — should not crash
        #expect(output.contains("rect \"A\""))
    }

    @Test func should_default_to_origin_when_no_position() {
        // given
        let input = """
            layer "Diagram" visible
              rect "A"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — defaults to 0,0
        #expect(output.contains("at 0,0"))
    }

    @Test func should_be_idempotent_on_expanded_input() {
        // given — already expanded absolute DSL
        let input = """
            layer "Diagram" visible
              rect "Server" at 5,3 size 20x5 style rounded
              arrow from "Server".bottom to "DB".top
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — should be unchanged (well, arrow ref stays the same)
        #expect(output.contains("rect \"Server\" at 5,3 size 20x5 style rounded"))
        #expect(output.contains("arrow from \"Server\".bottom to \"DB\".top"))
    }

    @Test func should_not_match_keywords_inside_labels() {
        // given — label contains the word "size" and "at"
        let input = """
            layer "Diagram" visible
              rect "at size style" at 0,0 size 20x3
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — should parse correctly without confusion
        #expect(output.contains("rect \"at size style\" at 0,0 size 20x3"))
    }

    @Test func should_handle_cross_group_references() {
        // given
        let input = """
            layer "Diagram" visible
              group "Frontend"
                rect "UI" at 0,0 size 10x3
              group "Backend"
                rect "API" right-of "UI"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — cross-group ref resolved
        #expect(output.contains("rect \"API\" at 14,0"))
    }

    @Test func should_preserve_remaining_properties() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Box" right-of "A" style double fill solid char "▓" noborder
              rect "A" at 0,0 size 10x3
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — properties preserved
        #expect(output.contains("style double"))
        #expect(output.contains("fill solid"))
        #expect(output.contains("char \"▓\""))
        #expect(output.contains("noborder"))
    }

    @Test func should_resolve_pencil_with_reference_coords() {
        // given
        let input = """
            layer "Diagram" visible
              rect "" id container at 0,0 size 67x5
              pencil at container.left+9,3 cells [0,0,"│";0,1,"│"]
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — container.left = 0, + 9 = 9
        #expect(output.contains("pencil at 9,3"))
    }

    @Test func should_auto_size_with_semantic_positioning() {
        // given
        let input = """
            layer "Diagram" visible
              rect "Frontend" at 0,0
              rect "API" below "Frontend"
            """

        // when
        let output = DSLPreprocessor.expand(input)

        // then — Frontend auto-sizes to 12x3, API below at col=0, row=3+2=5
        #expect(output.contains("rect \"Frontend\" at 0,0 size 12x3"))
        #expect(output.contains("rect \"API\" at 0,5"))
    }
}
