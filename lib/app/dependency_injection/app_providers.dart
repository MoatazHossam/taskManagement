import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/demo_user_profile.dart';
import '../../core/domain/app_clock.dart';
import '../../core/errors/app_error.dart';
import '../../core/storage/database/app_database.dart';
import '../../core/storage/database/seed/demo_data_service.dart';
import '../../core/storage/database/seed/demo_seed_ids.dart';
import '../../core/storage/repositories/local_settings_repository.dart';
import '../../core/storage/repositories/local_user_repository.dart';
import '../../core/storage/repositories/local_organization_repository.dart';
import '../../core/storage/repositories/local_task_repository.dart';
import '../../core/storage/repositories/local_configuration_repository.dart';
import '../../core/storage/repositories/local_notification_repository.dart';
import '../../core/storage/repositories/local_audit_repository.dart';
import '../../core/storage/repositories/local_sync_repository.dart';
import '../../shared/repositories/repositories.dart';
import '../../core/domain/entities.dart';
import '../../features/authentication/data/local_demo_authentication_service.dart';
import '../../features/authentication/domain/authentication_models.dart';
import '../../features/authentication/domain/authentication_service.dart';
import '../../shared/models/demo_profile_user_mapping.dart';

final localeProvider = StateProvider<Locale?>((ref) => null);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final connectivityProvider = StateProvider<SimulatedConnectivityStatus>((ref) => SimulatedConnectivityStatus.online);

class SessionState {
  const SessionState(
    this.status, {
    this.profile,
    this.session,
    this.user,
    this.role,
    this.failure,
  });
  final AuthenticationStatus status;
  final DemoUserProfile? profile;
  final AuthenticationSession? session;
  final OrganizationUser? user;
  final DemoUserRole? role;
  final AuthenticationFailure? failure;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController([this.service, this.users])
      : super(const SessionState(AuthenticationStatus.initializing));
  final AuthenticationService? service;
  final UserRepository? users;
  Future<void>? _initialization;

  void beginProfileSelection() => state = const SessionState(AuthenticationStatus.selectingProfile);
  void authenticate(DemoUserProfile profile) => state = SessionState(
        AuthenticationStatus.authenticated,
        profile: profile,
        role: profile.role,
      );

  /// Restores at most once for this controller. The composition root awaits the
  /// database gate before calling this method.
  Future<void> initialize({required bool offline}) =>
      _initialization ??= _initialize(offline: offline);

  Future<void> _initialize({required bool offline}) async {
    if (service == null) {
      state = const SessionState(AuthenticationStatus.unauthenticated);
      return;
    }
    final session = await service!.restoreSession(offline: offline);
    if (session == null) {
      state = const SessionState(AuthenticationStatus.unauthenticated);
      return;
    }
    await _apply(AuthenticationResult.success(session));
  }

  Future<void> signInProfile(DemoUserProfile profile) async {
    if (service == null) {
      authenticate(profile);
      return;
    }
    state = SessionState(AuthenticationStatus.authenticating, profile: profile);
    await _apply(await service!.signInWithDemoProfile(profile.id));
  }

  Future<void> signInCredentials(String username, String password) async {
    state = const SessionState(AuthenticationStatus.authenticating);
    await _apply(await service!.signInWithDemoCredentials(
      username: username,
      password: password,
    ));
  }

  Future<void> unlockPin(String pin) async =>
      _apply(await service!.unlockWithPin(pin));
  Future<void> unlockBiometric(bool success) async => _apply(
        await service!.unlockWithBiometrics(simulateSuccess: success),
      );

  Future<void> _apply(AuthenticationResult result) async {
    if (!result.isSuccess) {
      state = SessionState(
        state.status == AuthenticationStatus.locked
            ? AuthenticationStatus.locked
            : AuthenticationStatus.failure,
        profile: state.profile,
        session: state.session,
        user: state.user,
        role: state.role,
        failure: result.failure,
      );
      return;
    }
    final session = result.session!;
    final profile = demoProfiles
        .where((candidate) => candidate.id == session.demoProfileId)
        .firstOrNull;
    final user = await users?.getUserById(session.userId);
    final role = user == null ? profile?.role : _databaseRole(user.roleId);
    if (profile == null || role == null || profile.role != role) {
      await service?.signOut();
      state = const SessionState(
        AuthenticationStatus.failure,
        failure: AuthenticationFailure.roleMismatch,
      );
      return;
    }
    state = SessionState(
      session.requiresUnlock
          ? AuthenticationStatus.locked
          : AuthenticationStatus.authenticated,
      profile: profile,
      session: session,
      user: user,
      role: role,
    );
  }

