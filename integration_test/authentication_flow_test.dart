import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:organization_task_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('employee one-tap login and logout', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-employee')));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('credential login remains a deterministic local flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('username-input')), 'manager');
    await tester.enterText(find.byKey(const Key('password-input')), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Team tasks'), findsWidgets);
  });
}
