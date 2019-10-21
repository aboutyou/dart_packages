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

    bloc ??= widget.createBloc(context);
  }

  @override
  void didUpdateWidget(WithBloc<BlocType, StateType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listId.equals(oldWidget.inputs, widget.inputs)) {
      setState(() {
        bloc = widget.createBloc(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StateType>(
      valueListenable: bloc,
      child: widget.child,
      builder: (context, value, child) =>
          widget.builder(context, bloc, value, child),
    );
  }
}
