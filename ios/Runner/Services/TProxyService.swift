import Foundation
import NetworkExtension


class TProxyService {
    func createOrLoadVPNManager(completion: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                print("Error loading VPN configurations: \(error)")
                completion(nil)
                return
            }
            
            if let manager = managers?.first {
                // VPN configuration already exists, so return it
                completion(manager)
            } else {
                // No VPN configuration, create a new one
                let newManager = NETunnelProviderManager()
                
                // Configure the protocol for the tunnel
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.providerBundleIdentifier = "com.github.fv2ray.fv2ray.PacketTunnelProvider"
                tunnelProtocol.serverAddress = "127.0.0.1" // Not used but required
                
                newManager.protocolConfiguration = tunnelProtocol
                newManager.localizedDescription = "fv2ray"
                newManager.isEnabled = true
                
                // Save the new configuration
                newManager.saveToPreferences { error in
                    if let error = error {
                        print("Error saving VPN preferences: \(error)")
                        completion(nil)
                    } else {
                        print("VPN configuration saved successfully")
                        completion(newManager)
                    }
                }
            }
        }
    }

    func startService() {
        createOrLoadVPNManager { (manager) in
            guard let manager = manager else {
                print("No VPN manager available.")
                return
            }
            
            // Start the VPN using the manager
            do {
                try manager.connection.startVPNTunnel()
                print("VPN started.")
            } catch let vpnError {
                print("Failed to start VPN: \(vpnError)")
            }
        }
    }

    func stopService() {
        createOrLoadVPNManager { (manager) in
            guard let manager = manager else {
                print("No VPN manager available.")
                return
            }
            
            // Start the VPN using the manager
            do {
                try manager.connection.stopVPNTunnel()
                print("VPN started.")
            } catch let vpnError {
                print("Failed to start VPN: \(vpnError)")
            }
        }
    }

    func isServiceRunning(completion: @escaping (Bool) -> Void) {
        createOrLoadVPNManager { (manager) in
            guard let manager = manager else {
                print("No VPN manager available.")
                completion(false)
                return
            }
            
            // Check if the VPN is running
            let isRunning = manager.connection.status == .connected
            completion(isRunning)
        }
    }
}
