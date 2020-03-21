import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../sign_in_with_apple.dart';

/// A widget for conditionally rendering UI based on whether or not Sign in with Apple is available
class IsSignInWithAppleAvailable extends StatelessWidget {
  IsSignInWithAppleAvailable({
    Key key,
    @required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : assert(child != null),
        assert(fallback != null),
        isAvailableFuture = isAvailable(),
        super(key: key);

  @visibleForTesting
  IsSignInWithAppleAvailable.internal({
    Key key,
    @required this.child,
    @required this.isAvailableFuture,
    this.fallback = const SizedBox.shrink(),
  })  : assert(child != null),
        assert(fallback != null),
        super(key: key);

  /// Cached value whether or not sign-in with apple is available
  ///
  /// We cache, so we can return a [SynchronousFuture] in case this value has already been loaded
  static bool _isAvailable;

  /// Cached Future, so we only ever call this once on the native side
  static Future<bool> _isAvailableFuture;

  /// A static variable which will trigger a method call when the app launches
  ///
  /// This should allow most calls to [isAvailable] to return a [SynchronousFuture],
  /// which should result in a better UX (no jumping UI).
  ///
  /// ignore: unused_field
  static final _isAvavailableTrigger = isAvailable();

  static Future<bool> isAvailable() {
    if (_isAvailable != null) {
      return SynchronousFuture<bool>(_isAvailable);
    }

    return _isAvailableFuture ??=
        SignInWithApple.isAvailable().then((isAvailable) {
      _isAvailable = isAvailable;

      return isAvailable;
    });
  }

  /// A [Widget] which will only be rendered in case Sign in with Apple is available
  final Widget child;

  /// A [Widget] which will be rendered in case Sign in with Apple is not available
  ///
  /// If this is not provided, this will default to a [SizedBox.shrink]
  final Widget fallback;

  /// The future which will tell this widget whether or not Sign in with Apple is available
  final Future<bool> isAvailableFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAvailableFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return child;
        }

        return fallback;
      },
    );
  }
}
