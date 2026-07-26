import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/entities.dart';

abstract interface class OrganizationHierarchyService {
  Future<OrganizationContext> getUserContext(String userId);
  Future<List<Department>> getDepartmentPath(String departmentId);
  Future<List<Department>> getDescendantDepartments(String departmentId);
  Future<List<OrganizationUser>> getDirectReports(String managerId);
  Future<List<OrganizationUser>> getAllReports(String managerId);
  Future<List<Team>> getUserTeams(String userId);
  Future<List<OrganizationUser>> getTeamMembers(String teamId);
  Future<AccessScope> resolveScope(String userId);
}
