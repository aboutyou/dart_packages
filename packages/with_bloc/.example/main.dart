import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_queue/state_queue.dart';
import 'package:with_bloc/src/with_bloc.dart';

@immutable
abstract class LoginState {}

class LoggedOutState implements LoginState {}

class LoginInProgressState implements LoginState {}

class LoginErrorState implements LoginState {
  LoginErrorState(this.message);

  final String message;
}

class LoggedInState implements LoginState {
  LoggedInState(this.username);

  final String username;
}

class LoginBloc extends StateQueue<LoginState> {
  LoginBloc() : super(LoggedOutState());

  Future<void> login(String username, String password) {
    final completer = Completer();

    run((state) async* {
      yield LoginInProgressState();

      await Future.delayed(Duration(seconds: 1)); // would be API call

      if (password.length >= 8) {
        yield LoggedInState(username);
      } else {
        yield LoginErrorState('Invalid username/password combination');
      }

      completer.complete();
    });

    return completer.future;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithBloc<LoginBloc, LoginState>(
      createBloc: (context) => LoginBloc(),
      builder: (context, bloc, state, _) {
        if (state is LoggedInState) {
          // render logged-in app
          return Center(
            child: Text(
              'Hello ${state.username}',
            ),
          );
        }

        if (state is LoggedInState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return _LoginScreen(
          onLoginTap: bloc.login,
          errorMessage: state is LoginErrorState ? state.message : null,
        );
      },
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({
    Key key,
    @required this.onLoginTap,
    this.errorMessage,
  }) : super(key: key);

  final Future<void> Function(String username, String password) onLoginTap;

  /// Can be `null`
  final String errorMessage;

  @override
  __LoginScreenState createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool _loginInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: usernameTextController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        TextField(
          controller: passwordTextController,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        MaterialButton(
          child: Text('Login'),
          onPressed: !_loginInProgress ? _startLogin : null,
        ),
        if (widget.errorMessage != null) Text(widget.errorMessage),
      ],
    );
  }

  void _startLogin() async {
    setState(() {
      _loginInProgress = true;
    });

    await widget.onLoginTap(
      usernameTextController.text,
      passwordTextController.text,
    );

    setState(() {
      _loginInProgress = false;
    });
  }
}
