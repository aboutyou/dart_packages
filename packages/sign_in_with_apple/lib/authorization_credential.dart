import 'package:meta/meta.dart';

@immutable
abstract class AuthorizationCredential {}

/// An [AuthorizationCredential] that is based on the users Apple ID.
///
/// There two more specialized classes of this:
/// - [AuthorizationCredentialSignUpWithAppleID] will be available if the user has not yet signed in with his Apple ID for your App.
/// - [AuthorizationCredentialSignInWithAppleID] will be available on subsequent sign ins.
abstract class AuthorizationCredentialAppleID
    implements AuthorizationCredential {}

/// An [AuthorizationCredentialAppleID] which indicates that the user has already signed up in your app
/// and is now trying to sign in again.
///
/// This class only provides limitted amount of information about the user,
/// only enough to uniquely identify the user in your system.
class AuthorizationCredentialSignInWithAppleID
    implements AuthorizationCredential {
  AuthorizationCredentialSignInWithAppleID({
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

/// An [AuthorizationCredentialAppleID] which indicates that the user has not yet signed up in your app with his Apple ID.
/// This will only be available for the first time the user tries to sign in.
///
/// On subsequent sign ins, the [AuthorizationCredentialSignInWithAppleID] will be available.
class AuthorizationCredentialSignUpWithAppleID
    implements AuthorizationCredential {
  AuthorizationCredentialSignUpWithAppleID({
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

  /// Can be `null`
  final String givenName;

  /// Can be `null`
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

/// A [AuthorizationCredential] which will be returned in case the user has a saved a username/password combination in his keychain.
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
      if (response['email'] != null) {
        return AuthorizationCredentialSignUpWithAppleID(
          userIdentifier: response['userIdentifier'] as String,
          givenName: response['givenName'] as String,
          familyName: response['familyName'] as String,
          email: response['email'] as String,
          identityToken: response['identityToken'] as String,
          authorizationCode: response['authorizationCode'] as String,
        );
      }

      return AuthorizationCredentialSignInWithAppleID(
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
