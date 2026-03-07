import Foundation

final class GeoLocationService {
    enum GeoError: Error, LocalizedError {
        case lookupFailed
        var errorDescription: String? { "Geolocation lookup failed" }
    }

    func lookup(ip: String) async throws -> GeoLocation {
        guard let encoded = ip.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: Constants.API.ipApiGeoURL + encoded) else {
            throw GeoError.lookupFailed
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw GeoError.lookupFailed
        }
        let geo = try JSONDecoder().decode(GeoLocation.self, from: data)
        guard geo.status == "success" else {
            throw GeoError.lookupFailed
        }
        return geo
    }
}
