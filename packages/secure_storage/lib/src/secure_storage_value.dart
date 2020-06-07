import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ios/ios_settings.dart';

class SecureStorageValue {
  const SecureStorageValue({
    @required this.ios,
  }) : assert(ios != null);

  @visibleForTesting
  static final methodChannel = MethodChannel(
    'com.aboutyou.dart_packages.secure_storage',
  );

  final IOSSettings ios;

  Future<String> read() async {
    try {
      Map<String, dynamic> args;

      if (Platform.isIOS || Platform.isMacOS) {
        args = ios.toJson();
      } else if (Platform.isAndroid) {
        /// TODO: Android support
      }

      if (args == null) {
        throw UnsupportedError('Unsuportted platform');
      }

      return await methodChannel.invokeMethod<String>(
        'read',
        args,
      );
    } catch (exception) {}
  }

  Future<String> write({
    @required String value,
  }) async {
    try {
      Map<String, dynamic> args;

      if (Platform.isIOS || Platform.isMacOS) {
        args = ios.toJson();
      } else if (Platform.isAndroid) {
        /// TODO: Android support
      }

      if (args == null) {
        throw UnsupportedError('Unsuportted platform');
      }

      return await methodChannel.invokeMethod<String>(
        'write',
        {
          ...args,
          'value': value,
        },
      );
    } catch (exception) {}
  }

  Future<void> delete() async {
    try {
      Map<String, dynamic> args;

      if (Platform.isIOS || Platform.isMacOS) {
        args = ios.toJson();
      } else if (Platform.isAndroid) {
        /// TODO: Android support
      }

      if (args == null) {
        throw UnsupportedError('Unsuportted platform');
      }

      await methodChannel.invokeMethod<String>('delete', args);
    } catch (exception) {}
  }
}
