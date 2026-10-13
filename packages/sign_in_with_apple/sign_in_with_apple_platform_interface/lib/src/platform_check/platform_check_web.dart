// On the web the method channel implementation is replaced by
// `sign_in_with_apple_web`, so these checks only need to compile: they mirror
// `dart:io`'s behavior of not reporting any mobile/desktop operating system.
bool get isAndroid => false;

bool get isIOS => false;

bool get isMacOS => false;

bool get isFlutterTest => false;
