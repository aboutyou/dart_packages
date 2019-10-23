import 'package:test/test.dart';
import 'package:with_bloc/src/are_lists_equal.dart';

class _Equatable {
  bool operator ==(Object obj) {
    return obj is _Equatable;
  }

  int get hashCode => 1;
}

void main() {
  test('Should properly handle empty lists', () {
    expect(
      areListsEqual([], []),
      true,
    );
  });

  test('Lists with different amount of items', () {
    expect(
      areListsEqual([], [1]),
      false,
    );
  });

  test('Lists with same amount of items and equal items', () {
    expect(
      areListsEqual([1], [1]),
      true,
    );
  });

  test('Lists with same amount of items and not equal items', () {
    expect(
      areListsEqual([2], [1]),
      false,
    );
  });

  test('Lists with complex data structures 1', () {
    expect(
      /// These should not be equal because the [List] is not equal via `==`
      areListsEqual([[]], [[]]),
      false,
    );
  });

  test('Lists with complex data structures 2', () {
    expect(
      /// These should not be equal because the [Object] is not equal via `==`
      areListsEqual([Object()], [Object()]),
      false,
    );
  });

  test('Lists with const lists', () {
    expect(
      /// These should be equal because the use `const`
      areListsEqual([const []], [const []]),
      true,
    );
  });

  test('Lists with complex data structures', () {
    expect(
      /// These should be equal because the items implement a custom `==`
      areListsEqual([_Equatable()], [_Equatable()]),
      true,
    );
  });

  test('Lists with same items but different order', () {
    expect(
      areListsEqual([1, 2], [2, 1]),
      false,
    );
  });
}
