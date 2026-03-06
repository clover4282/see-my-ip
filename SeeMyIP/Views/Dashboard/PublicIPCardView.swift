import SwiftUI

struct PublicIPCardView: View {
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    let ip: String?
    let geoLocation: GeoLocation?
    let isLoading: Bool
    let copiedItemID: String?
    let onCopy: (String, String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.blue)
                Text("Public IP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isLoading && ip == nil {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else if let ip {
                let itemID = "public:\(ip)"
                let isCopied = copiedItemID == itemID
                let displayIP = formattedIP(ip)

                Button { onCopy(ip, itemID) } label: {
                    HStack {
                        Text(displayIP)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.semibold)
                            .interactiveForeground(idle: .primary, hover: .accentColor, pressed: .accentColor)
                        Spacer()
                        Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            .interactiveForeground(idle: isCopied ? .green : .secondary, hover: isCopied ? .green : .accentColor, pressed: isCopied ? .green : .accentColor)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .buttonStyle(InteractiveButtonStyle(cornerRadius: 10))

                if let geo = geoLocation {
                    GeoLocationView(location: geo)
                }
            } else {
                Text("Unable to determine")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.linearGradient(
                    colors: [.blue.opacity(0.08), .purple.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
    }

    private func formattedIP(_ ip: String) -> String {
        let ipv4Style = IPDisplayFormat(rawValue: ipv4Format) ?? .full
        let ipv6Style = IPDisplayFormat(rawValue: ipv6Format) ?? .hidden
        return IPFormatter.format(ip, ipv4Style: ipv4Style, ipv6Style: ipv6Style)
    }
}
