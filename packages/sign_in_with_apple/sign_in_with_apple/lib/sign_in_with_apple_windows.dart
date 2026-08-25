/// The Windows implementation of `sign_in_with_apple`.
///
/// Kept out of `package:sign_in_with_apple/sign_in_with_apple.dart` because it
/// imports `dart:io`, which a web build cannot compile. The generated plugin
/// registrant imports this library on Windows only — see `dartFileName` in this
/// package's pubspec — so nothing needs importing to make sign-in work.
///
/// Import it directly only to reach the parts of the Windows flow the shared
/// [SignInWithApplePlatform] API has nowhere to express: whether a browser
/// sign-in is still outstanding, and how to abandon one. Do that behind a
/// conditional import, or the web build follows `dart:io` back in:
///
/// ```dart
/// export 'apple_cancel_io.dart' if (dart.library.js_interop) 'apple_cancel_web.dart';
/// ```
///
/// [SignInWithAppleWindows] documents what the flow requires of the redirect
/// endpoint, which is where a Windows sign-in most often fails.
library sign_in_with_apple_windows;

export 'src/windows/sign_in_with_apple_windows.dart' show SignInWithAppleWindows;
