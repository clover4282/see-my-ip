import AppKit
import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.notifyOnIPChange) private var notifyOnIPChange = true
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notifications")
                .font(.headline)

            Toggle("Notify when public IP changes", isOn: $notifyOnIPChange)
                .interactiveControlHover(cornerRadius: 8, baseTint: .primary, hoverTint: .accentColor)

            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.caption)
                        .interactiveForeground(idle: .secondary, hover: .accentColor, pressed: .accentColor)
                }
                .buttonStyle(InteractiveButtonStyle())
            }
        }
        .onAppear { checkNotificationStatus() }
    }

    private var statusColor: Color {
        switch notificationStatus {
        case .authorized, .provisional: return .green
        case .denied: return .red
        default: return .orange
        }
    }

    private var statusText: String {
        switch notificationStatus {
        case .authorized, .provisional: return "Notifications enabled"
        case .denied: return "Notifications disabled"
        default: return "Permission not requested"
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
            }
        }
    }
}
