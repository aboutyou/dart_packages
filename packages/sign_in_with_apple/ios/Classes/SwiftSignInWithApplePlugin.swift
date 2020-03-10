import Flutter
import UIKit
import AuthenticationServices

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
  var _lastAYSignInWithAppleAuthorizationControllerDelegate: Any? = nil // will be `AYSignInWithAppleAuthorizationControllerDelegate` in practice, but we can't scope the variable to iOS13+

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "de.aboutyou.mobile.app.sign_in_with_apple", binaryMessenger: registrar.messenger())
    let instance = SwiftSignInWithApplePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            switch call.method {
                case "performAuthorizationRequest":                    
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    request.requestedScopes = [.fullName, .email]
                       
                    let passwordProvider = ASAuthorizationPasswordProvider()
                    let passwordRequest = passwordProvider.createRequest()
                           
                    let authorizationController = ASAuthorizationController(authorizationRequests: [passwordRequest, request])
                    let delegate = AYSignInWithAppleAuthorizationControllerDelegate(result)
                    _lastAYSignInWithAppleAuthorizationControllerDelegate = delegate // store to keep alive
                    authorizationController.delegate = delegate
                    authorizationController.performRequests()
                
                case "getCredentialState":
                    // Makes sure arguments exists and is a Map
                    guard let args = call.arguments as? [String: Any] else {
                        result(
                            FlutterError(
                                code: "MISSING_ARGS",
                                message: "Missing arguments map",
                                details: nil // call
                            )
                        );
                        return;
                    }
                                
                    guard let userIdentifier = args["userIdentifier"] as? String else {
                        return result(
                            FlutterError(
                                code: "MISSING_ARG",
                                message: "Argument 'userIdentifier' is missing",
                                details: nil // call -> call might have lead to `Unsupported value: <FlutterMethodCall: 0x6000000a2640> of type FlutterMethodCall` error
                            )
                        );
                    }
                    
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                        if let error = error {
                            result(
                                FlutterError(
                                    code: "ERR",
                                    message: "Failed to get credentials state: \(error)",
                                    details: nil // don't pass error here
                                )
                            )
                            
                            return;
                        }
                        
                        switch credentialState {
                        case .authorized:
                            result("authorized")
                            
                        case .revoked:
                            result("revoked")

                        case .notFound:
                            result("notFound")

                        default:
                            break
                        }
                    }
                
                default:
                    return result(FlutterMethodNotImplemented);
            }
        } else {
            result(
               FlutterError(
                   code: "ERR",
                   message: "Unsupported iOS version",
                   details: nil
               )
           )
        }
  }
}

@available(iOS 13.0, *)
class AYSignInWithAppleAuthorizationControllerDelegate : NSObject, ASAuthorizationControllerDelegate {
    var resultCallback: FlutterResult
    
    init(_ callback: @escaping FlutterResult) {
        resultCallback = callback
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            let result: [String:String?] = [
              "type": "appleid",
              "userIdentifier": userIdentifier,
              "givenName": fullName?.givenName,
              "familyName": fullName?.familyName,
              "email": email
            ]
            
            resultCallback(result);
        
        case let passwordCredential as ASPasswordCredential:
            let result: [String:String] = [
              "type": "password",
              "username": passwordCredential.user,
              "password": passwordCredential.password
            ]
            resultCallback(result);
            
        default:
            resultCallback("No credentials received \(authorization) \(authorization.credential)");
            
            break
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        resultCallback(
            FlutterError(
                code: "ERR",
                message: "AYSignInWithAppleAuthorizationControllerDelegate didCompleteWithError: \(error.localizedDescription)",
                details: nil // passing error would crash with `Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000 "(null)" of type NSError`
            )
        )
    }
}
