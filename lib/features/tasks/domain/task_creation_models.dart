import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';

enum TaskCreationResultStatus { success, validationFailure, permissionDenied, ownerNotAllowed, categoryUnavailable, priorityUnavailable, confidentialityUnavailable, invalidDates, invalidEffort, draftNotFound, duplicateSubmission, repositoryFailure, unknownFailure }
enum TaskValidationCode { titleRequired, titleTooLong, descriptionTooLong, creatorMissing, ownerMissing, ownerInactive, ownerOutsideOrganization, ownerNotAllowed, categoryMissing, priorityMissing, confidentialityMissing, confidentialityNotAllowed, dueDateRequired, dueDateBeforeStart, dueDateInPast, effortInvalid, assignmentModeInvalid }

class TaskValidationIssue {
  const TaskValidationIssue(this.code, this.messageKey, {this.field});
  final TaskValidationCode code;
  final String messageKey;
  final String? field;
}

class TaskValidationResult {
  const TaskValidationResult(this.issues);
  final List<TaskValidationIssue> issues;
  bool get isValid => issues.isEmpty;
}

class TaskCreationDefaults {
  const TaskCreationDefaults({required this.draft, required this.ownerLocked});
  final TaskDraft draft;
  final bool ownerLocked;
}

class TaskCreationOptions {
  const TaskCreationOptions({required this.priorities, required this.categories, required this.confidentialityLevels, required this.templates, required this.ownerCandidates, required this.ownerLocked});
  final List<TaskPriority> priorities;
  final List<TaskCategory> categories;
  final List<ConfidentialityLevel> confidentialityLevels;
  final List<TaskTemplate> templates;
  final List<OrganizationUser> ownerCandidates;
  final bool ownerLocked;
}

class TaskCreationResult {
  const TaskCreationResult({required this.status, this.task, this.issues = const [], required this.reasonCode, required this.messageKey, this.savedAsDraft = false});
  final TaskCreationResultStatus status;
  final Task? task;
  final List<TaskValidationIssue> issues;
  final String reasonCode, messageKey;
  final bool savedAsDraft;
  bool get isSuccess => status == TaskCreationResultStatus.success;
}

class TaskDraft {
  const TaskDraft({this.id, this.taskNumber, this.titleAr = '', this.titleEn = '', this.descriptionAr = '', this.descriptionEn = '', required this.creatorId, this.ownerUserId, this.departmentId, this.teamId, this.priorityId, this.categoryId, this.confidentialityLevelId, this.assignmentMode = AssignmentMode.singleOwner, this.plannedStart, this.dueDate, this.estimatedEffortMinutes, this.approvalRequired = false, this.completionEvidenceRequired = false, this.allowDecline = false, this.allowExtension = false, this.isPersonal = false, this.isRecurring = false, this.templateId, this.status = TaskStatus.draft, required this.createdAt, required this.updatedAt});
  final String? id, taskNumber, ownerUserId, departmentId, teamId, priorityId, categoryId, confidentialityLevelId, templateId;
  final String titleAr, titleEn, descriptionAr, descriptionEn, creatorId;
  final AssignmentMode assignmentMode;
  final DateTime? plannedStart, dueDate;
  final DateTime createdAt, updatedAt;
  final int? estimatedEffortMinutes;
  final bool approvalRequired, completionEvidenceRequired, allowDecline, allowExtension, isPersonal, isRecurring;
  final TaskStatus status;

  TaskDraft copyWith({String? id, String? taskNumber, String? titleAr, String? titleEn, String? descriptionAr, String? descriptionEn, String? ownerUserId, bool clearOwner = false, String? departmentId, String? teamId, String? priorityId, String? categoryId, String? confidentialityLevelId, DateTime? plannedStart, bool clearPlannedStart = false, DateTime? dueDate, bool clearDueDate = false, int? estimatedEffortMinutes, bool clearEffort = false, bool? approvalRequired, bool? completionEvidenceRequired, bool? allowDecline, bool? allowExtension, bool? isPersonal, String? templateId, TaskStatus? status, DateTime? updatedAt}) => TaskDraft(
    id: id ?? this.id, taskNumber: taskNumber ?? this.taskNumber, titleAr: titleAr ?? this.titleAr, titleEn: titleEn ?? this.titleEn, descriptionAr: descriptionAr ?? this.descriptionAr, descriptionEn: descriptionEn ?? this.descriptionEn, creatorId: creatorId, ownerUserId: clearOwner ? null : ownerUserId ?? this.ownerUserId, departmentId: departmentId ?? this.departmentId, teamId: teamId ?? this.teamId, priorityId: priorityId ?? this.priorityId, categoryId: categoryId ?? this.categoryId, confidentialityLevelId: confidentialityLevelId ?? this.confidentialityLevelId, assignmentMode: assignmentMode, plannedStart: clearPlannedStart ? null : plannedStart ?? this.plannedStart, dueDate: clearDueDate ? null : dueDate ?? this.dueDate, estimatedEffortMinutes: clearEffort ? null : estimatedEffortMinutes ?? this.estimatedEffortMinutes, approvalRequired: approvalRequired ?? this.approvalRequired, completionEvidenceRequired: completionEvidenceRequired ?? this.completionEvidenceRequired, allowDecline: allowDecline ?? this.allowDecline, allowExtension: allowExtension ?? this.allowExtension, isPersonal: isPersonal ?? this.isPersonal, isRecurring: isRecurring, templateId: templateId ?? this.templateId, status: status ?? this.status, createdAt: createdAt, updatedAt: updatedAt ?? this.updatedAt);

  TaskDraft applyTemplate(TaskTemplate template, DateTime now) => copyWith(templateId: template.id, titleAr: template.titleAr, titleEn: template.titleEn ?? titleEn, categoryId: template.categoryId, priorityId: template.priorityId, updatedAt: now);
}
