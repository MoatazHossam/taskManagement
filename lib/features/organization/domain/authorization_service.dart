import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';

abstract interface class AuthorizationService {
  Future<AuthorizationDecision> check({required String userId, required PermissionCode permission, AccessTarget? target});
  Future<Set<PermissionCode>> getEffectivePermissions(String userId);
  Future<bool> hasPermission(String userId, PermissionCode permission);
  Future<AccessScope> getMaximumScope(String userId, PermissionCode permission);
}
