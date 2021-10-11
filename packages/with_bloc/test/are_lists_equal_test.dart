import 'package:test/test.dart';
import 'package:with_bloc/src/are_lists_equal.dart';

/// Class whose instances are always equal to each other.
class _Equatable {
  @override
  bool operator ==(Object obj) {
    return obj is _Equatable;
  }

  @override
  int get hashCode => 1;
}

void main() {
  test('Should properly handle empty lists', () {
    expect(
      areListsEqual(<dynamic>[], <dynamic>[]),
      true,
    );
  });

  test('Lists with different amount of items', () {
    expect(
      areListsEqual(<dynamic>[], <dynamic>[1]),
      false,
    );
  });

  test('Lists with same amount of items and equal items', () {
    expect(
      areListsEqual(<dynamic>[1], <dynamic>[1]),
      true,
    );
  });

  test('Lists with same amount of items and not equal items', () {
    expect(
      areListsEqual(<dynamic>[2], <dynamic>[1]),
      false,
    );
  });

  test('Lists with complex data structures 1', () {
    expect(
      /// These should not be equal because the [List] is not equal via `==`
      areListsEqual(
        <dynamic>[<dynamic>[]],
        <dynamic>[<dynamic>[]],
      ),
      false,
    );
  });

  test('Lists with complex data structures 2', () {
    expect(
      /// These should not be equal because the [Object] is not equal via `==`
      areListsEqual(<dynamic>[Object()], <dynamic>[Object()]),
      false,
    );
  });

  test('Lists with const lists', () {
    expect(
      /// These should be equal because the use `const`
      areListsEqual(
        <dynamic>[const <dynamic>[]],
        <dynamic>[const <dynamic>[]],
      ),
      true,
    );
  });

  test('Lists with complex data structures', () {
    expect(
      /// These should be equal because the items implement a custom `==`
      areListsEqual(<dynamic>[_Equatable()], <dynamic>[_Equatable()]),
      true,
    );
  });

  test('Lists with same items but different order', () {
    expect(
      areListsEqual(<dynamic>[1, 2], <dynamic>[2, 1]),
      false,
    );
  });
}
