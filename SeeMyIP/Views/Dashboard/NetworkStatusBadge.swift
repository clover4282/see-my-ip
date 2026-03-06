import SwiftUI

struct NetworkStatusBadge: View {
    let type: NetworkInterfaceType
    let isConnected: Bool
    var isVPN: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            PulsingDot(color: statusColor)
            Image(systemName: type.iconName)
                .font(.caption)
            Text(statusText)
                .font(.caption)
            if isVPN {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("VPN")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary.opacity(0.5), in: Capsule())
    }

    private var statusColor: Color {
        if !isConnected { return .red }
        if isVPN { return .orange }
        switch type {
        case .wifi, .ethernet: return .green
        default: return .yellow
        }
    }

    private var statusText: String {
        if !isConnected { return "Disconnected" }
        return "\(type.displayName) Connected"
    }
}
