import SwiftUI

struct DisplaySettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.menuBarDisplayMode) private var menuBarDisplayMode = "icon"
    @AppStorage(Constants.UserDefaultsKeys.ipv4Format) private var ipv4Format = "full"
    @AppStorage(Constants.UserDefaultsKeys.ipv6Format) private var ipv6Format = "hidden"
    @AppStorage(Constants.UserDefaultsKeys.countryFormat) private var countryFormat = "emojiFlag"

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
            }

            LabeledContent("IPv4 Format") {
                Picker("", selection: $ipv4Format) {
                    ForEach(IPDisplayFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            LabeledContent("IPv6 Format") {
                Picker("", selection: $ipv6Format) {
                    ForEach(IPDisplayFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            LabeledContent("Country") {
                Picker("", selection: $countryFormat) {
                    ForEach(CountryDisplayFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }
        }
    }
}
