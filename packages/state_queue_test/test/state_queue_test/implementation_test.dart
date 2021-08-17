import 'package:state_queue/state_queue.dart';
import 'package:state_queue_test/state_queue_test.dart';
import 'package:test/test.dart';

class _TestBloc extends StateQueue<int> {
  _TestBloc() : super(0);

  void incr() {
    run((state) async* {
      yield state + 1;
    });
  }
}

void main() {
  test('Forwards exception from `build`', () {
    expect(
      () async {
        await runBlocTest<_TestBloc, int>(
          build: () => throw Exception('Build failure'),
        );
      },
      // ignore: avoid_annotating_with_dynamic
      throwsA((dynamic e) => e.toString() == 'Exception: Build failure'),
    );
  });

  test('Forwards exception from `act`', () {
    expect(
      () async {
        await runBlocTest<_TestBloc, int>(
          build: () => _TestBloc(),
          act: (_) => throw Exception('Act failure'),
        );
      },
      // ignore: avoid_annotating_with_dynamic
      throwsA((dynamic e) => e.toString() == 'Exception: Act failure'),
    );
  });

  test('Errors with too many states', () {
    expect(
      () async {
        await runBlocTest<_TestBloc, int>(
          build: () => _TestBloc(),
          expect: <int>[0, 1],
        );
      },
      throwsA(
        // ignore: avoid_annotating_with_dynamic
        (dynamic e) =>
            e is TestFailure &&
            e.message?.contains('Which: shorter than expected') == true,
      ),
    );
  });

  test('Errors with too few states', () {
    expect(
      () async {
        await runBlocTest<_TestBloc, int>(
          build: () => _TestBloc(),
          act: (b) {
            b..incr()..incr()..incr();
          },
          expect: <int>[0, 1],
        );
      },
      throwsA(
        // ignore: avoid_annotating_with_dynamic
        (dynamic e) =>
            e is TestFailure &&
            e.message!.contains('Which: longer than expected'),
      ),
    );
  });

  test('Errors with wrong states', () {
    expect(
      () async {
        await runBlocTest<_TestBloc, int>(
          build: () => _TestBloc(),
          act: (b) {
            b.incr();
          },
          expect: <int>[0, 7],
        );
      },
      throwsA(
        // ignore: avoid_annotating_with_dynamic
        (dynamic e) =>
            e is TestFailure &&
            e.message!.contains('Which: was <1> instead of <7> at location [1]'),
      ),
    );
  });
}
