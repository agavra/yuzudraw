import XCTest

@MainActor
final class CanvasEndToEndUITests: XCTestCase {
    private enum UIID {
        static let newProjectButton = "welcome.new-project"
        static let rectangleToolButton = "toolbar.tool.rectangle"
        static let canvasASCII = "canvas.ascii"
    }

    func test_canDrawRectangleThroughCanvas() {
        let app = XCUIApplication()
        app.launchEnvironment["YUZUDRAW_UI_TESTING"] = "1"
        app.launch()

        let newProjectButton = app.buttons[UIID.newProjectButton]
        XCTAssertTrue(newProjectButton.waitForExistence(timeout: 5))
        newProjectButton.click()

        let rectangleToolButton = app.buttons[UIID.rectangleToolButton]
        XCTAssertTrue(rectangleToolButton.waitForExistence(timeout: 5))
        rectangleToolButton.click()

        let window = app.windows.element(boundBy: 0)
        XCTAssertTrue(window.waitForExistence(timeout: 5))
        drag(on: window, from: CGVector(dx: 0.34, dy: 0.20), to: CGVector(dx: 0.48, dy: 0.34))

        let canvasASCII = app.staticTexts[UIID.canvasASCII]
        XCTAssertTrue(canvasASCII.waitForExistence(timeout: 5))

        let canvasValue = (canvasASCII.value as? String) ?? ""
        XCTAssertTrue(canvasValue.contains("┌"), "Expected rectangle border in canvas, got:\n\(canvasValue)")
        XCTAssertTrue(canvasValue.contains("┘"), "Expected rectangle border in canvas, got:\n\(canvasValue)")
    }

    private func drag(on element: XCUIElement, from start: CGVector, to end: CGVector) {
        let startCoordinate = element.coordinate(withNormalizedOffset: start)
        let endCoordinate = element.coordinate(withNormalizedOffset: end)
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
    }
}
