import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sign_in_with_apple_platform_interface/authorization_credential.dart';
import 'package:sign_in_with_apple_platform_interface/authorization_request.dart';
import 'package:sign_in_with_apple_platform_interface/credential_state.dart';
import 'package:sign_in_with_apple_platform_interface/web_authentication_options.dart';

export 'package:sign_in_with_apple_platform_interface/authorization_credential.dart';
export 'package:sign_in_with_apple_platform_interface/authorization_request.dart';
export 'package:sign_in_with_apple_platform_interface/credential_state.dart';
export 'package:sign_in_with_apple_platform_interface/exceptions.dart';
export 'package:sign_in_with_apple_platform_interface/nonce.dart';
export 'package:sign_in_with_apple_platform_interface/web_authentication_options.dart';

import 'method_channel_sign_in_with_apple.dart';

/// The interface that implementations of `sign_in_with_apple` must implement.
///
/// Platform implementations should extend this class rather than implement it as `sign_in_with_apple`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [SignInWithApplePlatform] methods.
abstract class SignInWithApplePlatform extends PlatformInterface {
  /// Constructs a SignInWithApplePlatform.
  SignInWithApplePlatform() : super(token: _token);

  static final Object _token = Object();

  static SignInWithApplePlatform _instance = MethodChannelSignInWithApple();

  /// The default instance of [SignInWithApplePlatform] to use.
  ///
  /// Defaults to [MethodChannelSignInWithApple].
  static SignInWithApplePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [SignInWithApplePlatform] when they register themselves.
  static set instance(SignInWithApplePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isAvailable() async {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    WebAuthenticationOptions? webAuthenticationOptions,
    String? nonce,
    String? state,
  }) async {
    throw UnimplementedError(
      'getAppleIDCredential() has not been implemented.',
    );
  }

  Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    throw UnimplementedError('getCredentialState() has not been implemented.');
  }

  Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    throw UnimplementedError(
      'getKeychainCredential() has not been implemented.',
    );
  }
}
