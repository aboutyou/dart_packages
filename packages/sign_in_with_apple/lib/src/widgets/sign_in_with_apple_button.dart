import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/src/widgets/apple_logo_painter.dart';

/// Style according to
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
class SignInWithAppleButton extends StatelessWidget {
  const SignInWithAppleButton({
    Key key,
    @required this.onPressed,
    this.text = 'Sign in with Apple',
    this.height = 44,
    this.style = SignInWithAppleButtonStyle.black,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.iconAlignment = IconAlignment.center,
  })  : assert(text != null),
        assert(height != null),
        assert(style != null),
        assert(borderRadius != null),
        assert(iconAlignment != null),
        super(key: key);

  final VoidCallback onPressed;

  final String text;

  final double height;

  final SignInWithAppleButtonStyle style;

  final BorderRadius borderRadius;

  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        style == SignInWithAppleButtonStyle.black ? Colors.black : Colors.white;
    final contrastColor =
        style == SignInWithAppleButtonStyle.black ? Colors.white : Colors.black;

    return Container(
      height: height,
      child: SizedBox.expand(
        child: CupertinoButton(
          borderRadius: borderRadius,
          padding: EdgeInsets.zero,
          color: backgroundColor,
          child: Container(
            decoration: style == SignInWithAppleButtonStyle.whiteOutlined
                ? BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: borderRadius,
                  )
                : null,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: height,
            child: Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Container(
                      width: height * 0.43 * (25 / 31),
                      height: height * 0.43,
                      child: CustomPaint(
                        painter: AppleLogoPainter(
                          color: contrastColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: height * 0.43 /* per Apple's guidelines */,
                    color: contrastColor,
                    // defaults styles aligned with https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/text_theme.dart
                    fontFamily: '.SF Pro Text',
                    letterSpacing: -0.41,
                  ),
                ),
                if (iconAlignment == IconAlignment.left)
                  // so text gets center aligned
                  Container(
                    width: 28,
                  )
              ],
              mainAxisAlignment: iconAlignment == IconAlignment.left
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// The style of the button according to the Apple Documentation.
///
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
enum SignInWithAppleButtonStyle {
  /// A black button with white text and white icon
  ///
  /// ![Black Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/black_button.png)
  black,

  /// A white button with black text and black icon
  ///
  /// ![White Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/white_button.png)
  white,

  /// A white button which has a black outline
  ///
  /// ![White Outline Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/white_outlined_button.png)
  whiteOutlined,
}

/// This controls the alignment of the Apple Logo on the [SignInWithAppleButton]
enum IconAlignment {
  /// The icon will be centered together with the text
  ///
  /// ![Center Icon Alignment](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/center_aligned_icon.png)
  center,

  /// The icon will be on the left side, while the text will be centered accordingly
  ///
  /// ![Left Icon Alignment](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/left_aligned_icon.png)
  left,
}
