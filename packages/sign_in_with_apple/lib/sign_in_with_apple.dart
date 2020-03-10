import 'dart:async';

import 'package:flutter/services.dart';

class SignInWithApple {
  static const MethodChannel _channel =
      const MethodChannel('sign_in_with_apple');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
