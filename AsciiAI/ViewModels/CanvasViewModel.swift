import SwiftUI

@Observable
final class CanvasViewModel {
    var canvas: Canvas

    init(canvas: Canvas = Canvas()) {
        self.canvas = canvas
    }
}
