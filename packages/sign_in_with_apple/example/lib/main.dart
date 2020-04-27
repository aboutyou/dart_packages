import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app: Sign in with Apple'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SignInWithAppleButton(
              onPressed: () async {
                final credential = await SignInWithApple.getAppleIDCredential(
                  scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                  webAuthenticationOptions: WebAuthenticationOptions(
                    // TODO: Set these 2 parameters to the values you entered in the Apple Developer portal during the setup
                    clientId:
                        'de.lunaone.flutter.signinwithappleexample.service',
                    redirectUri: Uri.parse(
                      'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
                    ),
                  ),
                );

                // This is the endpoint that will convert an authorization code obtained
                // via Sign in with Apple into a session in your system
                final signInWithAppleEndpoint = Uri(
                  scheme: 'https',
                  host: 'flutter-sign-in-with-apple-example.glitch.me',
                  path: '/sign_in_with_apple',
                  queryParameters: <String, String>{
                    'code': credential.authorizationCode,
                    'useBundleId':
                        Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
                  },
                );

                final session = await http.Client().post(
                  signInWithAppleEndpoint,
                );

                // If we got this far, a session based on the Apple ID credential has been created in your system,
                // and you can now set this as the app's session
                print(session);
              },
            ),
          ),
        ),
      ),
    );
  }
}
