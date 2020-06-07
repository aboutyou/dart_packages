import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_utils;
import 'dart:io' show Platform;

void main() async {
  // Open the dynamic library
  final path = "/app/libnewrelic.so";
  final dylib = ffi.DynamicLibrary.open(path);

  final initF = dylib
      .lookup<ffi.NativeFunction<nrInit>>(
        'newrelic_init',
      )
      .asFunction<NRInit>();

  final createNrAppConfig = dylib
      .lookup<ffi.NativeFunction<nrCreateAppConfig>>(
        'newrelic_create_app_config',
      )
      .asFunction<NRCreateAppConfig>();

  final createNrApp = dylib
      .lookup<ffi.NativeFunction<nrCreateApp>>(
        'newrelic_create_app',
      )
      .asFunction<NRCreateApp>();

  final createNrTransaction = dylib
      .lookup<ffi.NativeFunction<nrCreateWebTransaction>>(
        'newrelic_start_web_transaction',
      )
      .asFunction<NRCreateWebTransaction>();

  final endNrTransaction = dylib
      .lookup<ffi.NativeFunction<nrEndWebTransaction>>(
          'newrelic_end_transaction')
      .asFunction<NREndWebTransaction>();

  final noticeError = dylib
      .lookup<ffi.NativeFunction<nrNoticeError>>('newrelic_notice_error')
      .asFunction<NRNoticeError>();

  final newrelic_add_attribute_string = dylib
      .lookup<ffi.NativeFunction<nrAddAttributeString>>(
          'newrelic_add_attribute_string')
      .asFunction<NRAddAttributeString>();
  final newrelic_add_attribute_long = dylib
      .lookup<ffi.NativeFunction<nrAddAttributeLong>>(
          'newrelic_add_attribute_long')
      .asFunction<NRAddAttributeLong>();

  initF(ffi_utils.Utf8.toUtf8("newrelic:7878"), 10000);

  final appConfig = createNrAppConfig(
    ffi_utils.Utf8.toUtf8(Platform.environment["NEW_RELIC_APP_NAME"]),
    ffi_utils.Utf8.toUtf8(Platform.environment["NEW_RELIC_LICENSE_KEY"]),
  );

  print("config:");
  print(Platform.environment["NEW_RELIC_APP_NAME"]);
  print(Platform.environment["NEW_RELIC_LICENSE_KEY"]);

  final app = createNrApp(
    appConfig,
    10000,
  );

  print('app');
  print(app);

  for (var i = 0; i < 10; i++) {
    try {
      print('get txn');
      final txn = createNrTransaction(
        app,
        ffi_utils.Utf8.toUtf8("Sample Dart transaction $i"),
      );
      print('txn');
      print(txn);

      await Future<void>.delayed(Duration(seconds: 1));

      // final dp = ffi.Pointer<ffi.Pointer<NRWebTransaction>>.fromAddress(
      //   txn.address, // ffi.Pointer<NRWebTransaction>
      // );

      if (i % 3 == 0) {
        newrelic_add_attribute_long(
            txn, ffi_utils.Utf8.toUtf8("int_key"), 1000000);
        newrelic_add_attribute_string(txn, ffi_utils.Utf8.toUtf8("string_key"),
            ffi_utils.Utf8.toUtf8("yolo"));

        noticeError(
            txn,
            0,
            ffi_utils.Utf8.toUtf8(
              "Some error\n\rTest\n\n${StackTrace.current.toString()}",
            ),
            ffi_utils.Utf8.toUtf8("ExampleException"));
      }

      // dp.value

      // ffi.Pointer<

      //  ffi.allocate<Place>()
      final dp = ffi_utils.allocate<ffi.Pointer<NRWebTransaction>>()
        ..value = txn;
      // dp.value = txn;

      // ptr

      print(dp);

// fff
// ffi.DoublePointer
      print(
        endNrTransaction(dp) == 1,
        // endNrTransaction(txn),
      );
    } catch (e, s) {
      print(e);
      print(s);
    }

    // await Future<void>.delayed(Duration(seconds: 1));
  }

  // await runAsync(app);
  // await Future<void>.delayed(Duration(seconds: 10));
}

