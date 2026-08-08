// Tests for the app's entry point (SessionBootstrap).
//
// Flutter's test environment always returns HTTP 400 for real network
// calls rather than making one — see the "creates an HttpClient" warning
// flutter test prints. UserSession.resolveUserId() treats any non-201
// response as a failure, so these tests exercise the bootstrap screen's
// loading state and error/retry path, not a mocked happy-path login.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inarisense/main.dart';

void main() {
  setUp(() {
    // Without this, SharedPreferences.getInstance() hangs forever in a
    // widget test — it uses a platform channel that's never mocked by
    // default outside a real device/emulator, so UserSession.resolveUserId()
    // never completes and pumpAndSettle() times out waiting on it.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows a loading indicator while resolving the user session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: InariSenseApp()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows a retry option if the backend is unreachable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: InariSenseApp()));
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Could not connect to the server. Make sure the backend is running.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
