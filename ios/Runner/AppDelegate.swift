import Flutter

import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, TProxyService.StatusChangeListener {
    private var methodChannel: FlutterMethodChannel?
    private var tProxyService: TProxyService?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        self.tProxyService = TProxyService()
        self.tProxyService!.setStatusChangeListener(self)

        setupFlutterMethodChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private var fileObservers = [String: DispatchSourceFileSystemObject]()

    private func setupFlutterMethodChannel() {
        let controller = window?.rootViewController as! FlutterViewController
        self.methodChannel = FlutterMethodChannel(
            name: "com.github.anyportal.anyportal", binaryMessenger: controller.binaryMessenger)

        self.methodChannel!.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "vpn.startAll":
                self.tProxyService?.startAll()
                result(true)
            
            case "vpn.stopAll":
                self.tProxyService?.stopAll()
                result(true)
            
            case "vpn.startCore":
                self.tProxyService?.startCore()
                result(true)
            
            case "vpn.stopCore":
                self.tProxyService?.stopCore()
                result(true)
            
            case "vpn.startTun":
                self.tProxyService?.startTun()
                result(true)
            
            case "vpn.stopTun":
                self.tProxyService?.stopTun()
                result(true)
            
            case "vpn.isCoreActive":
                result(self.tProxyService?.isCoreActive)
            
            case "vpn.isTunActive":
                result(self.tProxyService?.isTunActive)
            
            case "vpn.isSystemProxyActive":
                result(false)
                
            case "log.core.startWatching":
                if let filePath = call.arguments as? [String: Any],
                    let path = filePath["filePath"] as? String
                {

                    let fileURL = URL(fileURLWithPath: path)
                    let fileDescriptor = open(fileURL.path, O_EVTONLY)

                    if fileDescriptor != -1 {
                        let source = DispatchSource.makeFileSystemObjectSource(
                            fileDescriptor: fileDescriptor,
                            eventMask: .write,
                            queue: DispatchQueue.main
                        )

                        source.setEventHandler {
                            self.methodChannel!.invokeMethod("onFileChange", arguments: path)
                        }

                        source.setCancelHandler {
                            close(fileDescriptor)
                        }

                        source.resume()
                        self.fileObservers[path] = source
                    }
                }

            case "log.core.stopWatching":
                if let args = call.arguments as? [String: Any],
                    let path = args["filePath"] as? String
                {

                    if let source = self.fileObservers[path] {
                        source.cancel()
                        self.fileObservers.removeValue(forKey: path)
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func onAllStatusChange(isCoreActive: Bool) {
        DispatchQueue.main.async {
            self.methodChannel?.invokeMethod("onAllStatusChange", arguments: isCoreActive)
        }
    }

    func onCoreStatusChange(isCoreActive: Bool) {
        DispatchQueue.main.async {
            self.methodChannel?.invokeMethod("onCoreStatusChange", arguments: isCoreActive)
        }
    }

    func onTunStatusChange(isTunActive: Bool) {
        DispatchQueue.main.async {
            self.methodChannel?.invokeMethod("onTunStatusChange", arguments: isTunActive)
        }
    }
}
