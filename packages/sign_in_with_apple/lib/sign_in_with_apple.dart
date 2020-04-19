import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/src/web_authentication_options.dart';
import 'package:sign_in_with_apple/src/exceptions.dart';

import './src/authorization_credential.dart';
import './src/authorization_request.dart';
import './src/credential_state.dart';

export './src/authorization_credential.dart'
    show
        AuthorizationCredential,
        AuthorizationCredentialAppleID,
        AuthorizationCredentialPassword;
export './src/authorization_request.dart'
    show
        AuthorizationRequest,
        PasswordAuthorizationRequest,
        AppleIDAuthorizationScopes,
        AppleIDAuthorizationRequest;
export './src/credential_state.dart' show CredentialState;
export './src/web_authentication_options.dart' show WebAuthenticationOptions;
export './src/widgets/is_sign_in_with_apple_available.dart'
    show IsSignInWithAppleAvailable;
export './src/widgets/sign_in_with_apple_button.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle, IconAlignment;

// ignore: avoid_classes_with_only_static_members
class SignInWithApple {
  @visibleForTesting
  static const channel = MethodChannel(
    'com.aboutyou.dart_packages.sign_in_with_apple',
  );

  /// Returns the credentials stored in the Keychain for the app-associated websites
  static Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    try {
      return parseAuthorizationCredentialPassword(
        await channel.invokeMethod<Map<dynamic, dynamic>>(
          'performAuthorizationRequest',
          [
            PasswordAuthorizationRequest(),
          ].map((request) => request.toJson()).toList(),
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  /// Requests Apple ID credentials from the system.
  ///
  /// Fields on the returned [AuthorizationCredential] will be set based on the given scopes,
  /// and user data will only be set if this is the initial authentication for the Apple ID with your app.
  ///
  /// In case of an error on the native side, we will throw an [SignInWithAppleException].
  /// If we have a more specific authorization error, we will throw [SignInWithAppleAuthorizationException],
  /// which has more information about the failure.
  /// 
  /// In case Sign in with Apple is not available, this will throw an [SignInWithAppleNotSupportedException].
  static Future<AuthorizationCredential> getAppleIDCredential({
    @required List<AppleIDAuthorizationScopes> scopes,

    /// Optional parameters for web-based authentication flows on non-Apple platforms
    WebAuthenticationOptions webAuthenticationOptions,
  }) async {
    assert(scopes != null);

    if (webAuthenticationOptions == null &&
        (!Platform.isIOS && !Platform.isMacOS)) {
      throw Exception(
        'webAuthenticationOptions parameter must be provided on non-Apple platforms',
      );
    }

    if (Platform.isAndroid) {
      return _signInWithAppleAndroid(
        scopes: scopes,
        webAuthenticationOptions: webAuthenticationOptions,
      );
    }

    try {
      if (!Platform.isIOS &&
          !Platform.isMacOS &&
          Platform.environment['FLUTTER_TEST'] != 'true') {
        throw SignInWithAppleNotSupportedException(
          message: 'The current platform is not supported',
        );
      }

      return parseAuthorizationCredentialAppleID(
        await channel.invokeMethod<Map<dynamic, dynamic>>(
          'performAuthorizationRequest',
          [
            AppleIDAuthorizationRequest(scopes: scopes),
          ].map((request) => request.toJson()).toList(),
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  /// Request the credentials state a giver [userIdentifier].
  /// The [userIdentifier] should come from a previos call to [requestCredentials] which returned an [AuthorizationCredentialAppleID].
  ///
  /// This method allows you to check whether or not the user is still authorized, revoked the access or has not yet signed up with it.
  ///
  /// This methods either completes with a [CredentialState] or throws an [SignInWithAppleException].
  /// In case there was an error while getting the credentials state, this throws a [SignInWithAppleCredentialsException].
  /// In case Sign in with Apple is not available, this will throw an [SignInWithAppleNotSupportedException].
  ///
  /// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider/3175423-getcredentialstate
  static Future<CredentialState> getCredentialState(
    String userIdentifier,
  ) async {
    assert(userIdentifier != null);

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

  /// This checks with the native platform whether or not Sign in with Apple is available.
  ///
  /// For iOS, the user will need `iOS 13` or higher.
  /// For macOS, the user will need `macOS Catalina` or higher.
  ///
  /// In case Sign in with Apple is not available, this will complete with `false`.
  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }

  static Future<AuthorizationCredential> _signInWithAppleAndroid({
    @required List<AppleIDAuthorizationScopes> scopes,
    @required WebAuthenticationOptions webAuthenticationOptions,
  }) async {
    assert(Platform.isAndroid);

    /// URL according to https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms#3332113
    final uri = Uri(
      scheme: 'https',
      host: 'appleid.apple.com',
      path: '/auth/authorize',
      queryParameters: <String, String>{
        'client_id': webAuthenticationOptions.clientId,
        'redirect_uri': webAuthenticationOptions.redirectUri.toString(),
        'scope': scopes
            .map((scope) {
              switch (scope) {
                case AppleIDAuthorizationScopes.email:
                  return 'email';
                case AppleIDAuthorizationScopes.fullName:
                  return 'name';
              }
              return null;
            })
            .where((scope) => scope != null)
            .join(' '),
        // Request `code`, which is also what `ASAuthorizationAppleIDCredential.authorizationCode` contains.
        // So the same handling can be used for Apple and 3rd party platforms
        'response_type': 'code',
        'response_mode': 'form_post',
      },
    ).toString();

    final result = await channel.invokeMethod<String>(
      'performAuthorizationRequest',
      <String, String>{
        'url': uri,
      },
    );

    return parseAuthorizationCredentialAppleIDFromDeeplink(Uri.parse(result));
  }
}
