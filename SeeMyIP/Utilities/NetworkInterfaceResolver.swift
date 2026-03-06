import Foundation

enum NetworkInterfaceResolver {
    private static let hiddenPrefixes = [
        "bridge", "ap", "awdl", "llw", "anpi", "gif", "stf", "XHC", "pktap"
    ]

    static var isHidden: (String) -> Bool = { name in
        hiddenPrefixes.contains { name.hasPrefix($0) }
    }

    static func resolveType(for name: String) -> NetworkInterfaceType {
        switch name {
        case "en0":
            return .wifi
        case let n where n.hasPrefix("en"):
            return .ethernet
        case let n where n.hasPrefix("utun"):
            return .vpn
        case let n where n.hasPrefix("ipsec"):
            return .vpn
        case let n where n.hasPrefix("pdp_ip"):
            return .cellular
        default:
            return .other
        }
    }

    static func displayName(for name: String) -> String {
        let type = resolveType(for: name)
        return "\(type.displayName) (\(name))"
    }
}
