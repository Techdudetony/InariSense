// Basic smoke test confirming the app boots and shows the placeholder
// home screen. This replaces Flutter's auto-generated template test,
// which referenced the default `mobile`/`MyApp` placeholder names rather
// than this project's actual package name (`inarisense`) and root widget
// (`InariSenseApp`).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inarisense/main.dart';

void main() {
  testWidgets('App boots and shows the placeholder home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: InariSenseApp()));

    expect(find.text('InariSense'), findsOneWidget);
    expect(find.text('Scaffold only — Home dashboard not yet built.'),
        findsOneWidget);
  });
}
