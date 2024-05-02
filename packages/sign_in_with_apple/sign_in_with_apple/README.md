# Sign in With Apple

Flutter bridge to Sign in with Apple.

Supports login via an Apple ID, as well as retrieving credentials saved in the user's keychain.

[<img src="https://raw.githubusercontent.com/aboutyou/dart_packages/28594220a50e98ca7cf82953482403938dae5cf6/assets/flutter_favorite.png" width="100" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

## Supported platforms

- iOS
- macOS
- Android
- Web

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

    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
  },
);
```

## Flow

![](https://raw.githubusercontent.com/aboutyou/dart_packages/be222ddd96233574f46b7ac512ec1e0735a9362d/assets/sign_in_with_apple/screenshots/1.png)

![](https://raw.githubusercontent.com/aboutyou/dart_packages/be222ddd96233574f46b7ac512ec1e0735a9362d/assets/sign_in_with_apple/screenshots/2.png)

## Integration

Integrating Sign in with Apple goes beyond just adding this plugin to your `pubspec.yaml` and using the credential-receiving functions exposed by it.

Once you receive the credentials, they need to be verified with Apple's servers (to ensure that they are valid and really concern the mentioned user) and then a new session should be derived from them in your system.

Your server should then daily verify the session with Apple (via a refresh token it obtained on the initial validation), and revoke the session in your system if the authorization has been withdrawn on Apple's side.

### Prerequisites

Before you can start integrating (or even testing) Sign in with Apple you need a [paid membership to the Apple Developer Program](https://developer.apple.com/programs/). Sign in with Apple is one of the restricted services which is not available for free with just an Apple ID ([source](https://developer.apple.com/programs/whats-included/)).

#### Apple Mail Relay

Since the users can use the private email relay, it is necessary to add an SPF record to the domains used to send emails, please read more here: https://developer.apple.com/help/account/configure-app-capabilities/configure-private-email-relay-service/
Without it, your service will not be able to send emails to users who choose to use Apple's private relay, and the emails will not be delivered.

### Setup

#### Register an App ID

If you don't have one yet, create a new one at https://developer.apple.com/account/resources/identifiers/list/bundleId following these steps:

- Click "Register an App ID"
- In the wizard select "App IDs", click "Continue"
- Set the `Description` and `Bundle ID`, and select the `Sign In with Apple` capability
  - Usually the default setting of "Enable as a primary App ID" should suffice here. If you ship multiple apps that should all share the same Apple ID credentials for your users, please consult the Apple documentation on how to best set these up.
- Click "Continue", and then click "Register" to finish the creation of the App ID

In case you already have an existing App ID that you want to use with Sign in with Apple:

- Open that App ID from the list
- Check the "Sign in with Apple" capability
- Click "Save"

If you have change your app's capabilities, you need to fetch the updated provisioning profiles (for example via Xcode) to use the new capabilities.

#### Create a Service ID

The Service ID is only needed for a Web or Android integration. If you only intend to integrate iOS you can skip this step.

Go to your apple developer page then ["Identifiers"](https://developer.apple.com/account/resources/identifiers/list) and follow these steps:

Next go to https://developer.apple.com/account/resources/identifiers/list/serviceId and follow these steps:

- Click "Register an Services ID"
- Select "Services IDs", click "Continue"
- Set your "Description" and "Identifier"
  - The "Identifier" will later be referred to as your `clientID`
- Click "Continue" and then "Register"

Now that the service is created, we have to enable it to be used for Sign in with Apple:

- Select the service from the list of services
- Check the box next to "Sign in with Apple", then click "Configure"
- In the `Domains and Subdomains` add the domains of the websites on which you want to use Sign in with Apple, e.g. `example.com`. You have to enter at least one domain here, even if you don't intend to use Sign in with Apple on any website.
- In the `Return URLs` box add the full return URL you want to use, e.g. https://example.com/callbacks/sign_in_with_apple
- Click "Next" and then "Done" to close the settings dialog
- Click "Continue" and then "Save" to update the service

In order to communicate with Apple's servers to verify the incoming authorization codes from your app clients, you need to create a key at https://developer.apple.com/account/resources/authkeys/list:

- Click "Create a key"
- Set the "Key Name" (E.g. "Sign in with Apple key")
- Check the box next to "Sign in with Apple", then click "Configure" on the same row
- Under "Primary App ID" select the App ID of the app you want to use (either the newly created one or an existing one)
- Click "Save" to leave the detail view
- Click "Continue" and then click "Register"
- Now you'll see a one-time-only screen where you must download the key by clicking the "Download" button
  - Also note the "Key ID" which will be used later when configuring the server

Now everything is set up on Apple's developer portal and we can start setting up the server.

### Server

The server part is usually integrated into your existing backends, and there are existing packages for most existing programming languages and web frameworks out there.

In order to show how to build a complete example, we set up a example project on [Glitch](https://glitch.com/) which offers simple and free hosting of a HTTPS-enabled web API, which is exactly what's needed here.

To get started with the Glitch-based example go to the project's page at https://glitch.com/~flutter-sign-in-with-apple-example and click "Remix this". Now you have your own copy of the sample server!

First select the `.env` file in the file browser on the left and put in your credentials (these will not be public, but only shared with invited collaborators).

Then click on the "Share" button next to your avatar in the upper left, select "Live App" and copy the entry page URL (e.g. `https://some-random-identifier.glitch.me`).

Now update the services you created earlier at https://developer.apple.com/account/resources/identifiers/list/serviceId to include the following URL under `Return URLs`: `https://[YOUR-PROJECT-NAME].glitch.me/callbacks/sign_in_with_apple` (replacing the name inside the `[]`).

After this is done, you can now proceed to integrate Sign in with Apple into the code of your Flutter app.

