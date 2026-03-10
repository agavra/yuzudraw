import Testing

@testable import YuzuDraw

struct GlyphMergeTests {
    @Test func should_merge_single_horizontal_with_single_vertical_into_cross() {
        // given
        let existing: Character = "─"

        // when
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.up, .down], style: .single)

        // then
        #expect(merged == "┼")
    }

    @Test func should_merge_single_corner_with_additional_direction_into_tee() {
        // given — top-left corner has right+down
        let existing: Character = "┌"

        // when — adding left direction turns it into a tee-down
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.left], style: .single)

        // then
        #expect(merged == "┬")
    }

    @Test func should_merge_single_vertical_with_double_horizontal_into_mixed_cross() {
        // given — single vertical (up+down)
        let existing: Character = "│"

        // when — adding double horizontal
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.left, .right], style: .double)

        // then — mixed cross: double horizontal, single vertical
        #expect(merged == "╪")
    }

    @Test func should_return_same_character_when_merging_with_empty() {
        // given
        let existing: Character = "┌"

        // when — adding no new directions
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [], style: .single)

        // then — should produce the same corner glyph
        #expect(merged == "┌")
    }

    @Test func should_merge_double_horizontal_with_single_vertical_into_mixed_cross() {
        // given — double horizontal
        let existing: Character = "═"

        // when — adding single vertical
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.up, .down], style: .single)

        // then — mixed cross: single vertical, double horizontal
        #expect(merged == "╪")
    }

    @Test func should_produce_tee_when_adding_direction_to_line() {
        // given — single horizontal line
        let existing: Character = "─"

        // when — adding down
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.down], style: .single)

        // then
        #expect(merged == "┬")
    }

    @Test func should_merge_with_space_producing_new_glyph() {
        // given
        let existing: Character = " "

        // when
        let merged = GlyphMerge.mergeGlyph(existing: existing, adding: [.left, .right], style: .double)

        // then
        #expect(merged == "═")
    }

    @Test func should_parse_mixed_glyph_connections() {
        // given — mixed corner: double horizontal + single vertical
        let conn = GlyphMerge.connections(for: "╒")

        // then
        #expect(conn != nil)
        #expect(conn?.right == .double)
        #expect(conn?.down == .single)
        #expect(conn?.up == nil)
        #expect(conn?.left == nil)
    }

    @Test func should_roundtrip_all_single_glyphs() {
        // given/when/then — each single-style glyph should roundtrip
        let singleGlyphs: [Character] = ["─", "│", "┌", "┐", "└", "┘", "├", "┤", "┬", "┴", "┼"]
        for glyph in singleGlyphs {
            let conn = GlyphMerge.connections(for: glyph)
            #expect(conn != nil, "Should parse \(glyph)")
            if let conn {
                let result = GlyphMerge.glyph(for: conn)
                #expect(result == glyph, "Expected \(glyph) but got \(result)")
            }
        }
    }

    @Test func should_roundtrip_all_double_glyphs() {
        // given/when/then
        let doubleGlyphs: [Character] = ["═", "║", "╔", "╗", "╚", "╝", "╠", "╣", "╦", "╩", "╬"]
        for glyph in doubleGlyphs {
            let conn = GlyphMerge.connections(for: glyph)
            #expect(conn != nil, "Should parse \(glyph)")
            if let conn {
                let result = GlyphMerge.glyph(for: conn)
                #expect(result == glyph, "Expected \(glyph) but got \(result)")
            }
        }
    }
}
