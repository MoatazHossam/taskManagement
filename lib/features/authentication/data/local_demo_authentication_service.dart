import '../../../core/domain/app_clock.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../../../core/demo/demo_seed_ids.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/demo_profile_user_mapping.dart';
import '../../../shared/models/demo_user_profile.dart';
import '../../../shared/repositories/repositories.dart';
import '../domain/authentication_models.dart';
import '../domain/authentication_service.dart';
import 'demo_authentication_config.dart';

final class LocalDemoAuthenticationService implements AuthenticationService {
  LocalDemoAuthenticationService({required this.users, required this.settings,
    required this.audit, required this.clock, required this.isOffline});
  final UserRepository users;
  final SettingsRepository settings;
  final AuditRepository audit;
  final AppClock clock;
  final bool Function() isOffline;
  AuthenticationSession? _active;
  int _pinAttempts = 0;

  static const _prefix = 'authentication.';
  static DemoUserRole _roleForId(String roleId) => switch (roleId) {
    DemoSeedIds.roleEmployee => DemoUserRole.employee,
    DemoSeedIds.roleManager => DemoUserRole.manager,
    DemoSeedIds.roleSenior => DemoUserRole.seniorManagement,
    DemoSeedIds.roleAdministrator => DemoUserRole.administrator,
    _ => throw StateError('Unknown role'),
  };

  @override
  Future<AuthenticationResult> signInWithDemoCredentials({required String username,
      required String password}) async {
    final profile = DemoAuthenticationConfig.credentialProfiles[username.trim().toLowerCase()];
    if (profile == null || password != DemoAuthenticationConfig.demoPassword) {
      await _event(AuditEventType.authenticationLoginFailed,
          DemoSeedIds.laila, 'invalid_credentials');
      return const AuthenticationResult.failure(AuthenticationFailure.invalidCredentials);
    }
    if (isOffline()) {
      await _event(AuditEventType.authenticationOfflineDenied,
          seededUserIdForDemoProfile(demoProfiles.firstWhere((p) => p.id == profile)),
          'new_login_offline');
      return const AuthenticationResult.failure(AuthenticationFailure.offlineAccessExpired);
    }
    return _authenticate(profile, AuditEventType.authenticationLoginSucceeded);
  }

  @override
  Future<AuthenticationResult> signInWithDemoProfile(String demoProfileId) async {
    if (isOffline()) {
      return const AuthenticationResult.failure(AuthenticationFailure.offlineAccessExpired);
    }
    return _authenticate(demoProfileId, AuditEventType.authenticationProfileSelected);
  }

  Future<AuthenticationResult> _authenticate(String profileId,
      AuditEventType event) async {
    try {
      final matches = demoProfiles.where((p) => p.id == profileId).toList();
      if (matches.length != 1 || !demoProfileUserIds.containsKey(profileId)) {
        return const AuthenticationResult.failure(AuthenticationFailure.profileMappingMissing);
      }
      final profile = matches.single;
      final userId = demoProfileUserIds[profileId]!;
      final user = await users.getUserById(userId);
      if (user == null) return const AuthenticationResult.failure(AuthenticationFailure.userNotFound);
      if (user.status != UserStatus.active) {
        await _event(AuditEventType.authenticationLoginFailed, user.id, 'inactive_user');
        return const AuthenticationResult.failure(AuthenticationFailure.inactiveUser);
      }
      final repositoryRole = _roleForId(user.roleId);
      if (repositoryRole != profile.role) {
        await _event(AuditEventType.authenticationLoginFailed, user.id, 'role_mismatch');
        return const AuthenticationResult.failure(AuthenticationFailure.roleMismatch);
      }
      final now = clock.now().toUtc();
      final session = AuthenticationSession(id: 'auth-${now.microsecondsSinceEpoch}',
        userId: user.id, demoProfileId: profileId,
        systemRoleCode: _roleCode(repositoryRole),
        status: AuthenticationSessionStatus.active, createdAt: now,
        lastAuthenticatedAt: now,
        expiresAt: now.add(DemoAuthenticationConfig.sessionDuration),
        offlineAccessExpiresAt: now.add(DemoAuthenticationConfig.offlineAccessDuration));
      _active = session;
      await _persist(session);
      await _event(event, user.id, event.code, session.id);
      return AuthenticationResult.success(session);
    } catch (_) {
      return const AuthenticationResult.failure(AuthenticationFailure.databaseUnavailable);
    }
  }

