import Foundation

struct IPHistoryEntry: Identifiable, Codable {
    let id: UUID
    let ip: String
    let previousIP: String?
    let timestamp: Date
    let networkType: NetworkInterfaceType
    let country: String?
    let countryCode: String?

    init(
        ip: String,
        previousIP: String? = nil,
        networkType: NetworkInterfaceType,
        country: String? = nil,
        countryCode: String? = nil
    ) {
        self.id = UUID()
        self.ip = ip
        self.previousIP = previousIP
        self.timestamp = Date()
        self.networkType = networkType
        self.country = country
        self.countryCode = countryCode
    }
}
