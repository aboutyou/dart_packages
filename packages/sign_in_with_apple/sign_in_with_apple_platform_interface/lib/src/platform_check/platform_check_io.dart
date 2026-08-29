import 'dart:io';

bool get isAndroid => Platform.isAndroid;

bool get isIOS => Platform.isIOS;

bool get isMacOS => Platform.isMacOS;

/// Whether the code is executing as part of a `flutter test` run.
bool get isFlutterTest => Platform.environment['FLUTTER_TEST'] == 'true';
