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
  /// Successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword]
  static Future<AuthorizationCredential> requestCredentials() async {
    return parseCredentialsResponse(
      await channel
          .invokeMethod<Map<dynamic, dynamic>>('performAuthorizationRequest'),
    );
  }

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

  /// Cached value whether or not sign-in with apple is available
  ///
  /// We cache, so we can return a [SynchronousFuture] in case this value has already been loaded
  static bool _isAvailable;

  /// Cached Future, so we only ever call this once on the native side
  static Future<bool> _isAvailableFuture;

  /// A static variable which will trigger a method call when the app launches
  ///
  /// This should allow most calls to [isAvailable] to return a [SynchronousFuture],
  /// which should result in a better UX (no jumping UI).
  ///
  /// ignore: unused_field
  static final _isAvavailableTrigger = isAvailable();

  static Future<bool> isAvailable() {
    if (_isAvailable != null) {
      return SynchronousFuture<bool>(_isAvailable);
    }

    return _isAvailableFuture ??=
        channel.invokeMethod<bool>('isAvailable').then((isAvailable) {
      _isAvailable = isAvailable;

      return isAvailable;
    });
  }
}
