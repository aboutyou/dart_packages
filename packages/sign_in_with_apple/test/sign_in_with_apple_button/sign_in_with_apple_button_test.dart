import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/src/widgets/sign_in_with_apple_button.dart';

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

  if (!Platform.isMacOS) {
    return;
  }

  setUp(() {
    // ignore: avoid_as
    final binding = TestWidgetsFlutterBinding.ensureInitialized()
        as TestWidgetsFlutterBinding;

    binding.window.devicePixelRatioTestValue = 3;
    binding.window.physicalSizeTestValue = Size(300, 100) * 3;
  });

  testWidgets('Default style', (tester) async {
    await tester.pumpWidget(
      TestSetup(
        child: SignInWithAppleButton(onPressed: () {}),
      ),
    );

    await expectLater(
      find.byType(CupertinoApp),
      matchesGoldenFile('goldens/default_style.png'),
    );
  });

  testWidgets('Pill-shaped', (tester) async {
    await tester.pumpWidget(
      TestSetup(
        child: SignInWithAppleButton(
          onPressed: () {},
          borderRadius: BorderRadius.all(
            Radius.circular(22.0),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CupertinoApp),
      matchesGoldenFile('goldens/pill_shaped.png'),
    );
  });

  testWidgets('Default style (white)', (tester) async {
    await tester.pumpWidget(
      TestSetup(
        child: SignInWithAppleButton(
          onPressed: () {},
          style: SignInWithAppleButtonStyle.white,
        ),
        backgroundColor: Colors.grey[350],
      ),
    );

    await expectLater(
      find.byType(CupertinoApp),
      matchesGoldenFile('goldens/default_style_white.png'),
    );
  });

  group('Button Style', () {
    testWidgets('Black', (tester) async {
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
    });

    testWidgets('White', (tester) async {
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
    });

    testWidgets('White Outlined', (tester) async {
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
    });
  });

  group('Icon Alignment', () {
    testWidgets('Left aligned icon', (tester) async {
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
    });

    testWidgets('Center aligned Icon', (tester) async {
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
    });
  });
}

class TestSetup extends StatelessWidget {
  const TestSetup({
    Key key,
    @required this.child,
    this.backgroundColor = Colors.white,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: (context, _) => Container(
        padding: EdgeInsets.all(10),
        color: backgroundColor,
        child: Column(
          children: <Widget>[
            child,
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      theme: CupertinoThemeData().copyWith(
        textTheme: CupertinoTextThemeData().copyWith(
          textStyle: TextStyle(fontFamily: 'SF'),
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
