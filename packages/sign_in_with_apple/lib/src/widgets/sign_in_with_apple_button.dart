import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/src/widgets/apple_logo_painter.dart';

const _appleIconSize = 28.0;

/// A `Sign in with Apple` button according to the Apple Guidelines.
///
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

  /// The callback which will be called when the button is pressed.
  final VoidCallback onPressed;

  /// The text to the
  final String text;

  /// The height of the button.
  ///
  /// This default to `44` according to the Apple Guidelines.
  final double height;

  /// The style of the button
  final SignInWithAppleButtonStyle style;

  /// The border radius of the button.
  ///
  /// Defaults to `8` pixels.
  final BorderRadius borderRadius;

  /// How the icon should be aligned inside the button
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        style == SignInWithAppleButtonStyle.black ? Colors.black : Colors.white;
    final contrastColor =
        style == SignInWithAppleButtonStyle.black ? Colors.white : Colors.black;

    // per Apple's guidelines
    final fontSize = height * 0.43;

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: contrastColor,
        // defaults styles aligned with https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/text_theme.dart#L16
        fontFamily: '.SF Pro Text',
        letterSpacing: -0.41,
      ),
    );

    final appleIcon = Container(
      width: _appleIconSize,
      height: _appleIconSize,
      child: Center(
        child: Container(
          width: fontSize * (25 / 31),
          height: fontSize,
          child: CustomPaint(
            painter: AppleLogoPainter(
              color: contrastColor,
            ),
          ),
        ),
      ),
    );

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
                if (iconAlignment == IconAlignment.center) ...[
                  appleIcon,
                  Flexible(
                    child: textWidget,
                  ),
                ] else if (iconAlignment == IconAlignment.left) ...[
                  appleIcon,
                  Expanded(
                    child: textWidget,
                  ),
                  SizedBox(
                    width: _appleIconSize,
                  ),
                ],
              ],
              mainAxisAlignment: MainAxisAlignment.center,
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
