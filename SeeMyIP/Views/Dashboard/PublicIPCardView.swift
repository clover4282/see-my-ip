import SwiftUI

struct PublicIPCardView: View {
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    let ip: String?
    let geoLocation: GeoLocation?
    let isLoading: Bool
    let copiedText: String?
    let onCopy: (String) -> Void

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
                let isCopied = copiedText == ip
                let displayIP = formattedIP(ip)

                Button { onCopy(ip) } label: {
                    HStack {
                        Text(displayIP)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            .foregroundStyle(isCopied ? .green : .secondary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .buttonStyle(.plain)

                if let geo = geoLocation {
                    GeoLocationView(location: geo)
                }

                Text(isCopied ? "Copied!" : "tap to copy")
                    .font(.caption2)
                    .foregroundStyle(isCopied ? Color.green : Color.gray.opacity(0.5))
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
