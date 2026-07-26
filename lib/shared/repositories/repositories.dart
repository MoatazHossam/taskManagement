import '../../core/domain/entities.dart';
import '../../core/domain/authorization_models.dart';
import '../../core/domain/domain_enums.dart';

abstract interface class UserRepository {
  Future<OrganizationUser?> getUserById(String id);
  Future<List<OrganizationUser>> getUsers();
  Future<List<OrganizationUser>> getActiveUsers();
  Future<List<OrganizationUser>> getUsersByDepartment(String id);
  Future<List<OrganizationUser>> getDirectReports(String managerId);
  Future<List<OrganizationUser>> getUsersByTeam(String teamId);
}

abstract interface class OrganizationRepository {
  Future<Organization?> getOrganization();
  Future<List<Department>> getDepartments();
  Future<Department?> getDepartmentById(String id);
  Future<List<Department>> getChildDepartments(String id);
  Future<List<Team>> getTeams();
  Future<Team?> getTeamById(String id);
  Future<List<Team>> getTeamsByDepartment(String id);
  Future<List<TeamMembership>> getTeamMembers(String teamId);
  Future<List<TeamMembership>> getMembershipsForUser(String userId);
  Future<List<Role>> getRoles();
  Future<Role?> getRoleById(String id);
  Future<List<Permission>> getPermissions();
  Future<List<RolePermission>> getRolePermissions(String roleId);
}

abstract interface class TaskRepository {
  Future<Task?> getTaskById(String id);
  Future<Task?> getTaskByNumber(String number);
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksForUser(String id);
  Future<List<Task>> getTasksForTeam(String id);
  Future<List<Task>> getTasksByBatch(String id);
  Future<List<Task>> getSubtasks(String id);
  Future<List<TaskAssignment>> getTaskAssignments(String id);
  Future<List<ChecklistItem>> getChecklistItems(String id);
  Future<List<TaskComment>> getComments(String id);
  Future<List<TaskAttachment>> getAttachments(String id);
  Future<List<TaskBlocker>> getBlockers(String id);
  Future<List<DeadlineExtensionRequest>> getExtensionRequests(String id);
  Future<List<TaskApproval>> getApprovals(String id);
  Future<void> insertTaskRecord(Task task);
  Future<void> updateTaskRecord(Task task);
  Future<void> insertAssignments(List<TaskAssignment> values);
}

abstract interface class TaskConfigurationRepository {
  Future<List<TaskPriority>> getPriorities();
  Future<TaskPriority?> getPriorityById(String id);
  Future<List<TaskCategory>> getCategories();
  Future<TaskCategory?> getCategoryById(String id);
  Future<List<ConfidentialityLevel>> getConfidentialityLevels();
  Future<List<ApprovalRule>> getApprovalRules();
  Future<List<EscalationRule>> getEscalationRules();
  Future<List<NotificationTemplate>> getNotificationTemplates();
  Future<List<TaskTemplate>> getTaskTemplates();
}

abstract interface class NotificationRepository {
  Future<List<AppNotification>> getNotificationsForUser(String id);
  Future<List<AppNotification>> getUnreadNotificationsForUser(String id);
  Future<int> getUnreadCount(String id);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
}

abstract interface class AuditRepository {
  Future<List<AuditEvent>> getAuditEvents();
  Future<List<AuditEvent>> getAuditEventsForTask(String id);
  Future<List<AuditEvent>> getAuditEventsForEntity(String type, String id);
  Future<void> appendAuditEvent(AuditEvent event);
}

abstract interface class SyncRepository {
  Future<List<SyncOperation>> getPendingOperations();
  Future<List<SyncOperation>> getFailedOperations();
  Future<List<SyncOperation>> getConflictingOperations();
  Future<void> appendOperation(SyncOperation operation);
  Future<void> updateOperationStatus(String id, SyncOperationStatus status);
  Future<void> incrementRetryCount(String id);
}

abstract interface class SettingsRepository {
  Future<String?> getSetting(String key);
  Future<Map<String, String>> getAllSettings();
  Future<void> saveSetting(String key, String value);
  Future<void> removeSetting(String key);
}

abstract interface class PermissionOverrideRepository {
  Future<List<PermissionOverride>> getOverridesForUser(String userId);
}
