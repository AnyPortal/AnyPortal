import Foundation
// import NetworkExtension
import Libv2raymobile


class TProxyService {
    public var isCoreActive = false;
    public var isTunActive = false;
    public var isSystemProxyActive = false;
    weak var statusChangeListener: StatusChangeListener?

    protocol StatusChangeListener: AnyObject {
        func onAllStatusChange(isCoreActive: Bool)
        func onCoreStatusChange(isCoreActive: Bool)
        func onTunStatusChange(isTunActive: Bool)
    }

    func setStatusChangeListener(_ listener: StatusChangeListener?) {
        self.statusChangeListener = listener
    }

    private func notifyAppDelegateAllStatusChange() {
        statusChangeListener?.onAllStatusChange(isCoreActive: isCoreActive)
    }

    private func notifyAppDelegateCoreStatusChange() {
        statusChangeListener?.onCoreStatusChange(isCoreActive: isCoreActive)
    }

    private func notifyAppDelegateTunStatusChange() {
        statusChangeListener?.onTunStatusChange(isTunActive: isTunActive)
    }

    func startAll(){
        startCore()
        startTun()
        notifyAppDelegateAllStatusChange()
    }

    func stopAll(){
        stopTun()
        stopCore()
        notifyAppDelegateAllStatusChange()
    }

    public var coreManager: Libv2raymobileCoreManager?
    private let preferences = UserDefaults.standard

    func startCore(){
        let geoipPath = Bundle.main.path(forResource: "geoip", ofType: "dat")
        let assetPath = (geoipPath! as NSString).deletingLastPathComponent
        let configFilePath = getConfigFilePath()

        coreManager = Libv2raymobileCoreManager()
        Libv2raymobileSetEnv("v2ray.location.asset", assetPath)
        Libv2raymobileSetEnv("xray.location.asset", assetPath)
        coreManager!.runConfig(configFilePath)
    
        isCoreActive = true
        notifyAppDelegateCoreStatusChange()
    }

    func stopCore(){
        coreManager?.stop()
        coreManager = nil
        isCoreActive = false
        notifyAppDelegateCoreStatusChange()
    }

    private func getConfigFilePath() -> String {
        let appPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appPath.appendingPathComponent("conf/core.gen.json").path
    }

    func startTun(){
        isTunActive = false
        notifyAppDelegateTunStatusChange()
    }
    
    func stopTun(){
        isTunActive = false
        notifyAppDelegateTunStatusChange()
    }
}
