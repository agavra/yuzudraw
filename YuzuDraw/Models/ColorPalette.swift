import Foundation

struct ColorPaletteEntry: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var color: ShapeColor

    init(id: UUID = UUID(), name: String, color: ShapeColor) {
        self.id = id
        self.name = name
        self.color = color
    }
}

struct ColorPalette: Codable, Equatable, Sendable {
    var entries: [ColorPaletteEntry]

    static let `default` = ColorPalette(entries: [
        ColorPaletteEntry(name: "Black", color: .black),
        ColorPaletteEntry(name: "Dark Gray", color: .darkGray),
        ColorPaletteEntry(name: "Gray", color: .gray),
        ColorPaletteEntry(name: "Light Gray", color: .lightGray),
        ColorPaletteEntry(name: "White", color: .white),
        ColorPaletteEntry(name: "Red", color: .red),
        ColorPaletteEntry(name: "Orange", color: .orange),
        ColorPaletteEntry(name: "Yellow", color: .yellow),
        ColorPaletteEntry(name: "Green", color: .green),
        ColorPaletteEntry(name: "Teal", color: .teal),
        ColorPaletteEntry(name: "Blue", color: .blue),
        ColorPaletteEntry(name: "Purple", color: .purple),
        ColorPaletteEntry(name: "Pink", color: .pink),
        ColorPaletteEntry(
            name: "Light Blue",
            color: ShapeColor(red: 0.4, green: 0.7, blue: 1.0)
        ),
        ColorPaletteEntry(
            name: "Light Green",
            color: ShapeColor(red: 0.4, green: 0.9, blue: 0.4)
        ),
        ColorPaletteEntry(
            name: "Light Yellow",
            color: ShapeColor(red: 1.0, green: 1.0, blue: 0.6)
        ),
    ])
}
