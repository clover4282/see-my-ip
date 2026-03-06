import Foundation

final class IPHistoryService {
    private var entries: [IPHistoryEntry] = []

    private var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("SeeMyIP", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent(Constants.Defaults.historyFileName)
    }

    init() {
        loadHistory()
    }

    func addEntry(_ entry: IPHistoryEntry) {
        entries.insert(entry, at: 0)
        if entries.count > Constants.Defaults.maxHistoryEntries {
            entries = Array(entries.prefix(Constants.Defaults.maxHistoryEntries))
        }
        saveHistory()
    }

    func getHistory() -> [IPHistoryEntry] {
        entries
    }

    func clearHistory() {
        entries.removeAll()
        saveHistory()
    }

    private func loadHistory() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        entries = (try? decoder.decode([IPHistoryEntry].self, from: data)) ?? []
    }

    private func saveHistory() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
