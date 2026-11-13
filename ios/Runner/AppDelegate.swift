import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var liveActivity: LiveActivityBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    liveActivity = LiveActivityBridge(
      messenger: engineBridge.applicationRegistrar.messenger()
    )
    FlutterMethodChannel(
      name: "com.dogayo.wayback/screen",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    ).setMethodCallHandler { call, result in
      guard call.method == "keepOn" else {
        result(FlutterMethodNotImplemented)
        return
      }
      UIApplication.shared.isIdleTimerDisabled = call.arguments as? Bool ?? false
      result(nil)
    }
  }
}
