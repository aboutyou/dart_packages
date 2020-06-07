import '../lib/src/app.dart' show NRApp;
import 'dart:io' show Platform;

void main() async {
  final app = NRApp(
    cSDKPath: "/app/libnewrelic.so",
    daemonHost: "newrelic:7878",
    appName: Platform.environment["NEW_RELIC_APP_NAME"],
    licenseKey: Platform.environment["NEW_RELIC_LICENSE_KEY"],
  );

  for (var i = 0; i < 10; i++) {
    try {
      final txn = app.startWebTransaction(
        ("GET /Sample/Dart/Transaction"),
      );

      await Future<void>.delayed(Duration(seconds: 1));

      txn.addAttribute("int_value", 123457);
      txn.addAttribute("string_value", "foobar");

      if (i % 3 == 0) {
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
