import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  const channel = MethodChannel('sign_in_with_apple');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await SignInWithApple.platformVersion, '42');
  });
}
