part of '../app_database.dart';

@DriftAccessor(tables: [Departments, Teams, TeamMemberships])
class OrganizationDao extends DatabaseAccessor<AppDatabase> with _$OrganizationDaoMixin {

  OrganizationDao(super.attachedDatabase);
 Future<List<Department>> getDepartments()=>attachedDatabase.select(attachedDatabase.departments).get();

  Future<Department?> getDepartmentById(String id)=>(attachedDatabase.select(attachedDatabase.departments)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<List<Department>> getChildDepartments(String id)=>(attachedDatabase.select(attachedDatabase.departments)..where((t)=>t.parentDepartmentId.equals(id))).get();

  Future<List<Team>> getTeams()=>attachedDatabase.select(attachedDatabase.teams).get();

  Future<Team?> getTeamById(String id)=>(attachedDatabase.select(attachedDatabase.teams)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<List<Team>> getTeamsByDepartment(String id)=>(attachedDatabase.select(attachedDatabase.teams)..where((t)=>t.departmentId.equals(id))).get();

  Future<List<TeamMembership>> getTeamMembers(String id)=>(attachedDatabase.select(attachedDatabase.teamMemberships)..where((t)=>t.teamId.equals(id))).get();

  Future<TeamMembership?> getActiveTeamMembership(String team,String user)=>(attachedDatabase.select(attachedDatabase.teamMemberships)..where((t)=>t.teamId.equals(team)&t.userId.equals(user)&t.isActive.equals(true))).getSingleOrNull();
 Future<void> insertDepartment(DepartmentsCompanion v)=>attachedDatabase.into(attachedDatabase.departments).insert(v);

  Future<void> insertTeam(TeamsCompanion v)=>attachedDatabase.into(attachedDatabase.teams).insert(v);

  Future<void> insertTeamMembership(TeamMembershipsCompanion v)=>attachedDatabase.into(attachedDatabase.teamMemberships).insert(v);
}
