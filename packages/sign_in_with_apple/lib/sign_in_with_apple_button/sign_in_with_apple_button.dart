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
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ),
              Container(
                child: Text(
                  'Sign in with Apple',
                  style: TextStyle(fontSize: 19),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 28,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
