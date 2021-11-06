import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple_platform_interface/method_channel_sign_in_with_apple.dart';
import 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart';

/// Wrapper class providing the methods to interact with Sign in with Apple.
// ignore: avoid_classes_with_only_static_members
class SignInWithApple {
  @visibleForTesting
  static MethodChannel get channel =>
      (SignInWithApplePlatform.instance as MethodChannelSignInWithApple)
          // ignore: invalid_use_of_visible_for_testing_member
          .channel;

  static Future<bool> isAvailable() async {
    return SignInWithApplePlatform.instance.isAvailable();
  }

  static Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    WebAuthenticationOptions? webAuthenticationOptions,
    String? nonce,
    String? state,
  }) async {
    return SignInWithApplePlatform.instance.getAppleIDCredential(
      scopes: scopes,
      webAuthenticationOptions: webAuthenticationOptions,
      nonce: nonce,
      state: state,
    );
  }

  /// Returns the credentials state for a given user.
  ///
  /// This method is only available on Apple platforms (which are also the only platforms where one retrieves a `userIdentifier` within [AuthorizationCredentialAppleID] instances).
  ///
  /// The [userIdentifier] argument should come from a previous call to [getAppleIDCredential] which returned an [AuthorizationCredentialAppleID].
  ///
  /// Throws a [SignInWithAppleException] in case of errors, and a specific [SignInWithAppleCredentialsException] in case there was an error
  /// while getting the credentials state.
  ///
  /// Throw a [SignInWithAppleNotSupportedException] on unsupported platforms.
  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    return SignInWithApplePlatform.instance.getCredentialState(userIdentifier);
  }

  static Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    return SignInWithApplePlatform.instance.getKeychainCredential();
  }
}
