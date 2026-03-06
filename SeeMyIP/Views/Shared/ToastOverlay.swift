import SwiftUI

struct ToastOverlay: View {
    let message: String
    let isShowing: Bool

    var body: some View {
        VStack {
            if isShowing {
                Text(message)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(duration: 0.3), value: isShowing)
    }
}
