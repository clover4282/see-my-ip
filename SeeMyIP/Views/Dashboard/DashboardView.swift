import SwiftUI

struct DashboardView: View {
    @Environment(IPDashboardViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.currentTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.title)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.currentTab == tab ? .primary : .secondary)
                        .background(viewModel.currentTab == tab ? Color.accentColor.opacity(0.1) : .clear)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)

            Divider()

            // Content
            Group {
                switch viewModel.currentTab {
                case .dashboard:
                    dashboardContent
                case .history:
                    HistoryListView()
                case .settings:
                    SettingsContainerView()
                }
            }
            .frame(minHeight: 300)

            Divider()

            // Footer
            HStack {
                Text("Updated: \(viewModel.relativeLastUpdated)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("See My IP")
                        .font(.headline)
                    Spacer()
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                            .animation(
                                viewModel.isLoading
                                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                                    : .default,
                                value: viewModel.isLoading
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                }

                // Network status
                NetworkStatusBadge(
                    type: viewModel.networkType,
                    isConnected: viewModel.isConnected,
                    isVPN: viewModel.isVPNActive
                )

                // Public IP card
                PublicIPCardView(
                    ip: viewModel.publicIP,
                    geoLocation: viewModel.geoLocation,
                    isLoading: viewModel.isLoading,
                    copiedText: viewModel.copiedText,
                    onCopy: viewModel.copyToClipboard
                )

                // Local IPs
                if !viewModel.localInterfaces.isEmpty {
                    LocalIPCardView(
                        interfaces: viewModel.localInterfaces,
                        copiedText: viewModel.copiedText,
                        onCopy: viewModel.copyToClipboard
                    )
                }

                // Error
                if let error = viewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}
