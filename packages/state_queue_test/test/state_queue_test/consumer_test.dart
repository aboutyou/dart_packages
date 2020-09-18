import 'package:state_queue/state_queue.dart';
import 'package:state_queue_test/state_queue_test.dart';

class _TestBloc extends StateQueue<int> {
  _TestBloc() : super(0);

  void setState(int n) {
    run((state) async* {
      yield n;
    });
  }

  void double() {
    run((state) async* {
      yield state * 2;
    });
  }

  void divideStateBy(int n) {
    run((state) async* {
      yield state ~/ n;
    });
  }
}

void main() {
  blocTest<_TestBloc, int>(
    'doubles correctly',
    build: () => _TestBloc(),
    act: (bloc) {
      bloc
        ..setState(1)
        ..double()
        ..double()
        ..double();
    },
    expect: [
      0,
      1,
      2,
      4,
      8,
    ],
  );
}
