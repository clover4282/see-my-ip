import Foundation

struct GitHubRelease: Decodable {
    let tagName: String
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
    }
}

enum UpdateCheckResult {
    case upToDate
    case newVersion(version: String, url: URL)
    case error(String)
}

actor UpdateService {
    private let repo = "clover4282/see-my-ip"

    func checkForUpdates() async -> UpdateCheckResult {
        let urlString = "https://api.github.com/repos/\(repo)/releases/latest"
        guard let url = URL(string: urlString) else {
            return .error("Invalid URL")
        }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                return .error("No releases found")
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

            if compareVersions(latestVersion, isNewerThan: currentVersion) {
                if let releaseURL = URL(string: release.htmlUrl) {
                    return .newVersion(version: latestVersion, url: releaseURL)
                }
            }

            return .upToDate
        } catch {
            return .error(error.localizedDescription)
        }
    }

    private func compareVersions(_ latest: String, isNewerThan current: String) -> Bool {
        let latestParts = latest.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(latestParts.count, currentParts.count)
        for i in 0..<maxCount {
            let l = i < latestParts.count ? latestParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if l > c { return true }
            if l < c { return false }
        }
        return false
    }
}
