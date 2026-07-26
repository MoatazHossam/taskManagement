part of '../app_database.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {

  SettingsDao(super.attachedDatabase);
 Future<AppSetting?> get(String key)=>(attachedDatabase.select(attachedDatabase.appSettings)..where((t)=>t.key.equals(key))).getSingleOrNull();
 Future<List<AppSetting>> getAll()=>attachedDatabase.select(attachedDatabase.appSettings).get();
 Future<void> upsert(AppSettingsCompanion value)=>attachedDatabase.into(attachedDatabase.appSettings).insertOnConflictUpdate(value);
 Future<int> remove(String key)=>(attachedDatabase.delete(attachedDatabase.appSettings)..where((t)=>t.key.equals(key))).go();
}
