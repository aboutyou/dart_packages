import 'package:flutter/material.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

void main() {
  // Workaround for macOS support (https://github.com/flutter/flutter/issues/39881)
  if (!Platform.isAndroid && !Platform.isIOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

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
              final credentials = await SignInWithApple.requestCredentials();

              print(credentials);

              if (credentials is AuthorizationCredentialAppleID) {
                /// send credentials to your server to create a session
                /// after they have been validated with Apple
              } else if (credentials is AuthorizationCredentialPassword) {
                /// Login the user using username/password combination
              }
            },
          ),
        ),
      ),
      ),
    );
  }
}
