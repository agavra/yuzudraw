import SwiftUI

struct CanvasView: View {
    @Bindable var viewModel: EditorViewModel
    private let canvasFontSize: CGFloat = 10
    @State private var charSize: CGSize = {
        let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        let size = ("M" as NSString).size(withAttributes: [.font: font])
        return size
    }()

    @State private var didMouseDown = false
    @State private var dragStartLocation: CGPoint?
    @State private var dragThresholdMet = false
    @State private var lastMouseDownTime: Date?
    @State private var lastMouseDownPoint: GridPoint?
    @State private var lastScrollOrigin: CGPoint?
    @State private var flagsMonitor: Any?
    @State private var clipView: NSClipView?
    @State private var handPreviousMouseLocation: CGPoint?
    private let rulerGutterLeft: CGFloat = 30
    private let rulerGutterTop: CGFloat = 16
    private static let diagonalNWSECursor = NSCursor(
        image: NSImage(
            systemSymbolName: "arrow.up.left.and.arrow.down.right",
            accessibilityDescription: "Diagonal Resize"
        ) ?? NSImage(),
        hotSpot: CGPoint(x: 8, y: 8)
    )
    private static let diagonalNESWCursor = NSCursor(
        image: NSImage(
            systemSymbolName: "arrow.up.right.and.arrow.down.left",
            accessibilityDescription: "Diagonal Resize"
        ) ?? NSImage(),
        hotSpot: CGPoint(x: 8, y: 8)
    )

