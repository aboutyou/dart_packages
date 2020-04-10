import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/src/exceptions.dart';

import './src/authorization_credential.dart';
import './src/authorization_request.dart';
import './src/credential_state.dart';

export './src/authorization_credential.dart'
    show
        AuthorizationCredential,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword;

export './src/authorization_request.dart'
    show
        AuthorizationRequest,
        PasswordAuthorizationRequest,
        AppleIDAuthorizationScopes,
        AppleIDAuthorizationRequest;
export './src/credential_state.dart' show CredentialState;
export './src/widgets/is_sign_in_with_apple_available.dart'
    show IsSignInWithAppleAvailable;
export './src/widgets/sign_in_with_apple_button.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle, IconAlignment;

// ignore: avoid_classes_with_only_static_members
class SignInWithApple {
  @visibleForTesting
  static const channel =
      MethodChannel('de.aboutyou.mobile.app.sign_in_with_apple');

  /// Request credentials from the system, preferring existing keychain credentials
  /// over "Sign in with Apple"
  ///
  /// When no credentials are returned (e.g. also by the user cancelling), this is treated as
  /// all other errors (just like the native API), and will throw an Exception
  ///
  /// Successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword]
  static Future<AuthorizationCredential> requestCredentials({
    @required List<AuthorizationRequest> requests,
  }) async {
    assert(requests != null);

    try {
      return parseCredentialsResponse(
        await channel.invokeMethod<Map<dynamic, dynamic>>(
          'performAuthorizationRequest',
          requests.map((request) => request.toJson()).toList(),
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    assert(userIdentifier != null);

    try {
      return parseCredentialState(
        await channel.invokeMethod<String>(
          'getCredentialState',
          <String, String>{'userIdentifier': userIdentifier},
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }
}
