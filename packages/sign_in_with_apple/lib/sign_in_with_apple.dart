import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/src/web_authentication_options.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;

import './authorization_credential.dart';
import './credential_state.dart';

export './authorization_credential.dart'
    show
        AuthorizationCredential,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword;
export './credential_state.dart' show CredentialState;
export './src/web_authentication_options.dart' show WebAuthenticationOptions;
export './src/widgets/is_sign_in_with_apple_available.dart'
    show IsSignInWithAppleAvailable;
export './src/widgets/sign_in_with_apple_button.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle, IconAlignment;

// ignore: avoid_classes_with_only_static_members
class SignInWithApple {
  @visibleForTesting
  static const channel =
      MethodChannel('de.aboutyou.mobile.app.sign_in_with_apple');

  /// Request credentials from the system, preferring existing keychain credentials
  /// over "Sign in with Apple"
  ///
  /// When no credentials are returned (e.g. also by the user cancelling), this is treated as
  /// all other errors (just like the native API), and will throw an Exception
  ///
  /// On Apple platforms (iOS, macOS) a successful result will be either of type [AuthorizationCredentialAppleID] or [AuthorizationCredentialPassword].
  /// On other platforms only [AuthorizationCredentialAppleID] will be returned in the success case
  static Future<AuthorizationCredential> requestCredentials({
    /// Optional parameters for web-based authentication flows on non-Apple platforms
    WebAuthenticationOptions webAuthenticationOptions,
  }) async {
    if (webAuthenticationOptions == null &&
        (!Platform.isIOS && !Platform.isMacOS)) {
      throw Exception(
        'webAuthenticationOptions parameter must be provided on non-Apple platforms',
      );
    }

    if (Platform.isAndroid) {
      return _signInWithAppleAndroid(webAuthenticationOptions);
    }

    return parseCredentialsResponse(
      await channel.invokeMethod<Map<dynamic, dynamic>>(
        'performAuthorizationRequest',
      ),
    );
  }

  /// Only supported on Apple platforms
  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    return parseCredentialState(
      await channel.invokeMethod<String>(
        'getCredentialState',
        <String, String>{'userIdentifier': userIdentifier},
      ),
    );
  }

  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }

  static Future<AuthorizationCredential> _signInWithAppleAndroid(
    WebAuthenticationOptions webAuthenticationOptions,
  ) async {
    assert(Platform.isAndroid);

    await custom_tabs.launch(
      // Build URL according to https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms#3332113
      Uri(
        scheme: 'https',
        host: 'appleid.apple.com',
        path: '/auth/authorize',
        queryParameters: <String, String>{
          'client_id': webAuthenticationOptions.clientId,
          'redirect_uri': webAuthenticationOptions.redirectUri.toString(),
          // TODO: Align with configurable scopes currently being implemented for iOS
          'scope': 'name email',
          // Request `code`, which is also what `ASAuthorizationAppleIDCredential.authorizationCode` contains
          // So the same handling can be used for Apple and 3rd party platforms
          'response_type': 'code',
          'response_mode': 'form_post',
        },
      ).toString(),
      option: custom_tabs.CustomTabsOption(),
    );

    throw Exception('');
  }
}
