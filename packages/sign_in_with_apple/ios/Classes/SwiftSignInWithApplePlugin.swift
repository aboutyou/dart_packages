import AuthenticationServices
import Flutter
import UIKit

public class SwiftSignInWithApplePlugin: NSObject, FlutterPlugin {
    var _lastAYSignInWithAppleAuthorizationController: Any? // will be `AYSignInWithAppleAuthorizationController` in practice, but we can't scope the variable to iOS13+

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "de.aboutyou.mobile.app.sign_in_with_apple", binaryMessenger: registrar.messenger())
        let instance = SwiftSignInWithApplePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            switch call.method {
            case "performAuthorizationRequest":
                let signInController = AYSignInWithAppleAuthorizationController(result)

                // store to keep alive
                _lastAYSignInWithAppleAuthorizationController = signInController

                signInController.performRequests()

            case "getCredentialState":
                // Makes sure arguments exists and is a Map
                guard let args = call.arguments as? [String: Any] else {
                    result(
                        FlutterError(
                            code: "MISSING_ARGS",
                            message: "Missing arguments map",
                            details: nil // call
                        )
                    )

                    return
                }

                guard let userIdentifier = args["userIdentifier"] as? String else {
                    result(
                        FlutterError(
                            code: "MISSING_ARG",
                            message: "Argument 'userIdentifier' is missing",
                            details: nil // call -> call might have lead to `Unsupported value: <FlutterMethodCall: 0x6000000a2640> of type FlutterMethodCall` error
                        )
                    )

                    return
                }

                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                    if let error = error {
                        result(
                            FlutterError(
                                code: "ERR",
                                message: "Failed to get credentials state: \(error)",
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
                                code: "ERR",
                                message: "Unexpected credential state: \(credentialState)",
                                details: nil
                            )
                        )
                    }
                }

            default:
                result(FlutterMethodNotImplemented)

                return
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
class AYSignInWithAppleAuthorizationController: NSObject, ASAuthorizationControllerDelegate {
    enum CurrentAction {
        case attemptWithPasswords
        case attemptWithoutPasswords
    }

    var resultCallback: FlutterResult

    var currentAction: CurrentAction = .attemptWithPasswords

    init(_ callback: @escaping FlutterResult) {
        resultCallback = callback
    }

    public func performRequests() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        var requests: [ASAuthorizationRequest] = [request]

        if currentAction == .attemptWithPasswords {
            let passwordProvider = ASAuthorizationPasswordProvider()
            let passwordRequest = passwordProvider.createRequest()

            requests.append(passwordRequest)
        }

        let authorizationController = ASAuthorizationController(authorizationRequests: requests)

        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            let result: [String: String?] = [
                "type": "appleid",
                "userIdentifier": userIdentifier,
                "givenName": fullName?.givenName,
                "familyName": fullName?.familyName,
                "email": email,
                "identityToken": appleIDCredential.identityToken != nil ? String(decoding: appleIDCredential.identityToken!, as: UTF8.self) : nil,
                "authorizationCode": appleIDCredential.authorizationCode != nil ? String(decoding: appleIDCredential.authorizationCode!, as: UTF8.self) : nil,
            ]

            resultCallback(result)

        case let passwordCredential as ASPasswordCredential:
            let result: [String: String] = [
                "type": "password",
                "username": passwordCredential.user,
                "password": passwordCredential.password,
            ]
            resultCallback(result)

        default:
            // Not getting any credentials would result in an error (didCompleteWithError)
            resultCallback(
                FlutterError(
                    code: "ERR",
                    message: "Unexpected credentials: \(authorization.credential)",
                    details: nil
                )
            )
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        if currentAction == .attemptWithPasswords {
            // Authentication request including passwords failed, probably because the user has not any applicable
            // passwords stored in keychain
            // Internally this case fails with `Error Domain=AKAuthenticationError Code=-7001`, which is explained by Apple as
            // `This is an expected error when both password and appleid requests are passed and there are no valid password credentials`
            //
            // I haven't found a way to check for that specific error code, so we just assume that that is the reason when a request with password fails,
            // and then try again without a password
            currentAction = .attemptWithoutPasswords

            return performRequests()
        }

        resultCallback(
            FlutterError(
                code: "ERR",
                message: "AYSignInWithAppleAuthorizationController didCompleteWithError: \(error.localizedDescription) \((error as NSError).domain) \((error as NSError).code)",
                details: nil
            )
        )
    }
}
