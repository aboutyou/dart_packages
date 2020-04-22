# Sign in With Apple

Flutter bridge to Sign in with Apple.

Supports login via an Apple ID, as well as credentials saved in the user's keychain.

## Supported platforms

- iOS
- macOS
- Android

## Example Usage

```dart
SignInWithAppleButton(
  onPressed: () async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);

    // Now send the credential (especially `credentials.authorizationCode`) to your server to create a session
    // after they have been validated with Apple
  },
);
```

## Flow

![](https://raw.githubusercontent.com/aboutyou/dart_packages/be222ddd96233574f46b7ac512ec1e0735a9362d/assets/sign_in_with_apple/screenshots/1.png)

![](https://raw.githubusercontent.com/aboutyou/dart_packages/be222ddd96233574f46b7ac512ec1e0735a9362d/assets/sign_in_with_apple/screenshots/2.png)

## Integration

### Android

In your `AndroidManifest.xml` inside `<application>` add

```xml
       <!-- Set up the Sign in with Apple activity, such that it's callable from the browser-redirect -->
        <activity
            android:name="com.aboutyou.dart_packages.sign_in_with_apple.SignInWithAppleCallback"
            android:exported="true"
        >
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="signinwithapple" />
                <data android:path="callback" />
            </intent-filter>
        </activity>
```

On the Sign in with Apple callback (specified in `WebAuthenticationOptions.redirectUri`), redirect safely back to your Android app using the following URL:

```
intent://callback?${PARAMETERS FROM CALLBACK BODY}#Intent;package=YOUR.PACKAGE.IDENTIFIER;scheme=signinwithapple;end
```

Leave the `callback` path and `signinwithapple` scheme untouched.

Furthermore, when handling the incoming credentials on the client, make sure to only overwrite the current (guest) session of the user once your own server have validated the incoming `code` parameter, such that your app is not susceptible to malicious incoming links (e.g. logging out the current user).
