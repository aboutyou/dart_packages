import 'package:flutter/widgets.dart';
import 'package:with_bloc/src/are_lists_equal.dart';

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
  /// Whenever the [inputs] change, a new BLoC will be created by calling this function.
  ///
  /// For creating the initial bloc, this function will be called in the `initState`.
  /// That means that you can listen to any `Provider`s or `MediaQuery`.
  ///
  /// If you need to `listen` to changes, consider moving the `Provider` call out of the method
  /// and then using the `value` itself in the [createBloc].
  /// Don't forget to also reference the `value` in the [inputs].
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
  /// If a part of your subtree doesn't depend on the [BlocType] or [StateType],
  /// it can be passed the [child] to this widget.
  /// You will then get this [child] back in the [builder] method as the fourth argument.
  /// Doing this will optimize the building of widgets, because whenever the [BlocType] changes,
  /// it will not be recreated.
  final Widget child;

  /// The parameters the BLoC depends upon.
  ///
  /// If these change, the BLoC will be recreated and the old BloC will be disposed.
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
  void initState() {
    super.initState();

    bloc = _initBloc();
  }

  @override
  void didUpdateWidget(WithBloc<BlocType, StateType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!areListsEqual(oldWidget.inputs, widget.inputs)) {
      _disposeBloc();

      /// Recreate the BLoC
      bloc = _initBloc();
    }
  }

  void _handleUpdate() {
    /// Trigger an update so the [build] method is called again
    setState(() {});
  }

  /// Creates a new BLoC and adds a new listener
  BlocType _initBloc() {
    return widget.createBloc(context)..addListener(_handleUpdate);
  }

  /// Removes the listener and disposes the current BLoC
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
