import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_bloc/with_bloc.dart';

import 'async_increment_bloc.dart';

Future<void> main() async {
  testWidgets(
    'WithBloc: Creates new bloc when `inputs` parameter changes',
    (tester) async {
      await tester.runAsync(() async {
        final withBloc =
            GlobalKey<WithBlocState<AsyncIncrementBloc, AsyncIncrementState>>();

        await tester.pumpWidget(
          WithBloc<AsyncIncrementBloc, AsyncIncrementState>(
            key: withBloc,
            createBloc: (context) => AsyncIncrementBloc(),
            inputs: <dynamic>[1],
            builder: (context, bloc, state, child) {
              return Container();
            },
          ),
        );

        final firstWidgetState = withBloc.currentState;

        final firstBloc = firstWidgetState.bloc;

        await firstBloc.runQueuedTasksToCompletion();

        final firstState = firstBloc.value;

        expect(firstState.count, 0);

        // Render the same widget configuration again, this must not create a new bloc
        await tester.pumpWidget(
          WithBloc<AsyncIncrementBloc, AsyncIncrementState>(
            key: withBloc,
            createBloc: (context) => AsyncIncrementBloc(),
            inputs: <dynamic>[1],
            builder: (context, bloc, state, child) {
              return Container();
            },
          ),
        );

        final firstAgainWidgetState = withBloc.currentState;

        final firstAgainBloc = firstAgainWidgetState.bloc;

        expect(
          firstBloc,
          firstAgainBloc,
          reason: 'does not create a new bloc when input stay same',
        );

        // Render with another `inputs` parameter, this must result in a new bloc and different state
        await tester.pumpWidget(
          WithBloc<AsyncIncrementBloc, AsyncIncrementState>(
            key: withBloc,
            createBloc: (context) => AsyncIncrementBloc(),
            inputs: <dynamic>[999],
            builder: (context, bloc, state, child) {
              return Container();
            },
          ),
        );

        final secondWidgetState = withBloc.currentState;

        final secondBloc = secondWidgetState.bloc;

        await secondBloc.runQueuedTasksToCompletion();

        final secondState = secondBloc.value;

        expect(firstBloc != secondBloc, true);

        expect(secondState.count, 0);
      });
    },
  );
}
