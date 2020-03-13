import 'package:flutter/widgets.dart';

import '../../sign_in_with_apple.dart';

/// A widget for conditionally rendering UI based on whether or not Sign in with Apple is available
class IsSignInWithAppleAvailable extends StatelessWidget {
  const IsSignInWithAppleAvailable({
    Key key,
    @required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : assert(child != null),
        assert(fallback != null),
        super(key: key);

  static final _isAvailable = SignInWithApple.isAvailable();

  /// A [Widget] which will only be rendered in case Sign in with Apple is available
  final Widget child;

  /// A [Widget] which will be rendered in case Sign in with Apple is not available
  ///
  /// If this is not provided, this will default to a [SizedBox.shrink]
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAvailable,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return child;
        }

        return fallback;
      },
    );
  }
}
