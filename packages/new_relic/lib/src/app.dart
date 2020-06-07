import 'package:meta/meta.dart';
import 'package:new_relic/src/sdk/sdk.dart' as csdk;
import 'package:ffi/ffi.dart' as ffi_utils;
import 'dart:ffi' as ffi;

class NRApp {
  NRApp._internal(
    csdk.NRCSDK sdk,
    ffi.Pointer<csdk.NRApp> app,
  )   : _sdk = sdk,
        _app = app;

  factory NRApp({
    @required String cSDKPath,
    @required String daemonHost,
    @required String appName,
    @required String licenseKey,
  }) {
    final sdk = csdk.NRCSDK(nrCSDKPath: cSDKPath);

    sdk.init(cStr(daemonHost), 10000);

    final app = sdk.createApp(
      sdk.createAppConfig(cStr(appName), cStr(licenseKey)),
      10000,
    );

    return NRApp._internal(sdk, app);
  }

  final csdk.NRCSDK _sdk;

  final ffi.Pointer<csdk.NRApp> _app;

  NRWebTransaction startWebTransaction(String transactionName) {
    return NRWebTransaction._internal(
      _sdk,
      _sdk.createWebTransaction(_app, cStr(transactionName)),
    );
  }
}

class NRWebTransaction {
  NRWebTransaction._internal(
    csdk.NRCSDK sdk,
    ffi.Pointer<csdk.NRWebTransaction> txn,
  )   : _sdk = sdk,
        _txn = txn;

  final csdk.NRCSDK _sdk;

  final ffi.Pointer<csdk.NRWebTransaction> _txn;

  bool addAttribute(String key, dynamic value) {
    if (value is int) {
      return _sdk.addAttributeLong(_txn, cStr(key), value) == 1;
    } else if (value is String) {
      return _sdk.addAttributeString(_txn, cStr(key), cStr(value)) == 1;
    } else {
      return _sdk.addAttributeString(_txn, cStr(key), cStr("$value")) == 1;
    }
  }

  void noticeError(dynamic error, StackTrace stackTrace) {
    _sdk.noticeError(
      _txn,
      0,
      cStr("$error \n${stackTrace.toString()}"),
      cStr("${error.runtimeType}"),
    );
  }

  bool end() {
    // need to build pointer to original transaction, so SDK can clear it
    final txn = ffi_utils.allocate<ffi.Pointer<csdk.NRWebTransaction>>()
      ..value = _txn;

    return _sdk.endWebTransaction(txn) == 1;
  }
}

ffi.Pointer<ffi_utils.Utf8> cStr(String str) {
  return ffi_utils.Utf8.toUtf8(str);
}
