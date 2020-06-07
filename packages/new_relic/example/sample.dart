import 'dart:math';

import '../lib/src/app.dart' show NRApp;
import 'dart:io' show Platform;

void main() async {
  final random = Random();

  final app = NRApp(
    cSDKPath: "/app/libnewrelic.so",
    daemonHost: "newrelic:7878",
    appName: Platform.environment["NEW_RELIC_APP_NAME"],
    licenseKey: Platform.environment["NEW_RELIC_LICENSE_KEY"],
  );

  for (var i = 0; i < 500; i++) {
    try {
      final txn = app.startWebTransaction(
        ("GET /Sample/Dart/Transaction"),
      );

      await Future<void>.delayed(
        Duration(milliseconds: 500 + random.nextInt(2500)),
      );

      txn.addAttribute("int_value", random.nextInt(100000));
      txn.addAttribute("string_value", "foobar");

      if (random.nextInt(10) == 0) {
        txn.noticeError(
          Exception("Test"),
          StackTrace.current,
        );
      }

      txn.end();
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
