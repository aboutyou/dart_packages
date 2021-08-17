import 'dart:async';

import 'package:state_queue/state_queue.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

class _TestBloc extends StateQueue<int> {
  _TestBloc() : super(0);

  void setState(int n) {
    run((state) async* {
      yield n;
    });
  }

  void divideStateBy(int n) {
    run((state) async* {
      yield state ~/ n;
    });
  }
}

void main() {
  test('Continues with next `run` after error', () async {
    final completer = Completer<int>();
    dynamic error;

    unawaited(
      // running this in a zone in order to be able to surpress the error logging to the console
      runZonedGuarded<Future<void>>(
        () async {
          final bloc = _TestBloc()
            ..setState(100)

            /// The `divideStateBy` will throw an error and make no changes to the state
            ..divideStateBy(0)
            ..divideStateBy(2);

          await bloc.runQueuedTasksToCompletion();

          completer.complete(bloc.value);
        },
        // ignore: avoid_annotating_with_dynamic, avoid_types_on_closure_parameters
        (dynamic localError, StackTrace stackTrace) {
          assert(error == null);

          error = localError;
        },
      ),
    );

    expect(
      await completer.future,

      /// This should be `50` because `100 / 2`
      50,
    );
    expect(
      error,
      isA<IntegerDivisionByZeroException>(),
    );
  });

  test(
    'PendingOperations: should register operations for run method',
    () async {
      final bloc = _TestBloc()..setState(5);

      expect(bloc.pendingOperations?.pendingCalls, 1);

      await bloc.runQueuedTasksToCompletion();

      /// Will be still `1` as the [Timer.run] inside the `PendingOperations` didn't run yet and so far has not marked the previous operation as done
      expect(bloc.pendingOperations?.pendingCalls, 1);

      /// Wait here to get the [Timer.run] callback be run
      await Future<void>.delayed(Duration.zero);

      expect(bloc.pendingOperations?.pendingCalls, 0);
    },
  );
}
