import Foundation
import Network

final class LocalNetworkService {
    struct NetworkStatusSnapshot {
        let isConnected: Bool
        let networkType: NetworkInterfaceType
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.seemyip.networkmonitor")

    var onNetworkChange: (() -> Void)?
    private var isConnected: Bool = false
    private var currentPath: NWPath?
    private let lock = NSLock()

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.lock.lock()
            self.currentPath = path
            self.isConnected = path.status == .satisfied
            self.lock.unlock()
            self.onNetworkChange?()
        }
        monitor.start(queue: queue)
    }

    func currentStatus() -> NetworkStatusSnapshot {
        lock.lock()
        defer { lock.unlock() }

        return NetworkStatusSnapshot(
            isConnected: isConnected,
            networkType: Self.networkType(for: currentPath)
        )
    }

    private static func networkType(for path: NWPath?) -> NetworkInterfaceType {
        guard let path, path.status == .satisfied else { return .none }
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        if path.usesInterfaceType(.cellular) { return .cellular }
        return .other
    }

    /// utun/ipsec 인터페이스에 IP가 할당되어 있으면 VPN 활성 상태로 판단
    var isVPNActive: Bool {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return false }
        defer { freeifaddrs(ifaddr) }

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = ptr {
            defer { ptr = addr.pointee.ifa_next }
            guard let sockAddr = addr.pointee.ifa_addr else { continue }
            let name = String(cString: addr.pointee.ifa_name)
            let family = sockAddr.pointee.sa_family

            guard name.hasPrefix("utun") || name.hasPrefix("ipsec") else { continue }
            guard family == UInt8(AF_INET) || family == UInt8(AF_INET6) else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(sockAddr, socklen_t(sockAddr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, 0, NI_NUMERICHOST) == 0 {
                let ip = String(cString: hostname)
                if !ip.hasPrefix("fe80") && ip != "::1" && ip != "127.0.0.1" {
                    return true
                }
            }
        }
        return false
    }

    func getLocalInterfaces() -> [NetworkInterface] {
        var interfaces: [NetworkInterface] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return interfaces
        }
        defer { freeifaddrs(ifaddr) }

        var addressMap: [String: (ipv4: String?, ipv6: String?)] = [:]

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = ptr {
            defer { ptr = addr.pointee.ifa_next }

            guard let sockAddr = addr.pointee.ifa_addr else { continue }
            let family = sockAddr.pointee.sa_family
            let name = String(cString: addr.pointee.ifa_name)

            if family == UInt8(AF_INET) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(sockAddr, socklen_t(sockAddr.pointee.sa_len),
                               &hostname, socklen_t(hostname.count),
                               nil, 0, NI_NUMERICHOST) == 0 {
                    let ip = String(cString: hostname)
                    addressMap[name, default: (nil, nil)].ipv4 = ip
                }
            } else if family == UInt8(AF_INET6) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(sockAddr, socklen_t(sockAddr.pointee.sa_len),
                               &hostname, socklen_t(hostname.count),
                               nil, 0, NI_NUMERICHOST) == 0 {
                    let ip = String(cString: hostname)
                    if !ip.hasPrefix("fe80") {
                        addressMap[name, default: (nil, nil)].ipv6 = ip
                    }
                }
            }
        }

        for (name, addresses) in addressMap where addresses.ipv4 != nil || addresses.ipv6 != nil {
            guard !NetworkInterfaceResolver.isHidden(name) else { continue }
            let type = NetworkInterfaceResolver.resolveType(for: name)
            interfaces.append(NetworkInterface(
                name: name,
                type: type,
                displayName: NetworkInterfaceResolver.displayName(for: name),
                ipv4Address: addresses.ipv4,
                ipv6Address: addresses.ipv6
            ))
        }

        return interfaces.sorted { lhs, rhs in
            let order: [NetworkInterfaceType] = [.wifi, .ethernet, .vpn, .cellular, .bridge, .other, .loopback]
            let lhsIdx = order.firstIndex(of: lhs.type) ?? order.count
            let rhsIdx = order.firstIndex(of: rhs.type) ?? order.count
            if lhsIdx != rhsIdx { return lhsIdx < rhsIdx }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    deinit {
        monitor.cancel()
    }
}
