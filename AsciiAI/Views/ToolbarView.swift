import SwiftUI

struct ToolbarView: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        HStack(spacing: 12) {
            toolButtons
            Divider().frame(height: 24)
            borderStylePicker
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
    }

    private var toolButtons: some View {
        HStack(spacing: 4) {
            toolButton(type: .select, label: "Select", icon: "arrow.uturnleft")
            toolButton(type: .box, label: "Box", icon: "rectangle")
            toolButton(type: .arrow, label: "Line", icon: "arrow.right")
            toolButton(type: .text, label: "Text", icon: "textformat")
        }
    }

    private func toolButton(type: ToolType, label: String, icon: String) -> some View {
        Button {
            viewModel.activeToolType = type
        } label: {
            Label(label, systemImage: icon)
                .frame(minWidth: 60)
        }
        .buttonStyle(.bordered)
        .tint(viewModel.activeToolType == type ? .accentColor : nil)
    }

    private var borderStylePicker: some View {
        HStack(spacing: 8) {
            Text("Border:")
                .foregroundStyle(.secondary)
            Picker("Border Style", selection: Binding(
                get: { viewModel.activeBorderStyle },
                set: { viewModel.setBorderStyle($0) }
            )) {
                Text("Single ─│┌┐").tag(BorderStyle.single)
                Text("Double ═║╔╗").tag(BorderStyle.double)
                Text("Rounded ─│╭╮").tag(BorderStyle.rounded)
                Text("Heavy ━┃┏┓").tag(BorderStyle.heavy)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
        }
    }
}

#Preview {
    ToolbarView(viewModel: EditorViewModel())
}
