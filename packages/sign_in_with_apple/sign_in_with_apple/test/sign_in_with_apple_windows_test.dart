@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple_windows.dart';
import 'package:sign_in_with_apple_platform_interface/sign_in_with_apple_platform_interface.dart';

//
// The Windows flow, driven end to end against a fake browser.
//
// The whole flow is Dart -- a loopback server, a browser launch, and a callback
// url -- so all of it can run here, on any host. What cannot run here is the
// redirect endpoint that stands between Apple and the loopback port, so
// [_redirectLikeTheEndpoint] implements the contract documented on
// [SignInWithAppleWindows] instead. That makes these tests the executable copy
// of a rule whose only other statement is prose next to some Java: if the state
// pattern or the loopback url changes here, the endpoint has to change too.
//

final _options = WebAuthenticationOptions(
  clientId: 'com.example.app.service',
  redirectUri: Uri.parse('https://api.example.com/asi'),
);

/// The pattern the redirect endpoint matches `state` against. Kept verbatim
/// from the docs on [SignInWithAppleWindows], where the Java copy of it lives.
final _windowsState = RegExp(r'^swa-win\.(\d{1,5})\.[A-Za-z0-9_-]{1,128}$');

/// A stand-in for the app's Apple identity token.
///
/// Not parsed by the plugin -- it is handed to the caller untouched -- so its
/// only job is to be a value that survives the round trip recognisably.
const _identityToken = 'header.payload.signature';

