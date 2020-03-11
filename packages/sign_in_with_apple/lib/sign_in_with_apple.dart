import 'dart:async';
import 'dart:io';

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
  /// Successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword]
  static Future<AuthorizationCredential> requestCredentials() async {
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
abstract class AuthorizationCredential {}

class AuthorizationCredentialAppleID implements AuthorizationCredential {
  AuthorizationCredentialAppleID({
    @required this.userIdentifier,
    @required this.givenName,
    @required this.familyName,
    @required this.email,
    @required this.identityToken,
    @required this.authorizationCode,
  })  : assert(userIdentifier != null),
        assert(identityToken != null),
        assert(authorizationCode != null);

  final String userIdentifier;

  /// Can be `null`, will only be returned on the first authorization
  final String givenName;

  /// Can be `null`, will only be returned on the first authorization
  final String familyName;

  /// Can be `null`, will only be returned on the first authorization
  final String email;

  /// Can be `null` on the native side, but is expected on the Flutter side,
  /// as the authorization would be useless without the tokens to validate them
  /// on your own server
  final String identityToken;

  /// Can be `null` on the native side, but is expected on the Flutter side,
  /// as the authorization would be useless without the tokens to validate them
  /// on your own server
  final String authorizationCode;

  @override
  String toString() {
    return 'AuthorizationAppleID($userIdentifier, $givenName, $familyName, $email, identityToken set? ${identityToken != null}, authorizationCode set? ${authorizationCode != null})';
  }
}

class AuthorizationCredentialPassword implements AuthorizationCredential {
  AuthorizationCredentialPassword({
    @required this.username,
    @required this.password,
  })  : assert(username != null),
        assert(password != null);

  final String username;

  final String password;

  @override
  String toString() {
    return 'AuthorizationCredential($username, [REDACTED PASSWORD])';
  }
}

AuthorizationCredential _parseCredentialsResponse(
    Map<dynamic, dynamic> response) {
  switch (response['type']) {
    case 'appleid':
      return AuthorizationCredentialAppleID(
        userIdentifier: response['userIdentifier'],
        givenName: response['givenName'],
        familyName: response['familyName'],
        email: response['email'],
        identityToken: response['identityToken'],
        authorizationCode: response['authorizationCode'],
      );

    case 'password':
      return AuthorizationCredentialPassword(
        username: response['username'],
        password: response['password'],
      );

    default:
      throw Exception('Unsupported result type ${response['type']}');
  }
}
