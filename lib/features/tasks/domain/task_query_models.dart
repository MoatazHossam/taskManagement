import 'dart:collection';

import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';

enum TaskListView { all, today, thisWeek, overdue, blocked, awaitingApproval, teamQueue, completed, drafts }
enum TaskSortField { dueDate, priority, creationDate, lastUpdate, progress, estimatedEffort, taskNumber }
enum SortDirection { ascending, descending }
enum TaskBooleanFilter { any, yes, no }
enum TaskStatusCategory { notStarted, active, waiting, attentionRequired, completed, closed }

const closedTaskStatuses = <TaskStatus>{
  TaskStatus.completed,
  TaskStatus.cancelled,
  TaskStatus.declined,
  TaskStatus.expired,
};

class TaskQuery {
  TaskQuery({
    this.searchText = '', this.view = TaskListView.all,
    Set<TaskStatus> statuses = const {}, Set<String> priorities = const {},
    this.dueDateFrom, this.dueDateTo, this.creationDateFrom, this.creationDateTo,
    Set<String> creatorIds = const {}, Set<String> ownerIds = const {},
    Set<String> contributorIds = const {}, Set<String> teamIds = const {},
    Set<String> departmentIds = const {}, Set<String> categoryIds = const {},
    Set<AssignmentMode> assignmentModes = const {},
    Set<ApprovalStatus> approvalStatuses = const {},
    Set<String> confidentialityLevels = const {},
    this.blockedState = TaskBooleanFilter.any,
    this.recurringState = TaskBooleanFilter.any,
    this.locallyModifiedState = TaskBooleanFilter.any,
    this.pendingSynchronizationState = TaskBooleanFilter.any,
    this.sortField = TaskSortField.dueDate,
    this.sortDirection = SortDirection.ascending,
  }) : statuses = UnmodifiableSetView(Set.of(statuses)), priorities = UnmodifiableSetView(Set.of(priorities)),
       creatorIds = UnmodifiableSetView(Set.of(creatorIds)), ownerIds = UnmodifiableSetView(Set.of(ownerIds)),
       contributorIds = UnmodifiableSetView(Set.of(contributorIds)), teamIds = UnmodifiableSetView(Set.of(teamIds)),
       departmentIds = UnmodifiableSetView(Set.of(departmentIds)), categoryIds = UnmodifiableSetView(Set.of(categoryIds)),
       assignmentModes = UnmodifiableSetView(Set.of(assignmentModes)), approvalStatuses = UnmodifiableSetView(Set.of(approvalStatuses)),
       confidentialityLevels = UnmodifiableSetView(Set.of(confidentialityLevels));
  final String searchText;
  final TaskListView view;
  final Set<TaskStatus> statuses;
  final Set<String> priorities, creatorIds, ownerIds, contributorIds, teamIds, departmentIds, categoryIds, confidentialityLevels;
  final Set<AssignmentMode> assignmentModes;
  final Set<ApprovalStatus> approvalStatuses;
  final DateTime? dueDateFrom, dueDateTo, creationDateFrom, creationDateTo;
  final TaskBooleanFilter blockedState, recurringState, locallyModifiedState, pendingSynchronizationState;
  final TaskSortField sortField;
  final SortDirection sortDirection;
  int get activeFilterCount => [statuses, priorities, creatorIds, ownerIds, contributorIds, teamIds, departmentIds, categoryIds, assignmentModes, approvalStatuses, confidentialityLevels].where((e) => e.isNotEmpty).length +
      [dueDateFrom, dueDateTo, creationDateFrom, creationDateTo].where((e) => e != null).length +
      [blockedState, recurringState, locallyModifiedState, pendingSynchronizationState].where((e) => e != TaskBooleanFilter.any).length;
  TaskQuery copyWith({String? searchText, TaskListView? view, Set<TaskStatus>? statuses, Set<String>? priorities,
    TaskSortField? sortField, SortDirection? sortDirection}) => TaskQuery(
      searchText: searchText ?? this.searchText, view: view ?? this.view, statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities, dueDateFrom: dueDateFrom, dueDateTo: dueDateTo,
      creationDateFrom: creationDateFrom, creationDateTo: creationDateTo, creatorIds: creatorIds, ownerIds: ownerIds,
      contributorIds: contributorIds, teamIds: teamIds, departmentIds: departmentIds, categoryIds: categoryIds,
      assignmentModes: assignmentModes, approvalStatuses: approvalStatuses, confidentialityLevels: confidentialityLevels,
      blockedState: blockedState, recurringState: recurringState, locallyModifiedState: locallyModifiedState,
      pendingSynchronizationState: pendingSynchronizationState, sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection);
}

