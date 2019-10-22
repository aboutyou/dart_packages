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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bloc ??= _initBloc();
  }

  @override
  void didUpdateWidget(WithBloc<BlocType, StateType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listId.equals(oldWidget.inputs, widget.inputs)) {
      _disposeBloc();

      /// Recreate the bloc
      bloc = _initBloc();
    }
  }

  void _handleUpdate() {
    /// Trigger an update so the [build] method is called again
    setState(() {});
  }

  /// Creates a new bloc and adds a new listener
  BlocType _initBloc() {
    return widget.createBloc(context)..addListener(_handleUpdate);
  }

  /// Removes the listener and disposes the current bloc
  BlocType _disposeBloc() {
    return bloc
      ..removeListener(_handleUpdate)
      ..dispose();
  }

  @override
  void dispose() {
    _disposeBloc();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      bloc,
      bloc.value,
      widget.child,
    );
  }
}
