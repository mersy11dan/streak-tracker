import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:streak_tracker/app.dart';
import 'package:streak_tracker/main.dart' as app;

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await (app.main as dynamic)();
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: StreakTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Streak Tracker'), findsOneWidget);
  });
}
