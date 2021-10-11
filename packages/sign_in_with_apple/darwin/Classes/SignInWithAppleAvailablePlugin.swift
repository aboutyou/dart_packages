import AuthenticationServices

#if os(OSX)
import FlutterMacOS
#elseif os(iOS)
import Flutter
#endif

let methodChannelName = "com.aboutyou.dart_packages.sign_in_with_apple"

@available(iOS 13.0, macOS 10.15, *)
public class SignInWithAppleAvailablePlugin: NSObject, FlutterPlugin {
    var _lastSignInWithAppleAuthorizationController: SignInWithAppleAuthorizationController?

    // This plugin should not be registered with directly
    //
    // This is merely a cross-platform plugin to handle the case Sign in with Apple is available
    // on the target platform
    //
    // Each target platform will still need a specific Plugin implementation
    // which will need to decide whether or not Sign in with Apple is available
    public static func register(with registrar: FlutterPluginRegistrar) {
        print("SignInWithAppleAvailablePlugin tried to register which is not allowed")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            result(true)
            
        case "performAuthorizationRequest":
            // Makes sure arguments exists and is a List
            guard let args = call.arguments as? [Any] else {
                result(
                    SignInWithAppleGenericError.missingArguments(call).toFlutterError()
                )
                return
            }

            let signInController = SignInWithAppleAuthorizationController(result)

            // store to keep alive
            _lastSignInWithAppleAuthorizationController = signInController

            signInController.performRequests(
                requests: SignInWithAppleAuthorizationController.parseRequests(
                    rawRequests: args
                )
            )

        case "getCredentialState":
            // Makes sure arguments exists and is a Map
            guard let args = call.arguments as? [String: Any] else {
                result(
                    SignInWithAppleGenericError.missingArguments(call).toFlutterError()
                )
                return
            }

            guard let userIdentifier = args["userIdentifier"] as? String else {
                result(
                    SignInWithAppleGenericError.missingArgument(
                        call,
                        "userIdentifier"
                    ).toFlutterError()
                )
                return
            }

            let appleIDProvider = ASAuthorizationAppleIDProvider()

            appleIDProvider.getCredentialState(forUserID: userIdentifier) {
                credentialState, error in
                if let error = error {
                    result(
                        SignInWithAppleError
                            .credentialsError(error.localizedDescription)
                            .toFlutterError()
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
                        SignInWithAppleError
                            .unexpectedCredentialsState(credentialState)
                            .toFlutterError()
                    )
                }
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

    // Parses a list of json requests into the proper [ASAuthorizationRequest] type.
    //
    // The parsing itself tries to be as lenient as possible to recover gracefully from parsing errors.
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

                if let nonce = requestMap["nonce"] as? String {
                    appleIDRequest.nonce = nonce;
                }

                if let state = requestMap["state"] as? String {
                    appleIDRequest.state = state;
                }

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

    public func performRequests(requests: [ASAuthorizationRequest]) {
        let authorizationController = ASAuthorizationController(
            authorizationRequests: requests
        )

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
                "state": appleIDCredential.state,
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
                SignInWithAppleError.unknownCredentials(
                    authorization.credential
                ).toFlutterError()
            )
        }
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let error = error as? ASAuthorizationError {
            callback(
                SignInWithAppleError.authorizationError(
                    error.code,
                    error.localizedDescription
                ).toFlutterError()
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