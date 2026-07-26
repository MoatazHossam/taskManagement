import 'package:drift/drift.dart';
import '../app_database.dart';
@DriftAccessor()
class SettingsDao extends DatabaseAccessor<AppDatabase> { SettingsDao(AppDatabase db):super(db);
 Future<AppSetting?> get(String key)=>(db.select(db.appSettings)..where((t)=>t.key.equals(key))).getSingleOrNull();
 Future<List<AppSetting>> getAll()=>db.select(db.appSettings).get();
 Future<void> upsert(AppSettingsCompanion value)=>db.into(db.appSettings).insertOnConflictUpdate(value);
 Future<int> remove(String key)=>(db.delete(db.appSettings)..where((t)=>t.key.equals(key))).go();
}
