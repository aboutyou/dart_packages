import AuthenticationServices
import Flutter
import UIKit

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
    // will be `AYSignInWithAppleAuthorizationController` in practice, but we can't scope the variable to iOS13+
    var _lastSignInWithAppleAuthorizationController: Any?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "de.aboutyou.mobile.app.sign_in_with_apple",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftSignInWithApplePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "isAvailable" {
            if #available(iOS 13.0, *) {
                result(true)
            } else {
                result(false)
            }
            
            return
        }
        
        if #available(iOS 13.0, *) {
            switch call.method {
            case "performAuthorizationRequest":
                // Makes sure arguments exists and is a List
                guard let args = call.arguments as? [Any] else {
                    result(
                        FlutterError(
                            code: "MISSING_ARGS",
                            message: "Missing arguments list",
                            details: nil // call
                        )
                    )

                    return
                }
                
                let signInController = SignInWithAppleAuthorizationController(
                    SignInWithAppleAuthorizationController.parseRequests(rawRequests: args),
                    callback: result
                )

                // store to keep alive
                _lastSignInWithAppleAuthorizationController = signInController

                signInController.performRequests()

            case "getCredentialState":
                // Makes sure arguments exists and is a Map
                guard let args = call.arguments as? [String: Any] else {
                    result(
                        FlutterError(
                            code: "MISSING_ARGS",
                            message: "Missing arguments map",
                            details: nil
                        )
                    )

                    return
                }

                guard let userIdentifier = args["userIdentifier"] as? String else {
                    result(
                        FlutterError(
                            code: "MISSING_ARG",
                            message: "Argument 'userIdentifier' is missing",
                            details: nil
                        )
                    )

                    return
                }

                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                    if let error = error {
                        result(
                            FlutterError(
                                code: "credentials-error",
                                message: error.localizedDescription,
                                details: nil
                            )
                        )

                        return
                    }

                    switch credentialState {
                    case .authorized:
                        result("authorized")

                    case .revoked:
                        result("revoked")

                    case .notFound:
                        result("notFound")

                    default:
                        result(
                            FlutterError(
                                code: "unexpected-credentials-state",
                                message: "Unexpected credential state: \(credentialState)",
                                details: nil
                            )
                        )
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(
                FlutterError(
                    code: "not-supported",
                    message: "Unsupported iOS version",
                    details: nil
                )
            )
        }
    }
}

@available(iOS 13.0, *)
class SignInWithAppleAuthorizationController: NSObject, ASAuthorizationControllerDelegate {
    var callback: FlutterResult
    
    var requests: [ASAuthorizationRequest]

    init(_ requests: [ASAuthorizationRequest], callback: @escaping FlutterResult) {
        self.requests = requests
        self.callback = callback
    }
    
    /// Parses a list of json requests into the proper [ASAuthorizationRequest] type.
    ///
    /// The parsing itself tries to be as lenient as possible to recover gracefully from parsing errors.
    public static func parseRequests(rawRequests: [Any]) -> [ASAuthorizationRequest] {
        var requests: [ASAuthorizationRequest] = []
        
        for request in rawRequests {
            guard let requestMap = request as? [String: Any] else {
                print("[SignInWithApplePlugin]: Request is not an object");
                continue
            }
            
            guard let type = requestMap["type"] as? String else {
                print("[SignInWithApplePlugin]: Request type is not an string");
                continue
            }
            
            switch (type) {
            case "appleid":
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let appleIDRequest = appleIDProvider.createRequest()
                
                if let scopes = requestMap["scopes"] as? [String] {
                    appleIDRequest.requestedScopes = []
                    
                    for scope in scopes {
                        switch scope {
                        case "email":
                            appleIDRequest.requestedScopes?.append(.email)
                        case "fullName":
                            appleIDRequest.requestedScopes?.append(.fullName)
                        default:
                            print("[SignInWithApplePlugin]: Unknown scope for the Apple ID request: \(scope)");
                            continue;
                        }
                    }
                }
                
                requests.append(appleIDRequest)
            case "password":
                let passwordProvider = ASAuthorizationPasswordProvider()
                let passwordRequest = passwordProvider.createRequest()
                
                requests.append(passwordRequest)
            default:
                print("[SignInWithApplePlugin]: Unknown request type: \(type)");
                continue;
            }
            
        }
        
        return requests
    }

    public func performRequests() {
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)

        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    private func parseData(data: Data?) -> String? {
        if let data = data {
            return String(decoding: data, as: UTF8.self)
        }
        
        return nil
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let result: [String: String?] = [
                "type": "appleid",
                "userIdentifier": appleIDCredential.user,
                "givenName": appleIDCredential.fullName?.givenName,
                "familyName": appleIDCredential.fullName?.familyName,
                "email": appleIDCredential.email,
                "identityToken": parseData(data: appleIDCredential.identityToken),
                "authorizationCode": parseData(data: appleIDCredential.authorizationCode),
            ]
            callback(result)

        case let passwordCredential as ASPasswordCredential:
            let result: [String: String] = [
                "type": "password",
                "username": passwordCredential.user,
                "password": passwordCredential.password,
            ]
            callback(result)

        default:
            // Not getting any credentials would result in an error (didCompleteWithError)
            callback(
                FlutterError(
                    code: "unknown-credentials",
                    message: "Unexpected credentials: \(authorization.credential)",
                    details: nil
                )
            )
        }
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let error = error as? ASAuthorizationError {
            var errorCode = "authorization-error/unknown"
            
            switch error.code {
            case .unknown:
                errorCode = "authorization-error/unknown"
            case .canceled:
                errorCode = "authorization-error/canceled"
            case .invalidResponse:
                errorCode = "authorization-error/invalidResponse"
            case .notHandled:
                errorCode = "authorization-error/notHandled"
            case .failed:
                errorCode = "authorization-error/failed"
            @unknown default:
                print("[SignInWithApplePlugin]: Unknown authorization error code: \(error.code)");
            }
            
            callback(
                FlutterError(
                    code: errorCode,
                    message: error.localizedDescription,
                    details: nil
                )
            )
        } else {
            print("[SignInWithApplePlugin]: Unknown authorization error \(error)")
            
            callback(
                FlutterError(
                    code: "non-authorization-error",
                    message: error.localizedDescription,
                    details: nil
                )
            )
        }
    }
}
