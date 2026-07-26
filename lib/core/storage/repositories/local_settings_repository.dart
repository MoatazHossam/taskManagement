import '../../../shared/repositories/repositories.dart';
import '../database/daos/settings_dao.dart';
final class LocalSettingsRepository implements SettingsRepository { const LocalSettingsRepository(this.dao); final SettingsDao dao; @override Future<String?> getSetting(String key)=>dao.read(key); @override Future<void> saveSetting(String key,String value)=>dao.write(key,value); @override Future<void> removeSetting(String key)=>dao.remove(key); }
