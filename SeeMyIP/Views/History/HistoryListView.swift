import SwiftUI

struct HistoryListView: View {
    @Environment(IPDashboardViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("IP Change History")
                    .font(.headline)
                Spacer()
                if !viewModel.history.isEmpty {
                    Button("Clear") {
                        viewModel.clearHistory()
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if viewModel.history.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundStyle(.quaternary)
                    Text("No History")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("IP changes will be recorded here")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(viewModel.history) { entry in
                            HistoryRow(entry: entry, onCopy: viewModel.copyToClipboard)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct HistoryRow: View {
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    @AppStorage(Constants.UserDefaultsKeys.countryFormat) private var countryFormat = "emojiFlag"
    let entry: IPHistoryEntry
    let onCopy: (String) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Button { onCopy(entry.ip) } label: {
                    Text(formattedIP(entry.ip))
                        .font(.system(.callout, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    if let countryText = formattedCountry {
                        Text(countryText)
                    }
                    Image(systemName: entry.networkType.iconName)
                        .font(.caption2)
                    Text(entry.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let prev = entry.previousIP {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("from")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(formattedIP(prev))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var formattedCountry: String? {
        let style = CountryDisplayFormat(rawValue: countryFormat) ?? .emojiFlag
        return CountryFlagMapper.formattedCountry(
            country: entry.country,
            countryCode: entry.countryCode,
            style: style
        )
    }

    private func formattedIP(_ ip: String) -> String {
        let ipv4Style = IPDisplayFormat(rawValue: ipv4Format) ?? .full
        let ipv6Style = IPDisplayFormat(rawValue: ipv6Format) ?? .hidden
        return IPFormatter.format(ip, ipv4Style: ipv4Style, ipv6Style: ipv6Style)
    }
}
