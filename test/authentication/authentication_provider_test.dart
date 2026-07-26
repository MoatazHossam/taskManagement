import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/app/dependency_injection/app_providers.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/core/storage/database/app_database.dart';
import 'package:organization_task_manager/core/storage/database/seed/demo_data_service.dart';
import 'package:organization_task_manager/core/storage/repositories/local_audit_repository.dart';
import 'package:organization_task_manager/core/storage/repositories/local_settings_repository.dart';
import 'package:organization_task_manager/core/storage/repositories/local_user_repository.dart';
import 'package:organization_task_manager/features/authentication/data/local_demo_authentication_service.dart';
import 'package:organization_task_manager/shared/enums/app_enums.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main() {
  late AppDatabase database;
  late LocalUserRepository users;
  late LocalDemoAuthenticationService service;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    const clock = FixedAppClock(DateTime.utc(2026, 7, 26, 10));
    await DemoDataService(database, clock).ensureSeeded();
    users = LocalUserRepository(UserDao(database));
    service = LocalDemoAuthenticationService(
      users: users,
      settings: LocalSettingsRepository(SettingsDao(database)),
      audit: LocalAuditRepository(AuditDao(database)),
      clock: clock,
      isOffline: () => false,
    );
  });

  tearDown(() => database.close());

  test('initializes once after restoration and derives database identity', () async {
    final controller = SessionController(service, users);
    expect(controller.state.status, AuthenticationStatus.initializing);
    await controller.initialize(offline: false);
    expect(controller.state.status, AuthenticationStatus.unauthenticated);
    await controller.initialize(offline: false);
    expect(controller.state.status, AuthenticationStatus.unauthenticated);

    await controller.signInProfile(demoProfiles.first);
    expect(controller.state.status, AuthenticationStatus.authenticated);
    expect(controller.state.user?.id, 'user-ahmed-hassan');
    expect(controller.state.role, DemoUserRole.employee);
  });

  test('failure, logout, switching and unlock transitions are authoritative', () async {
    final controller = SessionController(service, users);
    await controller.signInCredentials('employee', 'wrong');
    expect(controller.state.status, AuthenticationStatus.failure);
    expect(controller.state.session, isNull);

    await controller.signInProfile(demoProfiles.first);
    await controller.switchProfile(
      demoProfiles.firstWhere((profile) => profile.id == 'manager'),
    );
    expect(controller.state.role, DemoUserRole.manager);
    expect(controller.state.user?.id, 'user-sara-mahmoud');
    await controller.logout();
    expect(controller.state.status, AuthenticationStatus.unauthenticated);
    expect(controller.state.user, isNull);
  });

  test('provider overrides isolate and dispose the in-memory database', () async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    expect(container.read(appDatabaseProvider), same(database));
  });
}
