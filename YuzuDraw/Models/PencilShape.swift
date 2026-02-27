import Foundation

struct PencilCell: Codable, Equatable, Hashable, Sendable {
    var character: Character
    var color: ShapeColor?

    private enum CodingKeys: String, CodingKey {
        case character
        case color
    }

    init(character: Character, color: ShapeColor? = nil) {
        self.character = character
        self.color = color
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let charString = try container.decode(String.self, forKey: .character)
        guard let first = charString.first else {
            throw DecodingError.dataCorruptedError(
                forKey: .character, in: container,
                debugDescription: "Empty character string")
        }
        character = first
        color = try container.decodeIfPresent(ShapeColor.self, forKey: .color)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(character), forKey: .character)
        try container.encodeIfPresent(color, forKey: .color)
    }
}

struct PencilShape: Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var origin: GridPoint
    var cells: [GridPoint: PencilCell]

    init(
        id: UUID = UUID(),
        name: String? = nil,
        origin: GridPoint,
        cells: [GridPoint: PencilCell] = [:]
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.cells = cells
    }

    var boundingRect: GridRect {
        guard !cells.isEmpty else {
            return GridRect(origin: origin, size: GridSize(width: 1, height: 1))
        }
        let maxCol = cells.keys.map(\.column).max() ?? 0
        let maxRow = cells.keys.map(\.row).max() ?? 0
        return GridRect(
            origin: origin,
            size: GridSize(width: maxCol + 1, height: maxRow + 1)
        )
    }

    func contains(point: GridPoint) -> Bool {
        let offset = GridPoint(
            column: point.column - origin.column,
            row: point.row - origin.row
        )
        return cells[offset] != nil
    }

    func render(into canvas: inout Canvas) {
        for (offset, cell) in cells {
            canvas.setCharacter(
                cell.character,
                foreground: cell.color,
                background: nil,
                atColumn: origin.column + offset.column,
                row: origin.row + offset.row
            )
        }
    }

    /// Adds a cell at an absolute grid point, adjusting origin if needed to keep offsets non-negative.
    mutating func addCell(_ cell: PencilCell, at absolutePoint: GridPoint) {
        var relCol = absolutePoint.column - origin.column
        var relRow = absolutePoint.row - origin.row

        if relCol < 0 || relRow < 0 {
            let shiftCol = relCol < 0 ? -relCol : 0
            let shiftRow = relRow < 0 ? -relRow : 0

            origin = GridPoint(
                column: origin.column - shiftCol,
                row: origin.row - shiftRow
            )

            var newCells: [GridPoint: PencilCell] = [:]
            for (offset, existingCell) in cells {
                newCells[GridPoint(
                    column: offset.column + shiftCol,
                    row: offset.row + shiftRow
                )] = existingCell
            }
            cells = newCells

            relCol = absolutePoint.column - origin.column
            relRow = absolutePoint.row - origin.row
        }

        cells[GridPoint(column: relCol, row: relRow)] = cell
    }
}

// MARK: - Codable

/// GridPoint isn't a valid JSON key, so cells are encoded as an array of entries.
private struct PencilCellEntry: Codable, Sendable {
    var offset: GridPoint
    var cell: PencilCell
}

extension PencilShape: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case cells
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        origin = try container.decode(GridPoint.self, forKey: .origin)
        let entries = try container.decode([PencilCellEntry].self, forKey: .cells)
        var cellDict: [GridPoint: PencilCell] = [:]
        for entry in entries {
            cellDict[entry.offset] = entry.cell
        }
        cells = cellDict
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(origin, forKey: .origin)
        let entries = cells.map { PencilCellEntry(offset: $0.key, cell: $0.value) }
            .sorted { ($0.offset.row, $0.offset.column) < ($1.offset.row, $1.offset.column) }
        try container.encode(entries, forKey: .cells)
    }
}
