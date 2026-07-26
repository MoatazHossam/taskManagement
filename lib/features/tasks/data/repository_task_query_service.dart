import 'dart:collection';

import '../../../core/domain/app_clock.dart';
import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../../../shared/repositories/repositories.dart';
import '../../organization/domain/authorization_service.dart';
import '../domain/task_query_models.dart';
import '../domain/task_query_service.dart';

final class RepositoryTaskQueryService implements TaskQueryService {
  RepositoryTaskQueryService({required this.tasks, required this.users, required this.organization,
    required this.configuration, required this.audit, required this.authorization, required this.clock});
  final TaskRepository tasks; final UserRepository users; final OrganizationRepository organization;
  final TaskConfigurationRepository configuration; final AuditRepository audit;
  final AuthorizationService authorization; final AppClock clock;
  final Map<String, List<TaskSavedFilter>> _saved = {};

  @override
  Future<TaskQueryResult> queryTasks({required String userId, required TaskQuery query}) async {
    final all = (await tasks.getTasks()).where((t) => !t.isDeleted).toList();
    final visible = <Task>[];
    for (final task in all) { if ((await _decision(userId, task)).allowed) visible.add(task); }
    final items = <TaskListItem>[];
    for (final task in visible) {
      final item = await _item(task);
      if (await _scopeMatches(userId, item, query.scope) && _matches(item, query)) items.add(item);
    }
    items.sort((a, b) => _compare(a, b, query));
    return TaskQueryResult(items: items, totalCount: all.length, visibleCount: visible.length,
      hiddenByAuthorizationCount: all.length - visible.length, query: query, generatedAt: clock.now());
  }

  Future<bool> _scopeMatches(String userId, TaskListItem item, TaskQueryScope scope) async {
    if (scope == TaskQueryScope.organization) return true;
    final task = item.task;
    final directlyAssigned = task.creatorId == userId || task.leadOwnerId == userId ||
        item.assignments.any((assignment) => assignment.userId == userId);
    if (scope == TaskQueryScope.self) return directlyAssigned;
    final user = await users.getUserById(userId);
    if (scope == TaskQueryScope.department) {
      return item.assignedTeam?.departmentId == user?.departmentId ||
          item.primaryOwner?.departmentId == user?.departmentId;
    }
    final memberships = await organization.getMembershipsForUser(userId);
    return directlyAssigned || memberships.any((membership) => membership.teamId == task.assignedTeamId);
  }

  Future<AuthorizationDecision> _decision(String userId, Task task) async {
    final assignments = await tasks.getTaskAssignments(task.id);
    final direct = task.leadOwnerId == userId || task.creatorId == userId || assignments.any((a) => a.userId == userId);
    final team = task.assignedTeamId == null ? null : await organization.getTeamById(task.assignedTeamId!);
    final owner = task.leadOwnerId == null ? null : await users.getUserById(task.leadOwnerId!);
    final creator = await users.getUserById(task.creatorId);
    final root = await organization.getOrganization();
    final levels = await configuration.getConfidentialityLevels();
    final level = levels.where((e) => e.id == task.confidentialityLevelId).firstOrNull;
    final confidentiality = switch (level?.code) { 'restricted' => ConfidentialityCode.restricted,
      'confidential' => ConfidentialityCode.confidential, 'internal' => ConfidentialityCode.internal, _ => ConfidentialityCode.public };
    final target = AccessTarget(ownerUserId: direct ? userId : task.leadOwnerId,
      departmentId: team?.departmentId ?? owner?.departmentId ?? creator?.departmentId,
      teamId: task.assignedTeamId, organizationId: root?.id, confidentialityCode: confidentiality, isPersonal: task.isPersonal);
    for (final permission in direct
        ? const [PermissionCode.taskViewOwn, PermissionCode.taskViewTeam, PermissionCode.taskViewDepartment, PermissionCode.taskViewAll]
        : const [PermissionCode.taskViewTeam, PermissionCode.taskViewDepartment, PermissionCode.taskViewAll]) {
      final decision = await authorization.check(userId: userId, permission: permission, target: target);
      if (decision.allowed) return decision;
    }
    return authorization.check(userId: userId, permission: PermissionCode.taskViewOwn, target: target);
  }

