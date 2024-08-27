@JS()
library sign_in_with_apple_web;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart';

/// The web implementation of [SignInWithApplePlatform].
///
/// This class implements the `package:sign_in_with_apple` functionality for the web.
class SignInWithApplePlugin extends SignInWithApplePlatform {
  /// Registers this class as the default instance of [SignInWithApplePlatform].
  static void registerWith(Registrar registrar) {
    SignInWithApplePlatform.instance = SignInWithApplePlugin();
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    WebAuthenticationOptions? webAuthenticationOptions,
    String? nonce,
    String? state,
  }) async {
    try {
      final options = SignInWithAppleInitOptions(
        clientId: webAuthenticationOptions!.clientId,
        redirectURI: webAuthenticationOptions.redirectUri.toString(),
        scope: [
          for (final scope in scopes)
            if (scope == AppleIDAuthorizationScopes.email)
              'email'
            else if (scope == AppleIDAuthorizationScopes.fullName)
              'name',
        ].join(' '),
        state: state,
        nonce: nonce,
        usePopup: true,
      );

      init(options);
      final response = await signIn().toDart;

      return AuthorizationCredentialAppleID(
        authorizationCode: response.authorization.code,
        identityToken: response.authorization.idToken,
        state: response.authorization.state,
        email: response.user?.email,
        givenName: response.user?.name?.firstName,
        familyName: response.user?.name?.lastName,
        userIdentifier: null,
      );
    } catch (e) {
      // error per https://developer.apple.com/documentation/sign_in_with_apple/signinerrori
      final errorProp = (e as SignInErrorI).error;
      final errorCode = errorProp is String ? errorProp : 'UNKNOWN_SIWA_ERROR';

      throw SignInWithAppleCredentialsException(
        message: 'Authentication failed with $errorCode',
      );
    }
  }
}

extension type SignInWithAppleInitOptions._(JSObject _) implements JSObject {
  external String? get clientId;
  external String? get scope;
  external String? get redirectURI;
  external String? get state;
  external String? get nonce;
  external bool? get usePopup;

  // Must have an unnamed factory constructor with named arguments.
  external factory SignInWithAppleInitOptions({
    String? clientId,
    String? scope,
    String? redirectURI,
    String? state,
    String? nonce,
    bool? usePopup,
  });
}

@JS('console.log')
external void log(JSAny? o);

@JS('AppleID.auth.init')
external void init(SignInWithAppleInitOptions options);

@JS('AppleID.auth.signIn')
external JSPromise<SignInResponseI> signIn();

/// Sign in with Apple authorization response
///
/// Spec: https://developer.apple.com/documentation/sign_in_with_apple/signinresponsei
extension type SignInResponseI._(JSObject _) implements JSObject {
  external AuthorizationI get authorization;
  external UserI? get user;
}

extension type SignInErrorI._(JSObject _) implements JSObject {
  external String? error;
}

extension type AuthorizationI._(JSObject _) implements JSObject {
  external String get code;
  @JS('id_token')
  external String get idToken;
  external String? get state;
}

extension type UserI._(JSObject _) implements JSObject {
  external String? get email;
  external NameI? get name;
}

extension type NameI._(JSObject _) implements JSObject {
  external String get firstName;
  external String get lastName;
}
