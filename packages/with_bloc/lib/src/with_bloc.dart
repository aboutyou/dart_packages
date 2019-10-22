import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const listId = ListEquality<dynamic>();

class WithBloc<BlocType extends ValueNotifier<StateType>, StateType>
    extends StatefulWidget {
  const WithBloc({
    Key key,
    @required this.createBloc,
    this.inputs,
    @required this.builder,
    this.child,
  })  : assert(createBloc != null),
        assert(builder != null),
        super(key: key);

  final BlocType Function(BuildContext context) createBloc;

  final Widget Function(
    BuildContext context,
    BlocType bloc,
    StateType value,
    Widget child,
  ) builder;

  final Widget child;

  /// The parameters the BLoC depends upon.
  ///
  /// If these change, the BLoC will be recreated.
  final List<dynamic> inputs;

  @override
  WithBlocState<BlocType, StateType> createState() =>
      WithBlocState<BlocType, StateType>();
}

@visibleForTesting
class WithBlocState<BlocType extends ValueNotifier<StateType>, StateType>
    extends State<WithBloc<BlocType, StateType>> {
  @visibleForTesting
  BlocType bloc;

  BlocType _oldBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bloc ??= widget.createBloc(context);
  }

  @override
  void didUpdateWidget(WithBloc<BlocType, StateType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listId.equals(oldWidget.inputs, widget.inputs)) {
      /// Save the previous bloc so we can properly dispose it
      _oldBloc = bloc;

      /// Recreate the bloc
      bloc = widget.createBloc(context);
    }
  }

  @override
  void dispose() {
    bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StateType>(
      valueListenable: bloc,
      child: widget.child,
      builder: (context, value, child) {
        /// We need to dispose the old bloc
        if (_oldBloc != null) {
          /// The old bloc needs to be disposed after [ValueListenableBuilder] had a change to update itself
          /// so it can properly unsubscribe
          _oldBloc.dispose();
          _oldBloc = null;
        }

        return widget.builder(context, bloc, value, child);
      },
    );
  }
}
