import 'package:drift/drift.dart';
import '../../../shared/repositories/repositories.dart';
import '../database/app_database.dart';
final class LocalSettingsRepository implements SettingsRepository { const LocalSettingsRepository(this.dao); final SettingsDao dao; @override Future<String?> getSetting(String key) async=>(await dao.get(key))?.value; @override Future<Map<String,String>> getAllSettings() async=>{for(final r in await dao.getAll())r.key:r.value}; @override Future<void> saveSetting(String key,String value)=>dao.upsert(AppSettingsCompanion.insert(key:key,value:value,updatedAt:DateTime.now().toUtc())); @override Future<void> removeSetting(String key) async {await dao.remove(key);} }
