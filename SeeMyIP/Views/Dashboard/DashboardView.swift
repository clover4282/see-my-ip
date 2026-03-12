import AppKit
import SwiftUI

struct DashboardView: View {
    @Environment(IPDashboardViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow

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
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .padding(.vertical, 8)
                        .background(viewModel.currentTab == tab ? Color.accentColor.opacity(0.1) : .clear)
                        .contentShape(Rectangle())
                        .interactiveForeground(
                            idle: viewModel.currentTab == tab ? .primary : .secondary,
                            hover: .accentColor,
                            pressed: .accentColor
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(InteractiveButtonStyle(cornerRadius: 10))
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
                }
            }
            .frame(height: 380)

            Divider()

            // Footer
            HStack {
                Spacer()
                BuyMeCoffeeButton(compact: true)
                Button {
                    openWindow(id: "settings")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                } label: {
                    Text("Settings")
                        .font(.caption)
                        .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                }
                .buttonStyle(InteractiveButtonStyle())
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text("Quit")
                        .font(.caption)
                        .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                }
                .buttonStyle(InteractiveButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        .onAppear {
            viewModel.currentTab = .dashboard
            if let lastUpdated = viewModel.lastUpdated,
               Date().timeIntervalSince(lastUpdated) < 30 {
                return
            }
            Task { await viewModel.refresh() }
        }
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
                        if let url = URL(string: "x-apple.systempreferences:com.apple.Network-Settings.extension") {
                            NSWorkspace.shared.open(url)
                            NSApp.keyWindow?.close()
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "network")
                            Text("Network Settings")
                        }
                        .font(.system(size: 11))
                        .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                    }
                    .buttonStyle(InteractiveButtonStyle())
                    .help("Open Network Settings")
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
                    .buttonStyle(InteractiveButtonStyle())
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
                    copiedItemID: viewModel.copiedItemID,
                    onCopy: viewModel.copyToClipboard
                )

                // Local IPs
                if !viewModel.localInterfaces.isEmpty {
                    LocalIPCardView(
                        interfaces: viewModel.localInterfaces,
                        copiedItemID: viewModel.copiedItemID,
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