void main() {
  late Duration originalTimeout;

  setUp(() {
    originalTimeout = SignInWithAppleWindows.callbackTimeout;
  });

  tearDown(() {
    SignInWithAppleWindows.callbackTimeout = originalTimeout;
    // A test that left one pending would leak a bound port into the next one.
    SignInWithAppleWindows.cancelSignIn();
  });

  group('getAppleIDCredential', () {
    test('returns the credential the endpoint redirected with', () async {
      final browser = _FakeBrowser(
        respondWith: (_) => {
          'code': 'the-authorization-code',
          'id_token': _identityToken,
          'user': json.encode({
            'name': {'firstName': 'Ada', 'lastName': 'Lovelace'},
            'email': 'ada@example.com',
          }),
        },
      );

      final credential = await _signIn(browser);

      expect(credential.authorizationCode, 'the-authorization-code');
      expect(credential.identityToken, _identityToken);
      expect(credential.givenName, 'Ada');
      expect(credential.familyName, 'Lovelace');
      expect(credential.email, 'ada@example.com');

      // Windows has no native credential, so there is no user identifier to
      // report -- the same as the Android web flow, whose callers read `sub`
      // out of the identity token instead.
      expect(credential.userIdentifier, isNull);

      expect(await browser.page, contains('You can close this tab'));
    });

    test('asks Apple for the scopes, the client and the form_post response',
        () async {
      final browser = _FakeBrowser(
        respondWith: (_) => {'code': 'code'},
      );

      await _signIn(
        browser,
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: 'the-nonce',
      );

      final query = browser.authorizeUrl.queryParameters;

      expect(browser.authorizeUrl.host, 'appleid.apple.com');
      expect(browser.authorizeUrl.path, '/auth/authorize');
      expect(query['client_id'], _options.clientId);
      expect(query['redirect_uri'], _options.redirectUri.toString());
      expect(query['scope'], 'email name');
      expect(query['nonce'], 'the-nonce');

      // Both are what makes the endpoint's existing Android handling apply
      // unchanged: `code id_token` is what it already receives, and Apple
      // requires `form_post` once any scope is requested.
      expect(query['response_type'], 'code id_token');
      expect(query['response_mode'], 'form_post');
    });

    test('carries the listening port in the state, where the endpoint reads it',
        () async {
      final browser = _FakeBrowser(
        respondWith: (_) => {'code': 'code'},
      );

      await _signIn(browser);

      final state = browser.authorizeUrl.queryParameters['state'];
      expect(state, isNotNull);

      final match = _windowsState.firstMatch(state!);
      expect(
        match,
        isNotNull,
        reason: 'the endpoint identifies a Windows sign-in by this shape',
      );

      // The port in the state is the port the callback reached, which is the
      // whole reason the state has a port in it.
      expect(int.parse(match!.group(1)!), browser.callbackUrl.port);
    });

    test('returns the caller\'s state, not the one Apple echoed', () async {
      final browser = _FakeBrowser(
        respondWith: (_) => {'code': 'code'},
      );

      final credential = await _signIn(browser, state: 'the-callers-state');

      expect(credential.state, 'the-callers-state');
      // The value sent to Apple is the plugin's own, and it does not leak out
      // through the field the caller reads.
      expect(credential.state, isNot(browser.authorizeUrl.queryParameters['state']));
    });

    test('reports a cancel in the browser as a cancel', () async {
      final browser = _FakeBrowser(
        respondWith: (_) => {'error': 'user_cancelled_authorize'},
      );

      await expectLater(
        _signIn(browser),
        throwsA(
          isA<SignInWithAppleAuthorizationException>().having(
            (e) => e.code,
            'code',
            AuthorizationErrorCode.canceled,
          ),
        ),
      );
    });

    test('rejects a callback that cannot name the state it sent', () async {
      // Any local process can reach a loopback port, so a callback that did not
      // come from this sign-in must not be turned into a credential.
      final browser = _FakeBrowser(
        respondWith: (_) => {'code': 'an-injected-code', 'state': 'not-ours'},
      );

      await expectLater(
        _signIn(browser),
        throwsA(
          isA<SignInWithAppleAuthorizationException>().having(
            (e) => e.code,
            'code',
            AuthorizationErrorCode.invalidResponse,
          ),
        ),
      );

      expect(await browser.page, contains('did not complete'));
    });

    test('fails when no browser could be launched', () async {
      // Set explicitly rather than left to the real launcher: that one would
      // find no `rundll32` here and no browser anywhere, but on a Windows host
      // it would open a real tab.
      SignInWithAppleWindows.launchUrl = (_) async => false;

      await expectLater(
        SignInWithAppleWindows().getAppleIDCredential(
          scopes: [],
          webAuthenticationOptions: _options,
        ),
        throwsA(isA<SignInWithAppleAuthorizationException>()),
      );
    });

    test('requires webAuthenticationOptions', () async {
      await expectLater(
        SignInWithAppleWindows().getAppleIDCredential(scopes: []),
        throwsA(isA<Exception>()),
      );
    });

    test('gives up once the callback stops being worth waiting for', () async {
      SignInWithAppleWindows.callbackTimeout = const Duration(milliseconds: 50);

      await expectLater(
        _signIn(_FakeBrowser.thatNeverReturns()),
        throwsA(
          isA<SignInWithAppleAuthorizationException>().having(
            (e) => e.code,
            'code',
            AuthorizationErrorCode.canceled,
          ),
        ),
      );
    });

    test('closes the port it opened', () async {
      final browser = _FakeBrowser(respondWith: (_) => {'code': 'code'});

      await _signIn(browser);

      // Binding the same port again is the observable proof it was released --
      // a flow that leaked its server would fail here.
      final rebound = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        browser.callbackUrl.port,
      );
      await rebound.close();

      expect(SignInWithAppleWindows.signInIsPending, isFalse);
    });
  });

  group('cancelSignIn', () {
    test('ends a sign-in that is still waiting on the browser', () async {
      final browser = _FakeBrowser.thatNeverReturns();
      final signIn = _signIn(browser);

      await browser.launched;
      expect(SignInWithAppleWindows.signInIsPending, isTrue);

      SignInWithAppleWindows.cancelSignIn();

      await expectLater(
        signIn,
        throwsA(
          isA<SignInWithAppleAuthorizationException>().having(
            (e) => e.code,
            'code',
            AuthorizationErrorCode.canceled,
          ),
        ),
      );

      expect(SignInWithAppleWindows.signInIsPending, isFalse);
    });

    test('does nothing when no sign-in is pending', () {
      expect(SignInWithAppleWindows.signInIsPending, isFalse);
      expect(SignInWithAppleWindows.cancelSignIn, returnsNormally);
    });
  });

  group('the platform API', () {
    test('reports Sign in with Apple as available', () async {
      expect(await SignInWithAppleWindows().isAvailable(), isTrue);
    });

    test('has no credential state to report', () async {
      // Apple-platform only: there is no user identifier on Windows to ask
      // about, so this says so rather than failing further in.
      await expectLater(
        SignInWithAppleWindows().getCredentialState('user'),
        throwsA(isA<SignInWithAppleNotSupportedException>()),
      );
    });

    test('has no keychain to read', () async {
      await expectLater(
        SignInWithAppleWindows().getKeychainCredential(),
        throwsA(isA<SignInWithAppleNotSupportedException>()),
      );
    });
  });
}

