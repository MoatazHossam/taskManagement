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

final localeProvider = StateProvider<Locale?>((ref) => null);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final connectivityProvider = StateProvider<SimulatedConnectivityStatus>((ref) => SimulatedConnectivityStatus.online);

class SessionState {
  const SessionState(this.status, [this.profile]);
  final AuthenticationStatus status;
  final DemoUserProfile? profile;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState(AuthenticationStatus.unauthenticated));
  void beginProfileSelection() => state = const SessionState(AuthenticationStatus.selectingProfile);
  void authenticate(DemoUserProfile profile) => state = SessionState(AuthenticationStatus.authenticated, profile);
  void expire() => state = const SessionState(AuthenticationStatus.expired);
  void logout() => state = const SessionState(AuthenticationStatus.unauthenticated);
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>((ref) => SessionController());
final currentDemoProfileProvider = Provider<DemoUserProfile?>((ref) => ref.watch(sessionProvider).profile);

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
