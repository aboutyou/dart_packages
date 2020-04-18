import 'dart:convert';

import 'package:meta/meta.dart';

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
  }) : assert(authorizationCode != null);

  /// Can be `null`
  final String userIdentifier;

  /// Can be `null`, will only be returned on the first authorization
  final String givenName;

  /// Can be `null`, will only be returned on the first authorization
  final String familyName;

  /// Can be `null`, will only be returned on the first authorization
  final String email;

  /// Can be `null`
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

// ignore_for_file: avoid_as
AuthorizationCredentialAppleID parseAuthorizationCredentialAppleID(
  Map<dynamic, dynamic> response,
) {
  if (response['type'] == 'appleid') {
    return AuthorizationCredentialAppleID(
      userIdentifier: response['userIdentifier'] as String,
      givenName: response['givenName'] as String,
      familyName: response['familyName'] as String,
      email: response['email'] as String,
      identityToken: response['identityToken'] as String,
      authorizationCode: response['authorizationCode'] as String,
    );
  } else {
    throw Exception('Unsupported result type ${response['type']}');
  }
}

AuthorizationCredentialPassword parseAuthorizationCredentialPassword(
  Map<dynamic, dynamic> response,
) {
  if (response['type'] == 'password') {
    return AuthorizationCredentialPassword(
      username: response['username'] as String,
      password: response['password'] as String,
    );
  } else {
    throw Exception('Unsupported result type ${response['type']}');
  }
}

AuthorizationCredentialAppleID parseAuthorizationCredentialAppleIDFromDeeplink(
  Uri deeplink,
) {
  final user = deeplink.queryParameters.containsKey('user')
      ? json.decode(deeplink.queryParameters['user']) as Map<String, dynamic>
      : null;

  return AuthorizationCredentialAppleID(
    authorizationCode: deeplink.queryParameters['code'],
    email: user != null ? user['email'] as String : null,
    givenName: user != null ? user['name']['firstName'] as String : null,
    familyName: user != null ? user['name']['lastName'] as String : null,
    userIdentifier: null,
    identityToken: null,
  );
}
