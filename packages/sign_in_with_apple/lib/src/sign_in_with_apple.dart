import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Mention all internal imports implicitly, so we don't forget to export required classes
import 'package:sign_in_with_apple/src/authorization_credential.dart'
    show
        parseAuthorizationCredentialAppleID,
        parseAuthorizationCredentialAppleIDFromDeeplink,
        parseAuthorizationCredentialPassword;
import 'package:sign_in_with_apple/src/credential_state.dart'
    show parseCredentialState;

/// Wrapper class providing the methods to interact with Sign in with Apple.
// ignore: avoid_classes_with_only_static_members
class SignInWithApple {
  @visibleForTesting
  // ignore: public_member_api_docs
  static const channel = MethodChannel(
    'com.aboutyou.dart_packages.sign_in_with_apple',
  );

  /// Returns the credentials stored in the Keychain for the website associated with the current app.
  ///
  /// Only available on Apple platforms.
  ///
  /// Throws a [SignInWithAppleException] exception when no credentials have been found in the Keychain.
  static Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    try {
      if (!Platform.isIOS &&
          !Platform.isMacOS &&
          Platform.environment['FLUTTER_TEST'] != 'true') {
        throw const SignInWithAppleNotSupportedException(
          message: 'The current platform is not supported',
        );
      }

      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'performAuthorizationRequest',
        [
          const PasswordAuthorizationRequest(),
        ].map((request) => request.toJson()).toList(),
      );

      if (response == null) {
        throw Exception('getKeychainCredential: Received `null` response');
      }

      return parseAuthorizationCredentialPassword(response);
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  /// Requests an Apple ID credential.
  ///
  /// Shows the native UI on Apple's platform and a Chrome Custom Tab on Android.
  ///
  /// The returned [AuthorizationCredentialAppleID]'s `authorizationCode` should then be used to validate the token with Apple's servers and
  /// create a session in your system.
  ///
  /// Fields on the returned [AuthorizationCredentialAppleID] will be set based on the given scopes.
  ///
  /// User data fields (first name, last name, email) will only be set if this is the initial authentication between the current app and Apple ID.
  ///
  /// The returned Future will resolve in all cases on iOS and macOS, either with an exception if Sign in with Apple is not available,
  /// or as soon as the native UI goes away (either due cancellation or the completion of the authorization).
  ///
  /// On Android the returned Future will never resolve in case the user closes the Chrome Custom Tab without finsihing the authentication flow.
  /// Any previous Future would be rejected if the [getAppleIDCredential] is called again, while an earlier one is still pending.
  ///
  /// Throws an [SignInWithAppleException] in case there was any error retrieving the credential.
  /// A specialized [SignInWithAppleAuthorizationException] is thrown in case of authorization errors, which contains
  /// further information about the failure.
  ///
  /// Throws an [SignInWithAppleNotSupportedException] in case Sign in with Apple is not available (e.g. iOS < 13, macOS < 10.15)
  static Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,

    /// Optional parameters for web-based authentication flows on non-Apple platforms
    ///
    /// This parameter is required on Android.
    WebAuthenticationOptions? webAuthenticationOptions,

    /// Optional string which, if set, will be be embedded in the resulting `identityToken` field on the [AuthorizationCredentialAppleID].
    ///
    /// This can be used to mitigate replay attacks by using a unique argument per sign-in attempt.
    ///
    /// Can be `null`, in which case no nonce will be passed to the request.
    String? nonce,

    /// Data that’s returned to you unmodified in the corresponding [AuthorizationCredentialAppleID.state] after a successful authentication.
    ///
    /// Can be `null`, in which case no state will be passed to the request.
    String? state,
  }) async {
    if (Platform.isAndroid) {
      if (webAuthenticationOptions == null) {
        throw Exception(
          '`webAuthenticationOptions` argument must be provided on Android.',
        );
      }

      return _signInWithAppleAndroid(
        scopes: scopes,
        webAuthenticationOptions: webAuthenticationOptions,
        nonce: nonce,
        state: state,
      );
    }

    try {
      if (!Platform.isIOS &&
          !Platform.isMacOS &&
          Platform.environment['FLUTTER_TEST'] != 'true') {
        throw const SignInWithAppleNotSupportedException(
          message: 'The current platform is not supported',
        );
      }

      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'performAuthorizationRequest',
        [
          AppleIDAuthorizationRequest(
            scopes: scopes,
            nonce: nonce,
            state: state,
          ).toJson(),
        ],
      );

      if (response == null) {
        throw Exception('getKeychainCredential: Received `null` response');
      }

      return parseAuthorizationCredentialAppleID(
        response,
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
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
    if (!Platform.isIOS &&
        !Platform.isMacOS &&
        Platform.environment['FLUTTER_TEST'] != 'true') {
      throw const SignInWithAppleNotSupportedException(
        message: 'The current platform is not supported',
      );
    }

    try {
      return parseCredentialState(
        await channel.invokeMethod<String>(
          'getCredentialState',
          <String, String>{'userIdentifier': userIdentifier},
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  /// Returns whether Sign in with Apple is available on the current platform.
  ///
  /// If this returns `true`, [getAppleIDCredential] will not throw a [SignInWithAppleNotSupportedException] when called.
  ///
  /// Sign in with Apple is available on:
  /// - iOS 13 and higher
  /// - macOS 10.15 and higher
  /// - Android
  ///
  /// In case Sign in with Apple is not available, the returned Future completes with `false`.
  static Future<bool> isAvailable() async {
    return (await channel.invokeMethod<bool>('isAvailable')) ?? false;
  }

  static Future<AuthorizationCredentialAppleID> _signInWithAppleAndroid({
    required List<AppleIDAuthorizationScopes> scopes,
    required WebAuthenticationOptions webAuthenticationOptions,
    required String? nonce,
    required String? state,
  }) async {
    assert(Platform.isAndroid);

    // URL built according to https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms#3332113
    final uri = Uri(
      scheme: 'https',
      host: 'appleid.apple.com',
      path: '/auth/authorize',
      queryParameters: <String, String>{
        'client_id': webAuthenticationOptions.clientId,
        'redirect_uri': webAuthenticationOptions.redirectUri.toString(),
        'scope': scopes.map((scope) {
          switch (scope) {
            case AppleIDAuthorizationScopes.email:
              return 'email';
            case AppleIDAuthorizationScopes.fullName:
              return 'name';
          }
        }).join(' '),
        // Request `code`, which is also what `ASAuthorizationAppleIDCredential.authorizationCode` contains.
        // So the same handling can be used for Apple and 3rd party platforms
        'response_type': 'code id_token',
        'response_mode': 'form_post',

        if (nonce != null) 'nonce': nonce,

        if (state != null) 'state': state,
      },
    ).toString();

    try {
      final result = await channel.invokeMethod<String>(
        'performAuthorizationRequest',
        <String, String>{
          'url': uri,
        },
      );

      if (result == null) {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.invalidResponse,
          message: 'Did receive `null` URL from performAuthorizationRequest',
        );
      }

      return parseAuthorizationCredentialAppleIDFromDeeplink(Uri.parse(result));
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }
}
