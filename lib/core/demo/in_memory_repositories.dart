import 'dart:collection';

import '../../shared/repositories/repositories.dart';
import '../domain/domain_enums.dart';
import '../domain/entities.dart';
import 'demo_data_store.dart';

List<T> _copy<T>(Iterable<T> values) => List<T>.unmodifiable(values);

final class InMemoryUserRepository implements UserRepository {
  const InMemoryUserRepository(this.store);
  final DemoDataStore store;
  @override Future<OrganizationUser?> getUserById(String id) async => store.users.where((e) => e.id == id).firstOrNull;
  @override Future<List<OrganizationUser>> getUsers() async => _copy(store.users);
  @override Future<List<OrganizationUser>> getActiveUsers() async => _copy(store.users.where((e) => e.status == UserStatus.active));
  @override Future<List<OrganizationUser>> getUsersByDepartment(String id) async => _copy(store.users.where((e) => e.departmentId == id));
  @override Future<List<OrganizationUser>> getDirectReports(String managerId) async => _copy(store.users.where((e) => e.managerId == managerId));
  @override Future<List<OrganizationUser>> getUsersByTeam(String teamId) async { final ids = store.memberships.where((e) => e.teamId == teamId && e.leftAt == null).map((e) => e.userId).toSet(); return _copy(store.users.where((e) => ids.contains(e.id))); }
}

final class InMemoryOrganizationRepository implements OrganizationRepository {
  const InMemoryOrganizationRepository(this.store); final DemoDataStore store;
  @override Future<List<Department>> getDepartments() async => _copy(store.departments);
  @override Future<Department?> getDepartmentById(String id) async => store.departments.where((e) => e.id == id).firstOrNull;
  @override Future<List<Department>> getChildDepartments(String id) async => _copy(store.departments.where((e) => e.parentDepartmentId == id));
  @override Future<List<Team>> getTeams() async => _copy(store.teams);
  @override Future<List<Team>> getTeamsByDepartment(String id) async => _copy(store.teams.where((e) => e.departmentId == id));
  @override Future<List<TeamMembership>> getTeamMembers(String teamId) async => _copy(store.memberships.where((e) => e.teamId == teamId && e.leftAt == null));
}

final class InMemoryTaskRepository implements TaskRepository {
  const InMemoryTaskRepository(this.store); final DemoDataStore store;
  @override Future<Task?> getTaskById(String id) async => store.tasks.where((e) => e.id == id).firstOrNull;
  @override Future<Task?> getTaskByNumber(String number) async => store.tasks.where((e) => e.taskNumber == number).firstOrNull;
  @override Future<List<Task>> getTasks() async => _copy(store.tasks);
  @override Future<List<Task>> getTasksForUser(String id) async { final ids=store.assignments.where((e)=>e.userId==id).map((e)=>e.taskId).toSet(); return _copy(store.tasks.where((e)=>ids.contains(e.id))); }
  @override Future<List<Task>> getTasksForTeam(String id) async => _copy(store.tasks.where((e)=>e.assignedTeamId==id));
  @override Future<List<Task>> getTasksByBatch(String id) async => _copy(store.tasks.where((e)=>e.batchId==id));
  @override Future<List<Task>> getSubtasks(String id) async => _copy(store.tasks.where((e)=>e.parentTaskId==id));
  @override Future<List<TaskAssignment>> getTaskAssignments(String id) async => _copy(store.assignments.where((e)=>e.taskId==id));
  @override Future<List<ChecklistItem>> getChecklistItems(String id) async => _copy(store.checklistItems.where((e)=>e.taskId==id));
  @override Future<List<TaskComment>> getComments(String id) async => _copy(store.comments.where((e)=>e.taskId==id));
  @override Future<List<TaskAttachment>> getAttachments(String id) async => _copy(store.attachments.where((e)=>e.taskId==id));
  @override Future<List<TaskBlocker>> getBlockers(String id) async => _copy(store.blockers.where((e)=>e.taskId==id));
  @override Future<List<DeadlineExtensionRequest>> getExtensionRequests(String id) async => _copy(store.extensionRequests.where((e)=>e.taskId==id));
  @override Future<List<TaskApproval>> getApprovals(String id) async => _copy(store.approvals.where((e)=>e.taskId==id));
  @override Future<void> insertTaskRecord(Task task) async { if (store.tasks.any((e)=>e.id==task.id)) throw StateError('Duplicate task ${task.id}'); store.tasks.add(task); }
  @override Future<void> updateTaskRecord(Task task) async { final index=store.tasks.indexWhere((e)=>e.id==task.id); if(index<0) throw StateError('Unknown task ${task.id}'); store.tasks[index]=task; }
  @override Future<void> insertAssignments(List<TaskAssignment> values) async => store.assignments.addAll(values);
}

