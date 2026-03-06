import Foundation

struct IPAddress: Codable, Equatable, Hashable {
    let value: String
    let version: IPVersion

    enum IPVersion: String, Codable {
        case v4
        case v6
    }

    var isV4: Bool { version == .v4 }
    var isV6: Bool { version == .v6 }

    init(value: String) {
        self.value = value
        self.version = value.contains(":") ? .v6 : .v4
    }
}
