import Foundation

enum Constants {
    enum API {
        static let ipifyURL = "https://api.ipify.org?format=json"
        static let ifconfigURL = "https://ifconfig.me/ip"
        static let awsCheckIPURL = "https://checkip.amazonaws.com"
        static let ipApiGeoURL = "http://ip-api.com/json/"
    }

    enum Defaults {
        static let autoLocalInterface = "auto"
        static let refreshInterval = 300
        static let maxHistoryEntries = 50
        static let historyFileName = "ip_history.json"
        static let registeredSettings: [String: Any] = [
            UserDefaultsKeys.refreshInterval: refreshInterval,
            UserDefaultsKeys.menuBarDisplayMode: "icon",
            UserDefaultsKeys.menuBarLocalInterface: autoLocalInterface,
            UserDefaultsKeys.ipv4Format: "full",
            UserDefaultsKeys.ipv6Format: "hidden",
            UserDefaultsKeys.notifyOnIPChange: true,
            UserDefaultsKeys.playNotificationSound: true,
            UserDefaultsKeys.startAtLogin: false
        ]
    }

    enum UserDefaultsKeys {
        static let refreshInterval = "refreshInterval"
        static let menuBarDisplayMode = "menuBarDisplayMode"
        static let menuBarLocalInterface = "menuBarLocalInterface"
        static let ipv4Format = "ipv4Format"
        static let ipv6Format = "ipv6Format"
        static let notifyOnIPChange = "notifyOnIPChange"
        static let playNotificationSound = "playNotificationSound"
        static let startAtLogin = "startAtLogin"
    }
}
