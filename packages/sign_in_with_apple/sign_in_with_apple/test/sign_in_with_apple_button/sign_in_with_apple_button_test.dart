// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/src/widgets/sign_in_with_apple_button.dart';

// The tests are only run on macOS system, on other systems they will be skipped
// On other systems small differences can lead to failing goldens (e.g. text rendering)
Future<void> main() async {
  // Using Roboto here instead of Apple's San Francisco fonts, due to licensing issues
  //
  // Roboto is then remapped to the San Francisco's font name, so it gets picked up while running the tests
  // (`fontFamilyFallback` didn't work in tests and `Ahem` (block) font would be used instead)
  final fontData =
      File.fromUri(_resolvePathInTestDirectory('../assets/fonts/Roboto.ttf'))
          .readAsBytes()
          .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  final fontLoader = FontLoader('.SF Pro Text')..addFont(fontData);
  await fontLoader.load();

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    binding.window.devicePixelRatioTestValue = 3;
    binding.window.physicalSizeTestValue = const Size(300, 100) * 3;
  });

  group('Button Style', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .physicalSizeTestValue = const Size(300, 175) * 3;
    });

    for (final style in SignInWithAppleButtonStyle.values) {
      testWidgets(
        style.name,
        (tester) async {
          await tester.pumpWidget(
            TestSetup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DebugLabel('Enabled:'),
                  const SizedBox(height: 5),
                  SignInWithAppleButton(
                    onPressed: () {},
                    style: style,
                  ),
                  const SizedBox(height: 20),
                  const DebugLabel('Disabled:'),
                  const SizedBox(height: 5),
                  SignInWithAppleButton(
                    onPressed: null,
                    style: style,
                  ),
                ],
              ),
            ),
          );

          await expectLater(
            find.byType(CupertinoApp),
            matchesGoldenFile('goldens/${style.name}_button.png'),
          );
        },
        skip: !Platform.isMacOS,
      );
    }
  });

  group('Icon Alignment', () {
    testWidgets(
      'Left aligned icon',
      (tester) async {
        await tester.pumpWidget(
          TestSetup(
            child: SignInWithAppleButton(
              onPressed: () {},
              iconAlignment: IconAlignment.left,
            ),
          ),
        );

        await expectLater(
          find.byType(CupertinoApp),
          matchesGoldenFile('goldens/left_aligned_icon.png'),
        );
      },
      skip: !Platform.isMacOS,
    );

    testWidgets(
      'Center aligned Icon',
      (tester) async {
        await tester.pumpWidget(
          TestSetup(
            child: SignInWithAppleButton(
              onPressed: () {},
              iconAlignment: IconAlignment.center,
            ),
          ),
        );

        await expectLater(
          find.byType(CupertinoApp),
          matchesGoldenFile('goldens/center_aligned_icon.png'),
        );
      },
      skip: !Platform.isMacOS,
    );
  });

  testWidgets(
    'Allows to customize the border radius of the button',
    (tester) async {
      await tester.pumpWidget(
        TestSetup(
          child: SignInWithAppleButton(
            onPressed: () {},
            borderRadius: const BorderRadius.all(
              Radius.circular(22.0),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CupertinoApp),
        matchesGoldenFile('goldens/custom_border_radius.png'),
      );
    },
    skip: !Platform.isMacOS,
  );

  testWidgets(
    'Allows to customize the height of the button',
    (tester) async {
      await tester.pumpWidget(
        TestSetup(
          child: SignInWithAppleButton(
            onPressed: () {},
            height: 60,
          ),
        ),
      );

      await expectLater(
        find.byType(CupertinoApp),
        matchesGoldenFile('goldens/custom_height.png'),
      );

      expect(
        tester
            .getSize(
              find.byType(SignInWithAppleButton),
            )
            .height,
        60,
      );
    },
    skip: !Platform.isMacOS,
  );

  testWidgets(
    'Allows customizing of the text',
    (tester) async {
      await tester.pumpWidget(
        TestSetup(
          child: SignInWithAppleButton(
            onPressed: () {},
            text: 'Login with Apple',
          ),
        ),
      );

      await expectLater(
        find.byType(CupertinoApp),
        matchesGoldenFile('goldens/custom_text.png'),
      );

      expect(
        find.text('Login with Apple'),
        findsOneWidget,
      );
    },
    skip: !Platform.isMacOS,
  );

  testWidgets(
    'Allows providing a custom text widget',
    (tester) async {
      await tester.pumpWidget(
        TestSetup(
          child: SignInWithAppleButton(
            onPressed: () {},
            textWidget: const Text('Apple Login'),
          ),
        ),
      );

      await expectLater(
        find.byType(CupertinoApp),
        matchesGoldenFile('goldens/custom_text_widget.png'),
      );

      expect(
        find.text('Apple Login'),
        findsOneWidget,
      );
    },
    skip: !Platform.isMacOS,
  );

  testWidgets(
    'Calls the onPressed callback when the button is pressed',
    (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        TestSetup(
          child: SignInWithAppleButton(
            onPressed: () {
              callCount++;
            },
          ),
        ),
      );

      await tester.tapAt(
        tester.getCenter(find.byType(SignInWithAppleButton)),
      );
      await tester.pumpAndSettle();

      expect(callCount, 1);
    },
    skip: !Platform.isMacOS,
  );
}

class TestSetup extends StatelessWidget {
  const TestSetup({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  final Widget child;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(10),
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            child,
          ],
        ),
      ),
      theme: const CupertinoThemeData().copyWith(
        textTheme: const CupertinoTextThemeData().copyWith(
          textStyle: const TextStyle(fontFamily: 'SF'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Uri _resolvePathInTestDirectory(String path) {
  var cwd = Directory.current;
  final uri = cwd.uri.toString();

  // The CWD will be the root when the test is run from VSCode directly
  // We append ./test/ then to properly have resolve the response files
  if (!uri.endsWith('/test/') && !path.endsWith('/test/')) {
    cwd = Directory.fromUri(cwd.uri.resolve('./test'));
  }

  return cwd.uri.resolve(path);
}

class DebugLabel extends StatelessWidget {
  const DebugLabel(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontFamily: '.SF Pro Text',
      ),
    );
  }
}
