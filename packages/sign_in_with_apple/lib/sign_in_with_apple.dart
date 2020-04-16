import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/src/web_authentication_options.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
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

  /// Request credentials from the system.
  ///
  /// Through the [requests], you can specify which [AuthorizationCredential] should be requested.
  /// We currently support the following two:
  /// - [AuthorizationCredentialAppleID] which requests authentication with the users Apple ID.
  /// - [AuthorizationCredentialPassword] which asks for some credentials in the users Keychain.
  ///
  /// In case the authorization is successful, we will return an [AuthorizationCredential].
  /// These can currently be two different type of credentials:
  /// - [AuthorizationCredentialAppleID]
  /// - [AuthorizationCredentialPassword] (only on Apple platforms)
  /// The returned credentials do depend on the [requests] that you specified.
  ///
  /// In case of an error on the native side, we will throw an [SignInWithAppleException].
  /// If we have a more specific authorization error, we will throw [SignInWithAppleAuthorizationError],
  /// which has more information about the failure.
  static Future<AuthorizationCredential> requestCredentials({
    @required List<AuthorizationRequest> requests,

    /// Optional parameters for web-based authentication flows on non-Apple platforms
    WebAuthenticationOptions webAuthenticationOptions,
  }) async {
    assert(requests != null);

    if (webAuthenticationOptions == null &&
        (!Platform.isIOS && !Platform.isMacOS)) {
      throw Exception(
        'webAuthenticationOptions parameter must be provided on non-Apple platforms',
      );
    }

    if (Platform.isAndroid &&
        requests.whereType<AppleIDAuthorizationRequest>().isNotEmpty) {
      return _signInWithAppleAndroid(
          requests.whereType<AppleIDAuthorizationRequest>().first,
          webAuthenticationOptions);
    }

    try {
      return parseCredentialsResponse(
        await channel.invokeMethod<Map<dynamic, dynamic>>(
          'performAuthorizationRequest',
          requests.map((request) => request.toJson()).toList(),
        ),
      );
    } on PlatformException catch (exception) {
      throw SignInWithAppleException.fromPlatformException(exception);
    }
  }

  /// Request the credentials state for the user.
  ///
  /// This methods either completes with a [CredentialState] or throws an [SignInWithAppleException].
  /// In case there was an error while getting the credentials state, this throws a [SignInWithAppleCredentialsException].
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

  static Future<bool> isAvailable() {
    return channel.invokeMethod<bool>('isAvailable');
  }

  static Future<AuthorizationCredential> _signInWithAppleAndroid(
    AppleIDAuthorizationRequest appleIDAuthorizationRequest,
    WebAuthenticationOptions webAuthenticationOptions,
  ) async {
    assert(Platform.isAndroid);

    final uri = Uri(
      scheme: 'https',
      host: 'appleid.apple.com',
      path: '/auth/authorize',
      queryParameters: <String, String>{
        'client_id': webAuthenticationOptions.clientId,
        'redirect_uri': webAuthenticationOptions.redirectUri.toString(),
        // TODO: Align with configurable scopes currently being implemented for iOS
        'scope': appleIDAuthorizationRequest.scopes
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

    print(uri);

    // await custom_tabs.launch(
    //   // URL according to https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms#3332113
    //   uri,

    //   option: custom_tabs.CustomTabsOption(),
    // );

    final result = await channel.invokeMethod<String>(
      'performAuthorizationRequest',
      <String, String>{
        'url': uri,
      },
    );

    print(result);

    /// second time

    /// signinwithapple://callback?code=c7d1b13b5f1dd4c46ae22a128c2f28c2e.0.nrqtw.7xH1wz9jb9jyk8i5v2K2Jg

    /// signinwithapple://callback?code=c7253d404c180400eaa4691aa9c8c07ff.0.nrqtw.OALT9--SjOoLRti_wvrF5Q&user=%7B%22name%22%3A%7B%22firstName%22%3A%22Timm%22%2C%22lastName%22%3A%22Preetz%22%7D%2C%22email%22%3A%224rtppgbhgb%40privaterelay.appleid.com%22%7D

    return AuthorizationCredentialAppleID(
      userIdentifier: 'TODO',
      authorizationCode: result,
    );
  }
}
