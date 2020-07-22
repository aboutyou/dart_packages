import 'package:e2e/e2e.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign-in is available', (tester) async {
    final isAvailable = await SignInWithApple.isAvailable();

    expect(isAvailable, isTrue);
  });

  testWidgets('opnes sign in', (tester) async {
    final credential = SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.aboutyou.dart_packages.sign_in_with_apple.example',
        redirectUri: Uri.parse(
          'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
        ),
      ),
      nonce: 'example-nonce',
      state: 'example-state',
    );

    // Currently there is no easy way to test that the Browser window has been opened.
    // The getAppleIDCredential blocks until the process has been complected.
    // We need to wait and verify that no widget is visible as the browser is over them.
    await Future<void>.delayed(Duration(milliseconds: 200));

    expect(
      find.byType(Widget),
      findsNothing,
    );
  });
}
