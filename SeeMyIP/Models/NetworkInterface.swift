import Foundation

enum NetworkInterfaceType: String, Codable, CaseIterable {
    case wifi
    case ethernet
    case vpn
    case cellular
    case bridge
    case loopback
    case other
    case none

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .ethernet: return "Ethernet"
        case .vpn: return "VPN"
        case .cellular: return "Cellular"
        case .bridge: return "Bridge"
        case .loopback: return "Loopback"
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
        case .bridge: return "point.3.connected.trianglepath.dotted"
        case .loopback: return "arrow.triangle.2.circlepath"
        case .other: return "network"
        case .none: return "wifi.slash"
        }
    }

    var statusColor: String {
        switch self {
        case .wifi, .ethernet: return "green"
        case .vpn: return "orange"
        case .cellular, .bridge, .loopback, .other: return "yellow"
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
