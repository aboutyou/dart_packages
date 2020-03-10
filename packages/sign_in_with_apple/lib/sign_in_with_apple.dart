import 'dart:async';

import 'package:flutter/services.dart';

export './sign_in_with_apple_button/sign_in_with_apple_button.dart';

class SignInWithApple {
  static const MethodChannel _channel =
      const MethodChannel('de.aboutyou.mobile.app.sign_in_with_apple');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');

    return version;
  }
}
