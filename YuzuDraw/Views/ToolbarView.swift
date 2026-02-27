import SwiftUI

struct ToolbarView: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        HStack(spacing: 6) {
            toolButton(type: .select, icon: "cursorarrow", tooltip: "Select")
            toolButton(type: .box, icon: "rectangle", tooltip: "Box")
            toolButton(type: .arrow, icon: "arrow.right", tooltip: "Line")
            toolButton(type: .text, icon: "textformat", tooltip: "Text")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, y: 2)
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
