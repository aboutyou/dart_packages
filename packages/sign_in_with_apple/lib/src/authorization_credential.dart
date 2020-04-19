import 'dart:convert';

import 'package:meta/meta.dart';
import './authorization_request.dart';

@immutable
abstract class AuthorizationCredential {
  const AuthorizationCredential();
}

/// An [AuthorizationCredential] which comes from a succesful Apple ID authorization.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidcredential
class AuthorizationCredentialAppleID implements AuthorizationCredential {
  const AuthorizationCredentialAppleID({
    @required this.userIdentifier,
    @required this.givenName,
    @required this.familyName,
    @required this.email,
    @required this.identityToken,
    @required this.authorizationCode,
  }) : assert(authorizationCode != null);

  /// An identifier associated with the authenticated user.
  ///
  /// This will be provided upon every sign-in.
  /// This will stay the same between sign ins, until the user deauthorizes your App. TODO check if this is actually the case
  ///
  /// Can be `null`
  final String userIdentifier;

  /// The users given name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  ///
  /// Can be `null`
  final String givenName;

  /// The users family name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  ///
  /// Can be `null`
  final String familyName;

  /// The users email in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.email] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  ///
  /// Can be `null`
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

/// An [AuthorizationCredential] which request a username/password combination from the users Keychain.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/aspasswordcredential
class AuthorizationCredentialPassword implements AuthorizationCredential {
  const AuthorizationCredentialPassword({
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
