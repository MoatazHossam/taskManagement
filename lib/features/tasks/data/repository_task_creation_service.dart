import '../../../core/domain/app_clock.dart';
import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../../../shared/repositories/repositories.dart';
import '../../organization/domain/authorization_service.dart';
import '../domain/task_creation_models.dart';
import '../domain/task_creation_service.dart';
import '../domain/task_identity_service.dart';

final class RepositoryTaskCreationService implements TaskCreationService {
  RepositoryTaskCreationService({required this.tasks, required this.users, required this.organization, required this.configuration, required this.audit, required this.sync, required this.authorization, required this.identities, required this.clock});
  final TaskRepository tasks;
  final UserRepository users;
  final OrganizationRepository organization;
  final TaskConfigurationRepository configuration;
  final AuditRepository audit;
  final SyncRepository sync;
  final AuthorizationService authorization;
  final TaskIdentityService identities;
  final AppClock clock;

  @override
  Future<TaskCreationDefaults> getDefaults({required String userId}) async {
    final user = await users.getUserById(userId);
    if (user == null) throw StateError('user_missing');
    final canOthers = await authorization.hasPermission(userId, PermissionCode.taskCreateForOthers);
    final canSelf = await authorization.hasPermission(userId, PermissionCode.taskCreateSelf);
    if (!canOthers && !canSelf) throw StateError('permission_denied');
    final priorities = await configuration.getPriorities();
    final confidentiality = await configuration.getConfidentialityLevels();
    final now = clock.now().toUtc();
    return TaskCreationDefaults(ownerLocked: !canOthers, draft: TaskDraft(creatorId: userId, ownerUserId: canOthers ? null : userId, departmentId: user.departmentId, priorityId: priorities.where((e) => e.code == 'normal').firstOrNull?.id, confidentialityLevelId: confidentiality.where((e) => e.code == 'internal').firstOrNull?.id, createdAt: now, updatedAt: now));
  }

  @override
  Future<TaskCreationOptions> getOptions({required String userId}) async {
    final permissions = await authorization.getEffectivePermissions(userId);
    final canOthers = permissions.contains(PermissionCode.taskCreateForOthers);
    final levels = await configuration.getConfidentialityLevels();
    return TaskCreationOptions(priorities: await configuration.getPriorities(), categories: await configuration.getCategories(), confidentialityLevels: levels.where((e) => e.code != 'restricted' || permissions.contains(PermissionCode.taskViewRestricted)).toList(growable: false), templates: await configuration.getTaskTemplates(), ownerCandidates: canOthers ? await users.getActiveUsers() : [if (await users.getUserById(userId) case final user?) user], ownerLocked: !canOthers);
  }

  @override
  Future<TaskValidationResult> validate({required String userId, required TaskDraft draft}) => _validate(userId, draft, submitting: true);

