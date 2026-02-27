import SwiftUI

struct ToolbarView: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 4) {
                toolButton(type: .select, icon: "cursorarrow", tooltip: "Select")
                toolButton(type: .box, icon: "rectangle", tooltip: "Box")
                toolButton(type: .arrow, icon: "arrow.right", tooltip: "Line")
                toolButton(type: .text, icon: "textformat", tooltip: "Text")
            }
            .padding(.vertical, 3)
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(height: 34)
        .background(.bar)
    }

    private func toolButton(type: ToolType, icon: String, tooltip: String) -> some View {
        Button {
            viewModel.activeToolType = type
        } label: {
            Image(systemName: icon)
                .frame(width: 24, height: 20)
        }
        .controlSize(.small)
        .buttonStyle(.bordered)
        .tint(viewModel.activeToolType == type ? .accentColor : nil)
        .help(tooltip)
    }
}

#Preview {
    ToolbarView(viewModel: EditorViewModel())
}
