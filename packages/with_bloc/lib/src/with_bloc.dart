import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const listId = ListEquality<dynamic>();

/// A helper widget for easily creating [StateQueue] in the [build] method.
///
/// This widget takes care of creating the [BlocType] and disposing it when necessary.
/// It also handles recreating the [BlocType] whenever any [inputs] change.
class WithBloc<BlocType extends ValueNotifier<StateType>, StateType>
    extends StatefulWidget {
  const WithBloc({
    Key key,
    @required this.createBloc,
    @required this.builder,
    this.inputs = const [],
    this.child,
  })  : assert(createBloc != null),
        assert(builder != null),
        assert(inputs != null),
        super(key: key);

  /// A function which creates the [BlocType] instance
  ///
  /// This function might be called multiple times in the lifetime of this widget.
  /// Whenever the [inputs] change, a new bloc will be created by calling this function.
  final BlocType Function(BuildContext context) createBloc;

  /// A [Function] which builds a widget depending on the [BlocType] and [StateType].
  ///
  /// The [bloc] will be the current bloc and [value] is the current [StateType].
  /// When the bloc emits a new value, this function will be called again to reflect the changes in the UI.
  ///
  /// The [child] will be passed in as the fourth argument and might be `null` if not supplied.
  final Widget Function(
    BuildContext context,
    BlocType bloc,
    StateType value,
    Widget child,
  ) builder;

  /// A [BlocType]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree
  /// the [builder] builds depends on the value of the [BlocType].
  ///
  /// Can be `null`.
  ///
  /// See also:
  ///  - [ValueListenableBuilder]
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
