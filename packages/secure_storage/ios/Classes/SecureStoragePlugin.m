#import "SecureStoragePlugin.h"
#if __has_include(<secure_storage/secure_storage-Swift.h>)
#import <secure_storage/secure_storage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "secure_storage-Swift.h"
#endif

@implementation SecureStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSecureStoragePlugin registerWithRegistrar:registrar];
}
@end
