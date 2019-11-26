import 'dart:async';

/// Class that keeps track of ongoing, potentially `async`, operations.
///
/// Keeps a counter of ongoing operation and provides an interface to await
/// all currently scheduled operations.
class PendingOperations implements PendingOperationsReader {
  final _ongoingOperations = <String>[];

  int _pendingCalls = 0;

  Future<void> _knownCallsHandled = Future<void>.value();

  /// Registers a new pending operation and returns a new function that can be
  /// used to signal that the pending operation has completed.
  ///
  /// The returned function is safe to be used before `return` statements.
  void Function() registerPendingOperation(String description) {
    _pendingCalls++;
    _ongoingOperations.add(description);

    final completer = Completer<void>();

    _knownCallsHandled = Future.wait([_knownCallsHandled, completer.future]);

    // Guard that the `done` callback runs only once
    var done = false;

    return () => Timer.run(
          () {
            if (done) {
              assert(
                false,
                'Tried running completer function twice. Operation: $description',
              );
              return;
            }

            done = true;

            _ongoingOperations.remove(description);
            _pendingCalls--;
            completer.complete();
          },
        );
  }

  Future<void> awaitEndOfKnownCalls() {
    return _knownCallsHandled;
  }

  int get pendingCalls => _pendingCalls;

  String ongoingOperationsDescription() {
    return _ongoingOperations.join('\n');
  }
}

abstract class PendingOperationsReader {
  Future<void> awaitEndOfKnownCalls();

  int get pendingCalls;

  String ongoingOperationsDescription();
}
