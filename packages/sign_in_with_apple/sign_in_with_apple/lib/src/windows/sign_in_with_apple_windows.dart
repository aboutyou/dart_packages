import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart';

/// The Windows implementation of `sign_in_with_apple`.
///
/// Windows has no native Sign in with Apple, so this runs the same web flow
/// Android does — Apple's `/auth/authorize` in a browser, `response_mode=form_post`
/// to an https endpoint you host — and differs only in how the result gets back
/// into the app.
///
/// Android registers a custom scheme and the endpoint redirects to
/// `intent://callback?…`. Windows has no equivalent the browser will follow, so
/// this listens on a loopback port instead and has the endpoint redirect there.
/// Apple itself will not redirect to a loopback address: `redirect_uri` "must
/// include a domain name, and can't be an IP address or localhost", so the
/// endpoint is not optional — it is the only thing that can hand the credential
/// to a desktop app.
///
/// ## What the redirect endpoint has to do
///
/// The endpoint already receiving Apple's `form_post` for Android needs one
/// extra branch. [statePrefix] is what tells it this is a Windows sign-in, and
/// the port to send the result to is in the same value:
///
/// ```
/// state = "swa-win.<port>.<random>"
/// ```
///
/// On seeing that shape, redirect to `http://127.0.0.1:<port>/` with Apple's
/// POST body as the query string, rather than to the Android intent url:
///
/// ```java
/// // Pseudocode; `body` is Apple's form-encoded POST body, passed through as-is
/// // so `user`'s JSON stays encoded.
/// Matcher m = Pattern.compile("^swa-win\\.(\\d{1,5})\\.[A-Za-z0-9_-]{1,128}$")
///     .matcher(state);
/// if (m.matches()) {
///   int port = Integer.parseInt(m.group(1));
///   if (port >= 1024 && port <= 65535) {
///     response.sendRedirect("http://127.0.0.1:" + port + "/?" + body);
///     return;
///   }
/// }
/// // …otherwise the Android intent:// redirect, unchanged.
/// ```
///
/// Only the port varies, and only as digits within range: the host is fixed at
/// `127.0.0.1`, so the branch cannot be turned into a redirect to somebody
/// else's server.
///
/// ## Cancelling
///
/// A browser sign-in can be abandoned without the app hearing anything, so the
/// wait ends either at [callbackTimeout] or when the app calls [cancelSignIn].
/// See [signInIsPending] for which of those is worth offering a customer.
class SignInWithAppleWindows extends SignInWithApplePlatform {
  /// Registers this class as the platform implementation.
  ///
  /// Called by the generated Dart plugin registrant on Windows only, so nothing
  /// here runs on other platforms even though the file compiles everywhere
  /// `dart:io` exists.
  static void registerWith() {
    SignInWithApplePlatform.instance = SignInWithAppleWindows();
  }

  /// Marks a `state` value as belonging to a Windows sign-in.
  ///
  /// The redirect endpoint keys on this to tell a Windows sign-in from an
  /// Android one, so it is part of the contract with that endpoint and cannot
  /// change without changing it too. Not a secret — the value it prefixes
  /// carries the random part that is.
  static const statePrefix = 'swa-win';

  /// How long to wait for the browser to come back.
  ///
  /// A backstop for a sign-in that was abandoned in the browser, not the
  /// expected way for one to end — long enough for a customer to find a
  /// password manager and a second factor. An app that can offer a way out
  /// should do that instead: see [cancelSignIn].
  @visibleForTesting
  static Duration callbackTimeout = const Duration(minutes: 5);

  /// Opens [url] in the customer's browser, returning whether it was launched.
  ///
  /// Overridable so the flow can be tested end to end against a fake browser
  /// that fetches the callback url itself; production uses [_launchInBrowser].
  @visibleForTesting
  static Future<bool> Function(Uri url) launchUrl = _launchInBrowser;

  /// The loopback server of a sign-in waiting on the browser, if any.
  static HttpServer? _pendingServer;