  @override
  Future<AuthenticationSession?> restoreSession({required bool offline}) async {
    try {
      final values = await settings.getAllSettings();
      final userId = values['${_prefix}active_user_id'];
      final profileId = values['${_prefix}last_profile_id'];
      if (userId == null || profileId == null) return null;
      if (values['${_prefix}status'] == 'expired') return null;
      final user = await users.getUserById(userId);
      if (user == null || user.status != UserStatus.active ||
          demoProfileUserIds[profileId] != userId) {
        await _clearActiveSessionSettings();
        return null;
      }
      final repositoryRoleCode = _roleCode(_roleForId(user.roleId));
      if (values['${_prefix}role_code'] != repositoryRoleCode) {
        await _clearActiveSessionSettings();
        return null;
      }
      final now = clock.now().toUtc();
      final expires = DateTime.parse(values['${_prefix}expires_at']!).toUtc();
      final offlineExpires =
          DateTime.parse(values['${_prefix}offline_expires_at']!).toUtc();
      if (!now.isBefore(expires)) {
        await expireSession();
        return null;
      }
      if (offline && !now.isBefore(offlineExpires)) {
        await _event(AuditEventType.authenticationOfflineDenied, userId,
            'offline_access_expired');
        return null;
      }
      final method = AuthenticationUnlockMethod.values.byName(
          values['${_prefix}unlock_method'] ?? 'none');
      final session = AuthenticationSession(
        id: values['${_prefix}session_id']!, userId: userId,
        demoProfileId: profileId, systemRoleCode: _roleCode(_roleForId(user.roleId)),
        status: method == AuthenticationUnlockMethod.none
            ? AuthenticationSessionStatus.active : AuthenticationSessionStatus.locked,
        createdAt: DateTime.parse(values['${_prefix}created_at']!).toUtc(),
        lastAuthenticatedAt:
            DateTime.parse(values['${_prefix}last_authenticated_at']!).toUtc(),
        expiresAt: expires, offlineAccessExpiresAt: offlineExpires,
        isOfflineSession: offline, requiresUnlock: method != AuthenticationUnlockMethod.none,
        unlockMethod: method);
      _active = session;
      await _event(offline ? AuditEventType.authenticationOfflineUsed
          : AuditEventType.authenticationSessionRestored, userId, 'session_restored', session.id);
      return session;
    } catch (_) {
      await _clearActiveSessionSettings();
      return null;
    }
  }

  @override
  Future<AuthenticationResult> unlockWithPin(String pin) async {
    final session = _active;
    if (session == null) return const AuthenticationResult.failure(AuthenticationFailure.sessionExpired);
    if (_pinAttempts >= DemoAuthenticationConfig.maximumPinAttempts) {
      return const AuthenticationResult.failure(AuthenticationFailure.tooManyPinAttempts);
    }
    if (pin != DemoAuthenticationConfig.demoPin) {
      _pinAttempts++;
      await _event(AuditEventType.authenticationPinFailed, session.userId, 'pin_failed', session.id);
      return AuthenticationResult.failure(_pinAttempts >= DemoAuthenticationConfig.maximumPinAttempts
          ? AuthenticationFailure.tooManyPinAttempts : AuthenticationFailure.pinInvalid);
    }
    _pinAttempts = 0;
    _active = session.copyWith(status: AuthenticationSessionStatus.active,
      requiresUnlock: false, lastAuthenticatedAt: clock.now().toUtc());
    await _event(AuditEventType.authenticationPinSucceeded, session.userId, 'pin_succeeded', session.id);
    return AuthenticationResult.success(_active!);
  }