  Future<TaskValidationResult> _validate(String userId, TaskDraft draft, {required bool submitting}) async {
    final issues = <TaskValidationIssue>[];
    final actor = await users.getUserById(userId);
    final creator = await users.getUserById(draft.creatorId);
    final permissions = await authorization.getEffectivePermissions(userId);
    final canOthers = permissions.contains(PermissionCode.taskCreateForOthers);
    final canAssignSelf = permissions.contains(PermissionCode.taskAssignSelf);
    if (actor == null || creator == null || draft.creatorId != userId) issues.add(const TaskValidationIssue(TaskValidationCode.creatorMissing, 'currentUserMissing', field: 'creator'));
    if (!canOthers && !permissions.contains(PermissionCode.taskCreateSelf)) issues.add(const TaskValidationIssue(TaskValidationCode.ownerNotAllowed, 'permissionDenied'));
    if (!canOthers && !canAssignSelf) issues.add(const TaskValidationIssue(TaskValidationCode.ownerNotAllowed, 'permissionDenied'));
    if (draft.assignmentMode != AssignmentMode.singleOwner) issues.add(const TaskValidationIssue(TaskValidationCode.assignmentModeInvalid, 'singleOwnerOnly'));
    if (!canOthers && draft.ownerUserId != userId) issues.add(const TaskValidationIssue(TaskValidationCode.ownerNotAllowed, 'selfOwnerOnly', field: 'owner'));
    if (draft.isPersonal && draft.ownerUserId != userId) issues.add(const TaskValidationIssue(TaskValidationCode.ownerNotAllowed, 'selfOwnerOnly', field: 'owner'));
    final owner = draft.ownerUserId == null ? null : await users.getUserById(draft.ownerUserId!);
    if (submitting && draft.ownerUserId == null) issues.add(const TaskValidationIssue(TaskValidationCode.ownerMissing, 'ownerRequired', field: 'owner'));
    if (owner != null && owner.status != UserStatus.active) issues.add(const TaskValidationIssue(TaskValidationCode.ownerInactive, 'ownerInactive', field: 'owner'));
    if (owner != null && canOthers) {
      final root = await organization.getOrganization();
      final decision = await authorization.check(userId: userId, permission: PermissionCode.taskAssignOrganization, target: AccessTarget(ownerUserId: owner.id, departmentId: owner.departmentId, organizationId: root?.id));
      if (!decision.allowed) issues.add(const TaskValidationIssue(TaskValidationCode.ownerNotAllowed, 'ownerNotPermitted', field: 'owner'));
    }
    final ar = draft.titleAr.trim(), en = draft.titleEn.trim();
    if (submitting && ar.isEmpty && en.isEmpty) issues.add(const TaskValidationIssue(TaskValidationCode.titleRequired, 'taskTitleRequired', field: 'title'));
    if (ar.length > 150 || en.length > 150) issues.add(const TaskValidationIssue(TaskValidationCode.titleTooLong, 'taskTitleTooLong', field: 'title'));
    if (draft.descriptionAr.length > 4000 || draft.descriptionEn.length > 4000) issues.add(const TaskValidationIssue(TaskValidationCode.descriptionTooLong, 'taskDescriptionTooLong', field: 'description'));
    if (submitting && (draft.categoryId == null || await configuration.getCategoryById(draft.categoryId!) == null)) issues.add(const TaskValidationIssue(TaskValidationCode.categoryMissing, 'categoryRequired', field: 'category'));
    if (submitting && (draft.priorityId == null || await configuration.getPriorityById(draft.priorityId!) == null)) issues.add(const TaskValidationIssue(TaskValidationCode.priorityMissing, 'priorityRequired', field: 'priority'));
    final levels = await configuration.getConfidentialityLevels();
    final level = levels.where((e) => e.id == draft.confidentialityLevelId).firstOrNull;
    if (submitting && level == null) issues.add(const TaskValidationIssue(TaskValidationCode.confidentialityMissing, 'confidentialityRequired', field: 'confidentiality'));
    if (level?.code == 'restricted' && !permissions.contains(PermissionCode.taskViewRestricted)) issues.add(const TaskValidationIssue(TaskValidationCode.confidentialityNotAllowed, 'confidentialityNotPermitted', field: 'confidentiality'));
    if (draft.plannedStart != null && draft.dueDate != null && draft.dueDate!.isBefore(draft.plannedStart!)) issues.add(const TaskValidationIssue(TaskValidationCode.dueDateBeforeStart, 'dueBeforeStart', field: 'dueDate'));
    if (submitting && draft.dueDate != null && draft.dueDate!.isBefore(clock.now())) issues.add(const TaskValidationIssue(TaskValidationCode.dueDateInPast, 'dueInPast', field: 'dueDate'));
    if (draft.estimatedEffortMinutes != null && draft.estimatedEffortMinutes! <= 0) issues.add(const TaskValidationIssue(TaskValidationCode.effortInvalid, 'effortInvalid', field: 'effort'));
    return TaskValidationResult(List.unmodifiable(issues));
  }

  @override
  Future<TaskCreationResult> saveDraft({required String userId, required TaskDraft draft}) async {
    final permission = await _validate(userId, draft, submitting: false);
    if (permission.issues.any((e) => e.code == TaskValidationCode.creatorMissing || e.code == TaskValidationCode.ownerNotAllowed || e.code == TaskValidationCode.assignmentModeInvalid)) return _failure(permission, TaskCreationResultStatus.permissionDenied, 'permission_denied');
    try { return await _persist(userId, draft, submitted: false); } catch (_) { return const TaskCreationResult(status: TaskCreationResultStatus.repositoryFailure, reasonCode: 'repository_failure', messageKey: 'submissionFailed'); }
  }

  @override
  Future<TaskCreationResult> submit({required String userId, required TaskDraft draft}) async {
    if (draft.id != null) { final existing = await tasks.getTaskById(draft.id!); if (existing != null && existing.status != TaskStatus.draft) return const TaskCreationResult(status: TaskCreationResultStatus.duplicateSubmission, reasonCode: 'duplicate_submission', messageKey: 'duplicateSubmission'); }
    final validation = await validate(userId: userId, draft: draft);
    if (!validation.isValid) return _failure(validation, TaskCreationResultStatus.validationFailure, 'validation_failure');
    try { return await _persist(userId, draft, submitted: true); } catch (_) { return const TaskCreationResult(status: TaskCreationResultStatus.repositoryFailure, reasonCode: 'repository_failure', messageKey: 'submissionFailed'); }
  }

  TaskCreationResult _failure(TaskValidationResult validation, TaskCreationResultStatus status, String reason) => TaskCreationResult(status: status, issues: validation.issues, reasonCode: reason, messageKey: validation.issues.firstOrNull?.messageKey ?? 'submissionFailed');

