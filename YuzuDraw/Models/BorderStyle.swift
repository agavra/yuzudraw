import Foundation

enum StrokeStyle: String, Codable, CaseIterable, Sendable {
    case single
    case double
    case rounded
    case heavy

    var horizontal: Character {
        switch self {
        case .single, .rounded: return "─"
        case .double: return "═"
        case .heavy: return "━"
        }
    }

    var vertical: Character {
        switch self {
        case .single, .rounded: return "│"
        case .double: return "║"
        case .heavy: return "┃"
        }
    }

    var topLeft: Character {
        switch self {
        case .single: return "┌"
        case .double: return "╔"
        case .rounded: return "╭"
        case .heavy: return "┏"
        }
    }

    var topRight: Character {
        switch self {
        case .single: return "┐"
        case .double: return "╗"
        case .rounded: return "╮"
        case .heavy: return "┓"
        }
    }

    var bottomLeft: Character {
        switch self {
        case .single: return "└"
        case .double: return "╚"
        case .rounded: return "╰"
        case .heavy: return "┗"
        }
    }

    var bottomRight: Character {
        switch self {
        case .single: return "┘"
        case .double: return "╝"
        case .rounded: return "╯"
        case .heavy: return "┛"
        }
    }

    var teeDown: Character {
        switch self {
        case .single, .rounded: return "┬"
        case .double: return "╦"
        case .heavy: return "┳"
        }
    }

    var teeUp: Character {
        switch self {
        case .single, .rounded: return "┴"
        case .double: return "╩"
        case .heavy: return "┻"
        }
    }

    var teeRight: Character {
        switch self {
        case .single, .rounded: return "├"
        case .double: return "╠"
        case .heavy: return "┣"
        }
    }

    var teeLeft: Character {
        switch self {
        case .single, .rounded: return "┤"
        case .double: return "╣"
        case .heavy: return "┫"
        }
    }

    var cross: Character {
        switch self {
        case .single, .rounded: return "┼"
        case .double: return "╬"
        case .heavy: return "╋"
        }
    }
}

typealias BorderStyle = StrokeStyle
