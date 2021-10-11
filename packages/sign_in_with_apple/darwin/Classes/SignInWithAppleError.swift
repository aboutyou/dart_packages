import AuthenticationServices

#if os(OSX)
import FlutterMacOS
#elseif os(iOS)
import Flutter
// UIKit is only available on iOS and we need it for UIDevice
import UIKit
#endif

public enum SignInWithAppleGenericError {
    // An error for the case we are running on a not supported platform
    //
    // We currently support macOS 10.15 or higher and iOS 13 or higher
    case notSupported

    // An error in case the arguments of a FlutterMethodCall are missing or don't have the proper type
    case missingArguments(FlutterMethodCall)

    // An error in case a concrete argument inside the arguments of a FlutterMethodCall is missing
    // The second argument should be the identifier of the missing argument
    case missingArgument(FlutterMethodCall, String)

    func toFlutterError() -> FlutterError {
        switch self {
        case .notSupported:
            var platform = "unknown platform"

            #if os(OSX)
                platform = "macOS \(ProcessInfo.processInfo.operatingSystemVersion)"
            #elseif os(iOS)
                platform = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
            #endif

            return FlutterError(
                code: "not-supported",
                message: "Unsupported platform version: \(platform)",
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


@available(iOS 13.0, macOS 10.15, *)
public enum SignInWithAppleError {
    // In case there was an error while getting the state of the credentials for a specific user identifier
    // The first argument will be the localized error message
    case credentialsError(String)

    // In case we receive an unexpected credentials state
    case unexpectedCredentialsState(ASAuthorizationAppleIDProvider.CredentialState)

    // In case we get some unknown credential type in the successful authorization callback
    //
    // This contains the credential
    case unknownCredentials(ASAuthorizationCredential)

    // In case there was an error while trying to perform an authorization request
    //
    // This contains the actual authorization error code and the localized error message
    case authorizationError(ASAuthorizationError.Code, String)

    func toFlutterError() -> FlutterError {
        switch self {
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
        }
    }
}