import Foundation
import SwiftUI
import Network
import ServiceManagement

enum AppTab: String, CaseIterable {
    case dashboard
    case history

    var icon: String {
        switch self {
        case .dashboard: return "network"
        case .history: return "clock"
        }
    }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .history: return "History"
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
    var copiedItemID: String?
    var showLocalIPs: Bool = true
    var currentTab: AppTab = .dashboard
    var history: [IPHistoryEntry] = []

    // MARK: - Settings (tracked for reactivity)
    var menuBarDisplayModeValue: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.menuBarDisplayMode) ?? "icon"
    var menuBarLocalInterfaceValue: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.menuBarLocalInterface) ?? Constants.Defaults.autoLocalInterface

    // MARK: - Services
    private let publicIPService = PublicIPService()
    private let localNetworkService = LocalNetworkService()
    private let geoLocationService = GeoLocationService()
    private let historyService = IPHistoryService()

    private var refreshTask: Task<Void, Never>?
    private var networkDebounceTask: Task<Void, Never>?
    private var copyResetTask: Task<Void, Never>?
    @ObservationIgnored private var defaultsObserver: Any?

    // MARK: - Menu Bar
    var menuBarTitle: String {
        let mode = MenuBarDisplayMode(rawValue: menuBarDisplayModeValue) ?? .iconOnly
        switch mode {
        case .iconOnly:
            return "IP"
        case .publicIP:
            return publicIP ?? "IP"
        case .publicIPSummary:
            return summarizedIP(publicIP) ?? "IP"
        case .localIP:
            return selectedLocalIPAddress ?? "IP"
        case .localIPSummary:
            return summarizedIP(selectedLocalIPAddress) ?? "IP"
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
                guard let self else { return }
                self.networkDebounceTask?.cancel()
                self.networkDebounceTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    await self?.refresh()
                }
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
                self.menuBarLocalInterfaceValue = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.menuBarLocalInterface) ?? Constants.Defaults.autoLocalInterface
            }
        }
    }

    // MARK: - Actions
    func refresh() async {
        isLoading = true
        errorMessage = nil

        let networkStatus = localNetworkService.currentStatus()
        localInterfaces = localNetworkService.getLocalInterfaces()
        networkType = networkStatus.networkType
        isConnected = networkStatus.isConnected
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
        if errorMessage == nil {
            lastUpdated = Date()
        }
    }

    func copyToClipboard(_ text: String, itemID: String? = nil) {
        ClipboardService.copy(text)
        let copiedID = itemID ?? text
        copiedItemID = copiedID
        copyResetTask?.cancel()
        copyResetTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            if copiedItemID == copiedID {
                copiedItemID = nil
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

    private var selectedLocalIPAddress: String? {
        let selectedInterfaceName = menuBarLocalInterfaceValue

        if selectedInterfaceName != Constants.Defaults.autoLocalInterface,
           let selectedInterface = localInterfaces.first(where: { $0.name == selectedInterfaceName }) {
            if let ipv4 = selectedInterface.ipv4Address {
                return ipv4
            }
            if let ipv6 = selectedInterface.ipv6Address {
                return ipv6
            }
        }

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
