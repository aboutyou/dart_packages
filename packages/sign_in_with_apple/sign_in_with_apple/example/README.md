# sign_in_with_apple_example

Demonstrates how to use the sign_in_with_apple plugin.

## macOS

> While we prefer to install `cocoapods` via `bundler`, Flutter currently needs a global cocoapods installation to gather the plugin information.
> If you don't have the `pod` binary installed globally, you'll see an error like `CocoaPods not installed or not in valid state.`

```sh
brew install cocoapods # if not installed already
flutter config --enable-macos-desktop
# cd macos && bundle exec pod install && cd -
flutter run -d macOS
```

## Test Android deep links

### Simulate a callback from the SiwA process

This mimicks the `intent://` link the success redirect would use

```
adb shell am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "signinwithapple://callback?code=abc123" com.aboutyou.dart_packages.sign_in_with_apple.example
```

### Simulate a deep link into the app

```
adb shell am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "siwa-example://siwa.example.com/foo" com.aboutyou.dart_packages.sign_in_with_apple.example
```

This will close the Chrome Custom Tab if a SiwA login flow is active, and then show the deep link inside the app (just a `print` in the example)