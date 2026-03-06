import SwiftUI

struct SettingsContainerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DisplaySettingsView()
                Divider()
                BehaviorSettingsView()
                Divider()
                NotificationSettingsView()
            }
            .padding()
        }
    }
}
