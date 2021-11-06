import 'package:flutter/services.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// State of a credential of a particular user.
///
/// The user identifier that is needed for requesting this information comes from the [AuthorizationCredentialAppleID].
///
/// The current state of a user can be requested via [SignInWithApple.getCredentialState]
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider/credentialstate
enum CredentialState {
  /// The user is authorized.
  authorized,

  /// Authorization for the given user has been revoked.
  revoked,

  /// The user wasn't found.
  notFound,
}

/// Parses the string represenation of a [CredentialState] to its enum value.
///
/// The values are aligned with the native implementations.
///
/// Throws a [PlatformException] in case of unsupported [credentialState] arguments.
CredentialState parseCredentialState(String? credentialState) {
  switch (credentialState) {
    case 'authorized':
      return CredentialState.authorized;

    case 'revoked':
      return CredentialState.revoked;

    case 'notFound':
      return CredentialState.notFound;

    default:
      throw PlatformException(
        code: 'unsupported-value',
        message: 'Unsupported credential state: $credentialState',
      );
  }
}
