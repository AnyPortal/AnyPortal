import UIKit
import NetworkExtension
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var tProxyService: TProxyService?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Initialize TProxyService when the app starts
        tProxyService = TProxyService()
        
        setupFlutterMethodChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupFlutterMethodChannel() {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.github.fv2ray.fv2ray", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "startTProxy" {
                self.startTProxy()
                result(nil)
            } else if call.method == "stopTProxy" {
                self.stopTProxy()
                result(nil)
            } else if call.method == "isTProxyRunning" {
                let isRunning = self.isTProxyRunning()
                result(isRunning)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // Start the TProxyService (equivalent to startService() in Java)
    private func startTProxy() {
        tProxyService?.startService()
    }

    // Stop the TProxyService (equivalent to stopService() in Java)
    private func stopTProxy() {
        tProxyService?.stopService()
    }
    
    var _isTProxyRunning: Bool = false
    
    private func updateisTProxyRunning(value: Bool) {
        _isTProxyRunning = value
    }

    // Check if the TProxyService is running
    private func isTProxyRunning() -> Bool {
        tProxyService?.isServiceRunning(completion: updateisTProxyRunning)
        return _isTProxyRunning
    }
}
