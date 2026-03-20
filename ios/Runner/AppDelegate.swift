import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BirthdayWidgetChannel") {
        let binaryMessenger = registrar.messenger()
        let widgetChannel = FlutterMethodChannel(name: "com.example.birthday_progress/widget",
                                                  binaryMessenger: binaryMessenger)
        widgetChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if call.method == "updateWidget" {
            if let args = call.arguments as? [String: Any],
               let day = args["day"] as? Int,
               let month = args["month"] as? Int {
              
              if let userDefaults = UserDefaults(suiteName: "group.com.example.birthdayProgress") {
                  userDefaults.set(day, forKey: "birthday_day")
                  userDefaults.set(month, forKey: "birthday_month")
                  userDefaults.synchronize()
              }
              
              if #available(iOS 14.0, *) {
                  WidgetCenter.shared.reloadAllTimelines()
              }
              result(nil)
            } else {
              result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are missing", details: nil))
            }
          } else {
            result(FlutterMethodNotImplemented)
          }
        })
    }
  }
}
