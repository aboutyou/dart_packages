import AuthenticationServices
import FlutterMacOS

public class SignInWithApplePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger
        )
        
        if #available(macOS 10.15, *) {
            let instance = SignInWithAppleAvailablePlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        } else {
            let instance = SignInWithAppleUnavailablePlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
    }
}
