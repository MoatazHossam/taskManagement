part of '../app_database.dart';

@DriftAccessor(tables: [Priorities, Categories, ConfidentialityLevels, ApprovalRules, EscalationRules, NotificationTemplates, TaskTemplates])
class TaskConfigurationDao extends DatabaseAccessor<AppDatabase> with _$TaskConfigurationDaoMixin {

  TaskConfigurationDao(super.attachedDatabase);
 Future<List<Priority>> getPriorities()=>attachedDatabase.select(attachedDatabase.priorities).get();

  Future<Priority?> getPriorityById(String id)=>(attachedDatabase.select(attachedDatabase.priorities)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<List<Category>> getCategories()=>attachedDatabase.select(attachedDatabase.categories).get();

  Future<Category?> getCategoryById(String id)=>(attachedDatabase.select(attachedDatabase.categories)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<List<ConfidentialityLevel>> getConfidentialityLevels()=>attachedDatabase.select(attachedDatabase.confidentialityLevels).get();

  Future<List<ApprovalRule>> getApprovalRules()=>attachedDatabase.select(attachedDatabase.approvalRules).get();

  Future<List<EscalationRule>> getEscalationRules()=>attachedDatabase.select(attachedDatabase.escalationRules).get();

  Future<List<NotificationTemplate>> getNotificationTemplates()=>attachedDatabase.select(attachedDatabase.notificationTemplates).get();

  Future<List<TaskTemplate>> getTaskTemplates()=>attachedDatabase.select(attachedDatabase.taskTemplates).get();
  }
