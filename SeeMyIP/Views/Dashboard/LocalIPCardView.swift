import SwiftUI

struct LocalIPCardView: View {
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    let interfaces: [NetworkInterface]
    let copiedText: String?
    let onCopy: (String) -> Void
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Local Network")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(interfaces) { iface in
                    if let ipv4 = iface.ipv4Address {
                        interfaceRow(iface: iface, ip: ipv4)
                    }
                    if let ipv6 = iface.ipv6Address {
                        interfaceRow(iface: iface, ip: ipv6, isV6: true)
                    }
                }
            }
        }
    }

    private func interfaceRow(iface: NetworkInterface, ip: String, isV6: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iface.type.iconName)
                .frame(width: 16)
                .foregroundStyle(.secondary)
                .font(.caption)

            Text(isV6 ? "IPv6" : iface.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
                .lineLimit(1)

            Button { onCopy(ip) } label: {
                HStack(spacing: 4) {
                    Text(formattedIP(ip))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    if copiedText == ip {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private func formattedIP(_ ip: String) -> String {
        let ipv4Style = IPDisplayFormat(rawValue: ipv4Format) ?? .full
        let ipv6Style = IPDisplayFormat(rawValue: ipv6Format) ?? .hidden
        return IPFormatter.format(ip, ipv4Style: ipv4Style, ipv6Style: ipv6Style)
    }
}
