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

  /// Request credentials from the system.
  ///
  /// Through the [requests], you can specify which [AuthorizationRequest] should be requested.
  /// We currently support the following two:
  /// - [AppleIDAuthorizationRequest] which requests authentication with the users Apple ID.
  /// - [PasswordAuthorizationRequest] which asks for some credentials in the users Keychain.
  ///
  /// In case the authorization is successful, we will return an [AuthorizationCredential].
  /// These can currently be two different type of credentials:
  /// - [AuthorizationCredentialAppleID]
  /// - [AuthorizationCredentialPassword]
  /// The returned credentials do depend on the [requests] that you specified.
  ///
  /// In case of an error on the native side, we will throw an [SignInWithAppleException].
  /// If we have a more specific authorization error, we will throw [SignInWithAppleAuthorizationException],
  /// which has more information about the failure.
  /// In case Sign in with Apple is not available, this will throw an [SignInWithAppleNotSupportedException].
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

  /// Request the credentials state a giver [userIdentifier].
  /// The [userIdentifier] should come from a previos call to [requestCredentials] which returned an [AuthorizationCredentialAppleID].
  ///
  /// This method allows you to check whether or not the user is still authorized, revoked the access or has not yet signed up with it.
  ///
  /// This methods either completes with a [CredentialState] or throws an [SignInWithAppleException].
  /// In case there was an error while getting the credentials state, this throws a [SignInWithAppleCredentialsException].
  /// In case Sign in with Apple is not available, this will throw an [SignInWithAppleNotSupportedException].
  ///
  /// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider/3175423-getcredentialstate
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

  /// This checks with the native platform whether or not Sign in with Apple is available.
  ///
  /// For iOS, the user will need `iOS 13` or higher.
  /// For macOS, the user will need `macOS Catalina` or higher.
  ///
  /// In case Sign in with Apple is not available, this will complete with `false`.
  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }
}
