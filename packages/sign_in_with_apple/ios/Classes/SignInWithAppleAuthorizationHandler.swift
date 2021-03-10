import Foundation
import Flutter
import AuthenticationServices

/*
 A class that handles the case where during app use, if the user goes into the Settings app and
 revokes Apple sign-in access.
 */
class SignInWithAppleAuthorizationHandler: NSObject, FlutterStreamHandler {

    private var events: FlutterEventSink?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if #available(iOS 13, *) {
            self.events = events
            NotificationCenter.default.addObserver(self, selector: #selector(onCredentialRevokedNotification), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        self.events = nil
        return nil
    }

    @available(iOS 13.0, *)
    @objc
    private func onCredentialRevokedNotification() {
        self.events?(ASAuthorizationAppleIDProvider.credentialRevokedNotification)
    }
}
