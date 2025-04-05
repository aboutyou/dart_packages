## 7.0.1

- Allow `null` for `SignInWithAppleButton`'s `onPressed` handler to disable it

## 7.0.0

- Extend `AuthorizationErrorCode` cases
  - Fix warnings when compiling in Swift 6 mode

## 6.1.4

- Bump `sign_in_with_apple_web` dependency to _actually_ include fix from [#432](https://github.com/aboutyou/dart_packages/pull/432)

## 6.1.3

- Support Xcode 16 (in addition to all previously supported versions)

## 6.1.2

- Switch to modern Gradle setup (https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply) for the example app
- Fix JS types for scenarios omitting `email` scope or `state` parameter [#432](https://github.com/aboutyou/dart_packages/pull/432)

## 6.1.1

- Removes references to Flutter v1 Android embedding classes.

## 6.1.0

- Set min Flutter SDK to 3.19.0
- Upgrade `sign_in_with_apple_platform_interface` to `1.1.0`
- Upgrade `sign_in_with_apple_web` to `2.1.0`
- Android: Bump Kotlin version to 1.7.10 (Flutter 3.19.1 default)
- Android: Bump `compileSdkVersion` to 34 (Flutter 3.19.1 default)

## 6.0.0

- Migrate to package:web
- Bump minimum Flutter version to 3.19.1

## 5.0.0

- Support Gradle 8 ([@davidmartos96](https://github.com/davidmartos96) in [#375](https://github.com/aboutyou/dart_packages/pull/375))
  - Now requires at least Flutter [3.7.6](https://github.com/flutter/flutter/wiki/Hotfixes-to-the-Stable-Channel#376-mar-01-2023), which is needed to find the Java SDKs shipped with [Android Studio Arctic Fox](https://android-developers.googleblog.com/2021/07/android-studio-arctic-fox-202031-stable.html), which has been used in testing

## 4.3.0

- Android: Fixes an issue where the Chrome Custom Tab would disappear when the user "left" the app (e.g. using the app switcher) ([#162](https://github.com/aboutyou/dart_packages/issues/162))
  - Beware that your app's `launchMode` affects the specific behavior of the Chrome Custom Tab. For more information see the README.

## 4.2.0

- Remove `jcenter` repository for the Android package

## 4.1.0

- Add support for `transferred` credential state (Xcode 13.3.1 support) 

## 4.0.0

- Upgrade Kotlin version to `1.6.0`

## 3.3.0

- Switch to `sign_in_with_apple_platform_interface` in conjunction with the addition of web support

## 3.2.0

- Fix building macOS application with Xcode 13 and macOS Big Sur

## 3.1.0

- Add support for Xcode 13

## 3.0.0

- Add `null`-safety

## 2.5.4

- Reformat code with Flutter 1.20.4

## 2.5.3

- Fixes an issue with the compilation if `compileSdkVersion 29` or higher is forced upon the package's build ([#126](https://github.com/aboutyou/dart_packages/pull/126))

## 2.5.2

- Fix a bug where the authentication would crash on Android if only the `AppleIDAuthorizationScopes.email` was requested ([#117](https://github.com/aboutyou/dart_packages/pull/117))

## 2.5.1

- Fix security deeplink issue which allowed to crash Flutter apps which have the `signinwithapple` plugin installed on Android ([#103](https://github.com/aboutyou/dart_packages/pull/103))

## 2.5.0

- Properly handle the cancellation of the user from the web flow
  - Thanks to [@eduribas](https://github.com/eduribas) for contributing this fix

## 2.4.0

- Manual closes of the Chrome Custom Tab on Android are now reported through a `SignInWithAppleAuthorizationException` with the `code` `AuthorizationErrorCode.canceled` (same as on iOS)
- `AppleLogoPainter` is now exposed, so consumers can use it to build their own buttons

## 2.3.0

- Fix the Android implementation closing the Chrome Custom Tab to not execute `runApp` in the Flutter again, but rather bring the existing Flutter activity to the front
  - https://github.com/aboutyou/dart_packages/issues/81 / https://github.com/aboutyou/dart_packages/pull/82
  - Thanks to [@eduribas](https://github.com/eduribas) for contributing this fix

## 2.2.0

- Add the ability to pass a `state` value through the authentication flow

## 2.1.0+1

- Clean up example project to come without a pre-set team ID and a unused bundle ID.

## 2.1.0

- Expose `identityToken` to enable Firebase integration (https://github.com/aboutyou/dart_packages/issues/62)
- Add support for passing a `nonce` to the authentication request

## 2.0.0+5

- Extend integration docs for iOS and macOS

## 2.0.0+4

- Fix publication to really include 2.0.0+3

## 2.0.0+3

- Added Android integration example to README

## 2.0.0+2

- Fix typos in README

## 2.0.0+1

- Fix example code in README to show simplified API

## 2.0.0

- Added Android support
- Simplified external API

## 1.1.1

- Remove re-declared method in Android wrapper (#37)

## 1.1.0

- Added macOS support

## 1.0.0

- Initial release of Sign in with Apple plugin that can request authentication via Apple ID and stored keychain passwords
