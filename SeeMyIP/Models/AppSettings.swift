import Foundation

enum MenuBarDisplayMode: String, CaseIterable {
    case iconOnly = "icon"
    case publicIP = "publicIP"
    case publicIPSummary = "publicIPSummary"
    case localIP = "localIP"
    case localIPSummary = "localIPSummary"

    var displayName: String {
        switch self {
        case .iconOnly: return "Icon"
        case .publicIP: return "Public IP"
        case .publicIPSummary: return "Public IP Summary"
        case .localIP: return "Local IP"
        case .localIPSummary: return "Local IP Summary"
        }
    }
}

enum IPDisplayFormat: String, CaseIterable {
    case full = "full"
    case hidden = "hidden"
    case firstTwo = "firstTwo"
    case lastTwo = "lastTwo"
    case firstAndLast = "firstAndLast"

    var displayName: String {
        switch self {
        case .full: return "Full"
        case .hidden: return "Hidden"
        case .firstTwo: return "First 2 octets"
        case .lastTwo: return "Last 2 octets"
        case .firstAndLast: return "First & last"
        }
    }
}

enum CountryDisplayFormat: String, CaseIterable {
    case hidden = "hidden"
    case emojiFlag = "emojiFlag"
    case countryCode = "countryCode"
    case countryName = "countryName"

    var displayName: String {
        switch self {
        case .hidden: return "Hidden"
        case .emojiFlag: return "Emoji Flag"
        case .countryCode: return "Country Code"
        case .countryName: return "Country Name"
        }
    }
}

enum RefreshInterval: Int, CaseIterable {
    case off = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .oneMinute: return "1 min"
        case .fiveMinutes: return "5 min"
        case .fifteenMinutes: return "15 min"
        }
    }
}
