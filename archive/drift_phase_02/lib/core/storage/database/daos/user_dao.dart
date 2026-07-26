part of '../app_database.dart';

@DriftAccessor(tables: [Users, TeamMemberships])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {

  UserDao(super.attachedDatabase);
 Future<User?> getUserById(String id)=>(attachedDatabase.select(attachedDatabase.users)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<List<User>> getUsers()=>attachedDatabase.select(attachedDatabase.users).get();

  Future<List<User>> getActiveUsers()=>(attachedDatabase.select(attachedDatabase.users)..where((t)=>t.isActive.equals(true))).get();

  Future<List<User>> getUsersByDepartment(String id)=>(attachedDatabase.select(attachedDatabase.users)..where((t)=>t.departmentId.equals(id))).get();

  Future<List<User>> getDirectReports(String id)=>(attachedDatabase.select(attachedDatabase.users)..where((t)=>t.managerId.equals(id))).get();
 Future<List<User>> getUsersByTeam(String id) async {
  final q=attachedDatabase.select(attachedDatabase.users).join([innerJoin(attachedDatabase.teamMemberships,attachedDatabase.teamMemberships.userId.equalsExp(attachedDatabase.users.id))]); q.where(attachedDatabase.teamMemberships.teamId.equals(id)&attachedDatabase.teamMemberships.isActive.equals(true)); return (await q.get()).map((r)=>r.readTable(attachedDatabase.users)).toList();
  }
 Future<void> insertUser(UsersCompanion v)=>attachedDatabase.into(attachedDatabase.users).insert(v);

  Future<bool> updateUser(UsersCompanion v)=>attachedDatabase.update(attachedDatabase.users).replace(v);

  Future<int> deactivateUser(String id,DateTime at)=>(attachedDatabase.update(attachedDatabase.users)..where((t)=>t.id.equals(id))).write(UsersCompanion(isActive:const Value(false),status:const Value('inactive'),updatedAt:Value(at.toUtc())));
}
