abstract class KeychainClass {
  Map<String, dynamic> toJson() {}
}

class GenericPasswordKeychainClass implements KeychainClass {
  const GenericPasswordKeychainClass({
    this.account,
    this.service,
  });

  final String account;

  final String service;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'generic-password',
      if (account != null) 'account': account,
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
