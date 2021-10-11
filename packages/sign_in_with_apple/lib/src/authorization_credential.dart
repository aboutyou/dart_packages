import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import './authorization_request.dart';

/// Authorization details from a successful Sign in with Apple flow.
///
/// Most fields are optional in this class.
///
/// Especially [givenName], [familyName], and [email] member will only be provided on the first authorization between
/// the app and Apple ID.
///
/// The [authorizationCode] member is always present and should be used to check the authorizations with Apple servers
/// from your backend. Upon successful validation, you should create a session in your system for the current user,
/// or consider her now logged in.
@immutable
class AuthorizationCredentialAppleID {
  /// Creates an instance which contains the result of a successful Sign in with Apple flow.
  const AuthorizationCredentialAppleID({
    @required this.userIdentifier,
    @required this.givenName,
    @required this.familyName,
    required this.authorizationCode,
    @required this.email,
    @required this.identityToken,
    @required this.state,
  });

  /// An identifier associated with the authenticated user.
  ///
  /// This will always be provided on iOS and macOS systems. On Android, however, this will not be present.
  /// This will stay the same between sign ins, until the user deauthorizes your App.
  final String? userIdentifier;

  /// The users given name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? givenName;

  /// The users family name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? familyName;

  /// The users email in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.email] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? email;

  /// The verification code for the current authorization.
  ///
  /// This code should be used by your server component to validate the authorization with Apple within 5 minutes upon receiving it.
  final String authorizationCode;

  /// A JSON Web Token (JWT) that securely communicates information about the user to your app.
  final String? identityToken;

  /// The `state` parameter that was passed to the request.
  ///
  /// This data is not modified by Apple.
  final String? state;

  @override
  String toString() {
    return 'AuthorizationAppleID($userIdentifier, $givenName, $familyName, $email, $state)';
  }
}

/// Authorization details retrieved from the user's Keychain for the current app's website.
class AuthorizationCredentialPassword {
  /// Creates a new username/password combination, which is the result of a successful Keychain query.
  const AuthorizationCredentialPassword({
    required this.username,
    required this.password,
  });

  /// The username for the credential
  final String username;

  /// The password for the credential
  final String password;

  @override
  String toString() {
    return 'AuthorizationCredential($username, [REDACTED PASSWORD])';
  }
}

// ignore_for_file: avoid_as, public_member_api_docs
AuthorizationCredentialAppleID parseAuthorizationCredentialAppleID(
  Map<dynamic, dynamic> response,
) {
  if (response['type'] == 'appleid') {
    final authorizationCode = response['authorizationCode'] as String?;

    if (authorizationCode == null) {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message:
            'parseAuthorizationCredentialAppleID: `authorizationCode` field was `null`',
      );
    }

    return AuthorizationCredentialAppleID(
      userIdentifier: response['userIdentifier'] as String?,
      givenName: response['givenName'] as String?,
      familyName: response['familyName'] as String?,
      email: response['email'] as String?,
      authorizationCode: authorizationCode,
      identityToken: response['identityToken'] as String?,
      state: response['state'] as String?,
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
  if (deeplink.queryParameters.containsKey('error')) {
    /// In case an error occured during the web flow, the URL will have an `error` parameter.
    ///
    /// The only error code that might be returned is `user_cancelled_authorize`,
    /// which indicates that the user clicked the `Cancel` button during the web flow.
    ///
    /// https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms
    if (deeplink.queryParameters['error'] == 'user_cancelled_authorize') {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.canceled,
        message: 'User canceled authorization',
      );
    }
  }

  final user = deeplink.queryParameters.containsKey('user')
      ? json.decode(deeplink.queryParameters['user'] as String)
          as Map<String, dynamic>
      : null;
  final name = user != null ? user['name'] as Map<String, dynamic>? : null;

  final authorizationCode = deeplink.queryParameters['code'];
  if (authorizationCode == null) {
    throw const SignInWithAppleAuthorizationException(
      code: AuthorizationErrorCode.invalidResponse,
      message:
          'parseAuthorizationCredentialAppleIDFromDeeplink: No `code` query parameter set)',
    );
  }

  return AuthorizationCredentialAppleID(
    authorizationCode: authorizationCode,
    email: user?['email'] as String?,
    givenName: name?['firstName'] as String?,
    familyName: name?['lastName'] as String?,
    userIdentifier: null,
    identityToken: deeplink.queryParameters['id_token'],
    state: deeplink.queryParameters['state'],
  );
}
