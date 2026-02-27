import SwiftUI

struct ShapeColor: Codable, Equatable, Hashable, Sendable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        let length = hexString.count
        guard length == 6 || length == 8 else { return nil }

        guard let value = UInt64(hexString, radix: 16) else { return nil }

        if length == 6 {
            red = Double((value >> 16) & 0xFF) / 255.0
            green = Double((value >> 8) & 0xFF) / 255.0
            blue = Double(value & 0xFF) / 255.0
            alpha = 1.0
        } else {
            red = Double((value >> 24) & 0xFF) / 255.0
            green = Double((value >> 16) & 0xFF) / 255.0
            blue = Double((value >> 8) & 0xFF) / 255.0
            alpha = Double(value & 0xFF) / 255.0
        }
    }

    var hexString: String {
        let r = UInt8(clamping: Int((red * 255).rounded()))
        let g = UInt8(clamping: Int((green * 255).rounded()))
        let b = UInt8(clamping: Int((blue * 255).rounded()))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    var nsColor: NSColor {
        NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    // MARK: - HSB

    init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
        let h = min(max(hue, 0), 1)
        let s = min(max(saturation, 0), 1)
        let v = min(max(brightness, 0), 1)

        let i = Int(h * 6) % 6
        let f = h * 6 - Double(Int(h * 6))
        let p = v * (1 - s)
        let q = v * (1 - f * s)
        let t = v * (1 - (1 - f) * s)

        switch i {
        case 0: self.init(red: v, green: t, blue: p, alpha: alpha)
        case 1: self.init(red: q, green: v, blue: p, alpha: alpha)
        case 2: self.init(red: p, green: v, blue: t, alpha: alpha)
        case 3: self.init(red: p, green: q, blue: v, alpha: alpha)
        case 4: self.init(red: t, green: p, blue: v, alpha: alpha)
        default: self.init(red: v, green: p, blue: q, alpha: alpha)
        }
    }

    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        let r = red, g = green, b = blue
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        let brightness = maxC

        guard delta > 1e-6 else {
            return (hue: 0, saturation: 0, brightness: brightness)
        }

        let saturation = maxC > 0 ? delta / maxC : 0

        var hue: Double
        if r == maxC {
            hue = (g - b) / delta
        } else if g == maxC {
            hue = 2 + (b - r) / delta
        } else {
            hue = 4 + (r - g) / delta
        }
        hue /= 6
        if hue < 0 { hue += 1 }

        return (hue: hue, saturation: saturation, brightness: brightness)
    }

    // MARK: - Presets

    static let black = ShapeColor(red: 0, green: 0, blue: 0)
    static let white = ShapeColor(red: 1, green: 1, blue: 1)
    static let clear = ShapeColor(red: 0, green: 0, blue: 0, alpha: 0)
    static let red = ShapeColor(red: 1, green: 0, blue: 0)
    static let green = ShapeColor(red: 0, green: 0.8, blue: 0)
    static let blue = ShapeColor(red: 0, green: 0, blue: 1)
    static let yellow = ShapeColor(red: 1, green: 1, blue: 0)
    static let orange = ShapeColor(red: 1, green: 0.6, blue: 0)
    static let purple = ShapeColor(red: 0.6, green: 0, blue: 0.8)
    static let pink = ShapeColor(red: 1, green: 0.4, blue: 0.7)
    static let teal = ShapeColor(red: 0, green: 0.7, blue: 0.7)
    static let gray = ShapeColor(red: 0.5, green: 0.5, blue: 0.5)
    static let lightGray = ShapeColor(red: 0.8, green: 0.8, blue: 0.8)
    static let darkGray = ShapeColor(red: 0.3, green: 0.3, blue: 0.3)
}
