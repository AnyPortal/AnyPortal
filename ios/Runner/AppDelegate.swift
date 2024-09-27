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
            if call.method == "startTProxyService" {
                self.startTProxyService()
                result(nil)
            } else if call.method == "stopTProxyService" {
                self.stopTProxyService()
                result(nil)
            } else if call.method == "isTProxyServiceRunning" {
                let isRunning = self.isTProxyServiceRunning()
                result(isRunning)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // Start the TProxyService (equivalent to startService() in Java)
    private func startTProxyService() {
        tProxyService?.startService()
    }

    // Stop the TProxyService (equivalent to stopService() in Java)
    private func stopTProxyService() {
        tProxyService?.stopService()
    }
    
    var _isTProxyServiceRunning: Bool = false
    
    private func updateIsTProxyServiceRunning(value: Bool) {
        _isTProxyServiceRunning = value
    }

    // Check if the TProxyService is running
    private func isTProxyServiceRunning() -> Bool {
        tProxyService?.isServiceRunning(completion: updateIsTProxyServiceRunning)
        return _isTProxyServiceRunning
    }
}
