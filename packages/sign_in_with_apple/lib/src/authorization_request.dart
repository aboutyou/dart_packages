import 'package:meta/meta.dart';

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

  Map<String, dynamic> toJson();
}

/// The scopes that will be requested with the [AppleIDAuthorizationRequest].
/// This allows you to request additional information from the user upon sign up.
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorization/scope
enum AppleIDAuthorizationScopes {
  email,
  fullName,
}

/// An [AuthorizationRequest] which authenticates a user based on their Apple ID.
///
/// Apple Docs:
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider
/// - https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidrequest
class AppleIDAuthorizationRequest implements AuthorizationRequest {
  const AppleIDAuthorizationRequest({
    this.scopes = const [],
  }) : assert(scopes != null);

  final List<AppleIDAuthorizationScopes> scopes;

  @override
  String toString() => 'AppleIDAuthorizationRequest(scopes: $scopes)';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'appleid',
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
