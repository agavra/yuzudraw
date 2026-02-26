import Testing

@testable import AsciiAI

struct BorderStyleTests {
    @Test func should_provide_single_border_characters() {
        // given
        let style = BorderStyle.single

        // then
        #expect(style.horizontal == "─")
        #expect(style.vertical == "│")
        #expect(style.topLeft == "┌")
        #expect(style.topRight == "┐")
        #expect(style.bottomLeft == "└")
        #expect(style.bottomRight == "┘")
    }

    @Test func should_provide_double_border_characters() {
        // given
        let style = BorderStyle.double

        // then
        #expect(style.horizontal == "═")
        #expect(style.vertical == "║")
        #expect(style.topLeft == "╔")
        #expect(style.topRight == "╗")
        #expect(style.bottomLeft == "╚")
        #expect(style.bottomRight == "╝")
    }

    @Test func should_provide_rounded_border_characters() {
        // given
        let style = BorderStyle.rounded

        // then
        #expect(style.horizontal == "─")
        #expect(style.vertical == "│")
        #expect(style.topLeft == "╭")
        #expect(style.topRight == "╮")
        #expect(style.bottomLeft == "╰")
        #expect(style.bottomRight == "╯")
    }

    @Test func should_provide_heavy_border_characters() {
        // given
        let style = BorderStyle.heavy

        // then
        #expect(style.horizontal == "━")
        #expect(style.vertical == "┃")
        #expect(style.topLeft == "┏")
        #expect(style.topRight == "┓")
        #expect(style.bottomLeft == "┗")
        #expect(style.bottomRight == "┛")
    }

    @Test func should_have_four_cases() {
        // then
        #expect(BorderStyle.allCases.count == 4)
    }
}
