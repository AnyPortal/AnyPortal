import Foundation
import NetworkExtension
import HevSocks5Tunnel
import Libv2raymobile

class PacketTunnelProvider: NEPacketTunnelProvider {
    public var coreManager: Libv2raymobileCoreManager?
    private let preferences = UserDefaults.standard
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        if coreManager != nil {
            return
        }
        startCore()
        try! setTunnelNetworkSettings()
        startTun2Socks()

        completionHandler(nil)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        HevSocks5Tunnel.hev_socks5_tunnel_quit()
        coreManager?.stop()
        coreManager = nil

        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    func startCore() {
        let geoipPath = Bundle.main.path(forResource: "geoip", ofType: "dat")
        let assetPath = (geoipPath! as NSString).deletingLastPathComponent
        let configFilePath = getConfigFilePath()

        // Start core process (embedded or external)
        if preferences.bool(forKey: "flutter.core.useEmbedded") {
            coreManager = Libv2raymobileCoreManager()
            Libv2raymobileSetEnv("v2ray.location.asset", assetPath)
            Libv2raymobileSetEnv("xray.location.asset", assetPath)
            coreManager!.runConfig(configFilePath)
        }
    }
    
    func startTun2Socks() {
        let tunFd = getTunFd()
        if tunFd == nil {
            return
        }
        HevSocks5Tunnel.hev_socks5_tunnel_main_from_file(getTproxyConfigFilePath(), tunFd!)
    }

    private func getConfigFilePath() -> String {
        let appPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return appPath.appendingPathComponent("fv2ray/config.gen.json").path
    }
    
    private func getTproxyConfigFilePath() -> String {
        let appPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return appPath.appendingPathComponent("fv2ray/tproxy.yaml").path
    }

    private func getTunFd() -> Int32? {
        var ctlInfo = ctl_info()
        withUnsafeMutablePointer(to: &ctlInfo.ctl_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0.pointee)) {
                _ = strcpy($0, "com.apple.net.utun_control")
            }
        }
        for fd: Int32 in 0...1024 {
            var addr = sockaddr_ctl()
            var ret: Int32 = -1
            var len = socklen_t(MemoryLayout.size(ofValue: addr))
            withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    ret = getpeername(fd, $0, &len)
                }
            }
            if ret != 0 || addr.sc_family != AF_SYSTEM {
                continue
            }
            if ctlInfo.ctl_id == 0 {
                ret = ioctl(fd, CTLIOCGINFO, &ctlInfo)
                if ret != 0 {
                    continue
                }
            }
            if addr.sc_id == ctlInfo.ctl_id {
                return fd
            }
        }
        return nil
    }
    
    func setTunnelNetworkSettings() throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        var dnsServers = [String]()

        settings.mtu = NSNumber(integerLiteral: 8500)

        // IPv4 configuration
        if preferences.bool(forKey: "flutter.tun.ipv4") {
            let ipv4Address = "198.18.0.1"
            let dnsIPv4 = preferences.string(forKey: "flutter.tun.dns.ipv4") ?? "1.1.1.1"
            dnsServers.append(dnsIPv4)
            settings.ipv4Settings = {
                let settings = NEIPv4Settings(addresses: [ipv4Address], subnetMasks: ["255.255.255.255"])
                settings.includedRoutes = [NEIPv4Route.default()]
                return settings
            }()
        }

        // IPv6 configuration
        if preferences.bool(forKey: "flutter.tun.ipv4") {
            let ipv6Address = "fd6e:a81b:704f:1211::1"
            let dnsIPv6 = preferences.string(forKey: "flutter.tun.dns.ipv4") ?? "1.1.1.1"
            dnsServers.append(dnsIPv6)
            settings.ipv6Settings = {
                let settings = NEIPv6Settings(addresses: [ipv6Address], networkPrefixLengths: [64])
                settings.includedRoutes = [NEIPv6Route.default()]
                return settings
            }()
        }
        
        settings.dnsSettings = NEDNSSettings(servers: dnsServers)
        setTunnelNetworkSettings(settings)
    }
}
