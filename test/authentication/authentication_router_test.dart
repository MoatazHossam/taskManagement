import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:organization_task_manager/app/app.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/app/routing/app_router.dart';
import 'package:organization_task_manager/features/authentication/presentation/authentication_pages.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main() {
  for (final path in ['/app/employee/home', '/app/manager/home']) {
    testWidgets('unauthenticated access to $path redirects to login', (
      tester,
    ) async {
      final controller = SessionController()..logout();
      await tester.pumpWidget(_app(controller));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(DemoLoginPage));
      GoRouter.of(context).go(path);
      await tester.pumpAndSettle();
      expect(find.byType(DemoLoginPage), findsOneWidget);
    });
  }

  testWidgets('role changes and logout replace protected navigation', (
    tester,
  ) async {
    final controller = SessionController()
      ..authenticate(demoProfiles.firstWhere((p) => p.id == 'manager'));
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    controller.authenticate(
      demoProfiles.firstWhere((p) => p.id == 'administrator'),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(NavigationBar));
    GoRouter.of(context).go('/app/manager/home');
    await tester.pumpAndSettle();
    expect(find.text('Users'), findsWidgets);

    await controller.logout();
    await tester.pumpAndSettle();
    expect(find.byType(DemoLoginPage), findsOneWidget);
  });
}

Widget _app(SessionController controller) => ProviderScope(
  overrides: [
    localeProvider.overrideWith((ref) => const Locale('en')),
    sessionProvider.overrideWith((ref) => controller),
  ],
  child: const TaskManagementApp(),
);
