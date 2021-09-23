import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  test('Generates a nonce with the provided length', () {
    expect(
      generateNonce(length: 40),
      hasLength(40),
    );
  });

  test('Generates a nonce with the default length', () {
    expect(
      generateNonce(),
      hasLength(32),
    );
  });
}