  /// Whether a sign-in is still waiting for the browser to come back.
  ///
  /// True only for the part of the flow that [cancelSignIn] can end. Worth
  /// checking before offering a customer a cancel button, and again before
  /// acting on one: once the callback has landed the sign-in is going to
  /// succeed, and cancelling then would throw away a credential Apple has
  /// already granted.
  static bool get signInIsPending => _pendingServer != null;

  /// Abandons a sign-in that is waiting on the browser.
  ///
  /// Nothing can tell somebody still typing a password from somebody who closed
  /// the tab and walked off, which is why this is here to be driven by a button
  /// rather than by a shorter [callbackTimeout]. Closing the server ends the
  /// wait, and [getAppleIDCredential] then throws
  /// [SignInWithAppleAuthorizationException] with
  /// [AuthorizationErrorCode.canceled], exactly as a browser-side cancel does.
  ///
  /// Does nothing once the callback has arrived — see [signInIsPending].
  static void cancelSignIn() {
    final server = _pendingServer;
    if (server == null) {
      return;
    }

    _pendingServer = null;
    unawaited(server.close(force: true));
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    WebAuthenticationOptions? webAuthenticationOptions,
    String? nonce,
    String? state,
  }) async {
    if (webAuthenticationOptions == null) {
      throw Exception(
        '`webAuthenticationOptions` argument must be provided on Windows.',
      );
    }

    // Port 0 asks the OS for a free one, as RFC 8252 §7.3 asks: a fixed guess
    // is a port another app may already hold. Nothing needs registering
    // against it — Apple never sees this address, only the redirect endpoint
    // does, and it matches the loopback host rather than the port.
    final HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } on SocketException catch (error) {
      throw SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.unknown,
        message: 'Could not open a callback port: ${error.message}',
      );
    }

    // Held so [cancelSignIn] can end the wait below.
    _pendingServer = server;

    // Two jobs in one value, because Apple returns exactly one field unmodified.
    // The port tells the redirect endpoint where to send the result; the random
    // part proves the callback is the one this call started — any local process
    // can reach a loopback port (RFC 8252 §8.9).
    //
    // The caller's own `state` is deliberately not sent to Apple. It is
    // documented as coming back unmodified, and returning it from this closure
    // does that exactly, without a second value to encode into the one field or
    // a delimiter for callers to avoid.
    final callbackState = '$statePrefix.${server.port}.${_randomString(43)}';

    // Built as the Android flow builds it — same endpoint, same response type,
    // same `form_post` — so the endpoint's existing handling applies and only
    // the redirect at the end of it differs.
    final url = Uri.https('appleid.apple.com', '/auth/authorize', {
      'client_id': webAuthenticationOptions.clientId,
      'redirect_uri': webAuthenticationOptions.redirectUri.toString(),
      'scope': scopes.map((scope) {
        switch (scope) {
          case AppleIDAuthorizationScopes.email:
            return 'email';
          case AppleIDAuthorizationScopes.fullName:
            return 'name';
        }
      }).join(' '),
      'response_type': 'code id_token',
      'response_mode': 'form_post',
      if (nonce != null) 'nonce': nonce,
      'state': callbackState,
    });

    try {
      if (!await launchUrl(url)) {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.unknown,
          message: 'No browser could be launched',
        );
      }

      final HttpRequest request;
      try {
        request = await server.first.timeout(callbackTimeout);
      } on TimeoutException {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'Timed out waiting for the browser to return',
        );
      } catch (error) {
        // What a [cancelSignIn] mid-wait arrives as: the closed server ends
        // `first` with an error rather than a request. Reported as a cancel
        // because that is what it is — the app asked for this.
        throw SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'The sign-in was cancelled before the browser returned '
              '($error)',
        );
      }

      // The browser is sitting on this request until it is answered, so both
      // outcomes answer it: a rejected callback leaves the customer looking at
      // the failure page rather than at a page that never loads.
      try {
        final credential = _credentialFrom(
          request.requestedUri,
          callbackState: callbackState,
          callerState: state,
        );

        await _respond(request, succeeded: true);

        return credential;
      } on SignInWithAppleException {
        await _respond(request, succeeded: false);
        rethrow;
      }
    } finally {
      // Only when it is still ours. A cancelled flow whose browser launch was
      // slow to return reaches here after the app has started a second
      // sign-in, and clearing that one's handle would leave its cancel button
      // with nothing to close.
      if (_pendingServer == server) {
        _pendingServer = null;
      }
      await server.close(force: true);
    }
  }

  @override
  Future<CredentialState> getCredentialState(String userIdentifier) async {
    throw const SignInWithAppleNotSupportedException(
      message: 'getCredentialState is only available on Apple platforms',
    );
  }

  @override
  Future<AuthorizationCredentialPassword> getKeychainCredential() async {
    throw const SignInWithAppleNotSupportedException(
      message: 'getKeychainCredential is only available on Apple platforms',
    );
  }

  /// Turns the callback url into a credential, or throws explaining why not.
  static AuthorizationCredentialAppleID _credentialFrom(
    Uri callback, {
    required String callbackState,
    required String? callerState,
  }) {
    // Before anything is read out of it: any local process can reach the
    // loopback port, so a callback that cannot name the state this call sent is
    // not this call's callback.
    if (callback.queryParameters['state'] != callbackState) {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message: 'The callback state did not match the request',
      );
    }

    // Shared with the Android flow, so a cancel in the browser, a missing
    // `code` and the `user` JSON are all read the same way on both.
    final credential = parseAuthorizationCredentialAppleIDFromDeeplink(callback);

    // `state` comes back from the caller's argument rather than from the
    // callback, which carries [callbackState] instead. See the note where that
    // is built.
    return AuthorizationCredentialAppleID(
      userIdentifier: credential.userIdentifier,
      givenName: credential.givenName,
      familyName: credential.familyName,
      email: credential.email,
      authorizationCode: credential.authorizationCode,
      identityToken: credential.identityToken,
      state: callerState,
    );
  }

  static Future<void> _respond(
    HttpRequest request, {
    required bool succeeded,
  }) async {
    request.response
      ..statusCode = succeeded ? HttpStatus.ok : HttpStatus.badRequest
      ..headers.contentType = ContentType.html
      ..write(succeeded ? _donePage : _failedPage);

    await request.response.close();
  }

  /// Opens [url] in the customer's default browser.
  ///
  /// `rundll32 url.dll,FileProtocolHandler` rather than `cmd /c start`: an
  /// authorize url is full of `&`, which `cmd` treats as a command separator,
  /// and `start`'s first quoted argument is taken as a window title rather than
  /// a url. This hands the string to the shell's protocol handler with no shell
  /// parsing in between.
  static Future<bool> _launchInBrowser(Uri url) async {
    try {
      final result = await Process.run(
        'rundll32',
        ['url.dll,FileProtocolHandler', url.toString()],
      );

      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}

/// The url-safe alphabet, minus the `.` that separates the fields of a state.
///
/// Every character here is unreserved, so a state needs no escaping in a url.
/// Excluding `.` is what keeps the three fields parseable: a random part
/// carrying one would move where the endpoint reads the port from, and a
/// sign-in would fail on roughly one attempt in fifty.
const _stateChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

String _randomString(int length) {
  final random = Random.secure();

  return List.generate(
    length,
    (_) => _stateChars[random.nextInt(_stateChars.length)],
  ).join();
}

const _donePage = '''
<!doctype html><meta charset="utf-8">
<title>Signed in</title>
<body style="font:16px system-ui;padding:3em;text-align:center">
<p>Signed in. You can close this tab and return to the app.</p>
''';

const _failedPage = '''
<!doctype html><meta charset="utf-8">
<title>Sign in failed</title>
<body style="font:16px system-ui;padding:3em;text-align:center">
<p>Sign in did not complete. You can close this tab and try again.</p>
''';
