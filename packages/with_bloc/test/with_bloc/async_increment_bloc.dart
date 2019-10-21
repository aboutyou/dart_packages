import 'package:state_queue/state_queue.dart';
import 'package:meta/meta.dart';

@immutable
class AsyncIncrementState {
  AsyncIncrementState(this.count);

  final int count;
}

class AsyncIncrementBloc extends StateQueue<AsyncIncrementState> {
  AsyncIncrementBloc() : super(AsyncIncrementState(0));

  void increment() {
    run((state) async* {
      await Future.delayed(Duration(milliseconds: 100));

      yield AsyncIncrementState(state.count + 1);
    });
  }
}
