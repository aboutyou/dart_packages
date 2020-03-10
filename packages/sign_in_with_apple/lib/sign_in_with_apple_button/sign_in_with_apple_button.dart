import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// According to
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
class SignInWithAppleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: SizedBox.expand(
        child: CupertinoButton(
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Sign in with Apple',
                  style: TextStyle(fontSize: 19),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          onPressed: () {},
          color: Colors.black,
        ),
      ),
    );
  }
}