    var body: some View {
        GeometryReader { geo in
            let _ = updateViewportSize(geo.size)
            let contentWidth = max(gridWidth(for: geo.size), CGFloat(viewModel.canvas.columns) * charSize.width)
            let contentHeight = max(gridHeight(for: geo.size), CGFloat(viewModel.canvas.rows) * charSize.height)

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    gridBackground(width: contentWidth, height: contentHeight)
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    canvasText
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    columnRuler(width: contentWidth)
                        .offset(x: rulerGutterLeft, y: 0)

                    rowRuler(height: contentHeight)
                        .offset(x: 0, y: rulerGutterTop)

                    Rectangle()
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .frame(width: rulerGutterLeft, height: rulerGutterTop)

                    selectionOverlay
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    arrowAttachmentOverlay
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)

                    ScrollViewBoundsObserver(
                        onOffsetChange: { origin in
                            handleScrollOffsetChange(origin)
                        },
                        onClipViewFound: { cv in
                            clipView = cv
                        }
                    )
                    .frame(width: 0, height: 0)
                }
                .frame(
                    width: rulerGutterLeft + contentWidth,
                    height: rulerGutterTop + contentHeight,
                    alignment: .topLeading
                )
                .gesture(dragGesture)
                .onContinuousHover(coordinateSpace: .local) { phase in
                    handleCanvasHover(phase)
                }
                .overlay(alignment: .topLeading) {
                    textEditOverlay
                        .offset(x: rulerGutterLeft, y: rulerGutterTop)
                }
            }
            .background(Color(nsColor: .textBackgroundColor))
            .overlay(alignment: .bottom) {
                ToolbarView(viewModel: viewModel)
                    .padding(.bottom, 12)
            }
            .focusable()
            .focusEffectDisabled()
            .onAppear {
                flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    viewModel.isOptionKeyPressed = event.modifierFlags.contains(.option)
                    viewModel.isShiftKeyPressed = event.modifierFlags.contains(.shift)
                    return event
                }
            }
            .onDisappear {
                if let monitor = flagsMonitor {
                    NSEvent.removeMonitor(monitor)
                    flagsMonitor = nil
                }
            }
            .onKeyPress(keys: [.delete, .deleteForward]) { _ in
                handleDeleteKeyPress()
            }
            .onKeyPress(characters: .init(charactersIn: "\u{8}\u{7f}")) { _ in
                handleDeleteKeyPress()
            }
            .onKeyPress(.escape) {
                guard !viewModel.isEditingText else { return .ignored }
                return viewModel.handleEscape() ? .handled : .ignored
            }
            .onKeyPress(keys: [.upArrow, .downArrow, .leftArrow, .rightArrow]) { press in
                guard !viewModel.selectedShapeIDs.isEmpty, !viewModel.isEditingText else {
                    return .ignored
                }
                switch press.key {
                case .upArrow:
                    viewModel.moveSelectedShapes(dx: 0, dy: -1)
                case .downArrow:
                    viewModel.moveSelectedShapes(dx: 0, dy: 1)
                case .leftArrow:
                    viewModel.moveSelectedShapes(dx: -1, dy: 0)
                case .rightArrow:
                    viewModel.moveSelectedShapes(dx: 1, dy: 0)
                default:
                    return .ignored
                }
                return .handled
            }
            .onKeyPress(characters: .init(charactersIn: "vVrRlLtTpPhH")) { press in
                guard !viewModel.isEditingText else { return .ignored }
                switch press.characters.lowercased() {
                case "v":
                    viewModel.activeToolType = .select
                case "r":
                    viewModel.activeToolType = .rectangle
                case "l":
                    viewModel.activeToolType = .arrow
                case "t":
                    viewModel.activeToolType = .text
                case "p":
                    viewModel.activeToolType = .pencil
                    let hasSelectedPencil = viewModel.selectedShapes.contains {
                        if case .pencil = $0 { return true }
                        return false
                    }
                    if !hasSelectedPencil {
                        viewModel.selectedShapeIDs = []
                    }
                case "h":
                    viewModel.activeToolType = .hand
                default:
                    return .ignored
                }
                return .handled
            }
        }
    }

    private func gridWidth(for viewportSize: CGSize) -> CGFloat {
        max(0, viewportSize.width - rulerGutterLeft)
    }

    private func gridHeight(for viewportSize: CGSize) -> CGFloat {
        max(0, viewportSize.height - rulerGutterTop)
    }

    private func updateViewportSize(_ size: CGSize) {
        let newSize = CGSize(
            width: max(0, size.width - rulerGutterLeft),
            height: max(0, size.height - rulerGutterTop)
        )
        if viewModel.viewportSize != newSize {
            DispatchQueue.main.async {
                viewModel.viewportSize = newSize
                viewModel.rerender()
            }
        }
    }

    private func handleScrollOffsetChange(_ origin: CGPoint) {
        defer { lastScrollOrigin = origin }

        guard let previous = lastScrollOrigin else { return }
        let deltaX = origin.x - previous.x
        let deltaY = origin.y - previous.y
        guard deltaX != 0 || deltaY != 0 else { return }
        guard charSize.width > 0, charSize.height > 0 else { return }
        guard viewModel.viewportSize.width > 0, viewModel.viewportSize.height > 0 else { return }

        let gridVisibleLeft = max(0, origin.x - rulerGutterLeft)
        let gridVisibleTop = max(0, origin.y - rulerGutterTop)
        let gridVisibleRight = gridVisibleLeft + viewModel.viewportSize.width
        let gridVisibleBottom = gridVisibleTop + viewModel.viewportSize.height

        let visibleMaxColumn = Int(ceil(gridVisibleRight / charSize.width))
        let visibleMaxRow = Int(ceil(gridVisibleBottom / charSize.height))

        viewModel.expandCanvasForScrollIfNeeded(
            visibleMaxColumn: visibleMaxColumn,
            visibleMaxRow: visibleMaxRow,
            deltaX: deltaX,
            deltaY: deltaY
        )
    }

    // MARK: - Column ruler

    private func columnRuler(width: CGFloat) -> some View {
        SwiftUI.Canvas { context, size in
            let cols = Int(ceil(width / charSize.width))
            let rulerFont = Font.system(size: 9, design: .monospaced)
            for col in stride(from: 0, through: cols, by: 5) {
                let x = CGFloat(col) * charSize.width
                let text = Text("\(col)").font(rulerFont).foregroundColor(.secondary)
                context.draw(
                    text, at: CGPoint(x: x + 1, y: size.height / 2), anchor: .leading)
            }
        }
        .frame(width: width, height: rulerGutterTop)
    }

    // MARK: - Row ruler

    private func rowRuler(height: CGFloat) -> some View {
        SwiftUI.Canvas { context, size in
            let rows = Int(ceil(height / charSize.height))
            let rulerFont = Font.system(size: 9, design: .monospaced)
            for row in stride(from: 0, through: rows, by: 5) {
                let y = CGFloat(row) * charSize.height
                let text = Text("\(row)").font(rulerFont).foregroundColor(.secondary)
                context.draw(
                    text, at: CGPoint(x: size.width - 4, y: y + charSize.height / 2),
                    anchor: .trailing)
            }
        }
        .frame(width: rulerGutterLeft, height: height)
    }

    // MARK: - Grid background

    private func gridBackground(width: CGFloat, height: CGFloat) -> some View {
        SwiftUI.Canvas { context, _ in
            let cols = Int(ceil(width / charSize.width))
            let rows = Int(ceil(height / charSize.height))

            let gridColor = Color.gray.opacity(0.15)

            for col in 0...cols {
                let x = CGFloat(col) * charSize.width
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    },
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }

            for row in 0...rows {
                let y = CGFloat(row) * charSize.height
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    },
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Canvas text

    private var canvasText: some View {
        Text(viewModel.canvas.renderAttributed(defaultForeground: .black))
            .font(.system(size: canvasFontSize, design: .monospaced))
            .textSelection(.disabled)
            .fixedSize()
            .contentShape(Rectangle())
    }

    // MARK: - Selection overlay

    private var selectionOverlay: some View {
        ZStack(alignment: .topLeading) {
            if let groupRect = viewModel.selectedGroupBoundingRect {
                // Group selected but not entered — show dashed bounding box
                Rectangle()
                    .fill(Color.accentColor.opacity(0.05))
                    .overlay(
                        Rectangle()
                            .strokeBorder(
                                style: SwiftUI.StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                            .foregroundStyle(Color.accentColor)
                    )
                    .frame(
                        width: CGFloat(groupRect.size.width) * charSize.width,
                        height: CGFloat(groupRect.size.height) * charSize.height
                    )
                    .offset(
                        x: CGFloat(groupRect.origin.column) * charSize.width,
                        y: CGFloat(groupRect.origin.row) * charSize.height
                    )
            } else if viewModel.selectedShapes.count <= 1 {
                ForEach(viewModel.selectedShapes) { shape in
                    if case .arrow(let arrow) = shape {
                        ForEach(shape.resizeHandlePlacements, id: \.self) { placement in
                            let handleOffset = arrowHandleOffset(for: placement.handle, in: arrow)
                            Circle()
                                .fill(Color.accentColor)
                                .overlay(
                                    Circle()
                                        .stroke(Color(nsColor: .textBackgroundColor), lineWidth: 1)
                                )
                                .frame(width: 8, height: 8)
                                .offset(
                                    x: (CGFloat(placement.point.column) + handleOffset.x) * charSize.width - 4,
                                    y: (CGFloat(placement.point.row) + handleOffset.y) * charSize.height - 4
                                )
                        }
                    } else {
                        let rect = shape.boundingRect
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .stroke(Color.accentColor, lineWidth: 1)
                                .frame(
                                    width: CGFloat(rect.size.width) * charSize.width,
                                    height: CGFloat(rect.size.height) * charSize.height
                                )
                                .offset(
                                    x: CGFloat(rect.origin.column) * charSize.width,
                                    y: CGFloat(rect.origin.row) * charSize.height
                                )

                            ForEach(shape.resizeHandlePlacements, id: \.self) { placement in
                                let handlePosition = rectHandlePixelPosition(
                                    placement: placement, rect: rect, charSize: charSize
                                )
                                Circle()
                                    .fill(Color.accentColor)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(nsColor: .textBackgroundColor), lineWidth: 1)
                                    )
                                    .frame(width: 8, height: 8)
                                    .offset(
                                        x: handlePosition.x - 4,
                                        y: handlePosition.y - 4
                                    )
                            }
                        }
                    }
                }
            } else {
                ForEach(viewModel.selectedShapes) { shape in
                    let rect = shape.boundingRect
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.08))
                        .overlay(
                            Rectangle()
                                .stroke(Color.accentColor.opacity(0.95), lineWidth: 1)
                        )
                        .frame(
                            width: CGFloat(rect.size.width) * charSize.width,
                            height: CGFloat(rect.size.height) * charSize.height
                        )
                        .offset(
                            x: CGFloat(rect.origin.column) * charSize.width,
                            y: CGFloat(rect.origin.row) * charSize.height
                        )
                }
            }
            marqueeOverlay
        }
    }

    private func rectHandlePixelPosition(
        placement: ResizeHandlePlacement, rect: GridRect, charSize: CGSize
    ) -> CGPoint {
        let minX = CGFloat(rect.minColumn) * charSize.width
        let maxX = CGFloat(rect.maxColumn + 1) * charSize.width
        let minY = CGFloat(rect.minRow) * charSize.height
        let maxY = CGFloat(rect.maxRow + 1) * charSize.height
        let midX = (minX + maxX) / 2
        let midY = (minY + maxY) / 2
        switch placement.handle {
        case .topLeft: return CGPoint(x: minX, y: minY)
        case .top: return CGPoint(x: midX, y: minY)
        case .topRight: return CGPoint(x: maxX, y: minY)
        case .right: return CGPoint(x: maxX, y: midY)
        case .bottomRight: return CGPoint(x: maxX, y: maxY)
        case .bottom: return CGPoint(x: midX, y: maxY)
        case .bottomLeft: return CGPoint(x: minX, y: maxY)
        case .left: return CGPoint(x: minX, y: midY)
        default: return CGPoint(x: CGFloat(placement.point.column) * charSize.width, y: CGFloat(placement.point.row) * charSize.height)
        }
    }

    private func arrowHandleOffset(for handle: ResizeHandle, in arrow: ArrowShape) -> CGPoint {
        let direction = endpointDirection(for: handle, in: arrow)
        switch direction {
        case .left:
            return CGPoint(x: 0.25, y: 0.5)
        case .right:
            return CGPoint(x: 0.75, y: 0.5)
        case .up:
            return CGPoint(x: 0.5, y: 0.25)
        case .down:
            return CGPoint(x: 0.5, y: 0.75)
        case .none:
            return CGPoint(x: 0.5, y: 0.5)
        }
    }

    private enum EndpointDirection {
        case left
        case right
        case up
        case down
        case none
    }

    private func endpointDirection(for handle: ResizeHandle, in arrow: ArrowShape) -> EndpointDirection {
        let segments = arrow.pathSegments()
        guard !segments.isEmpty else { return .none }

        let from: GridPoint
        let to: GridPoint
        switch handle {
        case .start:
            from = segments[0].from
            to = segments[0].to
        case .end:
            from = segments[segments.count - 1].to
            to = segments[segments.count - 1].from
        case .topLeft, .top, .topRight, .right, .bottomLeft, .bottom, .bottomRight, .left:
            return .none
        }

        if to.column > from.column { return .right }
        if to.column < from.column { return .left }
        if to.row > from.row { return .down }
        if to.row < from.row { return .up }
        return .none
    }

    // MARK: - Marquee overlay

    @ViewBuilder
    private var marqueeOverlay: some View {
        if let rect = (viewModel.activeTool as? SelectionTool)?.marqueeRect {
            Rectangle()
                .fill(Color.accentColor.opacity(0.1))
                .overlay(
                    Rectangle()
                        .strokeBorder(
                            style: SwiftUI.StrokeStyle(lineWidth: 1, dash: [4, 3])
                        )
                        .foregroundStyle(Color.accentColor)
                )
                .frame(
                    width: CGFloat(rect.size.width) * charSize.width,
                    height: CGFloat(rect.size.height) * charSize.height
                )
                .offset(
                    x: CGFloat(rect.origin.column) * charSize.width,
                    y: CGFloat(rect.origin.row) * charSize.height
                )
        }
    }

    // MARK: - Arrow attachment overlay

    @ViewBuilder
    private var arrowAttachmentOverlay: some View {
        if !viewModel.arrowAttachmentPreviewPoints.isEmpty {
            let hoveredPoint = viewModel.hoveredArrowAttachmentPoint
            ZStack(alignment: .topLeading) {
                ForEach(Array(viewModel.arrowAttachmentPreviewPoints.enumerated()), id: \.offset) {
                    _, point in
                    Rectangle()
                        .fill(point == hoveredPoint ? Color.accentColor : Color.red.opacity(0.95))
                        .overlay(
                            Rectangle()
                                .stroke(
                                    point == hoveredPoint
                                        ? Color.white
                                        : Color(nsColor: .textBackgroundColor),
                                    lineWidth: point == hoveredPoint ? 2 : 1
                                )
                        )
                        .frame(width: point == hoveredPoint ? 10 : 8, height: point == hoveredPoint ? 10 : 8)
                        .offset(
                            x: (CGFloat(point.column) + 0.5) * charSize.width - (point == hoveredPoint ? 5 : 4),
                            y: (CGFloat(point.row) + 0.5) * charSize.height - (point == hoveredPoint ? 5 : 4)
                        )
                }
            }
        }
    }

    // MARK: - Text edit overlay

    private var textEditFieldSize: CGSize {
        let text = viewModel.textEditContent
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let minChars = 6
        let padding: CGFloat = 8
        let maxLineLength = lines.map(\.count).max() ?? 0
        let charCount = max(minChars, maxLineLength + 1)
        let width = CGFloat(charCount) * charSize.width + padding
        let lineCount = max(1, lines.count)
        let height = CGFloat(lineCount) * charSize.height + 4
        return CGSize(width: width, height: height)
    }

    @ViewBuilder
    private var textEditOverlay: some View {
        if viewModel.isEditingText, let point = viewModel.textEditPoint {
            let size = textEditFieldSize
            InlineTextEditor(
                text: $viewModel.textEditContent,
                font: NSFont.monospacedSystemFont(ofSize: canvasFontSize, weight: .regular),
                onCommit: { viewModel.commitTextEdit() },
                onCancel: { viewModel.cancelTextEdit() }
            )
            .frame(width: size.width, height: size.height)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(nsColor: .textBackgroundColor))
            .border(Color.accentColor)
            .offset(
                x: CGFloat(point.column) * charSize.width - 4,
                y: CGFloat(point.row) * charSize.height
            )
        }
    }

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if viewModel.activeToolType == .hand {
                    let mouseLocation = NSEvent.mouseLocation
                    if let previous = handPreviousMouseLocation, let clipView {
                        let dx = mouseLocation.x - previous.x
                        let dy = -(mouseLocation.y - previous.y)
                        let origin = clipView.bounds.origin
                        let newOrigin = CGPoint(
                            x: max(0, origin.x - dx),
                            y: max(0, origin.y - dy)
                        )
                        clipView.scroll(to: newOrigin)
                        clipView.enclosingScrollView?.reflectScrolledClipView(clipView)
                    } else {
                        NSCursor.closedHand.set()
                    }
                    handPreviousMouseLocation = mouseLocation
                    return
                }

                let adjusted = CGPoint(
                    x: value.location.x - rulerGutterLeft,
                    y: value.location.y - rulerGutterTop
                )
                let point = viewModel.gridPoint(from: adjusted, charSize: charSize)
                if !didMouseDown {
                    didMouseDown = true
                    dragStartLocation = value.location
                    dragThresholdMet = false
                    let now = Date()
                    if let lastTime = lastMouseDownTime,
                       let lastPoint = lastMouseDownPoint,
                       now.timeIntervalSince(lastTime) < 0.3,
                       abs(point.column - lastPoint.column) <= 1,
                       abs(point.row - lastPoint.row) <= 1
                    {
                        lastMouseDownTime = nil
                        lastMouseDownPoint = nil
                        viewModel.handleDoubleClick(at: point)
                    } else {
                        lastMouseDownTime = now
                        lastMouseDownPoint = point
                        viewModel.mouseDown(at: point)
                    }
                } else {
                    if !dragThresholdMet {
                        let dx = value.location.x - (dragStartLocation?.x ?? 0)
                        let dy = value.location.y - (dragStartLocation?.y ?? 0)
                        if dx * dx + dy * dy < 16.0 { return }
                        dragThresholdMet = true
                    }
                    viewModel.mouseDragged(to: point)
                }
            }
            .onEnded { value in
                if viewModel.activeToolType == .hand {
                    handPreviousMouseLocation = nil
                    NSCursor.openHand.set()
                    return
                }

                let adjusted = CGPoint(
                    x: value.location.x - rulerGutterLeft,
                    y: value.location.y - rulerGutterTop
                )
                let point = viewModel.gridPoint(from: adjusted, charSize: charSize)
                viewModel.mouseUp(at: point)
                didMouseDown = false
            }
    }

    private func cursor(for handle: ResizeHandle) -> NSCursor {
        switch handle {
        case .top, .bottom:
            return .resizeUpDown
        case .left, .right:
            return .resizeLeftRight
        case .topLeft, .bottomRight:
            return Self.diagonalNWSECursor
        case .topRight, .bottomLeft:
            return Self.diagonalNESWCursor
        case .start, .end:
            return .openHand
        }
    }

    private func handleCanvasHover(_ phase: HoverPhase) {
        switch phase {
        case .active(let location):
            let adjusted = CGPoint(
                x: location.x - rulerGutterLeft,
                y: location.y - rulerGutterTop
            )
            guard adjusted.x >= 0, adjusted.y >= 0 else {
                viewModel.updateHoverGridPoint(nil)
                NSCursor.arrow.set()
                return
            }

            let point = viewModel.gridPoint(from: adjusted, charSize: charSize)

            switch viewModel.activeToolType {
            case .hand:
                viewModel.updateHoverGridPoint(nil)
                NSCursor.openHand.set()
            case .select:
                viewModel.updateHoverGridPoint(nil)
                if let handleCursor = cursorForHandle(at: point) {
                    handleCursor.set()
                } else {
                    NSCursor.arrow.set()
                }
            case .rectangle, .arrow, .pencil, .text:
                viewModel.updateHoverGridPoint(point)
                NSCursor.crosshair.set()
            }

        case .ended:
            viewModel.updateHoverGridPoint(nil)
            NSCursor.arrow.set()
        }
    }

    private func cursorForHandle(at point: GridPoint) -> NSCursor? {
        guard viewModel.selectedShapes.count <= 1 else { return nil }
        for shape in viewModel.selectedShapes {
            if let handle = shape.resizeHandle(at: point) {
                return cursor(for: handle)
            }
        }
        return nil
    }

    private func handleDeleteKeyPress() -> KeyPress.Result {
        guard !viewModel.selectedShapeIDs.isEmpty, !viewModel.isEditingText else {
            return .ignored
        }
        viewModel.deleteSelectedShapes()
        return .handled
    }
}

