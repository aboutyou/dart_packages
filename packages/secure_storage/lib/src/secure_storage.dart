import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureStorage {
  @visibleForTesting
  static final methodChannel = MethodChannel(
    'com.aboutyou.dart_packages.secure_storage',
  );

  static Future<String> read({
    @required String key,
  }) async {
    assert(key != null);

    try {
      return await methodChannel.invokeMethod<String>('read', {
        'key': key,
      });
    } catch (exception) {}
  }

  static Future<String> write({
    @required String key,
    @required String value,
  }) async {
    assert(key != null);

    try {
      return await methodChannel.invokeMethod<String>('write', {
        'key': key,
        'value': value,
      });
    } catch (exception) {}
  }
}
