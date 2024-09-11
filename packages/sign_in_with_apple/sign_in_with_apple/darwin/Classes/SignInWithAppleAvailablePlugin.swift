import AuthenticationServices

#if os(OSX)
import FlutterMacOS
#elseif os(iOS)
import Flutter
#endif

let methodChannelName = "com.aboutyou.dart_packages.sign_in_with_apple"

// No @available is needed here since we will conditionally handle OS versions
public class SignInWithAppleAvailablePlugin: NSObject, FlutterPlugin {
    // Wrap the variable in an availability check to prevent errors
    var _lastSignInWithAppleAuthorizationController: Any?

    public static func register(with registrar: FlutterPluginRegistrar) {
        print("SignInWithAppleAvailablePlugin tried to register which is not allowed")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            if #available(macOS 10.15, *) {
                result(true)
            } else {
                result(false)
            }

        case "performAuthorizationRequest":
            // Ensure arguments exist and is a List
            guard let args = call.arguments as? [Any] else {
                result(SignInWithAppleGenericError.missingArguments(call).toFlutterError())
                return
            }

            // Only proceed if macOS 10.15 or newer is available
            if #available(macOS 10.15, *) {
                let signInController = SignInWithAppleAuthorizationController(result)
                // Safely cast to avoid errors on macOS 10.14
                _lastSignInWithAppleAuthorizationController = signInController

                signInController.performRequests(
                    requests: SignInWithAppleAuthorizationController.parseRequests(rawRequests: args)
                )
            } else {
                result(FlutterError(code: "UNSUPPORTED_OS", message: "macOS 10.15 or higher is required for Sign in with Apple", details: nil))
            }

        case "getCredentialState":
            guard let args = call.arguments as? [String: Any], let userIdentifier = args["userIdentifier"] as? String else {
                result(SignInWithAppleGenericError.missingArgument(call, "userIdentifier").toFlutterError())
                return
            }

            if #available(macOS 10.15, *) {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                    if let error = error {
                        result(SignInWithAppleError.credentialsError(error.localizedDescription).toFlutterError())
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
                        result(SignInWithAppleError.unexpectedCredentialsState(credentialState).toFlutterError())
                    }
                }
            } else {
                result(FlutterError(code: "UNSUPPORTED_OS", message: "macOS 10.15 or higher is required for Sign in with Apple", details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
class SignInWithAppleAuthorizationController: NSObject, ASAuthorizationControllerDelegate {
    var callback: FlutterResult

    init(_ callback: @escaping FlutterResult) {
        self.callback = callback
    }

    public static func parseRequests(rawRequests: [Any]) -> [ASAuthorizationRequest] {
        var requests: [ASAuthorizationRequest] = []

        for request in rawRequests {
            guard let requestMap = request as? [String: Any], let type = requestMap["type"] as? String else {
                print("[SignInWithApplePlugin]: Invalid request format")
                continue
            }

            switch type {
            case "appleid":
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let appleIDRequest = appleIDProvider.createRequest()

                if let nonce = requestMap["nonce"] as? String {
                    appleIDRequest.nonce = nonce
                }

                if let state = requestMap["state"] as? String {
                    appleIDRequest.state = state
                }

                if let scopes = requestMap["scopes"] as? [String] {
                    appleIDRequest.requestedScopes = scopes.compactMap {
                        switch $0 {
                        case "email":
                            return .email
                        case "fullName":
                            return .fullName
                        default:
                            print("[SignInWithApplePlugin]: Unknown scope: \($0)")
                            return nil
                        }
                    }
                }

                requests.append(appleIDRequest)
            case "password":
                let passwordProvider = ASAuthorizationPasswordProvider()
                let passwordRequest = passwordProvider.createRequest()
                requests.append(passwordRequest)
            default:
                print("[SignInWithApplePlugin]: Unknown request type: \(type)")
            }
        }

        return requests
    }

    public func performRequests(requests: [ASAuthorizationRequest]) {
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    private func parseData(data: Data?) -> String? {
        return data.flatMap { String(decoding: $0, as: UTF8.self) }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
                "state": appleIDCredential.state
            ]
            callback(result)

        case let passwordCredential as ASPasswordCredential:
            let result: [String: String] = [
                "type": "password",
                "username": passwordCredential.user,
                "password": passwordCredential.password
            ]
            callback(result)

        default:
            callback(SignInWithAppleError.unknownCredentials(authorization.credential).toFlutterError())
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        if let error = error as? ASAuthorizationError {
            callback(SignInWithAppleError.authorizationError(error.code, error.localizedDescription).toFlutterError())
        } else {
            callback(SignInWithAppleError.authorizationError(ASAuthorizationError.Code.unknown, error.localizedDescription).toFlutterError())
        }
    }
}
