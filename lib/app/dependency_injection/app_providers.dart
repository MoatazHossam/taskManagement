import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/demo_user_profile.dart';

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
