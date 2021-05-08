import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_utils;
import 'package:meta/meta.dart';

class NRCSDK {
  NRCSDK._internal({
    @required this.init,
    @required this.createAppConfig,
    @required this.createApp,
    @required this.createWebTransaction,
    @required this.endWebTransaction,
    @required this.noticeError,
    @required this.addAttributeString,
    @required this.addAttributeLong,
  });

  factory NRCSDK({
    @required String nrCSDKPath,
  }) {
    final dylib = ffi.DynamicLibrary.open(nrCSDKPath);

    final init = dylib
        .lookup<ffi.NativeFunction<nrInit>>(
          'newrelic_init',
        )
        .asFunction<NRInit>();

    final createAppConfig = dylib
        .lookup<ffi.NativeFunction<nrCreateAppConfig>>(
          'newrelic_create_app_config',
        )
        .asFunction<NRCreateAppConfig>();

    final createApp = dylib
        .lookup<ffi.NativeFunction<nrCreateApp>>(
          'newrelic_create_app',
        )
        .asFunction<NRCreateApp>();

    final createWebTransaction = dylib
        .lookup<ffi.NativeFunction<nrCreateWebTransaction>>(
          'newrelic_start_web_transaction',
        )
        .asFunction<NRCreateWebTransaction>();

    final endWebTransaction = dylib
        .lookup<ffi.NativeFunction<nrEndWebTransaction>>(
          'newrelic_end_transaction',
        )
        .asFunction<NREndWebTransaction>();

    final noticeError = dylib
        .lookup<ffi.NativeFunction<nrNoticeError>>('newrelic_notice_error')
        .asFunction<NRNoticeError>();

    final addAttributeString = dylib
        .lookup<ffi.NativeFunction<nrAddAttributeString>>(
          'newrelic_add_attribute_string',
        )
        .asFunction<NRAddAttributeString>();
    final addAttributeLong = dylib
        .lookup<ffi.NativeFunction<nrAddAttributeLong>>(
          'newrelic_add_attribute_long',
        )
        .asFunction<NRAddAttributeLong>();

    return NRCSDK._internal(
      init: init,
      createAppConfig: createAppConfig,
      createApp: createApp,
      createWebTransaction: createWebTransaction,
      endWebTransaction: endWebTransaction,
      noticeError: noticeError,
      addAttributeString: addAttributeString,
      addAttributeLong: addAttributeLong,
    );
  }

  final NRInit init;

  final NRCreateAppConfig createAppConfig;

  final NRCreateApp createApp;

  final NRCreateWebTransaction createWebTransaction;

  final NREndWebTransaction endWebTransaction;

  final NRNoticeError noticeError;

  final NRAddAttributeString addAttributeString;

  final NRAddAttributeLong addAttributeLong;
}

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
  // Fields don't matter (as they aren't read from Dart)
}

typedef nrCreateApp = ffi.Pointer<NRApp> Function(
    ffi.Pointer<NRAppConfig> appConfig, ffi.Uint16 daemonConnectionTimeout);
typedef NRCreateApp = ffi.Pointer<NRApp> Function(
  ffi.Pointer<NRAppConfig> appConfig,
  int daemonConnectionTimeout,
);

class NRApp extends ffi.Struct {
  // Fields don't matter (as they aren't read from Dart)
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
  // Fields don't matter (as they aren't read from Dart)
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
