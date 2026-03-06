import SwiftUI

@main
struct SeeMyIPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private static let settingsWindowID = "settings"
    @State private var viewModel = IPDashboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            DashboardView()
                .environment(viewModel)
        } label: {
            Text(viewModel.menuBarTitle)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: Self.settingsWindowID) {
            SettingsContainerView()
                .environment(viewModel)
                .frame(width: 360)
        }
        .windowResizability(.contentSize)
    }
}