  @override
  Future<AuthenticationResult> unlockWithBiometrics({bool simulateSuccess = true}) async {
    final session = _active;
    if (session == null) return const AuthenticationResult.failure(AuthenticationFailure.sessionExpired);
    if (!simulateSuccess) {
      await _event(AuditEventType.authenticationBiometricFailed, session.userId, 'simulation_failed', session.id);
      return const AuthenticationResult.failure(AuthenticationFailure.biometricUnavailable);
    }
    _active = session.copyWith(status: AuthenticationSessionStatus.active, requiresUnlock: false);
    await _event(AuditEventType.authenticationBiometricSucceeded, session.userId, 'simulation_succeeded', session.id);
    return AuthenticationResult.success(_active!);
  }

  @override
  Future<void> configureUnlock(AuthenticationUnlockMethod method) async {
    if (_active == null) return;
    _active = _active!.copyWith(unlockMethod: method);
    await settings.saveSetting('${_prefix}unlock_method', method.name);
  }

  @override
  Future<void> expireSession() async {
    if (_active != null) await _event(AuditEventType.authenticationSessionExpired,
        _active!.userId, 'session_expired', _active!.id);
    await settings.saveSetting('${_prefix}status', 'expired');
    _active = null;
  }

  @override
  Future<void> signOut() async {
    if (_active != null) await _event(AuditEventType.authenticationLogout,
        _active!.userId, 'logout', _active!.id);
    await _clearActiveSessionSettings();
    _active = null;
  }

  @override
  Future<AuthenticationResult> switchProfile(String demoProfileId) async {
    final old = _active;
    if (old != null) {
      final nextUserId = demoProfileUserIds[demoProfileId];
      await _event(
        AuditEventType.authenticationProfileSwitched,
        old.userId,
        'profile_switched',
        nextUserId == null ? old.userId : '${old.userId}:$nextUserId',
      );
    }
    await signOut();
    return signInWithDemoProfile(demoProfileId);
  }

  Future<void> _persist(AuthenticationSession session) async {
    final values = <String,String>{'session_id':session.id,
      'active_user_id':session.userId,'last_profile_id':session.demoProfileId,
      'role_code':session.systemRoleCode,
      'status':session.status.name,'created_at':session.createdAt.toIso8601String(),
      'last_authenticated_at':session.lastAuthenticatedAt.toIso8601String(),
      'expires_at':session.expiresAt.toIso8601String(),
      'offline_expires_at':session.offlineAccessExpiresAt.toIso8601String(),
      'unlock_method':session.unlockMethod.name};
    for (final entry in values.entries) await settings.saveSetting('$_prefix${entry.key}', entry.value);
  }

  Future<void> _clearActiveSessionSettings() async {
    for (final key in const [
      'active_user_id',
      'session_id',
      'role_code',
      'status',
      'created_at',
      'last_authenticated_at',
      'expires_at',
      'offline_expires_at',
      'unlock_method',
    ]) {
      await settings.removeSetting('$_prefix$key');
    }
  }

  Future<void> _event(AuditEventType type, String userId, String reason,
      [String? entityId]) async {
    try {
      await audit.appendAuditEvent(AuditEvent(
        id: 'auth-audit-${clock.now().toUtc().microsecondsSinceEpoch}-${type.code}',
        entityType: 'authentication_session',
        entityId: entityId ?? userId,
        eventType: type,
        performedBy: userId,
        performedAt: clock.now().toUtc(),
        reason: reason,
      ));
    } catch (_) {
      // Authentication remains deterministic when local audit persistence fails.
      // No storage exception or credential input is allowed to reach the UI.
    }
  }

  static String _roleCode(DemoUserRole role) => switch(role) {
    DemoUserRole.employee => 'employee', DemoUserRole.manager => 'manager',
    DemoUserRole.seniorManagement => 'senior_management',
    DemoUserRole.administrator => 'administrator'};
}