struct ScrollViewBoundsObserver: NSViewRepresentable {
    let onOffsetChange: (CGPoint) -> Void
    var onClipViewFound: ((NSClipView) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onOffsetChange: onOffsetChange, onClipViewFound: onClipViewFound)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            context.coordinator.attachIfNeeded(to: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onOffsetChange = onOffsetChange
        context.coordinator.onClipViewFound = onClipViewFound
        DispatchQueue.main.async {
            context.coordinator.attachIfNeeded(to: nsView)
        }
    }

    @MainActor
    final class Coordinator {
        var onOffsetChange: (CGPoint) -> Void
        var onClipViewFound: ((NSClipView) -> Void)?
        private weak var clipView: NSClipView?
        private var observer: NSObjectProtocol?

        init(onOffsetChange: @escaping (CGPoint) -> Void, onClipViewFound: ((NSClipView) -> Void)?) {
            self.onOffsetChange = onOffsetChange
            self.onClipViewFound = onClipViewFound
        }

        func attachIfNeeded(to view: NSView) {
            guard let scrollView = view.enclosingScrollView else { return }
            scrollView.horizontalScrollElasticity = .none
            scrollView.verticalScrollElasticity = .none
            let clip = scrollView.contentView
            guard clipView !== clip else { return }

            detach()
            clip.postsBoundsChangedNotifications = true
            observer = NotificationCenter.default.addObserver(
                forName: NSView.boundsDidChangeNotification,
                object: clip,
                queue: .main
            ) { [weak self, weak clip] _ in
                MainActor.assumeIsolated {
                    guard let self, let clip else { return }
                    self.onOffsetChange(clip.bounds.origin)
                }
            }
            clipView = clip
            onClipViewFound?(clip)
            onOffsetChange(clip.bounds.origin)
        }

