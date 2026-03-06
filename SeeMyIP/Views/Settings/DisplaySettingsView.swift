import SwiftUI

struct DisplaySettingsView: View {
    @Environment(IPDashboardViewModel.self) private var viewModel
    @AppStorage(Constants.UserDefaultsKeys.menuBarDisplayMode) private var menuBarDisplayMode = "icon"
    @AppStorage(Constants.UserDefaultsKeys.menuBarLocalInterface) private var menuBarLocalInterface = Constants.Defaults.autoLocalInterface
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Display")
                .font(.headline)

            LabeledContent("Menu Bar") {
                Picker("", selection: $menuBarDisplayMode) {
                    ForEach(MenuBarDisplayMode.allCases, id: \.rawValue) { mode in
                        Text(mode.displayName).tag(mode.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)
            }

            LabeledContent("Local IP Source") {
                Picker("", selection: $menuBarLocalInterface) {
                    Text("Auto").tag(Constants.Defaults.autoLocalInterface)
                    ForEach(viewModel.localInterfaces) { interface in
                        Text(interface.displayName).tag(interface.name)
                    }
                    if showsUnavailableInterfaceOption {
                        Text("Unavailable (\(menuBarLocalInterface))").tag(menuBarLocalInterface)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .interactiveControlHover(cornerRadius: 8, enabled: usesLocalIPMode, baseTint: usesLocalIPMode ? .primary : .secondary, hoverTint: .accentColor)
                .disabled(!usesLocalIPMode)
            }

            Divider()

            Text("Privacy")
                .font(.headline)

            LabeledContent("IPv4 Format") {
                Picker("", selection: $ipv4Format) {
                    ForEach(IPDisplayFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)
            }

            LabeledContent("IPv6 Format") {
                Picker("", selection: $ipv6Format) {
                    ForEach(IPDisplayFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)
            }
        }
    }

    private var usesLocalIPMode: Bool {
        switch MenuBarDisplayMode(rawValue: menuBarDisplayMode) ?? .iconOnly {
        case .localIP, .localIPSummary:
            return true
        case .iconOnly, .publicIP, .publicIPSummary:
            return false
        }
    }

    private var showsUnavailableInterfaceOption: Bool {
        menuBarLocalInterface != Constants.Defaults.autoLocalInterface &&
        !viewModel.localInterfaces.contains(where: { $0.name == menuBarLocalInterface })
    }
}
