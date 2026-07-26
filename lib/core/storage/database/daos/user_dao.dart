import 'package:drift/drift.dart';
import '../app_database.dart';
@DriftAccessor()
class UserDao extends DatabaseAccessor<AppDatabase> { UserDao(AppDatabase db):super(db);
 Future<User?> getUserById(String id)=>(db.select(db.users)..where((t)=>t.id.equals(id))).getSingleOrNull(); Future<List<User>> getUsers()=>db.select(db.users).get(); Future<List<User>> getActiveUsers()=>(db.select(db.users)..where((t)=>t.isActive.equals(true))).get(); Future<List<User>> getUsersByDepartment(String id)=>(db.select(db.users)..where((t)=>t.departmentId.equals(id))).get(); Future<List<User>> getDirectReports(String id)=>(db.select(db.users)..where((t)=>t.managerId.equals(id))).get();
 Future<List<User>> getUsersByTeam(String id) async { final q=db.select(db.users).join([innerJoin(db.teamMemberships,db.teamMemberships.userId.equalsExp(db.users.id))]); q.where(db.teamMemberships.teamId.equals(id)&db.teamMemberships.isActive.equals(true)); return (await q.get()).map((r)=>r.readTable(db.users)).toList(); }
 Future<void> insertUser(UsersCompanion v)=>db.into(db.users).insert(v); Future<bool> updateUser(UsersCompanion v)=>db.update(db.users).replace(v); Future<int> deactivateUser(String id,DateTime at)=>(db.update(db.users)..where((t)=>t.id.equals(id))).write(UsersCompanion(isActive:const Value(false),status:const Value('inactive'),updatedAt:Value(at.toUtc())));
}
