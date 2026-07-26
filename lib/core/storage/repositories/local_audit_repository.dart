import '../../../shared/repositories/repositories.dart';
import '../../domain/entities.dart';
import '../database/app_database.dart';
import '../database/mappers/audit_sync_mappers.dart';
final class LocalAuditRepository implements AuditRepository { const LocalAuditRepository(this.dao); final AuditDao dao; @override Future<List<AuditEvent>> getAuditEvents() async=>(await dao.getAuditEvents()).map((e)=>e.toAuditEventDomain()).toList(); @override Future<List<AuditEvent>> getAuditEventsForTask(String id) async=>(await dao.getAuditEventsForTask(id)).map((e)=>e.toAuditEventDomain()).toList(); @override Future<List<AuditEvent>> getAuditEventsForEntity(String type,String id) async=>(await dao.getAuditEventsForEntity(type,id)).map((e)=>e.toAuditEventDomain()).toList(); @override Future<void> appendAuditEvent(AuditEvent e)=>dao.appendAuditEvent(e.toCompanion()); }
