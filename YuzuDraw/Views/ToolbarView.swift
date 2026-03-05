import SwiftUI

struct ToolbarView: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        HStack(spacing: 6) {
            toolButton(type: .select, icon: "cursorarrow", tooltip: "Select (V)")
            toolButton(type: .hand, icon: "hand.raised", tooltip: "Hand (H)")
            toolButton(type: .rectangle, icon: "rectangle", tooltip: "Rectangle (R)")
            toolButton(type: .arrow, icon: "arrow.right", tooltip: "Line (L)")
            toolButton(type: .text, icon: "textformat", tooltip: "Text (T)")
            toolButton(type: .pencil, icon: "pencil.and.scribble", tooltip: "Pencil (P)")
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
            if type == .pencil {
                let hasSelectedPencil = viewModel.selectedShapes.contains {
                    if case .pencil = $0 { return true }
                    return false
                }
                if !hasSelectedPencil {
                    viewModel.selectedShapeIDs = []
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: type == .pencil ? 14 : 12))
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
