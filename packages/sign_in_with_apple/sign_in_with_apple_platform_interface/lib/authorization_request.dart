import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import './authorization_credential.dart';

/// A base class which describes an authorization request that we will make on the native side.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationrequest
///
/// We currently only support the following authorization requests:
/// - [AppleIDAuthorizationRequest]
/// - [PasswordAuthorizationRequest]
@immutable
abstract class AuthorizationRequest {
  const AuthorizationRequest();

  /// A method which turns this [AuthorizationRequest] into a JSON representation
  /// which can be send over a [MethodChannel].
  Map<String, dynamic> toJson();
}

/// The scopes that will be requested with the [AppleIDAuthorizationRequest].
/// This allows you to request additional information from the user upon sign up.
///
/// This information will only be provided on the first authorizations.
/// Upon further authorizations, you will only get the user identifier,
/// meaning you will need to store this data securely on your servers.
/// For more information see: https://forums.developer.apple.com/thread/121496
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorization/scope
enum AppleIDAuthorizationScopes {
  email,
  fullName,
}

/// An [AuthorizationRequest] which authenticates a user based on their Apple ID.
///
/// This will prompt the user to sign in using their stored Apple ID on their device.
/// Upon completion, this will result in an [AuthorizationCredentialAppleID].
///
/// Apple Docs:
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidrequest
class AppleIDAuthorizationRequest implements AuthorizationRequest {
  const AppleIDAuthorizationRequest({
    this.scopes = const [],
    this.nonce,
    this.state,
  });

  /// A list of scopes that can be requested from the user.
  ///
  /// This information will only be provided on the first authorization.
  /// Upon further authorizations, you will only get the user identifier,
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final List<AppleIDAuthorizationScopes> scopes;

  /// The nonce value which was provided when initiating the sign-in.
  ///
  /// Can be `null` if no value was given on the request.
  final String? nonce;

  /// Data that’s returned to you unmodified in the corresponding [AuthorizationCredentialAppleID.state] after a successful authentication.
  ///
  /// Can be `null` if no value was given on the request.
  final String? state;

  @override
  String toString() => 'AppleIDAuthorizationRequest(scopes: $scopes)';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'appleid',
      if (nonce != null) 'nonce': nonce,
      if (state != null) 'state': state,
      'scopes': [
        for (final scope in scopes)
          if (scope == AppleIDAuthorizationScopes.email)
            'email'
          else if (scope == AppleIDAuthorizationScopes.fullName)
            'fullName',
      ],
    };
  }
}

/// An [AuthorizationRequest] that uses credentials which are stored in the users Keychain.
///
/// Apple Docs:
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationpasswordprovider
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationpasswordrequest
class PasswordAuthorizationRequest implements AuthorizationRequest {
  const PasswordAuthorizationRequest();

  @override
  String toString() => 'PasswordAuthorizationRequest()';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'password',
    };
  }
}