  Future<void> switchProfile(DemoUserProfile profile) async =>
      _apply(await service!.switchProfile(profile.id));
  Future<void> expire() {
    state = const SessionState(AuthenticationStatus.expired);
    return service?.expireSession() ?? Future.value();
  }

  Future<void> logout() {
    state = const SessionState(AuthenticationStatus.unauthenticated);
    return service?.signOut() ?? Future.value();
  }
}

final authenticationServiceProvider=Provider<AuthenticationService>((ref)=>LocalDemoAuthenticationService(users:ref.watch(userRepositoryProvider),settings:ref.watch(settingsRepositoryProvider),audit:ref.watch(auditRepositoryProvider),clock:const SystemAppClock(),isOffline:()=>ref.read(connectivityProvider)==SimulatedConnectivityStatus.offline));
final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(
    ref.watch(authenticationServiceProvider),
    ref.watch(userRepositoryProvider),
  ),
);
final currentDemoProfileProvider = Provider<DemoUserProfile?>((ref) => ref.watch(sessionProvider).profile);
final activeSessionProvider=Provider<AuthenticationSession?>((ref)=>ref.watch(sessionProvider).session);
final currentOrganizationUserProvider = Provider<OrganizationUser?>((ref) => ref.watch(sessionProvider).user);
final currentSystemRoleProvider = Provider<DemoUserRole?>((ref) => ref.watch(sessionProvider).role);
final canRestoreOfflineSessionProvider = FutureProvider<bool>((ref) async {
  final value = await ref
      .watch(settingsRepositoryProvider)
      .getSetting('authentication.offline_expires_at');
  if (value == null) return false;
  final expiry = DateTime.tryParse(value)?.toUtc();
  return expiry != null && DateTime.now().toUtc().isBefore(expiry);
});

// Phase 02 infrastructure providers. Presentation consumes repository contracts,
// never these Drift implementation details directly.
final appDatabaseProvider = Provider<AppDatabase>((ref) { final database=AppDatabase(); ref.onDispose(database.close); return database; });
final demoDataServiceProvider = Provider<DemoDataService>((ref)=>DemoDataService(ref.watch(appDatabaseProvider),const SystemAppClock()));
final userRepositoryProvider=Provider<UserRepository>((ref)=>LocalUserRepository(UserDao(ref.watch(appDatabaseProvider))));
final organizationRepositoryProvider=Provider<OrganizationRepository>((ref)=>LocalOrganizationRepository(OrganizationDao(ref.watch(appDatabaseProvider))));
final taskRepositoryProvider=Provider<TaskRepository>((ref)=>LocalTaskRepository(TaskDao(ref.watch(appDatabaseProvider))));
final taskConfigurationRepositoryProvider=Provider<TaskConfigurationRepository>((ref)=>LocalTaskConfigurationRepository(TaskConfigurationDao(ref.watch(appDatabaseProvider))));
final notificationRepositoryProvider=Provider<NotificationRepository>((ref)=>LocalNotificationRepository(NotificationDao(ref.watch(appDatabaseProvider)),const SystemAppClock()));
final auditRepositoryProvider=Provider<AuditRepository>((ref)=>LocalAuditRepository(AuditDao(ref.watch(appDatabaseProvider))));
final syncRepositoryProvider=Provider<SyncRepository>((ref)=>LocalSyncRepository(SyncDao(ref.watch(appDatabaseProvider)),const SystemAppClock()));
final settingsRepositoryProvider = Provider<SettingsRepository>((ref)=>LocalSettingsRepository(SettingsDao(ref.watch(appDatabaseProvider))));

final databaseInitializationProvider=FutureProvider<void>((ref) async {
 try { await ref.read(demoDataServiceProvider).ensureSeeded(); }
 catch (_) { throw const DataLayerException(); }
});

DemoUserRole? _databaseRole(String roleId) => switch (roleId) {
  DemoSeedIds.roleEmployee => DemoUserRole.employee,
  DemoSeedIds.roleManager => DemoUserRole.manager,
  DemoSeedIds.roleSenior => DemoUserRole.seniorManagement,
  DemoSeedIds.roleAdministrator => DemoUserRole.administrator,
  _ => null,
};
