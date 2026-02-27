import Foundation
import Testing

@testable import YuzuDraw

struct ShapeColorTests {
    // MARK: - Hex Initialization

    @Test func should_parse_hex_rrggbb() {
        // given/when
        let color = ShapeColor(hex: "#FF6600")

        // then
        #expect(color != nil)
        #expect(color!.red == 1.0)
        #expect(color!.green == 102.0 / 255.0)
        #expect(color!.blue == 0.0)
        #expect(color!.alpha == 1.0)
    }

    @Test func should_parse_hex_rrggbbaa() {
        // given/when
        let color = ShapeColor(hex: "#FF660080")

        // then
        #expect(color != nil)
        #expect(color!.red == 1.0)
        #expect(color!.alpha == 128.0 / 255.0)
    }

    @Test func should_parse_hex_without_hash() {
        // given/when
        let color = ShapeColor(hex: "FF0000")

        // then
        #expect(color != nil)
        #expect(color!.red == 1.0)
        #expect(color!.green == 0.0)
        #expect(color!.blue == 0.0)
    }

    @Test func should_return_nil_for_invalid_hex() {
        // given/when/then
        #expect(ShapeColor(hex: "ZZZ") == nil)
        #expect(ShapeColor(hex: "#12345") == nil)
        #expect(ShapeColor(hex: "") == nil)
    }

    // MARK: - Hex Output

    @Test func should_produce_hex_string() {
        // given
        let color = ShapeColor(red: 1.0, green: 0.0, blue: 0.0)

        // when
        let hex = color.hexString

        // then
        #expect(hex == "#FF0000FF")
    }

    // MARK: - Hex Round-trip

    @Test func should_round_trip_hex() {
        // given
        let original = ShapeColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 0.5)

        // when
        let hex = original.hexString
        let restored = ShapeColor(hex: hex)

        // then
        #expect(restored != nil)
        #expect(abs(restored!.red - original.red) < 0.01)
        #expect(abs(restored!.green - original.green) < 0.01)
        #expect(abs(restored!.blue - original.blue) < 0.01)
        #expect(abs(restored!.alpha - original.alpha) < 0.01)
    }

    // MARK: - Codable Round-trip

    @Test func should_round_trip_codable() throws {
        // given
        let original = ShapeColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)

        // when
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ShapeColor.self, from: data)

        // then
        #expect(decoded == original)
    }

    // MARK: - Presets

    @Test func should_have_correct_presets() {
        // given/when/then
        #expect(ShapeColor.black == ShapeColor(red: 0, green: 0, blue: 0))
        #expect(ShapeColor.white == ShapeColor(red: 1, green: 1, blue: 1))
        #expect(ShapeColor.clear.alpha == 0)
        #expect(ShapeColor.red.red == 1.0)
        #expect(ShapeColor.blue.blue == 1.0)
    }

    // MARK: - SwiftUI / NSColor Conversion

    @Test func should_convert_to_nscolor() {
        // given
        let color = ShapeColor(red: 1, green: 0, blue: 0)

        // when
        let nsColor = color.nsColor

        // then
        #expect(nsColor.redComponent == 1.0)
        #expect(nsColor.greenComponent == 0.0)
        #expect(nsColor.blueComponent == 0.0)
    }
}
