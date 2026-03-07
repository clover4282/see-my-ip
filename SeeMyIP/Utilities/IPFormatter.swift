import Foundation
import Network

enum IPFormatter {
    static func format(_ ip: String, style: IPDisplayFormat) -> String {
        if ip.contains(":") {
            return formatIPv6(ip, style: style)
        }
        return formatIPv4(ip, style: style)
    }

    static func format(_ ip: String, ipv4Style: IPDisplayFormat, ipv6Style: IPDisplayFormat) -> String {
        format(ip, style: ip.contains(":") ? ipv6Style : ipv4Style)
    }

    private static func formatIPv4(_ ip: String, style: IPDisplayFormat) -> String {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return ip }
        switch style {
        case .full:
            return ip
        case .hidden:
            return "***.***.***.***"
        case .firstTwo:
            return "\(parts[0]).\(parts[1]).*.*"
        case .lastTwo:
            return "*.*.\(parts[2]).\(parts[3])"
        case .firstAndLast:
            return "\(parts[0]).*.*.\(parts[3])"
        }
    }

    private static func formatIPv6(_ ip: String, style: IPDisplayFormat) -> String {
        switch style {
        case .full:
            return ip
        case .hidden:
            return "****:****:****:****"
        case .firstTwo:
            guard let segments = normalizedIPv6Segments(for: ip) else { return ip }
            let first = segments.prefix(2).joined(separator: ":")
            return "\(first):..."
        case .lastTwo:
            guard let segments = normalizedIPv6Segments(for: ip) else { return ip }
            let last = segments.suffix(2).joined(separator: ":")
            return "...:\(last)"
        case .firstAndLast:
            guard let segments = normalizedIPv6Segments(for: ip) else { return ip }
            return "\(segments.first ?? ""):...:\(segments.last ?? "")"
        }
    }

    private static func normalizedIPv6Segments(for ip: String) -> [String]? {
        guard let address = IPv6Address(ip) else { return nil }

        let bytes = Array(address.rawValue)
        guard bytes.count == 16 else { return nil }

        return stride(from: 0, to: bytes.count, by: 2).map { index in
            let value = (UInt16(bytes[index]) << 8) | UInt16(bytes[index + 1])
            return String(value, radix: 16)
        }
    }
}
