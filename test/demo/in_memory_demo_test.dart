import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/demo/demo_data_store.dart';
import 'package:organization_task_manager/core/demo/demo_seed_ids.dart';
import 'package:organization_task_manager/core/demo/in_memory_repositories.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/core/domain/domain_enums.dart';
import 'package:organization_task_manager/features/authentication/data/local_demo_authentication_service.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main() {
  final clock = FixedAppClock(DateTime.utc(2026, 1, 15, 10));
  late DemoDataStore store;
  late InMemoryUserRepository users;
  late InMemorySettingsRepository settings;
  late InMemoryAuditRepository audit;
  late LocalDemoAuthenticationService auth;

  setUp(() {
    store = DemoDataStore(clock: clock);
    users = InMemoryUserRepository(store);
    settings = InMemorySettingsRepository(store);
    audit = InMemoryAuditRepository(store);
    auth = LocalDemoAuthenticationService(
      users: users,
      settings: settings,
      audit: audit,
      clock: clock,
      isOffline: () => false,
    );
  });

  test('all five profiles and credential aliases authenticate', () async {
    for (final profile in demoProfiles) {
      expect((await auth.signInWithDemoProfile(profile.id)).isSuccess, isTrue);
      await auth.signOut();
    }
    for (final alias in [
      'employee',
      'manager',
      'executive',
      'admin',
      'support',
    ]) {
      expect(
        (await auth.signInWithDemoCredentials(
          username: alias,
          password: 'demo123',
        )).isSuccess,
        isTrue,
      );
      await auth.signOut();
    }
    expect(
      (await auth.signInWithDemoCredentials(
        username: 'employee',
        password: 'wrong',
      )).isSuccess,
      isFalse,
    );
  });

  test(
    'PIN, biometric, offline, logout, switching, and audit redaction',
    () async {
      expect(
        (await auth.signInWithDemoProfile(demoProfiles.first.id)).isSuccess,
        isTrue,
      );
      expect((await auth.unlockWithPin('0000')).isSuccess, isFalse);
      expect((await auth.unlockWithPin('1234')).isSuccess, isTrue);
      expect(
        (await auth.unlockWithBiometrics(simulateSuccess: false)).isSuccess,
        isFalse,
      );
      expect((await auth.unlockWithBiometrics()).isSuccess, isTrue);
      expect((await auth.switchProfile(demoProfiles[1].id)).isSuccess, isTrue);
      await auth.signOut();
      expect(
        await settings.getSetting('authentication.active_user_id'),
        isNull,
      );
      final serialized = (await audit.getAuditEvents())
          .map((e) => '${e.reason}${e.entityId}')
          .join();
      expect(serialized, isNot(contains('1234')));
      expect(serialized, isNot(contains('0000')));
      final offline = LocalDemoAuthenticationService(
        users: users,
        settings: settings,
        audit: audit,
        clock: clock,
        isOffline: () => true,
      );
      expect(
        (await offline.signInWithDemoProfile(demoProfiles.first.id)).isSuccess,
        isFalse,
      );
    },
  );

  test('repositories filter and expose immutable snapshots', () async {
    expect(await users.getDirectReports(DemoSeedIds.sara), hasLength(3));
    expect(
      await users.getUsersByTeam(DemoSeedIds.technicalSupportQueue),
      hasLength(1),
    );
    final organization = InMemoryOrganizationRepository(store);
    expect(
      await organization.getTeamsByDepartment(DemoSeedIds.operations),
      hasLength(2),
    );
    expect(
      () => (store.users.toList(growable: false)).add(store.users.first),
      throwsUnsupportedError,
    );
  });

  test(
    'all scenarios and their typed references are internally valid',
    () async {
      final scenarioIds = {
        for (var i = 1; i <= 15; i++) DemoSeedIds.scenario(i),
      };
      expect(store.tasks.map((e) => e.id).toSet(), containsAll(scenarioIds));
      final userIds = store.users.map((e) => e.id).toSet();
      final departmentIds = store.departments.map((e) => e.id).toSet();
      final teamIds = store.teams.map((e) => e.id).toSet();
      final categoryIds = store.categories.map((e) => e.id).toSet();
      final priorityIds = store.priorities.map((e) => e.id).toSet();
      final roleIds = store.roles.map((e) => e.id).toSet();
      for (final user in store.users) {
        expect(departmentIds, contains(user.departmentId));
        expect(roleIds, contains(user.roleId));
      }
      for (final membership in store.memberships) {
        expect(userIds, contains(membership.userId));
        expect(teamIds, contains(membership.teamId));
      }
      for (final task in store.tasks) {
        expect(userIds, contains(task.creatorId));
        expect(categoryIds, contains(task.categoryId));
        expect(priorityIds, contains(task.priorityId));
      }
      expect(
        await InMemorySyncRepository(store).getConflictingOperations(),
        hasLength(1),
      );
      expect(
        store.roles.map((e) => e.code),
        containsAll(
          SystemRoleCode.values.where((e) => e != SystemRoleCode.unknown),
        ),
      );
    },
  );
}