// void runAsync(ffi.Pointer<NRApp> app) {
// }

// newrelic_create_app_config("Your Application Name", "LICENSE_KEY_HERE");

// workaround, as there is no bool return type: https://github.com/dart-lang/sdk/issues/36855
typedef nrInit = ffi.Int8 Function(
  ffi.Pointer<ffi_utils.Utf8> host,
  ffi.Int32 connectionTimeout,
);
typedef NRInit = int Function(
  ffi.Pointer<ffi_utils.Utf8> host,
  int connectionTimeout,
);

typedef nrCreateAppConfig = ffi.Pointer<NRAppConfig> Function(
  ffi.Pointer<ffi_utils.Utf8> applicationName,
  ffi.Pointer<ffi_utils.Utf8> licenseKey,
);
typedef NRCreateAppConfig = ffi.Pointer<NRAppConfig> Function(
  ffi.Pointer<ffi_utils.Utf8> applicationName,
  ffi.Pointer<ffi_utils.Utf8> licenseKey,
);

class NRAppConfig extends ffi.Struct {
  //fields don't matter to us
}

typedef nrCreateApp = ffi.Pointer<NRApp> Function(
    ffi.Pointer<NRAppConfig> appConfig, ffi.Uint16 daemonConnectionTimeout);
typedef NRCreateApp = ffi.Pointer<NRApp> Function(
  ffi.Pointer<NRAppConfig> appConfig,
  int daemonConnectionTimeout,
);

class NRApp extends ffi.Struct {
  //fields don't matter to us
}

typedef nrCreateWebTransaction = ffi.Pointer<NRWebTransaction> Function(
  ffi.Pointer<NRApp> app,
  ffi.Pointer<ffi_utils.Utf8> transactionName,
);
typedef NRCreateWebTransaction = ffi.Pointer<NRWebTransaction> Function(
  ffi.Pointer<NRApp> app,
  ffi.Pointer<ffi_utils.Utf8> transactionName,
);

class NRWebTransaction extends ffi.Struct {
  //fields don't matter to us
}

// workaround, as there is no bool return type: https://github.com/dart-lang/sdk/issues/36855
typedef nrEndWebTransaction = ffi.Int8 Function(
  ffi.Pointer<ffi.Pointer<NRWebTransaction>> txn, // yes, double pointer
);
typedef NREndWebTransaction = int Function(
  ffi.Pointer<ffi.Pointer<NRWebTransaction>> txn,
);

typedef nrNoticeError = ffi.Void Function(
  ffi.Pointer<NRWebTransaction> txn,
  ffi.Int32 priority,
  ffi.Pointer<ffi_utils.Utf8> errorMessage,
  ffi.Pointer<ffi_utils.Utf8> errorClasse,
);
typedef NRNoticeError = void Function(
  ffi.Pointer<NRWebTransaction> txn,
  int priority,
  ffi.Pointer<ffi_utils.Utf8> errorMessage,
  ffi.Pointer<ffi_utils.Utf8> errorClasse,
);

typedef nrAddAttributeString = ffi.Int8 Function(
  ffi.Pointer<NRWebTransaction> txn,
  ffi.Pointer<ffi_utils.Utf8> key,
  ffi.Pointer<ffi_utils.Utf8> value,
);
// int is bool
typedef NRAddAttributeString = int Function(
  ffi.Pointer<NRWebTransaction> txn,
  ffi.Pointer<ffi_utils.Utf8> key,
  ffi.Pointer<ffi_utils.Utf8> value,
);

typedef nrAddAttributeLong = ffi.Int8 Function(
  ffi.Pointer<NRWebTransaction> txn,
  ffi.Pointer<ffi_utils.Utf8> key,
  ffi.Int64 value,
);
// int is bool
typedef NRAddAttributeLong = int Function(
  ffi.Pointer<NRWebTransaction> txn,
  ffi.Pointer<ffi_utils.Utf8> key,
  int value,
);
