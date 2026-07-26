import '../../../core/domain/entities.dart';
import '../../../shared/models/demo_user_profile.dart';

enum AuthenticationSessionStatus { active, locked, expired }
enum AuthenticationUnlockMethod { none, pin, simulatedBiometric }
enum AuthenticationFailure {
  invalidCredentials, inactiveUser, userNotFound, profileMappingMissing,
  roleMismatch, sessionExpired, offlineAccessExpired, pinInvalid,
  tooManyPinAttempts, biometricUnavailable, databaseUnavailable, unknown,
}
enum AuthenticationStateStatus {
  initializing, unauthenticated, selectingLanguage, selectingProfile,
  authenticating, authenticated, locked, expired, failure,
}

class AuthenticationSession {
  const AuthenticationSession({required this.id, required this.userId,
    required this.demoProfileId, required this.systemRoleCode,
    required this.status, required this.createdAt,
    required this.lastAuthenticatedAt, required this.expiresAt,
    required this.offlineAccessExpiresAt, this.isOfflineSession = false,
    this.requiresUnlock = false,
    this.unlockMethod = AuthenticationUnlockMethod.none});
  final String id, userId, demoProfileId, systemRoleCode;
  final AuthenticationSessionStatus status;
  final DateTime createdAt, lastAuthenticatedAt, expiresAt,
      offlineAccessExpiresAt;
  final bool isOfflineSession, requiresUnlock;
  final AuthenticationUnlockMethod unlockMethod;

  AuthenticationSession copyWith({AuthenticationSessionStatus? status,
    DateTime? lastAuthenticatedAt, bool? isOfflineSession,
    bool? requiresUnlock, AuthenticationUnlockMethod? unlockMethod}) =>
      AuthenticationSession(id: id, userId: userId,
        demoProfileId: demoProfileId, systemRoleCode: systemRoleCode,
        status: status ?? this.status, createdAt: createdAt,
        lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
        expiresAt: expiresAt, offlineAccessExpiresAt: offlineAccessExpiresAt,
        isOfflineSession: isOfflineSession ?? this.isOfflineSession,
        requiresUnlock: requiresUnlock ?? this.requiresUnlock,
        unlockMethod: unlockMethod ?? this.unlockMethod);
}

class AuthenticationResult {
  const AuthenticationResult._({this.session, this.failure});
  const AuthenticationResult.success(AuthenticationSession session)
      : this._(session: session);
  const AuthenticationResult.failure(AuthenticationFailure failure)
      : this._(failure: failure);
  final AuthenticationSession? session;
  final AuthenticationFailure? failure;
  bool get isSuccess => session != null;
}

class AuthenticationState {
  const AuthenticationState(this.status, {this.session, this.user,
    this.profile, this.failure, this.pinAttempts = 0});
  final AuthenticationStateStatus status;
  final AuthenticationSession? session;
  final OrganizationUser? user;
  final DemoUserProfile? profile;
  final AuthenticationFailure? failure;
  final int pinAttempts;
}
