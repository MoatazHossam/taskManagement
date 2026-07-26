import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../core/domain/app_clock.dart';
import '../../../core/domain/domain_enums.dart';
import '../data/repository_task_query_service.dart';
import '../domain/task_query_models.dart';
import '../domain/task_query_service.dart';

final taskQueryServiceProvider = Provider<TaskQueryService>((ref) => RepositoryTaskQueryService(
  tasks: ref.watch(taskRepositoryProvider), users: ref.watch(userRepositoryProvider),
  organization: ref.watch(organizationRepositoryProvider), configuration: ref.watch(taskConfigurationRepositoryProvider),
  audit: ref.watch(auditRepositoryProvider), authorization: ref.watch(authorizationServiceProvider), clock: const SystemAppClock()));

final currentTaskQueryProvider = StateProvider<TaskQuery>((ref) {
  ref.watch(currentOrganizationUserProvider)?.id;
  return TaskQuery();
});
final selectedQuickViewProvider = Provider<TaskListView>((ref) => ref.watch(currentTaskQueryProvider).view);
final selectedTaskSortProvider = Provider<({TaskSortField field, SortDirection direction})>((ref) {
  final query = ref.watch(currentTaskQueryProvider); return (field: query.sortField, direction: query.sortDirection);
});
final taskQueryResultProvider = FutureProvider<TaskQueryResult?>((ref) async {
  final user = ref.watch(currentOrganizationUserProvider); if (user == null) return null;
  return ref.watch(taskQueryServiceProvider).queryTasks(userId: user.id, query: ref.watch(currentTaskQueryProvider));
});
final taskDetailsProvider = FutureProvider.family<TaskDetails?, String>((ref, id) async {
  final user = ref.watch(currentOrganizationUserProvider); if (user == null) return null;
  return ref.watch(taskQueryServiceProvider).getTaskDetails(userId: user.id, taskId: id);
});
final taskTimelineProvider = FutureProvider.family<List<TaskTimelineEntry>, String>((ref, id) async {
  final user = ref.watch(currentOrganizationUserProvider); if (user == null) return const [];
  return ref.watch(taskQueryServiceProvider).getTaskTimeline(userId: user.id, taskId: id);
});
final savedTaskFiltersProvider = FutureProvider<List<TaskSavedFilter>>((ref) async {
  final user = ref.watch(currentOrganizationUserProvider); if (user == null) return const [];
  return ref.watch(taskQueryServiceProvider).getSavedFilters(user.id);
});

final permittedTaskScopesProvider = FutureProvider<Set<TaskQueryScope>>((ref) async {
  final user = ref.watch(currentOrganizationUserProvider);
  if (user == null) return const {TaskQueryScope.self};
  final permissions = await ref.watch(authorizationServiceProvider).getEffectivePermissions(user.id);
  final scopes = <TaskQueryScope>{TaskQueryScope.self};
  if (permissions.contains(PermissionCode.taskViewTeam)) scopes.add(TaskQueryScope.team);
  if (permissions.contains(PermissionCode.taskViewDepartment)) scopes.add(TaskQueryScope.department);
  if (permissions.contains(PermissionCode.taskViewAll)) scopes.add(TaskQueryScope.organization);
  return scopes;
});
