import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple_button/sign_in_with_apple_button.dart';

Future<void> main() async {
  final fontData = File('../assets/fonts/SF.ttf')
      .readAsBytes()
      .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  final fontLoader = FontLoader('SF')..addFont(fontData);
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