class TaskListItem {
  const TaskListItem({required this.task, required this.priority, required this.category, required this.confidentiality,
    required this.assignments, required this.primaryOwner, required this.assignedTeam, required this.hasActiveBlocker,
    required this.isOverdue, required this.isDueToday, required this.isDueThisWeek});
  final Task task;
  final TaskPriority? priority;
  final TaskCategory? category;
  final ConfidentialityLevel? confidentiality;
  final List<TaskAssignment> assignments;
  final OrganizationUser? primaryOwner;
  final Team? assignedTeam;
  final bool hasActiveBlocker, isOverdue, isDueToday, isDueThisWeek;
  int get progressPercentage => task.progressPercentage.clamp(0, 100);
}

class TaskQueryResult {
  TaskQueryResult({required List<TaskListItem> items, required this.totalCount, required this.visibleCount,
    required this.hiddenByAuthorizationCount, required this.query, required this.generatedAt}) : items = List.unmodifiable(items);
  final List<TaskListItem> items;
  final int totalCount, visibleCount, hiddenByAuthorizationCount;
  final TaskQuery query;
  final DateTime generatedAt;
  int get activeFilterCount => query.activeFilterCount;
}

class TaskTimelineEntry {
  const TaskTimelineEntry({required this.id, required this.eventType, required this.actor, required this.timestamp,
    this.reason, required this.offline, required this.syncState});
  final String id;
  final AuditEventType eventType;
  final OrganizationUser? actor;
  final DateTime timestamp;
  final String? reason;
  final bool offline;
  final LocalEntitySyncState syncState;
}

class ChecklistSummary { const ChecklistSummary(this.completed, this.total); final int completed, total; }
class TaskDetails {
  TaskDetails({required this.task, required this.creator, required this.leadOwner, required this.assignedTeam,
    required List<TaskAssignment> assignments, required this.category, required this.priority, required this.confidentiality,
    required this.checklistSummary, required this.subtaskCount, required this.activeBlocker, required this.approval,
    required this.attachmentCount, required this.commentCount, required List<TaskTimelineEntry> timeline,
    required this.authorizationDecision}) : assignments = List.unmodifiable(assignments), timeline = List.unmodifiable(timeline);
  final Task task; final OrganizationUser? creator, leadOwner; final Team? assignedTeam; final List<TaskAssignment> assignments;
  final TaskCategory? category; final TaskPriority? priority; final ConfidentialityLevel? confidentiality;
  final ChecklistSummary checklistSummary; final int subtaskCount, attachmentCount, commentCount;
  final TaskBlocker? activeBlocker; final TaskApproval? approval; final List<TaskTimelineEntry> timeline;
  final AuthorizationDecision authorizationDecision;
}

class TaskSavedFilter {
  const TaskSavedFilter({required this.id, required this.name, required this.query, this.isDefault = false, this.isPreset = false});
  final String id, name; final TaskQuery query; final bool isDefault, isPreset;
  TaskSavedFilter copyWith({bool? isDefault}) => TaskSavedFilter(id: id, name: name, query: query, isDefault: isDefault ?? this.isDefault, isPreset: isPreset);
}
