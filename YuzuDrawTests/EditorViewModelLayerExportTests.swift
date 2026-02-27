import Testing

@testable import YuzuDraw

@MainActor
struct EditorViewModelLayerExportTests {
    @Test func should_export_selected_layer_as_normalized_text() {
        // given
        let layer = Layer(
            name: "Layer 1",
            shapes: [
                .box(BoxShape(origin: GridPoint(column: 8, row: 6), size: GridSize(width: 4, height: 3)))
            ]
        )
        let viewModel = EditorViewModel(document: Document(layers: [layer]))
        viewModel.selectedLayerID = layer.id

        // when
        let exported = viewModel.selectedLayerPlainText()

        // then
        #expect(exported == "┌──┐\n│  │\n└──┘")
    }

    @Test func should_return_nil_when_selected_layer_has_no_shapes() {
        // given
        let layer = Layer(name: "Empty Layer")
        let viewModel = EditorViewModel(document: Document(layers: [layer]))
        viewModel.selectedLayerID = layer.id

        // when
        let exported = viewModel.selectedLayerPlainText()

        // then
        #expect(exported == nil)
    }
}
