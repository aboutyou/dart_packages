## 3.2.0

- Fix building macOS application with XCode 13 and macOS Big Sur

## 3.1.0

- Add support for XCode 13

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
