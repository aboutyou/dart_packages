import Flutter
import UIKit
import AuthenticationServices

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "de.aboutyou.mobile.app.sign_in_with_apple", binaryMessenger: registrar.messenger())
    let instance = SwiftSignInWithApplePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    NSLog("NS receiving call \(call.method)")
    print("receiving call \(call.method)");
    
    if #available(iOS 13.0, *) {
        if call.method == "signInWithApple" {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let passwordProvider = ASAuthorizationPasswordProvider()
            let passwordRequest = passwordProvider.createRequest()
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [passwordRequest, request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
  }
}

@available(iOS 13.0, *)
extension SwiftSignInWithApplePlugin : ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("DONE");
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("Apple ID credentials \(userIdentifier) \(fullName?.givenName ?? "") \(fullName?.familyName ?? "") \(email ?? "")");
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("web credentials \(username) \(password)");
            
        default:
            break
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("error");
        NSLog("error")
    }
}
