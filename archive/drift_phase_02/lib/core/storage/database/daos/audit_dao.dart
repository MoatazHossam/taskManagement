part of '../app_database.dart';

@DriftAccessor(tables: [AuditEvents])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {

  AuditDao(super.attachedDatabase);

  Future<List<AuditEvent>> getAuditEvents()=>(attachedDatabase.select(attachedDatabase.auditEvents)..orderBy([(t)=>OrderingTerm.desc(t.performedAt)])).get();

  Future<List<AuditEvent>> getAuditEventsForTask(String id)=>(attachedDatabase.select(attachedDatabase.auditEvents)..where((t)=>t.taskId.equals(id))..orderBy([(t)=>OrderingTerm.desc(t.performedAt)])).get();

  Future<List<AuditEvent>> getAuditEventsForEntity(String type,String id)=>(attachedDatabase.select(attachedDatabase.auditEvents)..where((t)=>t.entityType.equals(type)&t.entityId.equals(id))).get();

  Future<void> appendAuditEvent(AuditEventsCompanion v)=>attachedDatabase.into(attachedDatabase.auditEvents).insert(v);
  }
