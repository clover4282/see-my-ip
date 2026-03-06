import SwiftUI

@main
struct SeeMyIPApp: App {
    @State private var viewModel = IPDashboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            DashboardView()
                .environment(viewModel)
        } label: {
            HStack(spacing: 4) {
                if viewModel.showsMenuBarIcon {
                    Image(systemName: viewModel.menuBarIcon)
                }

                if !viewModel.menuBarTitle.isEmpty {
                    Text(viewModel.menuBarTitle)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.semibold)
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
