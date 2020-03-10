import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

export './sign_in_with_apple_button/sign_in_with_apple_button.dart';

class SignInWithApple {
  static const MethodChannel _channel =
      const MethodChannel('de.aboutyou.mobile.app.sign_in_with_apple');

  /// Request credentials from the system, preferring existing keychain credentials
  /// over "Sign in with Apple"
  ///
  /// When no credentials are returned (e.g. also by the user cancelling), this is treated as
  /// all other errors (just like the native API), and will throw an Exception
  ///
  /// Successful result will be either of type [AuthorizationAppleID] or [AuthorizationPassword]
  static Future<Authorization> requestCredentials() async {
    return _parseCredentialsResponse(
      await _channel
          .invokeMethod<Map<dynamic, dynamic>>('performAuthorizationRequest'),
    );
  }

  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    return _parseCredentialState(
      await _channel.invokeMethod<String>(
        'getCredentialState',
        <String, String>{'userIdentifier': userIdentifier},
      ),
    );
  }
}

enum CredentialState {
  authorized,
  revoked,
  notFound,
}

CredentialState _parseCredentialState(String credentialState) {
  switch (credentialState) {
    case 'authorized':
      return CredentialState.authorized;

    case 'revoked':
      return CredentialState.revoked;

    case 'notFound':
      return CredentialState.notFound;

    default:
      throw Exception("Unsupported credential state $credentialState");
  }
}

@immutable
abstract class Authorization {}

class AuthorizationAppleID implements Authorization {
  AuthorizationAppleID({
    @required this.userIdentifier,
    @required this.givenName,
    @required this.familyName,
    @required this.email,
  }) : assert(userIdentifier != null);

  final String userIdentifier;

  /// Can be `null`
  final String givenName;

  /// Can be `null`
  final String familyName;

  /// Can be `null`
  final String email;

  @override
  String toString() {
    return 'AuthorizationAppleID($userIdentifier, $givenName, $familyName, $email)';
  }
}

class AuthorizationPassword implements Authorization {
  AuthorizationPassword({
    @required this.username,
    @required this.password,
  })  : assert(username != null),
        assert(password != null);

  final String username;

  final String password;

  @override
  String toString() {
    return 'AuthorizationPassword($username, [REDACTED PASSWORD])';
  }
}

Authorization _parseCredentialsResponse(Map<dynamic, dynamic> response) {
  switch (response['type']) {
    case 'appleid':
      return AuthorizationAppleID(
        userIdentifier: response['userIdentifier'],
        givenName: response['givenName'],
        familyName: response['familyName'],
        email: response['email'],
      );

    case 'password':
      return AuthorizationPassword(
        username: response['username'],
        password: response['password'],
      );

    default:
      throw Exception('Unsupported result type ${response['type']}');
  }
}
