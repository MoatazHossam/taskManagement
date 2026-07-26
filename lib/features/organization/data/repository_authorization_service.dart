import 'dart:collection';

import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../shared/repositories/repositories.dart';
import '../domain/authorization_service.dart';
import '../domain/organization_hierarchy_service.dart';
import '../domain/permission_catalog.dart';

final class RepositoryAuthorizationService implements AuthorizationService {
  const RepositoryAuthorizationService({required this.users, required this.organization, required this.hierarchy, required this.overrides});
  final UserRepository users;
  final OrganizationRepository organization;
  final OrganizationHierarchyService hierarchy;
  final PermissionOverrideRepository overrides;

  @override
  Future<Set<PermissionCode>> getEffectivePermissions(String userId) async {
    final user = await users.getUserById(userId);
    if (user == null) return const {};
    final role = await organization.getRoleById(user.roleId);
    final rolePermissions = PermissionCatalog.forRole(role?.code ?? SystemRoleCode.unknown);
    if (rolePermissions == null) return const {};
    final result = Set<PermissionCode>.of(rolePermissions);
    final memberships = await organization.getMembershipsForUser(userId);
    if (memberships.any((m) => m.membershipRole == TeamMembershipRole.queueMember)) {
      result.addAll({PermissionCode.taskClaimTeamQueue, PermissionCode.taskReleaseTeamQueue});
    }
    for (final override in await overrides.getOverridesForUser(userId)) {
      if (override.effect == PermissionOverrideEffect.deny) { result.remove(override.permissionCode); } else { result.add(override.permissionCode); }
    }
    return UnmodifiableSetView(result);
  }

  @override
  Future<bool> hasPermission(String userId, PermissionCode permission) async => (await check(userId: userId, permission: permission)).allowed;

  @override
  Future<AccessScope> getMaximumScope(String userId, PermissionCode permission) async {
    final user = await users.getUserById(userId);
    final role = user == null ? null : await organization.getRoleById(user.roleId);
    if (role == null) return AccessScope.self;
    final explicit = (await overrides.getOverridesForUser(userId)).where((o) => o.permissionCode == permission && o.effect == PermissionOverrideEffect.allow).firstOrNull;
    if (explicit?.scope != null) return explicit!.scope!;
    if (permission.code.startsWith('admin.')) return AccessScope.administration;
    if (permission == PermissionCode.taskClaimTeamQueue || permission == PermissionCode.taskReleaseTeamQueue || permission.code.endsWith('_team')) return AccessScope.team;
    if (permission.code.contains('department')) return AccessScope.department;
    if (permission.code.contains('organization') || permission == PermissionCode.organizationViewAll || permission == PermissionCode.directoryViewUsers || permission == PermissionCode.directoryViewReportingLines) return AccessScope.organization;
    return PermissionCatalog.roleScope(role.code) == AccessScope.administration ? AccessScope.organization : PermissionCatalog.roleScope(role.code);
  }

  @override
  Future<AuthorizationDecision> check({required String userId, required PermissionCode permission, AccessTarget? target}) async {
    if (permission == PermissionCode.unknown || !PermissionCatalog.all.contains(permission)) return _deny(permission, AuthorizationReasonCode.permissionMissing);
    final user = await users.getUserById(userId);
    if (user == null) return _deny(permission, AuthorizationReasonCode.userNotFound);
    final role = await organization.getRoleById(user.roleId);
    if (role == null || PermissionCatalog.forRole(role.code) == null) return _deny(permission, AuthorizationReasonCode.roleNotFound);
    final userOverrides = await overrides.getOverridesForUser(userId);
    if (userOverrides.any((o) => o.permissionCode == permission && o.effect == PermissionOverrideEffect.deny)) return _deny(permission, AuthorizationReasonCode.explicitDeny);
    final effective = await getEffectivePermissions(userId);
    if (!effective.contains(permission)) return _deny(permission, AuthorizationReasonCode.permissionMissing);
    final scope = await getMaximumScope(userId, permission);
    if (target == null) return _allow(permission, scope, AccessScope.self);
    if (target.confidentialityCode == ConfidentialityCode.restricted && !effective.contains(PermissionCode.taskViewRestricted)) return _deny(permission, AuthorizationReasonCode.confidentialityRestricted, scope);
    if (target.confidentialityCode == ConfidentialityCode.confidential && target.ownerUserId != userId && !effective.contains(PermissionCode.taskViewConfidential)) return _deny(permission, AuthorizationReasonCode.confidentialityRestricted, scope);
    final root = await organization.getOrganization();
    if (target.confidentialityCode == ConfidentialityCode.internal && target.organizationId != null && target.organizationId != root?.id) return _deny(permission, AuthorizationReasonCode.differentOrganization, scope);
    if (permission == PermissionCode.taskClaimTeamQueue || permission == PermissionCode.taskReleaseTeamQueue) {
      final memberships = await organization.getMembershipsForUser(userId);
      final member = memberships.any((m) => m.teamId == target.teamId && m.membershipRole == TeamMembershipRole.queueMember);
      final team = target.teamId == null ? null : await organization.getTeamById(target.teamId!);
      return member && team?.isQueueEnabled == true ? _allow(permission, scope, AccessScope.team) : _deny(permission, AuthorizationReasonCode.queueMembershipMissing, scope);
    }
    final required = await _requiredScope(userId, target);
    if (_rank(scope) < _rank(required)) return _deny(permission, AuthorizationReasonCode.insufficientScope, scope, required);
    return _allow(permission, scope, required);
  }

  Future<AccessScope> _requiredScope(String userId, AccessTarget target) async {
    if (target.isPersonal || target.ownerUserId == userId) return AccessScope.self;
    final memberships = await organization.getMembershipsForUser(userId);
    if (target.teamId != null && memberships.any((m) => m.teamId == target.teamId)) return AccessScope.team;
    final user = await users.getUserById(userId);
    if (target.departmentId == user?.departmentId) return AccessScope.department;
    if (user != null && target.departmentId != null && (await hierarchy.getDescendantDepartments(user.departmentId)).any((d) => d.id == target.departmentId)) return AccessScope.department;
    return AccessScope.organization;
  }

  int _rank(AccessScope value) => switch (value) { AccessScope.self => 0, AccessScope.team => 1, AccessScope.department => 2, AccessScope.organization || AccessScope.administration => 3 };
  AuthorizationDecision _allow(PermissionCode permission, AccessScope scope, AccessScope required) => AuthorizationDecision(allowed: true, permission: permission, requiredScope: required, effectiveScope: scope, reasonCode: AuthorizationReasonCode.granted, localizedReasonKey: 'permissionGranted');
  AuthorizationDecision _deny(PermissionCode permission, AuthorizationReasonCode reason, [AccessScope effective = AccessScope.self, AccessScope required = AccessScope.self]) => AuthorizationDecision(allowed: false, permission: permission, requiredScope: required, effectiveScope: effective, reasonCode: reason, localizedReasonKey: reason == AuthorizationReasonCode.insufficientScope ? 'insufficientScope' : 'permissionDenied');
}
