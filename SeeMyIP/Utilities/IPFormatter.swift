import Foundation

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
        let segments = ip.split(separator: ":")
        guard segments.count >= 3 else { return ip }
        switch style {
        case .full:
            return ip
        case .hidden:
            return "****:****:****:****"
        case .firstTwo:
            return "\(segments[0]):\(segments[1]):..."
        case .lastTwo:
            return "...:\(segments[segments.count - 2]):\(segments.last ?? "")"
        case .firstAndLast:
            return "\(segments[0]):...:\(segments.last ?? "")"
        }
    }
}