  Future<TaskCreationResult> _persist(String userId, TaskDraft draft, {required bool submitted}) async {
    final now = clock.now().toUtc(), id = draft.id ?? identities.nextTaskId(), number = draft.taskNumber ?? identities.nextTaskNumber();
    final existing = await tasks.getTaskById(id);
    if (existing != null && existing.creatorId != userId) return const TaskCreationResult(status: TaskCreationResultStatus.permissionDenied, reasonCode: 'draft_owner_mismatch', messageKey: 'permissionDenied');
    final creator = (await users.getUserById(userId))!;
    final role = await organization.getRoleById(creator.roleId);
    final task = Task(id: id, taskNumber: number, titleAr: draft.titleAr.trim(), titleEn: draft.titleEn.trim().isEmpty ? null : draft.titleEn.trim(), descriptionAr: draft.descriptionAr.trim(), descriptionEn: draft.descriptionEn.trim().isEmpty ? null : draft.descriptionEn.trim(), creatorId: userId, creatorRoleCode: role?.code ?? SystemRoleCode.unknown, creationSource: draft.templateId == null ? TaskCreationSource.manual : TaskCreationSource.template, assignmentMode: AssignmentMode.singleOwner, leadOwnerId: draft.ownerUserId, priorityId: draft.priorityId ?? 'priority-normal', categoryId: draft.categoryId ?? 'category-personal', status: submitted ? TaskStatus.assigned : TaskStatus.draft, confidentialityLevelId: draft.confidentialityLevelId ?? 'confidentiality-internal', visibilityType: draft.isPersonal ? TaskVisibilityType.personal : TaskVisibilityType.assignedUsers, plannedStartDate: draft.plannedStart, dueDate: draft.dueDate, estimatedEffortMinutes: draft.estimatedEffortMinutes, progressPercentage: 0, approvalRequired: draft.approvalRequired, completionEvidenceRequired: draft.completionEvidenceRequired, allowDecline: draft.allowDecline, allowExtension: draft.allowExtension, approvalStatus: draft.approvalRequired ? ApprovalStatus.pending : ApprovalStatus.notRequired, isPersonal: draft.isPersonal, isRecurring: false, createdAt: existing?.createdAt ?? now, updatedAt: now, syncState: LocalEntitySyncState.pending, isLocallyModified: true);
    existing == null ? await tasks.insertTaskRecord(task) : await tasks.updateTaskRecord(task);
    if (submitted && draft.ownerUserId != null && (await tasks.getTaskAssignments(id)).isEmpty) await tasks.insertAssignments([TaskAssignment(id: 'assignment-$id-owner', taskId: id, userId: draft.ownerUserId!, assignmentRole: AssignmentRole.owner, assignmentStatus: AssignmentStatus.assigned, isPrimary: true, assignedAt: now, createdAt: now, updatedAt: now)]);
    await audit.appendAuditEvent(AuditEvent(id: 'audit-$id-${submitted ? 'submitted' : existing == null ? 'draft-created' : 'draft-updated'}', taskId: id, entityType: 'task', entityId: id, eventType: existing == null ? AuditEventType.created : AuditEventType.updated, performedBy: userId, performedAt: now, reason: submitted ? 'task_submitted' : 'draft_saved'));
    await sync.appendOperation(SyncOperation(id: 'sync-$id-${existing == null ? 'create' : 'update'}', entityType: 'task', entityId: id, operationType: existing == null ? SyncOperationType.create : SyncOperationType.update, payloadJson: '{"taskId":"$id"}', createdAt: now, status: SyncOperationStatus.pending));
    return TaskCreationResult(status: TaskCreationResultStatus.success, task: task, reasonCode: submitted ? 'task_submitted' : 'draft_saved', messageKey: submitted ? 'taskCreatedSuccessfully' : 'draftSaved', savedAsDraft: !submitted);
  }

  @override
  Future<TaskDraft?> loadDraft({required String userId, required String taskId}) async { final task = await tasks.getTaskById(taskId); if (task == null || task.status != TaskStatus.draft || task.creatorId != userId) return null; return TaskDraft(id: task.id, taskNumber: task.taskNumber, titleAr: task.titleAr, titleEn: task.titleEn ?? '', descriptionAr: task.descriptionAr, descriptionEn: task.descriptionEn ?? '', creatorId: task.creatorId, ownerUserId: task.leadOwnerId, priorityId: task.priorityId, categoryId: task.categoryId, confidentialityLevelId: task.confidentialityLevelId, plannedStart: task.plannedStartDate, dueDate: task.dueDate, estimatedEffortMinutes: task.estimatedEffortMinutes, approvalRequired: task.approvalRequired, completionEvidenceRequired: task.completionEvidenceRequired, allowDecline: task.allowDecline, allowExtension: task.allowExtension, isPersonal: task.isPersonal, status: task.status, createdAt: task.createdAt, updatedAt: task.updatedAt); }

  @override
  Future<void> deleteDraft({required String userId, required String taskId}) async { final task = await tasks.getTaskById(taskId); if (task == null || task.status != TaskStatus.draft) throw StateError('draft_not_found'); if (task.creatorId != userId) throw StateError('permission_denied'); await tasks.deleteTaskRecord(taskId); final now = clock.now().toUtc(); await audit.appendAuditEvent(AuditEvent(id: 'audit-$taskId-draft-deleted', taskId: taskId, entityType: 'task', entityId: taskId, eventType: AuditEventType.deleted, performedBy: userId, performedAt: now, reason: 'draft_deleted')); }
}
