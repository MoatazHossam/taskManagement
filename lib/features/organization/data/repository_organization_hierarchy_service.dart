import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../../../shared/repositories/repositories.dart';
import '../domain/organization_hierarchy_service.dart';
import '../domain/permission_catalog.dart';

final class RepositoryOrganizationHierarchyService
    implements OrganizationHierarchyService {
  const RepositoryOrganizationHierarchyService({
    required this.users,
    required this.organization,
  });
  final UserRepository users;
  final OrganizationRepository organization;

  @override
  Future<List<Department>> getDepartmentPath(String departmentId) async {
    final result = <Department>[];
    final visited = <String>{};
    String? current = departmentId;
    while (current != null && visited.add(current)) {
      final department = await organization.getDepartmentById(current);
      if (department == null) break;
      result.add(department);
      current = department.parentDepartmentId;
    }
    return List.unmodifiable(result.reversed);
  }

  @override
  Future<List<Department>> getDescendantDepartments(String departmentId) async {
    final result = <Department>[];
    final visited = <String>{departmentId};
    final pending = <String>[departmentId];
    while (pending.isNotEmpty) {
      final children = await organization.getChildDepartments(
        pending.removeAt(0),
      );
      children.sort((a, b) => a.code.compareTo(b.code));
      for (final child in children) {
        if (visited.add(child.id)) {
          result.add(child);
          pending.add(child.id);
        }
      }
    }
    return List.unmodifiable(result);
  }

  @override
  Future<List<OrganizationUser>> getDirectReports(String managerId) async {
    final result = await users.getDirectReports(managerId);
    result.sort((a, b) => a.employeeNumber.compareTo(b.employeeNumber));
    return List.unmodifiable(result);
  }

  @override
  Future<List<OrganizationUser>> getAllReports(String managerId) async {
    final result = <OrganizationUser>[];
    final visited = <String>{managerId};
    final pending = <String>[managerId];
    while (pending.isNotEmpty) {
      for (final report in await getDirectReports(pending.removeAt(0))) {
        if (visited.add(report.id)) {
          result.add(report);
          pending.add(report.id);
        }
      }
    }
    return List.unmodifiable(result);
  }

  @override
  Future<List<Team>> getUserTeams(String userId) async {
    final memberships = await organization.getMembershipsForUser(userId);
    final result = <Team>[];
    for (final membership in memberships) {
      final team = await organization.getTeamById(membership.teamId);
      if (team != null) result.add(team);
    }
    result.sort((a, b) => a.code.compareTo(b.code));
    return List.unmodifiable(result);
  }

  @override
  Future<List<OrganizationUser>> getTeamMembers(String teamId) async {
    final memberships = await organization.getTeamMembers(teamId);
    final result = <OrganizationUser>[];
    for (final membership in memberships) {
      final user = await users.getUserById(membership.userId);
      if (user != null) result.add(user);
    }
    result.sort((a, b) => a.employeeNumber.compareTo(b.employeeNumber));
    return List.unmodifiable(result);
  }

  @override
  Future<AccessScope> resolveScope(String userId) async {
    final user = await users.getUserById(userId);
    if (user == null) return AccessScope.self;
    final role = await organization.getRoleById(user.roleId);
    return PermissionCatalog.roleScope(role?.code ?? SystemRoleCode.unknown);
  }

  @override
  Future<OrganizationContext> getUserContext(String userId) async {
    final user = await users.getUserById(userId);
    final root = await organization.getOrganization();
    if (user == null) throw StateError('organization.user_not_found');
    if (root == null) throw StateError('organization.unavailable');
    final role = await organization.getRoleById(user.roleId);
    if (role == null) throw StateError('authorization.role_not_found');
    final department = await organization.getDepartmentById(user.departmentId);
    final manager = user.managerId == null
        ? null
        : await users.getUserById(user.managerId!);
    final memberships = await organization.getMembershipsForUser(user.id);
    final teams = await getUserTeams(user.id);
    final ledIds = memberships
        .where((m) => m.membershipRole == TeamMembershipRole.lead)
        .map((m) => m.teamId)
        .toSet();
    final queueIds = memberships
        .where((m) => m.membershipRole == TeamMembershipRole.queueMember)
        .map((m) => m.teamId)
        .toSet();
    return OrganizationContext(
      user: user,
      role: role,
      organization: root,
      department: department,
      departmentPath: department == null
          ? const []
          : await getDepartmentPath(department.id),
      manager: manager,
      directReports: await getDirectReports(user.id),
      allReports: await getAllReports(user.id),
      teams: teams,
      ledTeams: teams.where((t) => ledIds.contains(t.id)).toList(),
      queueMemberships: teams.where((t) => queueIds.contains(t.id)).toList(),
      effectivePermissions: PermissionCatalog.forRole(role.code) ?? const {},
      maximumAccessScope: await resolveScope(user.id),
    );
  }
}