  Future<TaskListItem> _item(Task task) async {
    final assignments = await tasks.getTaskAssignments(task.id);
    final ownerAssignment = assignments.where((a) => a.isPrimary || a.assignmentRole == AssignmentRole.owner || a.assignmentRole == AssignmentRole.leadOwner).firstOrNull;
    final blockers = await tasks.getBlockers(task.id);
    final now = clock.now(); final due = task.dueDate?.toLocal(); final today = now.toLocal();
    final start = DateTime(today.year, today.month, today.day).subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return TaskListItem(task: task, priority: await configuration.getPriorityById(task.priorityId),
      category: await configuration.getCategoryById(task.categoryId),
      confidentiality: (await configuration.getConfidentialityLevels()).where((e) => e.id == task.confidentialityLevelId).firstOrNull,
      assignments: assignments, primaryOwner: ownerAssignment == null ? null : await users.getUserById(ownerAssignment.userId),
      assignedTeam: task.assignedTeamId == null ? null : await organization.getTeamById(task.assignedTeamId!),
      hasActiveBlocker: blockers.any((b) => b.status == BlockerStatus.active),
      isOverdue: due != null && due.isBefore(now.toLocal()) && !closedTaskStatuses.contains(task.status),
      isDueToday: due != null && _sameDay(due, today), isDueThisWeek: due != null && !due.isBefore(start) && due.isBefore(end));
  }

  bool _matches(TaskListItem i, TaskQuery q) {
    final t = i.task; final search = _normalize(q.searchText);
    if (search.isNotEmpty && ![t.taskNumber, t.titleAr, t.titleEn ?? '', t.descriptionAr, t.descriptionEn ?? ''].any((v) => _normalize(v).contains(search))) return false;
    if (!_view(i, q.view)) return false;
    if (q.statuses.isNotEmpty && !q.statuses.contains(t.status)) return false;
    if (q.priorities.isNotEmpty && !q.priorities.contains(t.priorityId) && !q.priorities.contains(i.priority?.code)) return false;
    if (!_range(t.dueDate, q.dueDateFrom, q.dueDateTo) || !_range(t.createdAt, q.creationDateFrom, q.creationDateTo)) return false;
    if (q.creatorIds.isNotEmpty && !q.creatorIds.contains(t.creatorId)) return false;
    final ownerIds = i.assignments.where((a) => a.assignmentRole != AssignmentRole.contributor).map((a) => a.userId).toSet();
    final contributors = i.assignments.where((a) => a.assignmentRole == AssignmentRole.contributor).map((a) => a.userId).toSet();
    if (q.ownerIds.isNotEmpty && ownerIds.intersection(q.ownerIds).isEmpty) return false;
    if (q.contributorIds.isNotEmpty && contributors.intersection(q.contributorIds).isEmpty) return false;
    if (q.teamIds.isNotEmpty && !q.teamIds.contains(t.assignedTeamId)) return false;
    if (q.departmentIds.isNotEmpty && !q.departmentIds.contains(i.assignedTeam?.departmentId)) return false;
    if (q.categoryIds.isNotEmpty && !q.categoryIds.contains(t.categoryId)) return false;
    if (q.assignmentModes.isNotEmpty && !q.assignmentModes.contains(t.assignmentMode)) return false;
    if (q.approvalStatuses.isNotEmpty && !q.approvalStatuses.contains(t.approvalStatus)) return false;
    if (q.confidentialityLevels.isNotEmpty && !q.confidentialityLevels.contains(t.confidentialityLevelId) && !q.confidentialityLevels.contains(i.confidentiality?.code)) return false;
    if (!_boolean(q.blockedState, i.hasActiveBlocker || t.status == TaskStatus.blocked) || !_boolean(q.recurringState, t.isRecurring) ||
        !_boolean(q.locallyModifiedState, t.isLocallyModified) || !_boolean(q.pendingSynchronizationState, t.syncState == LocalEntitySyncState.pending)) return false;
    return true;
  }
  bool _view(TaskListItem i, TaskListView v) => switch (v) { TaskListView.all => true, TaskListView.today => i.isDueToday,
    TaskListView.thisWeek => i.isDueThisWeek, TaskListView.overdue => i.isOverdue,
    TaskListView.blocked => i.hasActiveBlocker || i.task.status == TaskStatus.blocked,
    TaskListView.awaitingApproval => i.task.status == TaskStatus.completionRequested || i.task.approvalStatus == ApprovalStatus.pending,
    TaskListView.teamQueue => i.task.assignmentMode == AssignmentMode.teamQueue,
    TaskListView.completed => i.task.status == TaskStatus.completed, TaskListView.drafts => i.task.status == TaskStatus.draft,
    TaskListView.critical => i.priority?.code == 'critical' || i.priority?.code == 'urgent' || i.isOverdue ||
      i.hasActiveBlocker || i.task.approvalStatus == ApprovalStatus.pending || i.task.status == TaskStatus.completionRequested };
  bool _boolean(TaskBooleanFilter f, bool value) => f == TaskBooleanFilter.any || (f == TaskBooleanFilter.yes) == value;
  bool _range(DateTime? value, DateTime? from, DateTime? to) => value == null ? from == null && to == null : (from == null || !value.isBefore(from)) && (to == null || !value.isAfter(to));
  String _normalize(String value) => value.trim().toLowerCase().replaceAll(RegExp('[\u064B-\u065F\u0670]'), '').replaceAll('ـ', '');
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  int _compare(TaskListItem a, TaskListItem b, TaskQuery q) {
    Comparable? av, bv;
    switch (q.sortField) { case TaskSortField.dueDate: av=a.task.dueDate; bv=b.task.dueDate; case TaskSortField.priority: av=a.priority?.level; bv=b.priority?.level;
      case TaskSortField.creationDate: av=a.task.createdAt; bv=b.task.createdAt; case TaskSortField.lastUpdate: av=a.task.updatedAt; bv=b.task.updatedAt;
      case TaskSortField.progress: av=a.progressPercentage; bv=b.progressPercentage; case TaskSortField.estimatedEffort: av=a.task.estimatedEffortMinutes; bv=b.task.estimatedEffortMinutes;
      case TaskSortField.taskNumber: av=a.task.taskNumber; bv=b.task.taskNumber; }
    var result = av == null ? (bv == null ? 0 : 1) : bv == null ? -1 : av.compareTo(bv);
    if (q.sortDirection == SortDirection.descending && av != null && bv != null) result = -result;
    return result != 0 ? result : a.task.taskNumber.compareTo(b.task.taskNumber);
  }

