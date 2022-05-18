import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pending_operations/pending_operations.dart';

typedef StateUpdater<T> = Stream<T> Function(T state);

@immutable
abstract class _QueueEntry<T> {}

class _UpdaterEntry<T> implements _QueueEntry<T> {
  _UpdaterEntry(
    this.updater, {
    required this.onDone,
  });

  final StateUpdater<T> updater;

  final void Function() onDone;
}

class _CompletionNotifierEntry<T> implements _QueueEntry<T> {
  _CompletionNotifierEntry(this.completer);

  final Completer<void> completer;
}

/// A bloc emitting a single state value, which is updated by running updater functions (within [run]) in sequence.
///
/// The [StateQueue] class is abstract and needs to be subclassed to create a new bloc class.
///
/// {@tool sample}
///
/// ```dart
/// class StringState extends StateQueue<String> {
///   StringState({
///     @required String initialValue,
///   }) : super(initialValue);
///
///   void append(String suffix) {
///     run(
///       (state) async* {
///         yield state + suffix;
///       },
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// Any state yielding function executing inside [run] will run to completion
/// (potentially yielding multiple states). Only once this has completed will
/// the next updater function scheduled with [run] be started.
/// (See [run] for further details on how to work with it.)
///
/// As [StateQueue] implements [ValueNotifier] it can be used to trigger the
/// build of widgets using [ValueListenableBuilder] (or `WithBloc` in cases
/// where you also want to create the bloc and subscribe to it at the same time).
abstract class StateQueue<T> extends ValueNotifier<T>
    implements ValueListenable<T> {
  StateQueue(T value) : super(value) {
    /// This takes care of running the actual work scheduled by [run] and [runQueuedTasksToCompletion].
    ///
    /// After [_QueueEntry]s are queued in an async stream, they are executed
    /// sequentially and each is run to completion before the next one is started.
    ///
    /// There a two types of queue entries:
    /// * [_UpdaterEntry], which contains a state yielding `updater` function
    /// * [_CompletionNotifierEntry], which is just a marker to be called when
    ///   encountered in the [_taskQueue] stream notifying tests that all
    ///   previous entries have completed
    _taskQueue.stream.asyncExpand<T>((event) async* {
      if (event is _UpdaterEntry<T>) {
        try {
          await for (final nextState in event.updater(this.value)) {
            yield nextState;
          }

          // ignore: avoid_catches_without_on_clauses
        } catch (error, stack) {
          Zone.current.handleUncaughtError(error, stack);
        } finally {
          event.onDone();
        }
      } else if (event is _CompletionNotifierEntry<T>) {
        event.completer.complete();
      }
    }).forEach((nextState) {
      // don't push any more states after instance is disposed
      if (!isDisposed && super.value != nextState) {
        _setValue(nextState);
      }
    });
  }

  final _taskQueue = StreamController<_QueueEntry<T>>();

  final _pendingOperations = PendingOperations();

  PendingOperationsReader get pendingOperations => _pendingOperations;

  @override
  set value(T value) {
    throw Exception('"value" must not be set directly. Use `run`.');
  }

  // ignore: use_setters_to_change_properties
  /// This setter has only been added to work around a code generation issue we saw with `dartdevc` (for Flutter web development)
  /// Should be removed in the future.
  void _setValue(T value) {
    super.value = value;
  }

  /// Schedules a state yielding [updater] function to be run.
  ///
  /// The passed function will run after all previously scheduled functions ran to completion.
  ///
  ///
  ///
  /// While [run] takes an `async*` function, the completion of the scheduled
  /// function can not be awaited from the caller.
  /// Hence any function in a [StateQueue] implementation purely calling [run]
  /// should not be async itself, as to not mislead the caller of the bloc method
  /// to expect that all computation is done once the method on the bloc succeeds.
  ///
  /// DON'T DO THIS, because the [Future] returned by `append` would complete immediately,
  /// while the function passed to `run` wouldn't even have started.
  ///
  /// ```dart
  /// Future<void> append(String suffix) async {
  ///   run(
  ///     (state) async* {
  ///       yield state + suffix;
  ///     },
  ///   );
  /// }
  /// ```
  ///
  /// The reason for this lack of awaitability is that bloc methods are generally called
  /// from widgets, which should not await their result for the purpose of coordinating
  /// between blocs.
  ///
  ///
  ///
  /// Also be aware of the implications using multiple individual [run]s inside one bloc method.
  /// While there are a few legitimate cases to do this, most of them involve checking the
  /// passed `state` to find out whether the next update should still be yielded, or whether
  /// it's obsolete now because the state was already changed by another invocation.
  /// Usually it's correct and also much simpler to have a single [run] invocation in a bloc
  /// method which `awaits`s and `yield`s as much as it needs to. The guarantee that this
  /// async [updater] will not be interrupted by any other state changes makes it much
  /// easier to reason about.
  ///
  ///
  /// Since [updater] functions `yield` new states, they are free to yield more than one state
  ///
  /// State changes are not immediately reflected inside the [run].
  /// If you call a method from a [run] which accesses `state` or `value`, it might not have the updated state yet when this function runs.
  ///
  ///   /// ```dart
  /// Future<void> append(String suffix)  async{
  ///   run(
  ///     (state) async* {
  ///       yield 'computing';
  ///
  ///       final result = await [state, suffix].join(''); // asume join is async, or a network call, etc.
  ///
  ///       yield result;
  ///     },
  ///   );
  /// }
  /// ```
  ///
  ///
  ///
  /// If the [updater] function crashes during execution, the last yielded state
  /// will be kept (meaning there is no rollback).
  /// So if you emit intermediate state (like loading) be sure to use `try/catch/finally`
  /// to not leave the bloc hanging in a pending state for eternity.
  /// The error will be captured and be reported to the current [Zone] for error handling.
  /// You can intercept these errors by wrapping your [runApp] in a [runZoned]
  /// and providing a callback to the `onError` parameter.
  ///
  /// A note for testing: A function passed as [updater] should not call [run] itself
  /// (neither directly nor indirectly), as that makes testing hard as the completion
  /// of the bloc can not be awaited properly.
  @protected
  void run(StateUpdater<T> updater) {
    assert(!isDisposed);
    final entry = _UpdaterEntry(
      updater,
      onDone: _pendingOperations.registerPendingOperation('UpdaterEntry'),
    );

    _taskQueue.sink.add(entry);
  }

  @override
  @mustCallSuper
  void dispose() {
    _taskQueue.close();

    super.dispose();
  }

  @protected
  bool get isDisposed => _taskQueue.isClosed;

  /// Returns a `Future` which completes once all currently queued tasks have completed
  @visibleForTesting
  Future<void> runQueuedTasksToCompletion() async {
    assert(!isDisposed);

    final completer = Completer<void>();

    _taskQueue.sink.add(_CompletionNotifierEntry<T>(completer));

    return completer.future;
  }
}
