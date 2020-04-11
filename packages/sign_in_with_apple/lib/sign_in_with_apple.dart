import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import './authorization_credential.dart';
import './credential_state.dart';

export './authorization_credential.dart'
    show
        AuthorizationCredential,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword;
export './credential_state.dart' show CredentialState;
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
  /// On Apple platforms (iOS, macOS) a successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword].
  /// On other platforms only [AuthorizationCredentialAppleID] will be returned in the success case
  static Future<AuthorizationCredential> requestCredentials({
    /// Optional parameters for web-based authentication flows on non-Apple platforms
    WebAuthenticationOptions webAuthenticationOptions,
  }) async {
    if (webAuthenticationOptions == null &&
        (!Platform.iOS && !Platform.macOS)) {
      throw Exception(
          'webAuthenticationOptions parameter must be provided on non-Apple platforms');
    }

    return parseCredentialsResponse(
      await channel.invokeMethod<Map<dynamic, dynamic>>(
        'performAuthorizationRequest',
      ),
    );
  }

  /// Only supported on Apple platforms
  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    return parseCredentialState(
      await channel.invokeMethod<String>(
        'getCredentialState',
        <String, String>{'userIdentifier': userIdentifier},
      ),
    );
  }

  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }
}