final class InMemoryTaskConfigurationRepository implements TaskConfigurationRepository {
  const InMemoryTaskConfigurationRepository(this.store); final DemoDataStore store;
  @override Future<List<TaskPriority>> getPriorities() async=>_copy(store.priorities);
  @override Future<TaskPriority?> getPriorityById(String id) async=>store.priorities.where((e)=>e.id==id).firstOrNull;
  @override Future<List<TaskCategory>> getCategories() async=>_copy(store.categories);
  @override Future<TaskCategory?> getCategoryById(String id) async=>store.categories.where((e)=>e.id==id).firstOrNull;
  @override Future<List<ConfidentialityLevel>> getConfidentialityLevels() async=>_copy(store.confidentialityLevels);
  @override Future<List<ApprovalRule>> getApprovalRules() async=>_copy(store.approvalRules);
  @override Future<List<EscalationRule>> getEscalationRules() async=>_copy(store.escalationRules);
  @override Future<List<NotificationTemplate>> getNotificationTemplates() async=>_copy(store.notificationTemplates);
  @override Future<List<TaskTemplate>> getTaskTemplates() async=>_copy(store.taskTemplates);
}

final class InMemoryNotificationRepository implements NotificationRepository {
  const InMemoryNotificationRepository(this.store); final DemoDataStore store;
  @override Future<List<AppNotification>> getNotificationsForUser(String id) async=>_copy(store.notifications.where((e)=>e.recipientId==id));
  @override Future<List<AppNotification>> getUnreadNotificationsForUser(String id) async=>_copy(store.notifications.where((e)=>e.recipientId==id&&!e.isRead));
  @override Future<int> getUnreadCount(String id) async=>(await getUnreadNotificationsForUser(id)).length;
  @override Future<void> markAsRead(String id) async { final i=store.notifications.indexWhere((e)=>e.id==id); if(i>=0){final e=store.notifications[i];store.notifications[i]=AppNotification(id:e.id,recipientId:e.recipientId,type:e.type,titleAr:e.titleAr,titleEn:e.titleEn,messageAr:e.messageAr,messageEn:e.messageEn,taskId:e.taskId,createdAt:e.createdAt,isRead:true,deliveryChannel:e.deliveryChannel,deliveryStatus:e.deliveryStatus);} }
  @override Future<void> markAllAsRead(String userId) async { for(final e in _copy(store.notifications.where((e)=>e.recipientId==userId&&!e.isRead))) { await markAsRead(e.id); } }
}

final class InMemoryAuditRepository implements AuditRepository {
  const InMemoryAuditRepository(this.store); final DemoDataStore store;
  @override Future<List<AuditEvent>> getAuditEvents() async=>_copy(store.auditEvents);
  @override Future<List<AuditEvent>> getAuditEventsForTask(String id) async=>_copy(store.auditEvents.where((e)=>e.taskId==id));
  @override Future<List<AuditEvent>> getAuditEventsForEntity(String type,String id) async=>_copy(store.auditEvents.where((e)=>e.entityType==type&&e.entityId==id));
  @override Future<void> appendAuditEvent(AuditEvent event) async=>store.auditEvents.add(event);
}

final class InMemorySyncRepository implements SyncRepository {
  const InMemorySyncRepository(this.store); final DemoDataStore store;
  @override Future<List<SyncOperation>> getPendingOperations() async=>_copy(store.syncOperations.where((e)=>e.status==SyncOperationStatus.pending));
  @override Future<List<SyncOperation>> getFailedOperations() async=>_copy(store.syncOperations.where((e)=>e.status==SyncOperationStatus.failed));
  @override Future<List<SyncOperation>> getConflictingOperations() async=>_copy(store.syncOperations.where((e)=>e.status==SyncOperationStatus.conflict));
  @override Future<void> appendOperation(SyncOperation operation) async=>store.syncOperations.add(operation);
  @override Future<void> updateOperationStatus(String id,SyncOperationStatus status) async { final i=store.syncOperations.indexWhere((e)=>e.id==id); if(i<0)return; final e=store.syncOperations[i];store.syncOperations[i]=SyncOperation(id:e.id,entityType:e.entityType,entityId:e.entityId,operationType:e.operationType,payloadJson:e.payloadJson,createdAt:e.createdAt,status:status,conflictType:e.conflictType); }
  @override Future<void> incrementRetryCount(String id) async { /* Retry counts are not part of the active domain model. */ }
}

final class InMemorySettingsRepository implements SettingsRepository {
  const InMemorySettingsRepository(this.store); final DemoDataStore store;
  @override Future<String?> getSetting(String key) async=>store.settings[key];
  @override Future<Map<String,String>> getAllSettings() async=>UnmodifiableMapView(Map.of(store.settings));
  @override Future<void> saveSetting(String key,String value) async{store.settings[key]=value;}
  @override Future<void> removeSetting(String key) async{store.settings.remove(key);}
  Future<void> clear() async=>store.settings.clear();
  Future<void> clearAuthenticationSession() async=>store.settings.removeWhere((key,_)=>key.startsWith('authentication.'));
}
