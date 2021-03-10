import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    SignInWithApple.channel.setMockMethodCallHandler(null);
  });

  test('performAuthorizationRequest -> Apple ID', () async {
    SignInWithApple.channel.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'performAuthorizationRequest') {
        return <dynamic, dynamic>{
          'type': 'appleid',
          'userIdentifier': 'some userIdentifier',
          'givenName': 'some givenName',
          'familyName': 'some familyName',
          'email': 'some@email.com',
          'identityToken': 'identityToken',
          'authorizationCode': 'authorizationCode',
        };
      }

      throw Exception('Unexpected method');
    });

    expect(
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.example',
          redirectUri: Uri.parse('https://example.com'),
        ),
      ),
      isA<AuthorizationCredentialAppleID>(),
    );
  });

  test('performAuthorizationRequest -> Username/Password', () async {
    SignInWithApple.channel.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'performAuthorizationRequest') {
        return <dynamic, dynamic>{
          'type': 'password',
          'username': 'user1',
          'password': 'admin',
        };
      }

      throw Exception('Unexpected method');
    });

    expect(
      await SignInWithApple.getKeychainCredential(),
      isA<AuthorizationCredentialPassword>(),
    );
  });

  // How to mock EventChannel notification
  // https://github.com/flutter/flutter/issues/38954
  test('onCredentialRevokedNotification -> Trigger notification', () async {
    var count = 0;
    void increment() {
      count++;
    }

    SignInWithApple.onCredentialRevokedNotification.listen((event) {
      increment();
    });

    expect(count, 0);

    await ServicesBinding.instance?.defaultBinaryMessenger
        .handlePlatformMessage(
            'com.aboutyou.dart_packages.sign_in_with_apple_events',
            StandardMethodCodec().encodeSuccessEnvelope(null),
            (data) {});

    expect(count, 1);
  });
}
