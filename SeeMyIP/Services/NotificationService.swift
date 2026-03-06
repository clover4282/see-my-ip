import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func sendIPChangeNotification(oldIP: String, newIP: String) {
        let content = UNMutableNotificationContent()
        content.title = "IP Address Changed"
        content.body = "Your public IP changed from \(oldIP) to \(newIP)"
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.playNotificationSound) {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
