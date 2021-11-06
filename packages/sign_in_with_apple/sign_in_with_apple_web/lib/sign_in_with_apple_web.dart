@JS()
library sign_in_with_apple_web;

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
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
        redirectURI: 'https://${html.window.location.host}/',
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
      final response = await promiseToFuture<SignInResponseI>(signIn());

      return AuthorizationCredentialAppleID(
        authorizationCode: response.authorization.code,
        identityToken: response.authorization.id_token,
        state: response.authorization.state,
        email: response.user?.email,
        givenName: response.user?.name?.firstName,
        familyName: response.user?.name?.lastName,
        userIdentifier: null,
      );
    } catch (e) {
      // TODO: Currently we can't cast this further, as the type is lost
      //       But we should be able to map this into a better error through JS, so that we can at least get the error code
      throw SignInWithAppleCredentialsException(message: '$e');
    }
  }
}

@JS()
@anonymous
class SignInWithAppleInitOptions {
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
external void log(Object o);

@JS('AppleID.auth.init')
external void init(SignInWithAppleInitOptions options);

@JS('AppleID.auth.signIn')
external Object /* like Future<SignInResponseI> */ signIn();

/// Sign in with Apple authorization response
///
/// Spec: https://developer.apple.com/documentation/sign_in_with_apple/signinresponsei
@JS()
@anonymous
class SignInResponseI {
  external AuthorizationI get authorization;
  external UserI? get user;
}

@JS()
@anonymous
class AuthorizationI {
  external String get code;
  // ignore: non_constant_identifier_names
  external String get id_token;
  external String get state;
}

@JS()
@anonymous
class UserI {
  external String get email;
  external NameI? get name;
}

@JS()
@anonymous
class NameI {
  external String get firstName;
  external String get lastName;
}
