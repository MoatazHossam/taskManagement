import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/demo_user_profile.dart';
import '../../core/domain/app_clock.dart';
import '../../core/errors/app_error.dart';
import '../../core/storage/database/app_database.dart';
import '../../core/storage/database/daos/settings_dao.dart';
import '../../core/storage/database/daos/user_dao.dart';
import '../../core/storage/database/daos/organization_dao.dart';
import '../../core/storage/database/daos/task_dao.dart';
import '../../core/storage/database/daos/task_configuration_dao.dart';
import '../../core/storage/database/daos/notification_dao.dart';
import '../../core/storage/database/daos/audit_dao.dart';
import '../../core/storage/database/daos/sync_dao.dart';
import '../../core/storage/database/seed/demo_data_service.dart';
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
  const SessionState(this.status, [this.profile, this.session, this.failure]);
  final AuthenticationStatus status;
  final DemoUserProfile? profile;
  final AuthenticationSession? session;
  final AuthenticationFailure? failure;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController([this.service]) : super(const SessionState(AuthenticationStatus.unauthenticated));
  final AuthenticationService? service;
  void beginProfileSelection() => state = const SessionState(AuthenticationStatus.selectingProfile);
  void authenticate(DemoUserProfile profile) => state = SessionState(AuthenticationStatus.authenticated, profile);
  Future<void> initialize({required bool offline}) async {
    if (service == null) return;
    state = const SessionState(AuthenticationStatus.initializing);
    final session = await service!.restoreSession(offline: offline);
    if (session == null) { state = const SessionState(AuthenticationStatus.unauthenticated); return; }
    final profile = demoProfiles.where((p)=>p.id==session.demoProfileId).firstOrNull;
    state = SessionState(session.requiresUnlock ? AuthenticationStatus.locked : AuthenticationStatus.authenticated, profile, session);
  }
  Future<void> signInProfile(DemoUserProfile profile) async {
    if (service == null) { authenticate(profile); return; }
    state = SessionState(AuthenticationStatus.authenticating, profile);
    _apply(await service!.signInWithDemoProfile(profile.id), profile);
  }
  Future<void> signInCredentials(String username,String password) async {
    state = const SessionState(AuthenticationStatus.authenticating);
    final result=await service!.signInWithDemoCredentials(username:username,password:password);
    final profile=result.session==null?null:demoProfiles.where((p)=>p.id==result.session!.demoProfileId).firstOrNull;
    _apply(result,profile);
  }
  Future<void> unlockPin(String pin) async => _apply(await service!.unlockWithPin(pin),state.profile);
  Future<void> unlockBiometric(bool success) async => _apply(await service!.unlockWithBiometrics(simulateSuccess:success),state.profile);
  void _apply(AuthenticationResult result,DemoUserProfile? profile){
    if(result.isSuccess){state=SessionState(AuthenticationStatus.authenticated,profile,result.session);}
    else {state=SessionState(state.status==AuthenticationStatus.locked?AuthenticationStatus.locked:AuthenticationStatus.failure,profile,state.session,result.failure);}
  }
  Future<void> switchProfile(DemoUserProfile profile) async => _apply(await service!.switchProfile(profile.id),profile);
  Future<void> expire() { state = const SessionState(AuthenticationStatus.expired); return service?.expireSession() ?? Future.value(); }
  Future<void> logout() { state = const SessionState(AuthenticationStatus.unauthenticated); return service?.signOut() ?? Future.value(); }
}

final authenticationServiceProvider=Provider<AuthenticationService>((ref)=>LocalDemoAuthenticationService(users:ref.watch(userRepositoryProvider),settings:ref.watch(settingsRepositoryProvider),audit:ref.watch(auditRepositoryProvider),clock:const SystemAppClock(),isOffline:()=>ref.read(connectivityProvider)==SimulatedConnectivityStatus.offline));
final sessionProvider = StateNotifierProvider<SessionController, SessionState>((ref) => SessionController(ref.watch(authenticationServiceProvider)));
final currentDemoProfileProvider = Provider<DemoUserProfile?>((ref) => ref.watch(sessionProvider).profile);
final activeSessionProvider=Provider<AuthenticationSession?>((ref)=>ref.watch(sessionProvider).session);
final currentOrganizationUserProvider=FutureProvider<OrganizationUser?>((ref) async {final session=ref.watch(activeSessionProvider);if(session==null)return null;await ref.watch(databaseInitializationProvider.future);return ref.watch(userRepositoryProvider).getUserById(session.userId);});
final currentSystemRoleProvider=Provider<DemoUserRole?>((ref){final profile=ref.watch(currentDemoProfileProvider);final session=ref.watch(activeSessionProvider);if(profile==null||session==null||demoProfileUserIds[profile.id]!=session.userId)return null;return profile.role;});
final canRestoreOfflineSessionProvider=FutureProvider<bool>((ref) async {final settings=ref.watch(settingsRepositoryProvider);final value=await settings.getSetting('authentication.offline_expires_at');return value!=null&&DateTime.now().toUtc().isBefore(DateTime.parse(value));});

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