Future<AuthorizationCredentialAppleID> _signIn(
  _FakeBrowser browser, {
  List<AppleIDAuthorizationScopes> scopes = const [],
  String? nonce,
  String? state,
}) {
  SignInWithAppleWindows.launchUrl = browser.open;

  return SignInWithAppleWindows().getAppleIDCredential(
    scopes: scopes,
    webAuthenticationOptions: _options,
    nonce: nonce,
    state: state,
  );
}

/// What the redirect endpoint does with Apple's `form_post`, in Dart.
///
/// The Java at `api.tecartabible.com/asi` has to agree with this: a Windows
/// state means redirect to the loopback port with Apple's body as the query,
/// and only a numeric in-range port is ever put in the url.
Uri _redirectLikeTheEndpoint(String state, Map<String, String> body) {
  final match = _windowsState.firstMatch(state);
  if (match == null) {
    throw StateError('the endpoint would have sent this to intent://');
  }

  final port = int.parse(match.group(1)!);
  if (port < 1024 || port > 65535) {
    throw StateError('the endpoint would not redirect to port $port');
  }

  return Uri.http('127.0.0.1:$port', '/', {'state': state, ...body});
}

/// A browser that follows Apple and the redirect endpoint in one step.
///
/// Deliberately does not wait for the loopback response before reporting the
/// launch: a real browser is a separate process, and the flow does not start
/// listening until the launch returns. Awaiting the fetch here would leave both
/// sides waiting for the other.
class _FakeBrowser {
  _FakeBrowser({required this.respondWith});

  /// A browser that opens the url and never comes back -- an abandoned tab.
  factory _FakeBrowser.thatNeverReturns() => _FakeBrowser(respondWith: null);

  /// What Apple posts to the endpoint, given the authorize url's query.
  ///
  /// A `state` here overrides the one the plugin sent, which is how a callback
  /// that is not this sign-in's gets simulated.
  final Map<String, String> Function(Map<String, String> query)? respondWith;

  late final Uri authorizeUrl;
  late final Uri callbackUrl;

  final _launched = Completer<void>();
  final _page = Completer<String>();

  /// Completes once the flow has handed over a url, so a test can act on a
  /// sign-in that is definitely waiting.
  Future<void> get launched => _launched.future;

  /// The page the browser was left showing.
  Future<String> get page => _page.future;

  Future<bool> open(Uri url) async {
    authorizeUrl = url;

    final body = respondWith?.call(url.queryParameters);
    if (body != null) {
      final state = url.queryParameters['state']!;
      callbackUrl = _redirectLikeTheEndpoint(state, body);
      unawaited(_follow(callbackUrl));
    }

    _launched.complete();

    return true;
  }

  Future<void> _follow(Uri url) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      _page.complete(await response.transform(utf8.decoder).join());
    } catch (error) {
      if (!_page.isCompleted) {
        _page.completeError(error);
      }
    } finally {
      client.close();
    }
  }
}
