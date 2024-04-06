import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sign_in_with_apple_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('com.aboutyou.dart_packages.sign_in_with_apple');

/// An implementation of [SignInWithApplePlatform] that uses method channels.
class MethodChannelSignInWithApple extends SignInWithApplePlatform {
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<bool> isAvailable() async {
    return (await _channel.invokeMethod<bool>('isAvailable')) ?? false;
  }

  @override
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
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

      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
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

  @override
  Future<CredentialState> getCredentialState(
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
        await _channel.invokeMethod<String>(
          'getCredentialState',
          <String, String>{'userIdentifier': userIdentifier},
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  @override
  Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    try {
      if (!Platform.isIOS &&
          !Platform.isMacOS &&
          Platform.environment['FLUTTER_TEST'] != 'true') {
        throw const SignInWithAppleNotSupportedException(
          message: 'The current platform is not supported',
        );
      }

      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
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

  Future<AuthorizationCredentialAppleID> _signInWithAppleAndroid({
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
      final result = await _channel.invokeMethod<String>(
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
