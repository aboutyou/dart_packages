import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/widgets/sign_in_with_apple_button.dart';

setupView(WidgetTester tester) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(300, 100) * 3;
}

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

  group('Button Style', () {
    testWidgets(
      'Black',
      (tester) async {
        setupView(tester);

        await tester.pumpWidget(
          TestSetup(
            child: SignInWithAppleButton(
              onPressed: () {},
              style: SignInWithAppleButtonStyle.black,
            ),
          ),
        );

        await expectLater(
          find.byType(CupertinoApp),
          matchesGoldenFile('goldens/black_button.png'),
        );
      },
      skip: !Platform.isMacOS,
    );

    testWidgets(
      'White',
      (tester) async {
        setupView(tester);

        await tester.pumpWidget(
          TestSetup(
            backgroundColor: Colors.black,
            child: SignInWithAppleButton(
              onPressed: () {},
              style: SignInWithAppleButtonStyle.white,
            ),
          ),
        );

        await expectLater(
          find.byType(CupertinoApp),
          matchesGoldenFile('goldens/white_button.png'),
        );
      },
      skip: !Platform.isMacOS,
    );

    testWidgets(
      'White Outlined',
      (tester) async {
        setupView(tester);

        await tester.pumpWidget(
          TestSetup(
            child: SignInWithAppleButton(
              onPressed: () {},
              style: SignInWithAppleButtonStyle.whiteOutlined,
            ),
          ),
        );

        await expectLater(
          find.byType(CupertinoApp),
          matchesGoldenFile('goldens/white_outlined_button.png'),
        );
      },
      skip: !Platform.isMacOS,
    );
  });

  group('Icon Alignment', () {
    testWidgets(
      'Left aligned icon',
      (tester) async {
        setupView(tester);

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
        setupView(tester);

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
      setupView(tester);

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
      setupView(tester);

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
      setupView(tester);

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
    'Calls the onPressed callback when the button is pressed',
    (tester) async {
      setupView(tester);

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
