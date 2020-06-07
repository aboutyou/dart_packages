import 'package:meta/meta.dart';

abstract class KeychainClass {
  Map<String, dynamic> toJson();
}

class GenericPasswordKeychainClass implements KeychainClass {
  const GenericPasswordKeychainClass({
    @required this.account,
    this.service,
  }) : assert(account != null);

  final String account;

  final String service;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'generic-password',
      'account': account,
      if (service != null) 'service': service,
    };
  }
}

class IOSSettings {
  const IOSSettings({
    this.keychainClass,
  }) : assert(keychainClass != null);

  final KeychainClass keychainClass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (keychainClass != null) 'keychain-class': keychainClass.toJson(),
    };
  }
}
