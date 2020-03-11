import 'dart:async';

import 'package:flutter/services.dart';

import './authorization_credential.dart';
import './credential_state.dart';

export './authorization_credential.dart'
    show
        AuthorizationCredential,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword;
export './credential_state.dart' show CredentialState;
export './sign_in_with_apple_button/sign_in_with_apple_button.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle, IconAlignment;

class SignInWithApple {
  static const MethodChannel _channel =
      MethodChannel('de.aboutyou.mobile.app.sign_in_with_apple');

  /// Request credentials from the system, preferring existing keychain credentials
  /// over "Sign in with Apple"
  ///
  /// When no credentials are returned (e.g. also by the user cancelling), this is treated as
  /// all other errors (just like the native API), and will throw an Exception
  ///
  /// Successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword]
  static Future<AuthorizationCredential> requestCredentials() async {
    return parseCredentialsResponse(
      await _channel
          .invokeMethod<Map<dynamic, dynamic>>('performAuthorizationRequest'),
    );
  }

  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    return parseCredentialState(
      await _channel.invokeMethod<String>(
        'getCredentialState',
        <String, String>{'userIdentifier': userIdentifier},
      ),
    );
  }
}
