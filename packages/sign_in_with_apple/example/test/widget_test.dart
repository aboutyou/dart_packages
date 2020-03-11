import 'package:flutter_test/flutter_test.dart';

import 'package:sign_in_with_apple_example/main.dart';

void main() {
  testWidgets('', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that platform version is retrieved.
    expect(
      find.byType(MyApp),
      findsOneWidget,
    );
  });
}
