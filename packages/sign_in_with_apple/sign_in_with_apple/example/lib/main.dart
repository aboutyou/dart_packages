import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Needed because we can't import `web` into a mobile app,
// while on the flip-side access to `dart:io` throws at runtime (hence the `kIsWeb` check below)
import 'html_shim.dart' if (dart.library.js_interop) 'package:web/web.dart'
    show window;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: ((settings) {
        // This is also invoked for incoming deep links

        // ignore: avoid_print
        print('onGenerateRoute: $settings');

        return null;
      }),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app: Sign in with Apple'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: SignInWithAppleButton(
              onPressed: () async {
                final credential = await SignInWithApple.getAppleIDCredential(
                  scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                  webAuthenticationOptions: WebAuthenticationOptions(
                    // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                    clientId:
                        'de.lunaone.flutter.signinwithappleexample.service',
                    redirectUri:
                        // For web your redirect URI needs to be the host of the "current page",
                        // while for Android you will be using the API server that redirects back into your app via a deep link
                        // NOTE(tp): For package local development use (as described in `Development.md`)
                        // Uri.parse('https://siwa-flutter-plugin.dev/')
                        kIsWeb
                            ? Uri.parse('https://${window.location.host}/')
                            : Uri.parse(
                                'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
                              ),
                  ),
                  // TODO: Remove these if you have no need for them
                  nonce: 'example-nonce',
                  state: 'example-state',
                );

                // ignore: avoid_print
                print(credential);

                // This is the endpoint that will convert an authorization code obtained
                // via Sign in with Apple into a session in your system
                final signInWithAppleEndpoint = Uri(
                  scheme: 'https',
                  host: 'flutter-sign-in-with-apple-example.glitch.me',
                  path: '/sign_in_with_apple',
                  queryParameters: <String, String>{
                    'code': credential.authorizationCode,
                    if (credential.givenName != null)
                      'firstName': credential.givenName!,
                    if (credential.familyName != null)
                      'lastName': credential.familyName!,
                    'useBundleId':
                        !kIsWeb && (Platform.isIOS || Platform.isMacOS)
                            ? 'true'
                            : 'false',
                    if (credential.state != null) 'state': credential.state!,
                  },
                );

                final session = await http.Client().post(
                  signInWithAppleEndpoint,
                );

                // If we got this far, a session based on the Apple ID credential has been created in your system,
                // and you can now set this as the app's session
                // ignore: avoid_print
                print(session);
              },
            ),
          ),
        ),
      ),
    );
  }
}
