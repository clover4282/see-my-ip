import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.notifyOnIPChange) private var notifyOnIPChange = true
    @AppStorage(Constants.UserDefaultsKeys.playNotificationSound) private var playSound = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notifications")
                .font(.headline)

            Toggle("Notify when public IP changes", isOn: $notifyOnIPChange)

            Toggle("Play sound for notifications", isOn: $playSound)
                .disabled(!notifyOnIPChange)
                .foregroundStyle(notifyOnIPChange ? .primary : .secondary)
        }
    }
}
