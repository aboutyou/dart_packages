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
        isAvailableFuture = SignInWithApple.isAvailable(),
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
