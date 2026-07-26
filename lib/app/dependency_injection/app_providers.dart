import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/demo_user_profile.dart';
import '../../core/domain/app_clock.dart';
import '../../core/storage/database/app_database.dart';
import '../../core/storage/database/daos/settings_dao.dart';
import '../../core/storage/database/seed/demo_data_service.dart';
import '../../core/storage/repositories/local_settings_repository.dart';
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
final settingsRepositoryProvider = Provider<SettingsRepository>((ref)=>LocalSettingsRepository(SettingsDao(ref.watch(appDatabaseProvider))));