        private func detach() {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
                self.observer = nil
            }
            clipView = nil
        }

        nonisolated func cleanUp() {
            MainActor.assumeIsolated {
                detach()
            }
        }

        deinit {
            cleanUp()
        }
    }
}

// MARK: - Inline Text Editor

struct InlineTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let textView = scrollView.documentView as! NSTextView
        textView.delegate = context.coordinator
        textView.font = font
        textView.string = text
        textView.isRichText = false
        textView.drawsBackground = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
            textView.selectAll(nil)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: InlineTextEditor

        init(_ parent: InlineTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if let event = NSApp.currentEvent, event.modifierFlags.contains(.shift) {
                    textView.insertNewlineIgnoringFieldEditor(nil)
                    return true
                }
                parent.onCommit()
                return true
            }
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onCancel()
                return true
            }
            return false
        }
    }
}

#Preview {
    CanvasView(viewModel: {
        let vm = EditorViewModel()
        vm.document.addShape(
            .rectangle(RectangleShape(
                origin: GridPoint(column: 5, row: 3),
                size: GridSize(width: 14, height: 5),
                strokeStyle: .single,
                label: "Server"
            )),
            toLayerAt: 0
        )
        vm.document.addShape(
            .rectangle(RectangleShape(
                origin: GridPoint(column: 30, row: 3),
                size: GridSize(width: 14, height: 5),
                strokeStyle: .double,
                label: "Database"
            )),
            toLayerAt: 0
        )
        vm.document.addShape(
            .arrow(ArrowShape(
                start: GridPoint(column: 19, row: 5),
                end: GridPoint(column: 30, row: 5)
            )),
            toLayerAt: 0
        )
        vm.rerender()
        return vm
    }())
    .frame(width: 600, height: 400)
}
