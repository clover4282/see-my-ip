import Foundation
import SwiftUI
import Network
import ServiceManagement

enum AppTab: String, CaseIterable {
    case dashboard
    case history
    case settings

    var icon: String {
        switch self {
        case .dashboard: return "network"
        case .history: return "clock"
        case .settings: return "gearshape"
        }
    }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
}

@Observable
@MainActor
final class IPDashboardViewModel {
    // MARK: - State
    var publicIP: String?
    var localInterfaces: [NetworkInterface] = []
    var geoLocation: GeoLocation?
    var networkType: NetworkInterfaceType = .none
    var isConnected: Bool = false
    var isVPNActive: Bool = false
    var isLoading: Bool = false
    var lastUpdated: Date?
    var errorMessage: String?
    var copiedText: String?
    var showLocalIPs: Bool = true
    var currentTab: AppTab = .dashboard
    var history: [IPHistoryEntry] = []

    // MARK: - Settings (tracked for reactivity)
    var menuBarDisplayModeValue: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.menuBarDisplayMode) ?? "icon"

    // MARK: - Services
    private let publicIPService = PublicIPService()
    private let localNetworkService = LocalNetworkService()
    private let geoLocationService = GeoLocationService()
    private let historyService = IPHistoryService()

    private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var defaultsObserver: Any?

    // MARK: - Menu Bar
    var menuBarIcon: String {
        if isVPNActive { return "shield.lefthalf.filled" }
        return networkType.iconName
    }

    var showsMenuBarIcon: Bool {
        let mode = MenuBarDisplayMode(rawValue: menuBarDisplayModeValue) ?? .iconOnly
        return mode == .iconOnly
    }

    var menuBarTitle: String {
        let mode = MenuBarDisplayMode(rawValue: menuBarDisplayModeValue) ?? .iconOnly
        switch mode {
        case .iconOnly:
            return ""
        case .publicIP:
            return publicIP ?? "IP"
        case .publicIPSummary:
            return summarizedIP(publicIP) ?? "IP"
        case .localIP:
            return primaryLocalIPAddress ?? "IP"
        case .localIPSummary:
            return summarizedIP(primaryLocalIPAddress) ?? "IP"
        }
    }

    var relativeLastUpdated: String {
        guard let date = lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Init
    init() {
        UserDefaults.standard.register(defaults: Constants.Defaults.registeredSettings)

        localNetworkService.onNetworkChange = { [weak self] in
            Task { @MainActor [weak self] in
                await self?.refresh()
            }
        }
        history = historyService.getHistory()
        NotificationService.shared.requestPermission()
        startAutoRefresh()
        Task { await refresh() }

        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.menuBarDisplayModeValue = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.menuBarDisplayMode) ?? "icon"
            }
        }
    }

    // MARK: - Actions
    func refresh() async {
        isLoading = true
        errorMessage = nil

        localInterfaces = localNetworkService.getLocalInterfaces()
        networkType = localNetworkService.currentNetworkType
        isConnected = localNetworkService.isConnected
        isVPNActive = localNetworkService.isVPNActive

        guard isConnected else {
            isLoading = false
            publicIP = nil
            geoLocation = nil
            return
        }

        do {
            let newIP = try await publicIPService.fetchPublicIP()
            let oldIP = publicIP
            let shouldLookupGeo = newIP != oldIP || geoLocation == nil || geoLocation?.query != newIP

            if newIP != oldIP {
                publicIP = newIP
            }

            if shouldLookupGeo {
                geoLocation = try? await geoLocationService.lookup(ip: newIP)
            }

            if let oldIP, newIP != oldIP {
                let entry = IPHistoryEntry(
                    ip: newIP,
                    previousIP: oldIP,
                    networkType: networkType,
                    country: geoLocation?.country,
                    countryCode: geoLocation?.countryCode
                )
                historyService.addEntry(entry)
                history = historyService.getHistory()

                let shouldNotify = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notifyOnIPChange)
                if shouldNotify {
                    NotificationService.shared.sendIPChangeNotification(oldIP: oldIP, newIP: newIP)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        lastUpdated = Date()
    }

    func copyToClipboard(_ text: String) {
        ClipboardService.copy(text)
        copiedText = text
        Task {
            try? await Task.sleep(for: .seconds(2))
            if copiedText == text {
                copiedText = nil
            }
        }
    }

    func clearHistory() {
        historyService.clearHistory()
        history = []
    }

    func startAutoRefresh() {
        refreshTask?.cancel()
        let seconds = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.refreshInterval)
        guard seconds > 0 else { return }

        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { break }
                await self?.refresh()
            }
        }
    }

    func updateLoginItem(enabled: Bool) {
        if enabled {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
    }

    private var primaryLocalIPAddress: String? {
        for interface in localInterfaces {
            if let ipv4 = interface.ipv4Address {
                return ipv4
            }
            if let ipv6 = interface.ipv6Address {
                return ipv6
            }
        }
        return nil
    }

    private func summarizedIP(_ ip: String?) -> String? {
        guard let ip else { return nil }

        if ip.contains(":") {
            let segments = ip.split(separator: ":").filter { !$0.isEmpty }
            guard let last = segments.last else { return nil }
            return ":\(last)"
        }

        let octets = ip.split(separator: ".")
        guard let last = octets.last else { return nil }
        return ".\(last)"
    }
}
