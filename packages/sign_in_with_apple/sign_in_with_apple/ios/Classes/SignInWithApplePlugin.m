#import "SignInWithApplePlugin.h"
#if __has_include(<sign_in_with_apple/sign_in_with_apple-Swift.h>)
#import <sign_in_with_apple/sign_in_with_apple-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sign_in_with_apple-Swift.h"
#endif

@implementation SignInWithApplePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSignInWithApplePlugin registerWithRegistrar:registrar];
}
@end
