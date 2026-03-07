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
                    Button {
                        viewModel.clearHistory()
                    } label: {
                        Text("Clear")
                            .font(.caption)
                            .interactiveForeground(idle: .red, hover: .red, pressed: .red)
                    }
                    .buttonStyle(InteractiveButtonStyle())
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
                    LazyVStack(spacing: 0) {
                        let items = viewModel.history
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, entry in
                            HistoryRow(
                                entry: entry,
                                endTimestamp: index == 0 ? nil : items[index - 1].timestamp,
                                copiedItemID: viewModel.copiedItemID,
                                onCopy: viewModel.copyToClipboard
                            )
                            if index < items.count - 1 {
                                Divider()
                            }
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
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        formatter.zeroFormattingBehavior = [.dropLeading]
        return formatter
    }()

    let entry: IPHistoryEntry
    let endTimestamp: Date?
    let copiedItemID: String?
    let onCopy: (String, String?) -> Void

    var body: some View {
        let itemID = "history:\(entry.id.uuidString)"

        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Button { onCopy(entry.ip, itemID) } label: {
                    HStack(spacing: 6) {
                        Text(formattedIP(entry.ip))
                            .font(.system(.callout, design: .monospaced))
                            .fontWeight(.medium)
                            .interactiveForeground(idle: .primary, hover: .accentColor, pressed: .accentColor)
                        Image(systemName: copiedItemID == itemID ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.caption2)
                            .interactiveForeground(
                                idle: copiedItemID == itemID ? .green : .secondary.opacity(0.5),
                                hover: copiedItemID == itemID ? .green : .accentColor,
                                pressed: copiedItemID == itemID ? .green : .accentColor
                            )
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(InteractiveButtonStyle())

                metadataView
            }

            Spacer(minLength: 0)

            if endTimestamp == nil {
                Text("NOW")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(.green))
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var metadataView: some View {
        if let endTimestamp {
            Text("\(Self.timestampFormatter.string(from: entry.timestamp)) · active \(durationText(until: endTimestamp, isCurrent: false))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        } else {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                Text("\(Self.timestampFormatter.string(from: entry.timestamp)) · active \(durationText(until: context.date, isCurrent: true))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func durationText(until endDate: Date, isCurrent: Bool) -> String {
        let interval = max(0, endDate.timeIntervalSince(entry.timestamp))
        if let duration = Self.durationFormatter.string(from: interval) {
            return duration
        }
        return isCurrent ? "now" : "< 1m"
    }

    private func formattedIP(_ ip: String) -> String {
        let ipv4Style = IPDisplayFormat(rawValue: ipv4Format) ?? .full
        let ipv6Style = IPDisplayFormat(rawValue: ipv6Format) ?? .hidden
        return IPFormatter.format(ip, ipv4Style: ipv4Style, ipv6Style: ipv6Style)
    }
}
