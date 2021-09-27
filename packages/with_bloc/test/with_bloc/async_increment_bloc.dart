import 'package:state_queue/state_queue.dart';
import 'package:meta/meta.dart';

@immutable
class AsyncIncrementState {
  const AsyncIncrementState(this.count);

  final int count;
}

class AsyncIncrementBloc extends StateQueue<AsyncIncrementState> {
  AsyncIncrementBloc() : super(const AsyncIncrementState(0));

  void increment() {
    run((state) async* {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      yield AsyncIncrementState(state.count + 1);
    });
  }
}
