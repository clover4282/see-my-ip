import AppKit
#if canImport(Sparkle)
import Sparkle
#endif
import SwiftUI

struct SettingsContainerView: View {
    @State private var updateResult: UpdateCheckResult?
    @State private var isCheckingUpdate = false
    private let updateService = UpdateService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DisplaySettingsView()
                Divider()
                BehaviorSettingsView()
                Divider()
                NotificationSettingsView()
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Update")
                        .font(.headline)

                    HStack(spacing: 12) {
                        #if canImport(Sparkle)
                        Button("Check for Updates") {
                            AppDelegate.updater?.checkForUpdates()
                        }
                        .buttonStyle(InteractiveButtonStyle())
                        #else
                        Button {
                            isCheckingUpdate = true
                            updateResult = nil
                            Task {
                                let result = await updateService.checkForUpdates()
                                isCheckingUpdate = false
                                updateResult = result
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if isCheckingUpdate {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                                Text("Check for Updates")
                                    .font(.caption)
                                    .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                            }
                        }
                        .buttonStyle(InteractiveButtonStyle())
                        .disabled(isCheckingUpdate)

                        if let result = updateResult {
                            switch result {
                            case .upToDate:
                                Text("Up to date")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            case .newVersion(let version, let url):
                                Button {
                                    NSWorkspace.shared.open(url)
                                } label: {
                                    Text("v\(version) available")
                                        .font(.caption)
                                        .interactiveForeground(idle: .orange, hover: .accentColor, pressed: .accentColor)
                                }
                                .buttonStyle(InteractiveButtonStyle())
                            case .error(let message):
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .lineLimit(1)
                            }
                        }
                        #endif

                        Spacer()

                        Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Text("About")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Button {
                            if let url = URL(string: "https://github.com/clover4282/see-my-ip") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Text("GitHub")
                                .font(.caption)
                                .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                        }
                        .buttonStyle(InteractiveButtonStyle())

                        Button {
                            if let url = URL(string: "mailto:clover4282@gmail.com?subject=SeeMyIP%20Bug%20Report&body=App%20Version:%20\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")%0AmacOS:%20\(ProcessInfo.processInfo.operatingSystemVersionString)%0A%0ADescription:%0A") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Text("Report Bug")
                                .font(.caption)
                                .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                        }
                        .buttonStyle(InteractiveButtonStyle())
                    }
                }
                Divider()
                HStack {
                    Spacer()
                    BuyMeCoffeeButton()
                }
            }
            .padding()
        }
    }
}

struct BuyMeCoffeeButton: View {
    var compact: Bool = false

    var body: some View {
        Button {
            guard let url = URL(string: "https://buymeacoffee.com/clover4282") else { return }
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: compact ? 4 : 8) {
                BuyMeACoffeeLogo()
                    .frame(width: compact ? 12 : 22, height: compact ? 12 : 22)
                Text(compact ? "Coffee" : "Buy me a coffee")
                    .font(.system(size: compact ? 10 : 13, weight: .semibold))
            }
            .padding(.horizontal, compact ? 6 : 12)
            .padding(.vertical, compact ? 2 : 5)
            .foregroundStyle(Color.black.opacity(0.86))
            .background(
                RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.84, blue: 0.12))
            )
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}
