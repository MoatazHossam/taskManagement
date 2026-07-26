part of '../app_database.dart';

@DriftAccessor(tables: [SyncOperations])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {

  SyncDao(super.attachedDatabase);

  Future<List<SyncOperation>> _by(String s)=>(attachedDatabase.select(attachedDatabase.syncOperations)..where((t)=>t.status.equals(s))..orderBy([(t)=>OrderingTerm.asc(t.createdAt)])).get();

  Future<List<SyncOperation>> getPendingOperations()=>_by('pending');

  Future<List<SyncOperation>> getFailedOperations()=>_by('failed');

  Future<List<SyncOperation>> getConflictingOperations()=>_by('conflict');

  Future<void> appendOperation(SyncOperationsCompanion v)=>attachedDatabase.into(attachedDatabase.syncOperations).insert(v);

  Future<int> updateOperationStatus(String id,String status,{String? errorMessage})=>(attachedDatabase.update(attachedDatabase.syncOperations)..where((t)=>t.id.equals(id))).write(SyncOperationsCompanion(status:Value(status),errorMessage:Value(errorMessage)));

  Future<int> incrementRetryCount(String id,DateTime at)=>(attachedDatabase.customUpdate('UPDATE sync_operations SET retry_count=retry_count+1,last_attempt_at=? WHERE id=?',variables:[Variable(at.toUtc()),Variable(id)],updates:{attachedDatabase.syncOperations}));
  }
