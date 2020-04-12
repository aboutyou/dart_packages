import 'package:flutter/services.dart';

import './authorization_credential.dart';

/// The state of a credentials of a particular user.
/// The user identifier that is needed for requesting this information comes from the [AuthorizationCredentialAppleID].
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider/credentialstate
enum CredentialState {
  /// The user is authorized.
  authorized,

  /// Authorization for the given user has been revoked.
  revoked,

  /// The user can’t be found.
  notFound,
}

CredentialState parseCredentialState(String credentialState) {
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
