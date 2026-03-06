import SwiftUI

struct LocalIPCardView: View {
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    let interfaces: [NetworkInterface]
    let copiedItemID: String?
    let onCopy: (String, String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Local Network")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

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

    private func interfaceRow(iface: NetworkInterface, ip: String, isV6: Bool = false) -> some View {
        let itemID = "local:\(iface.name):\(ip)"

        return HStack(spacing: 8) {
            Image(systemName: iface.type.iconName)
                .frame(width: 16)
                .foregroundStyle(.secondary)
                .font(.callout)

            Text(isV6 ? "IPv6" : iface.displayName)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 92, alignment: .leading)
                .lineLimit(1)

            Button { onCopy(ip, itemID) } label: {
                HStack(spacing: 4) {
                    Text(formattedIP(ip))
                        .font(.system(.callout, design: .monospaced))
                        .interactiveForeground(idle: .primary, hover: .accentColor, pressed: .accentColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    if copiedItemID == itemID {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(InteractiveButtonStyle())

            Spacer()
        }
    }

    private func formattedIP(_ ip: String) -> String {
        let ipv4Style = IPDisplayFormat(rawValue: ipv4Format) ?? .full
        let ipv6Style = IPDisplayFormat(rawValue: ipv6Format) ?? .hidden
        return IPFormatter.format(ip, ipv4Style: ipv4Style, ipv6Style: ipv6Style)
    }
}
