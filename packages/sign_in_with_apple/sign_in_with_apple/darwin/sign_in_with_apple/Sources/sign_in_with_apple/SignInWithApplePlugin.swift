import AuthenticationServices

#if os(OSX)
import FlutterMacOS
#elseif os(iOS)
import Flutter
// UIKit is only available on iOS and we need it for UIDevice
import UIKit
#endif

public class SignInWithApplePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger

        #if os(macOS)
        messenger = registrar.messenger
        #else
        messenger = registrar.messenger()
        #endif

        let channel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: messenger
        )

        let instance: FlutterPlugin

        if #available(macOS 10.15, iOS 13.0, *) {
            instance = SignInWithAppleAvailablePlugin()
        } else {
            instance = SignInWithAppleUnavailablePlugin()
        }

        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}
