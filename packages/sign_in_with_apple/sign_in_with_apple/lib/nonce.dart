import 'dart:math';

const _chars =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

/// Generate a cryptographically secure random nonce
String generateNonce({int length = 32}) {
  final random = Random.secure();

  return Iterable.generate(
    length,
    (_) => _chars[random.nextInt(_chars.length)],
  ).join();
}
