import AuthenticationServices
import Flutter
import UIKit

public enum SignInWithAppleError {
    case notSupported(String)
    
    case missingArguments(FlutterMethodCall)
    
    case missingArgument(FlutterMethodCall, String)
    
    @available(iOS 13.0, *)
    case credentialsError(String)
    @available(iOS 13.0, *)
    case unexpectedCredentialsState(ASAuthorizationAppleIDProvider.CredentialState)
    @available(iOS 13.0, *)
    case unknownCredentials(ASAuthorizationCredential)
    @available(iOS 13.0, *)
    case authorizationError(ASAuthorizationError.Code, String)
    
    func toFlutterError() -> FlutterError {
        switch self {
        case .notSupported(let message):
            return FlutterError(
                code: "not-supported",
                message: message,
                details: nil
            )
        case .credentialsError(let message):
            return FlutterError(
                code: "credentials-error",
                message: message,
                details: nil
            )
        case .unexpectedCredentialsState(let credentialState):
            return FlutterError(
                code: "unexpected-credentials-state",
                message: "Unexpected credential state: \(credentialState)",
                details: nil
            )
        case .unknownCredentials(let credential):
            return FlutterError(
                code: "unknown-credentials",
                message: "Unexpected credentials: \(credential)",
                details: nil
            )
        case .authorizationError(let code, let message):
            var errorCode = "authorization-error/unknown"
            
            switch code {
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
                print("[SignInWithApplePlugin]: Unknown authorization error code: \(code)");
            }
            
            return FlutterError(
                code: errorCode,
                message: message,
                details: nil
            )
        case .missingArguments(let call):
            return FlutterError(
                code: "missing-args",
                message: "Missing arguments",
                details: call.arguments
            )
        case .missingArgument(let call, let key):
            return FlutterError(
                code: "missing-arg",
                message: "Argument '\(key)' is missing",
                details: call.arguments
            )
        }
    }
}

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
    // will be `SignInWithAppleAuthorizationController` in practice, but we can't scope the variable to iOS13+
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
                        SignInWithAppleError.missingArguments(call).toFlutterError()
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
                        SignInWithAppleError.missingArguments(call).toFlutterError()
                    )

                    return
                }

                guard let userIdentifier = args["userIdentifier"] as? String else {
                    result(
                        SignInWithAppleError.missingArgument(
                            call,
                            "userIdentifier"
                        ).toFlutterError()
                    )

                    return
                }

                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                    if let error = error {
                        result(
                            SignInWithAppleError.credentialsError(error.localizedDescription).toFlutterError()
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
                            SignInWithAppleError.unexpectedCredentialsState(credentialState).toFlutterError()
                        )
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(
                SignInWithAppleError.notSupported("Unsupported iOS version").toFlutterError()
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
                SignInWithAppleError.unknownCredentials(authorization.credential).toFlutterError()
            )
        }
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let error = error as? ASAuthorizationError {
            callback(
                SignInWithAppleError.authorizationError(error.code, error.localizedDescription)
            )
        } else {
            print("[SignInWithApplePlugin]: Unknown authorization error \(error)")
            
            callback(
                SignInWithAppleError.authorizationError(
                    ASAuthorizationError.Code.unknown,
                    error.localizedDescription
                ).toFlutterError()
            )
        }
    }
}
