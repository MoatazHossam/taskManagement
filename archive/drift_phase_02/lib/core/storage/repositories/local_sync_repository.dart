import '../../../shared/repositories/repositories.dart';
import '../../domain/entities.dart';
import '../../domain/domain_enums.dart';
import '../../domain/app_clock.dart';
import '../database/app_database.dart';
import '../database/mappers/audit_sync_mappers.dart';
final class LocalSyncRepository implements SyncRepository { const LocalSyncRepository(this.dao,this.clock); final SyncDao dao; final AppClock clock; @override Future<List<SyncOperation>> getPendingOperations() async=>(await dao.getPendingOperations()).map((e)=>e.toSyncOperationDomain()).toList(); @override Future<List<SyncOperation>> getFailedOperations() async=>(await dao.getFailedOperations()).map((e)=>e.toSyncOperationDomain()).toList(); @override Future<List<SyncOperation>> getConflictingOperations() async=>(await dao.getConflictingOperations()).map((e)=>e.toSyncOperationDomain()).toList(); @override Future<void> appendOperation(SyncOperation e)=>dao.appendOperation(e.toCompanion()); @override Future<void> updateOperationStatus(String id,SyncOperationStatus s) async {await dao.updateOperationStatus(id,s.code);} @override Future<void> incrementRetryCount(String id) async {await dao.incrementRetryCount(id,clock.now());} }
