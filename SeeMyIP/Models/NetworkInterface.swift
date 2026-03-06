import Foundation

enum NetworkInterfaceType: String, Codable, CaseIterable {
    case wifi
    case ethernet
    case vpn
    case cellular
    case other
    case none

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .ethernet: return "Ethernet"
        case .vpn: return "VPN"
        case .cellular: return "Cellular"
        case .other: return "Other"
        case .none: return "No Connection"
        }
    }

    var iconName: String {
        switch self {
        case .wifi: return "wifi"
        case .ethernet: return "cable.connector"
        case .vpn: return "shield.lefthalf.filled"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .other: return "network"
        case .none: return "wifi.slash"
        }
    }

    var statusColor: String {
        switch self {
        case .wifi, .ethernet: return "green"
        case .vpn: return "orange"
        case .cellular, .other: return "yellow"
        case .none: return "red"
        }
    }
}

struct NetworkInterface: Identifiable, Codable, Equatable {
    var id: String { name }
    let name: String
    let type: NetworkInterfaceType
    let displayName: String
    let ipv4Address: String?
    let ipv6Address: String?
}
