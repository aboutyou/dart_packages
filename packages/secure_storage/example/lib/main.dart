import 'package:flutter/material.dart';
import 'dart:async';

import 'package:secure_storage/secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final value = SecureStorageValue(
  ios: IOSSettings(
    keychainClass: GenericPasswordKeychainClass(
      account: 'aymlive2@aboutyou.de',
    ),
  ),
);

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await value.write(value: 'Hello 2');

    final v = await value.read();

    print(v);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: \n'),
        ),
      ),
    );
  }
}
