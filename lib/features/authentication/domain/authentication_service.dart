import 'authentication_models.dart';

abstract interface class AuthenticationService {
  Future<AuthenticationResult> signInWithDemoCredentials({
    required String username, required String password});
  Future<AuthenticationResult> signInWithDemoProfile(String demoProfileId);
  Future<AuthenticationResult> unlockWithPin(String pin);
  Future<AuthenticationResult> unlockWithBiometrics({bool simulateSuccess = true});
  Future<AuthenticationSession?> restoreSession({required bool offline});
  Future<void> configureUnlock(AuthenticationUnlockMethod method);
  Future<void> expireSession();
  Future<void> signOut();
  Future<AuthenticationResult> switchProfile(String demoProfileId);
}
