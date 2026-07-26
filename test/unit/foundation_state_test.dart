import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/app/routing/app_router.dart';
import 'package:organization_task_manager/app/routing/role_shell_page.dart';
import 'package:organization_task_manager/shared/enums/app_enums.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main() {
  test('every demo role has the approved destination count', () {
    expect(destinationsForRole(DemoUserRole.employee), hasLength(5));
    expect(destinationsForRole(DemoUserRole.manager), hasLength(6));
    expect(destinationsForRole(DemoUserRole.seniorManagement), hasLength(5));
    expect(destinationsForRole(DemoUserRole.administrator), hasLength(7));
  });
  test('locale, theme, and connectivity providers change in memory', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(localeProvider.notifier).state = const Locale('en');
    c.read(themeModeProvider.notifier).state = ThemeMode.dark;
    c.read(connectivityProvider.notifier).state =
        SimulatedConnectivityStatus.offline;
    expect(c.read(localeProvider)?.languageCode, 'en');
    expect(c.read(themeModeProvider), ThemeMode.dark);
    expect(c.read(connectivityProvider), SimulatedConnectivityStatus.offline);
  });
  test('session transitions do not retain a user', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final controller = c.read(sessionProvider.notifier);
    controller.beginProfileSelection();
    expect(
      c.read(sessionProvider).status,
      AuthenticationStatus.selectingProfile,
    );
    controller.authenticate(demoProfiles.first);
    expect(c.read(currentDemoProfileProvider), demoProfiles.first);
    controller.expire();
    expect(c.read(sessionProvider).status, AuthenticationStatus.expired);
    expect(c.read(currentDemoProfileProvider), isNull);
    controller.logout();
    expect(
      c.read(sessionProvider).status,
      AuthenticationStatus.unauthenticated,
    );
  });
  test('role access rejects another role root', () {
    expect(
      canAccessRolePath(DemoUserRole.employee, '/app/employee/tasks'),
      isTrue,
    );
    expect(
      canAccessRolePath(DemoUserRole.employee, '/app/manager/home'),
      isFalse,
    );
    expect(
      canAccessRolePath(DemoUserRole.administrator, '/app/admin/users'),
      isTrue,
    );
  });
}
