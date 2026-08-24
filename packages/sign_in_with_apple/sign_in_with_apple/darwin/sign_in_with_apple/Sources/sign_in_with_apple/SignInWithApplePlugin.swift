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
            // Apple anchors Sign in with Apple to the current view's window:
            // https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple#Request-Authorization-with-Apple-ID
            //
            // Flutter recommends getting window/scene context from the registrar's viewController:
            // https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
            instance = SignInWithAppleAvailablePlugin(
                presentationAnchorProvider: { [weak registrar] in
                    registrar?.viewController?.view.window
                }
            )
        } else {
            instance = SignInWithAppleUnavailablePlugin()
        }

        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}
