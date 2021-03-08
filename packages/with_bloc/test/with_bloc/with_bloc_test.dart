import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_bloc/with_bloc.dart';

import 'async_increment_bloc.dart';
import 'disposable_bloc.dart';

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

        final firstWidgetState = withBloc.currentState!;

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

        final firstAgainWidgetState = withBloc.currentState!;

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

        final secondWidgetState = withBloc.currentState!;

        final secondBloc = secondWidgetState.bloc;

        await secondBloc.runQueuedTasksToCompletion();

        final secondState = secondBloc.value;

        expect(firstBloc != secondBloc, true);

        expect(secondState.count, 0);
      });
    },
  );

  testWidgets(
    'Disposes old bloc if new one gets created',
    (tester) async {
      await tester.runAsync(() async {
        var createdInstances = 0;
        var disposedInstances = 0;

        DisposableBloc createBloc(BuildContext context) {
          createdInstances++;

          return DisposableBloc(
            onDispose: () {
              /// Increment the counter when the bloc get's disposed
              disposedInstances++;
            },
          );
        }

        await tester.pumpWidget(
          WithBloc<DisposableBloc, int>(
            createBloc: createBloc,
            inputs: <dynamic>[1],
            builder: (context, bloc, state, child) {
              return Container();
            },
          ),
        );

        /// Only one instance should be created and none should be disposed after the initial render
        expect(createdInstances, 1);
        expect(disposedInstances, 0);

        /// Rerender the widget with different inputs to trigger an update of the bloc
        await tester.pumpWidget(
          WithBloc<DisposableBloc, int>(
            createBloc: createBloc,
            inputs: <dynamic>[999],
            builder: (context, bloc, state, child) {
              return Container();
            },
          ),
        );

        /// Should have create a new one and disposed the old one
        expect(createdInstances, 2);
        expect(disposedInstances, 1);

        await tester.pumpWidget(
          Container(),
        );

        /// Should have disposed the current instance due to the widget being unmounted
        expect(createdInstances, 2);
        expect(disposedInstances, 2);
      });
    },
  );
}
