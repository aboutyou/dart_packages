import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../sign_in_with_apple.dart';

Widget _fallbackBuilder(BuildContext context) => const SizedBox.shrink();

/// A widget for conditionally rendering UI based on whether or not Sign in with Apple is available
class SignInWithAppleBuilder extends StatefulWidget {
  const SignInWithAppleBuilder({
    Key? key,
    required this.builder,
    this.fallbackBuilder = _fallbackBuilder,
  }) : super(key: key);

  /// A [WidgetBuilder] which will be executed in case Sign in with Apple is available
  final WidgetBuilder builder;

  /// A [WidgetBuilder] which will be executed in case Sign in with Apple is not available
  ///
  /// If this is not provided, this will default to a builder returning a [SizedBox.shrink]
  final WidgetBuilder fallbackBuilder;

  @override
  _SignInWithAppleBuilderState createState() => _SignInWithAppleBuilderState();
}

class _SignInWithAppleBuilderState extends State<SignInWithAppleBuilder> {
  /// Future which will resolve to tell whether or not Sign in with Apple is available
  Future<bool>? _isAvailableFuture;

  @override
  void initState() {
    super.initState();

    _isAvailableFuture = SignInWithApple.isAvailable();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAvailableFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return widget.builder(context);
        }

        return widget.fallbackBuilder(context);
      },
    );
  }
}
