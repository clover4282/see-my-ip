import Foundation

final class PublicIPService {
    private struct IPifyResponse: Codable {
        let ip: String
    }

    enum IPError: Error, LocalizedError {
        case allAPIsFailed
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .allAPIsFailed: return "All IP lookup services failed"
            case .invalidResponse: return "Invalid response from IP service"
            }
        }
    }

    func fetchPublicIP() async throws -> String {
        if let ip = try? await fetchFromIPify() { return ip }
        if let ip = try? await fetchFromIfconfig() { return ip }
        if let ip = try? await fetchFromAWS() { return ip }
        throw IPError.allAPIsFailed
    }

    private func fetchFromIPify() async throws -> String {
        let url = URL(string: Constants.API.ipifyURL)!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw IPError.invalidResponse
        }
        let result = try JSONDecoder().decode(IPifyResponse.self, from: data)
        return result.ip
    }

    private func fetchFromIfconfig() async throws -> String {
        let url = URL(string: Constants.API.ifconfigURL)!
        var request = URLRequest(url: url)
        request.setValue("curl", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200,
              let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ip.isEmpty else {
            throw IPError.invalidResponse
        }
        return ip
    }

    private func fetchFromAWS() async throws -> String {
        let url = URL(string: Constants.API.awsCheckIPURL)!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200,
              let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ip.isEmpty else {
            throw IPError.invalidResponse
        }
        return ip
    }
}