  @override
  Future<TaskDetails?> getTaskDetails({required String userId, required String taskId}) async {
    final task = await tasks.getTaskById(taskId); if (task == null) return null;
    final decision = await _decision(userId, task); if (!decision.allowed) return null;
    final assignments = await tasks.getTaskAssignments(taskId); final checklist = await tasks.getChecklistItems(taskId);
    final blockers = await tasks.getBlockers(taskId); final approvals = await tasks.getApprovals(taskId);
    final assignmentUsers = <String, OrganizationUser>{};
    for (final assignment in assignments) {
      final user = await users.getUserById(assignment.userId);
      if (user != null) assignmentUsers[user.id] = user;
    }
    return TaskDetails(task: task, creator: await users.getUserById(task.creatorId),
      leadOwner: task.leadOwnerId == null ? null : await users.getUserById(task.leadOwnerId!),
      assignedTeam: task.assignedTeamId == null ? null : await organization.getTeamById(task.assignedTeamId!), assignments: assignments,
      category: await configuration.getCategoryById(task.categoryId), priority: await configuration.getPriorityById(task.priorityId),
      confidentiality: (await configuration.getConfidentialityLevels()).where((e) => e.id == task.confidentialityLevelId).firstOrNull,
      checklistSummary: ChecklistSummary(checklist.where((e) => e.isCompleted).length, checklist.length),
      subtaskCount: (await tasks.getSubtasks(taskId)).length, activeBlocker: blockers.where((e) => e.status == BlockerStatus.active).firstOrNull,
      approval: approvals.firstOrNull, attachmentCount: (await tasks.getAttachments(taskId)).length,
      commentCount: (await tasks.getComments(taskId)).length, timeline: await getTaskTimeline(userId: userId, taskId: taskId),
      assignmentUsers: assignmentUsers, authorizationDecision: decision);
  }
  @override
  Future<List<TaskTimelineEntry>> getTaskTimeline({required String userId, required String taskId}) async {
    final task = await tasks.getTaskById(taskId); if (task == null || !(await _decision(userId, task)).allowed) return const [];
    final entries = <TaskTimelineEntry>[];
    for (final e in await audit.getAuditEventsForTask(taskId)) { entries.add(TaskTimelineEntry(id: e.id, eventType: e.eventType,
      actor: await users.getUserById(e.performedBy), timestamp: e.performedAt, reason: e.reason, offline: false, syncState: task.syncState)); }
    if (entries.isEmpty) entries.add(TaskTimelineEntry(id: '${task.id}-created', eventType: AuditEventType.created,
      actor: await users.getUserById(task.creatorId), timestamp: task.createdAt, offline: false, syncState: task.syncState));
    entries.sort((a,b) => b.timestamp.compareTo(a.timestamp)); return UnmodifiableListView(entries);
  }
  @override Future<List<TaskSavedFilter>> getSavedFilters(String userId) async => UnmodifiableListView(_saved[userId] ?? const []);
  @override Future<void> saveFilter({required String userId, required TaskSavedFilter filter}) async { if (filter.name.trim().isEmpty) throw ArgumentError.value(filter.name, 'name');
    final list = _saved.putIfAbsent(userId, () => []); final index = list.indexWhere((e) => e.name.toLowerCase() == filter.name.trim().toLowerCase());
    if (index >= 0) list[index] = filter; else list.add(filter); }
  @override Future<void> deleteSavedFilter({required String userId, required String filterId}) async => _saved[userId]?.removeWhere((e) => e.id == filterId);
  @override Future<void> setDefaultFilter({required String userId, required String? filterId}) async { final list = _saved[userId]; if (list == null) return;
    for (var i=0;i<list.length;i++) { list[i] = list[i].copyWith(isDefault: list[i].id == filterId); } }
}
