import AuthenticationServices
import Flutter
import UIKit

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        let events = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: registrar.messenger()
        )

        if #available(iOS 13.0, *) {
            let instance = SignInWithAppleAvailablePlugin()
            let handlerInstance = SignInWithAppleAuthorizationHandler()
            registrar.addMethodCallDelegate(instance, channel: channel)
            events.setStreamHandler(handlerInstance)
        } else {
            let instance = SignInWithAppleUnavailablePlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
    }
}
