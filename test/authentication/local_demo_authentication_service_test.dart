import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/core/storage/database/app_database.dart';
import 'package:organization_task_manager/core/storage/database/daos/audit_dao.dart';
import 'package:organization_task_manager/core/storage/database/daos/settings_dao.dart';
import 'package:organization_task_manager/core/storage/database/daos/user_dao.dart';
import 'package:organization_task_manager/core/storage/database/seed/demo_data_service.dart';
import 'package:organization_task_manager/core/storage/repositories/local_audit_repository.dart';
import 'package:organization_task_manager/core/storage/repositories/local_settings_repository.dart';
import 'package:organization_task_manager/core/storage/repositories/local_user_repository.dart';
import 'package:organization_task_manager/features/authentication/data/local_demo_authentication_service.dart';
import 'package:organization_task_manager/features/authentication/domain/authentication_models.dart';
import 'package:organization_task_manager/shared/models/demo_user_profile.dart';

void main() {
  late AppDatabase database;
  late LocalDemoAuthenticationService service;
  late FixedAppClock clock;
  var offline = false;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FixedAppClock(DateTime.utc(2026, 7, 26, 10));
    await DemoDataService(database, clock).ensureSeeded();
    service = LocalDemoAuthenticationService(
      users: LocalUserRepository(UserDao(database)),
      settings: LocalSettingsRepository(SettingsDao(database)),
      audit: LocalAuditRepository(AuditDao(database)),
      clock: clock,
      isOffline: () => offline,
    );
  });
  tearDown(() => database.close());

  test('profile and credentials resolve authoritative seeded users', () async {
    final employee = await service.signInWithDemoProfile('employee');
    expect(employee.session?.userId, 'user-ahmed-hassan');
    expect(employee.session?.systemRoleCode, 'employee');
    await service.signOut();
    final manager = await service.signInWithDemoCredentials(
      username: 'manager', password: 'demo123');
    expect(manager.session?.userId, 'user-sara-mahmoud');
    expect(manager.session?.systemRoleCode, 'manager');
  });

  test('all five profiles and credential aliases resolve seeded identities', () async {
    const credentials = <String, String>{
      'employee': 'employee',
      'manager': 'manager',
      'executive': 'senior',
      'admin': 'administrator',
      'support': 'queue',
    };
    for (final profile in demoProfiles) {
      final result = await service.signInWithDemoProfile(profile.id);
      expect(result.isSuccess, isTrue, reason: profile.id);
      await service.signOut();
    }
    for (final entry in credentials.entries) {
      final result = await service.signInWithDemoCredentials(
        username: entry.key,
        password: 'demo123',
      );
      expect(result.session?.demoProfileId, entry.value);
      await service.signOut();
    }
  });

  test('invalid credentials are rejected and never audited', () async {
    final result = await service.signInWithDemoCredentials(
      username: 'employee', password: 'secret-value');
    expect(result.failure, AuthenticationFailure.invalidCredentials);
    final rows = await database.select(database.auditEvents).get();
    expect(rows.map((row) => row.reason).join(), isNot(contains('secret-value')));
    expect(rows.map((row) => row.reason).join(), isNot(contains('1234')));
  });

  test('audit and settings serialization contain no credential material', () async {
    await service.signInWithDemoCredentials(
      username: 'employee',
      password: 'demo123',
    );
    await service.unlockWithPin('9876');
    await service.unlockWithPin('1234');
    final settings = await database.select(database.appSettings).get();
    final audits = await database.select(database.auditEvents).get();
    final serialized = [
      ...settings.expand((row) => [row.key, row.value]),
      ...audits.expand((row) => [row.reason ?? '', row.entityId]),
    ].join('|').toLowerCase();
    for (final forbidden in ['demo123', '1234', '9876', 'password']) {
      expect(serialized, isNot(contains(forbidden)));
    }
  });

  test('malformed and partially missing persisted sessions fail closed', () async {
    await service.signInWithDemoProfile('employee');
    await database.into(database.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'authentication.expires_at',
        value: 'not-a-date',
        updatedAt: clock.now(),
      ),
    );
    expect(await service.restoreSession(offline: false), isNull);
    expect(
      await LocalSettingsRepository(SettingsDao(database))
          .getSetting('authentication.active_user_id'),
      isNull,
    );

    await service.signInWithDemoProfile('employee');
    await LocalSettingsRepository(SettingsDao(database))
        .removeSetting('authentication.session_id');
    expect(await service.restoreSession(offline: false), isNull);
  });

  test('session restores, locks, unlocks and expires locally', () async {
    expect((await service.signInWithDemoProfile('employee')).isSuccess, isTrue);
    await service.configureUnlock(AuthenticationUnlockMethod.pin);
    final restored = await service.restoreSession(offline: false);
    expect(restored?.requiresUnlock, isTrue);
    expect((await service.unlockWithPin('0000')).failure,
      AuthenticationFailure.pinInvalid);
    expect((await service.unlockWithPin('1234')).isSuccess, isTrue);
    await service.expireSession();
    expect(await service.restoreSession(offline: false), isNull);
  });

  test('offline allows only a valid previously authenticated session', () async {
    expect((await service.signInWithDemoProfile('employee')).isSuccess, isTrue);
    offline = true;
    expect((await service.restoreSession(offline: true))?.isOfflineSession, isTrue);
    expect((await service.signInWithDemoCredentials(
      username: 'manager', password: 'demo123')).failure,
      AuthenticationFailure.offlineAccessExpired);
  });

  test('biometric simulation and profile switching replace identity', () async {
    await service.signInWithDemoProfile('employee');
    expect((await service.unlockWithBiometrics(simulateSuccess: false)).failure,
      AuthenticationFailure.biometricUnavailable);
    expect((await service.unlockWithBiometrics()).isSuccess, isTrue);
    final switched = await service.switchProfile('administrator');
    expect(switched.session?.userId, 'user-laila-youssef');
    expect(switched.session?.systemRoleCode, 'administrator');
  });
}
