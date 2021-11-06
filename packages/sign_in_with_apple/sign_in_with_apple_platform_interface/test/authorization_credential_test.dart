import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart';

void main() {
  test('parseAuthorizationCredentialAppleIDFromDeeplink: Only Code', () async {
    final deeplink = Uri.parse(
      'signinwithapple://callback?code=c7d1b13b5f1dd4c46ae22a128c2f28c2e.0.nrqtw.7xH1wz9jb9jyk8i5v2K2Jg',
    );

    final parsed = parseAuthorizationCredentialAppleIDFromDeeplink(deeplink);

    expect(
      parsed.authorizationCode,
      'c7d1b13b5f1dd4c46ae22a128c2f28c2e.0.nrqtw.7xH1wz9jb9jyk8i5v2K2Jg',
    );
  });

  test('parseAuthorizationCredentialAppleIDFromDeeplink: With User', () async {
    final deeplink = Uri.parse(
      'signinwithapple://callback?code=c7253d404c180400eaa4691aa9c8c07ff.0.nrqtw.OALT9--SjOoLRti_wvrF5Q&user=%7B%22name%22%3A%7B%22firstName%22%3A%22Timm%22%2C%22lastName%22%3A%22Preetz%22%7D%2C%22email%22%3A%224rtppgbhgb%40privaterelay.appleid.com%22%7D',
    );

    final parsed = parseAuthorizationCredentialAppleIDFromDeeplink(deeplink);

    expect(
      parsed.authorizationCode,
      'c7253d404c180400eaa4691aa9c8c07ff.0.nrqtw.OALT9--SjOoLRti_wvrF5Q',
    );

    expect(
      parsed.givenName,
      'Timm',
    );

    expect(
      parsed.familyName,
      'Preetz',
    );

    expect(
      parsed.email,
      '4rtppgbhgb@privaterelay.appleid.com',
    );
  });

  test(
    'parseAuthorizationCredentialAppleIDFromDeeplink: With user but only email',
    () async {
      final deeplink = Uri.parse(
        'signinwithapple://callback?code=c7253d404c180400eaa4691aa9c8c07ff.0.nrqtw.OALT9--SjOoLRti_wvrF5Q&user=%7B%22email%22%3A%224rtppgbhgb%40privaterelay.appleid.com%22%7D',
      );

      final parsed = parseAuthorizationCredentialAppleIDFromDeeplink(deeplink);

      expect(
        parsed.authorizationCode,
        'c7253d404c180400eaa4691aa9c8c07ff.0.nrqtw.OALT9--SjOoLRti_wvrF5Q',
      );

      expect(parsed.givenName, isNull);
      expect(parsed.familyName, isNull);

      expect(
        parsed.email,
        '4rtppgbhgb@privaterelay.appleid.com',
      );
    },
  );
}
