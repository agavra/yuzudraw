import Testing

@testable import AsciiAI

struct StrokeStyleTests {
    @Test func should_provide_single_border_characters() {
        // given
        let style = StrokeStyle.single

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
        let style = StrokeStyle.double

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
        let style = StrokeStyle.rounded

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
        let style = StrokeStyle.heavy

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
        #expect(StrokeStyle.allCases.count == 4)
    }
}