### Android

Adding Sign in with Apple to a Flutter app is shown from 2 sides here. First we look into making the example app work with our server-side setup, and then we go over the additional steps required to set up your app from scratch.

To use this plugin on Android, you will need to use the [Android V2 Embedding](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects).  
You can find out if you are already using the new embedding by looking into your `AndroidManifest.xml` and look for the following element:
```xml
<meta-data
  android:name="flutterEmbedding"
  android:value="2" 
/>
```

In case you are not yet using Android V2 Embedding, please first upgrade your app using the following guide: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects

#### `launchMode`

To ensure that deep links from the login web page (shown in a Chrome Custom Tab) back to the app still work, your app must use `launchMode` `singleTask` or `singleTop`
  - When using `singleTask` the Chrome Custom Tab persists across app switches from within Android's app switcher, but will be dismissed when the app is launched anew from the home screen icon / app gallery
  - With launch mode `singleTop` the Chrome Custom Tab stays present both after using the app switcher or launching the app anew via its icon
  - If you change your app's `launchMode` be sure to test any other third-party integrations that might be affected by this (e.g. deep links)

### Web

For web support you need to add the follow script import to your `index.html`'s `<head>` tag:

```html
<script type="text/javascript" src="https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js"></script>
```

(We haven't found a way to only load this on demand, as the script seemingly inits itself on page load.)

Then in the service's configuration in Apple's developer portal add the domains that host your page both in `Domains and Subdomains` as well as `Returns URLs`.  
The former is needed so you can open the flow from the web page, while the latter is used to post the final credentials back from the pop-up to the opening page. (If you omit this, the flow will just silently be stuck in the last step.)

#### Example App

- Open the `example` folder inside this package in an editor of your choice
- Run `flutter packages get`
- Open `lib/main.dart` and look at the `SignInWithAppleButton.onPressed` callback
  - Set the `scopes` parameter to your required scopes, for testing we can keep requesting a name and email
  - Update the values passed to the `WebAuthenticationOptions` constructor to match the values in the Apple Developer Portal
  - Likewise update the `signInWithAppleEndpoint` variable to point to your
- Once you have updated the code, `flutter run` the example on an Android device or emulator

#### Your App

In your `android/app/src/main/AndroidManifest.xml` inside `<application>` add

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

On the Sign in with Apple callback on your server (specified in `WebAuthenticationOptions.redirectUri`), redirect safely back to your Android app using the following URL:

```
intent://callback?${PARAMETERS FROM CALLBACK BODY}#Intent;package=YOUR.PACKAGE.IDENTIFIER;scheme=signinwithapple;end
```

The `PARAMETERS FROM CALLBACK BODY` should be filled with the urlencoded body you receive on the endpoint from Apple's server, and the `package` parameter should be changed to match your app's package identifier (as published on the Google Play Store). Leave the `callback` path and `signinwithapple` scheme untouched.

Furthermore, when handling the incoming credentials on the client, make sure to only overwrite the current (guest) session of the user once your own server have validated the incoming `code` parameter, such that your app is not susceptible to malicious incoming links (e.g. logging out the current user).

### iOS

At this point you should have added the Sign in with Apple capability to either your own app's capabilities or the test application you created to run the example.

In case you don't have `Automatically manage Signing` turned on in Xcode, you will need to recreate and download the updated Provisioning Profiles for your app, so they include the new `Sign in with Apple` capability. Then you can download the new certificates and select them in Xcode.

In case XCode manages your signing, this step will be done automatically for you. Just make sure the `Sign in with Apple` capability is actived as described in the example below.

Additionally this assumes that you have at least one iOS device registered in your developer account for local testing, so you can run the example on a device.

#### Example

- Open the `example` folder in a terminal and run `flutter packages get`
- Open `example/ios/Runner.xcworkspace` in Xcode
- Under `Runner` (file browser side bar) -> `Targets` -> `Runner` -> `Signing & Capabilities` set the "Bundle Identifier" ("App ID") you have created in the Apple Developer Portal earlier
  - Ensure that "Sign in with Apple" is listed under the capabilities (if not, add it via the `+`)
- Now open a terminal in the `example` folder and execute the follow commands
  - `cd ios`
  - `bundle install`, to install the Ruby dependencies used for Cocoapods
  - `bundle exec pod install`, to install the Cocoapods for the iOS project
- In the terminal navigate back to the root of the `example` folder and `flutter run` on your test device

#### Your App

- First and foremost make sure that your app has the "Sign in with Apple" capability (`Runner` (file browser side bar) -> `Targets` -> `Runner` -> `Signing & Capabilities`), as otherwise Sign in with Apple will fail without visual indication (the code will still receive exceptions)
- Either integrate the example server as shown above, or build your own backend
  - Ensure that the `clientID` used when validating the received `code` parameter with Apple's server is dependent on the client: Use the App ID (also called "Bundle ID" in some places) when using codes from apps running on Apple platforms, and use the service ID when using a code retrieved from a web authentication flow

### macOS

The setup for macOS is mostly similar to iOS. As usual for Flutter development for macOS, you must be on the `dev` or `master` channel.

#### Example

- Open the `example` folder in a terminal and run `flutter packages get`
- Open `example/macos/Runner.xcworkspace` in Xcode
- Under `Runner` (file browser side bar) -> `Targets` -> `Runner` -> `Signing & Capabilities` set the "Bundle Identifier" ("App ID") you have created in the Apple Developer Portal earlier
  - Ensure that "Sign in with Apple" is listed under the capabilities (if not, add it via the `+`)
  - Additionally there should be no warning on that screen. (For example your Mac must be registered for local development. (If not, you'll see a "one click fix" button to do so.))
- In the terminal navigate back to the root of the `example` folder and `flutter run` on your test device
