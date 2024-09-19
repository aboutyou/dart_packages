import UIKit
import Flutter


#if (os(iOS) && swift(>=6.0)) || (os(macOS) && swift(>=6.0.0))
@main
#else
@UIApplicationMain
#endif
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
