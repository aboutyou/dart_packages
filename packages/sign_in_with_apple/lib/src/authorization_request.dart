import 'package:meta/meta.dart';

@immutable
abstract class AuthorizationRequest {
  const AuthorizationRequest();

  Map<String, dynamic> toJson();
}

enum AppleIDAuthorizationScopes {
  email,
  fullName,
}

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
      'scopes': scopes
          .map((scope) {
            switch (scope) {
              case AppleIDAuthorizationScopes.email:
                return 'email';
              case AppleIDAuthorizationScopes.fullName:
                return 'fullName';
            }

            assert(false);
            return null;
          })
          .where((value) => value != null)
          .toList(),
    };
  }
}

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
