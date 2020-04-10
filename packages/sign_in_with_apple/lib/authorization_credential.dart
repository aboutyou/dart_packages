import 'package:meta/meta.dart';

@immutable
abstract class AuthorizationCredential {}

abstract class AuthorizationCredentialAppleID
    implements AuthorizationCredential {}

class AuthorizationCredentialLoginAppleID implements AuthorizationCredential {
  AuthorizationCredentialLoginAppleID({
    @required this.userIdentifier,
    @required this.identityToken,
    @required this.authorizationCode,
  })  : assert(userIdentifier != null),
        assert(identityToken != null),
        assert(authorizationCode != null);

  final String userIdentifier;

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
    return 'AuthorizationCredentialLoginAppleID($userIdentifier, identityToken set? ${identityToken != null}, authorizationCode set? ${authorizationCode != null})';
  }
}

class AuthorizationCredentialSignUpAppleID implements AuthorizationCredential {
  AuthorizationCredentialSignUpAppleID({
    @required this.userIdentifier,
    @required this.givenName,
    @required this.familyName,
    @required this.email,
    @required this.identityToken,
    @required this.authorizationCode,
  })  : assert(userIdentifier != null),
        assert(identityToken != null),
        assert(authorizationCode != null),
        assert(givenName != null),
        assert(familyName != null),
        assert(email != null);

  final String userIdentifier;

  final String givenName;

  final String familyName;

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
    return 'AuthorizationCredentialSignUpAppleID($userIdentifier, $givenName, $familyName, $email, identityToken set? ${identityToken != null}, authorizationCode set? ${authorizationCode != null})';
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
AuthorizationCredential parseCredentialsResponse(
  Map<dynamic, dynamic> response,
) {
  switch (response['type'] as String) {
    case 'appleid':
      if (response['givenName'] != null &&
          response['familyName'] != null &&
          response['email'] != null) {
        return AuthorizationCredentialSignUpAppleID(
          userIdentifier: response['userIdentifier'] as String,
          givenName: response['givenName'] as String,
          familyName: response['familyName'] as String,
          email: response['email'] as String,
          identityToken: response['identityToken'] as String,
          authorizationCode: response['authorizationCode'] as String,
        );
      }

      return AuthorizationCredentialLoginAppleID(
        userIdentifier: response['userIdentifier'] as String,
        identityToken: response['identityToken'] as String,
        authorizationCode: response['authorizationCode'] as String,
      );

    case 'password':
      return AuthorizationCredentialPassword(
        username: response['username'] as String,
        password: response['password'] as String,
      );

    default:
      throw Exception('Unsupported result type ${response['type']}');
  }
}
