import SwiftUI

struct CopyableText: View {
    let text: String
    let font: Font
    let onCopy: (String) -> Void
    @State private var isCopied = false

    init(_ text: String, font: Font = .system(.body, design: .monospaced), onCopy: @escaping (String) -> Void) {
        self.text = text
        self.font = font
        self.onCopy = onCopy
    }

    var body: some View {
        Button {
            onCopy(text)
            withAnimation {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isCopied = false
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(text)
                    .font(font)
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(isCopied ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}
