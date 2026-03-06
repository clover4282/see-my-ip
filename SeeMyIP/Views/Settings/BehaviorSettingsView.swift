import SwiftUI

struct BehaviorSettingsView: View {
    @Environment(IPDashboardViewModel.self) private var viewModel
    @AppStorage(Constants.UserDefaultsKeys.refreshInterval) private var refreshInterval = 300
    @AppStorage(Constants.UserDefaultsKeys.startAtLogin) private var startAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Behavior")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Text("Refresh Interval")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: $refreshInterval) {
                    Text("Off").tag(0)
                    Text("1 min").tag(60)
                    Text("5 min").tag(300)
                    Text("15 min").tag(900)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)
                .onChange(of: refreshInterval) {
                    viewModel.startAutoRefresh()
                }
            }

            Toggle("Start at Login", isOn: $startAtLogin)
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)
                .onChange(of: startAtLogin) { _, newValue in
                    viewModel.updateLoginItem(enabled: newValue)
                }
        }
    }
}
