import 'dart:collection';

import 'domain_enums.dart';
import 'entities.dart';

enum AccessScope { self, team, department, organization, administration }

enum PermissionOverrideEffect { allow, deny }

enum ConfidentialityCode { public, internal, confidential, restricted }

class PermissionOverride {
  const PermissionOverride({
    required this.userId,
    required this.permissionCode,
    required this.effect,
    required this.reason,
    this.scope,
  });
  final String userId;
  final PermissionCode permissionCode;
  final PermissionOverrideEffect effect;
  final String reason;
  final AccessScope? scope;
}

class AccessTarget {
  const AccessTarget({
    this.ownerUserId,
    this.departmentId,
    this.teamId,
    this.organizationId,
    this.confidentialityCode = ConfidentialityCode.public,
    this.isPersonal = false,
  });
  final String? ownerUserId, departmentId, teamId, organizationId;
  final ConfidentialityCode confidentialityCode;
  final bool isPersonal;
}

enum AuthorizationReasonCode {
  granted,
  userNotFound,
  roleNotFound,
  permissionMissing,
  explicitDeny,
  insufficientScope,
  differentOrganization,
  confidentialityRestricted,
  queueMembershipMissing,
  unknown,
}

class AuthorizationDecision {
  const AuthorizationDecision({
    required this.allowed,
    required this.permission,
    required this.requiredScope,
    required this.effectiveScope,
    required this.reasonCode,
    required this.localizedReasonKey,
  });
  final bool allowed;
  final PermissionCode permission;
  final AccessScope requiredScope, effectiveScope;
  final AuthorizationReasonCode reasonCode;
  final String localizedReasonKey;
}

class OrganizationContext {
  OrganizationContext({
    required this.user,
    required this.role,
    required this.organization,
    this.department,
    List<Department> departmentPath = const [],
    this.manager,
    List<OrganizationUser> directReports = const [],
    List<OrganizationUser> allReports = const [],
    List<Team> teams = const [],
    List<Team> ledTeams = const [],
    List<Team> queueMemberships = const [],
    Set<PermissionCode> effectivePermissions = const {},
    required this.maximumAccessScope,
  }) : departmentPath = List.unmodifiable(departmentPath),
       directReports = List.unmodifiable(directReports),
       allReports = List.unmodifiable(allReports),
       teams = List.unmodifiable(teams),
       ledTeams = List.unmodifiable(ledTeams),
       queueMemberships = List.unmodifiable(queueMemberships),
       effectivePermissions = UnmodifiableSetView(Set.of(effectivePermissions));
  final OrganizationUser user;
  final Role role;
  final Organization organization;
  final Department? department;
  final List<Department> departmentPath;
  final OrganizationUser? manager;
  final List<OrganizationUser> directReports, allReports;
  final List<Team> teams, ledTeams, queueMemberships;
  final Set<PermissionCode> effectivePermissions;
  final AccessScope maximumAccessScope;
}
