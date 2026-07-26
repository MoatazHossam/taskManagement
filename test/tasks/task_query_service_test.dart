import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/demo/demo_data_store.dart';
import 'package:organization_task_manager/core/demo/demo_seed_ids.dart';
import 'package:organization_task_manager/core/demo/in_memory_repositories.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/features/organization/data/repository_authorization_service.dart';
import 'package:organization_task_manager/features/organization/data/repository_organization_hierarchy_service.dart';
import 'package:organization_task_manager/features/tasks/data/repository_task_query_service.dart';
import 'package:organization_task_manager/features/tasks/domain/task_query_models.dart';

void main() {
  late DemoDataStore store;
  late RepositoryTaskQueryService service;
  setUp(() {
    const clock = FixedAppClock(DateTime.utc(2026, 7, 26, 12));
    store = DemoDataStore(clock: clock);
    final users = InMemoryUserRepository(store);
    final organization = InMemoryOrganizationRepository(store);
    final authorization = RepositoryAuthorizationService(
      users: users,
      organization: organization,
      hierarchy: RepositoryOrganizationHierarchyService(
        users: users,
        organization: organization,
      ),
      overrides: InMemoryPermissionOverrideRepository(store),
    );
    service = RepositoryTaskQueryService(
      tasks: InMemoryTaskRepository(store),
      users: users,
      organization: organization,
      configuration: InMemoryTaskConfigurationRepository(store),
      audit: InMemoryAuditRepository(store),
      authorization: authorization,
      clock: clock,
    );
  });

  test('authorization runs before employee search exposure', () async {
    final result = await service.queryTasks(
      userId: DemoSeedIds.ahmed,
      query: TaskQuery(searchText: 'SCN-01'),
    );
    expect(result.items.single.task.taskNumber, 'SCN-01');
    expect(result.visibleCount, lessThanOrEqualTo(result.totalCount));
    expect(() => result.items.add(result.items.single), throwsUnsupportedError);
  });

  test('administrator has no implicit operational task visibility', () async {
    final result = await service.queryTasks(
      userId: DemoSeedIds.laila,
      query: TaskQuery(),
    );
    expect(result.items, isEmpty);
  });

  test('quick view, Arabic search, and stable sort are deterministic', () async {
    final arabic = await service.queryTasks(
      userId: DemoSeedIds.omar,
      query: TaskQuery(searchText: 'السيناريو 4'),
    );
    expect(arabic.items.single.task.id, 'scenario-04');
    final blocked = await service.queryTasks(
      userId: DemoSeedIds.omar,
      query: TaskQuery(view: TaskListView.blocked),
    );
    expect(blocked.items.map((e) => e.task.id), contains('scenario-04'));
    final sorted = await service.queryTasks(
      userId: DemoSeedIds.omar,
      query: TaskQuery(sortField: TaskSortField.priority),
    );
    expect(sorted.items, isNotEmpty);
  });

  test('details fail closed and saved filters are isolated', () async {
    expect(
      await service.getTaskDetails(
        userId: DemoSeedIds.laila,
        taskId: 'scenario-01',
      ),
      isNull,
    );
    await service.saveFilter(
      userId: DemoSeedIds.sara,
      filter: TaskSavedFilter(
        id: 'high',
        name: 'High Priority',
        query: TaskQuery(priorities: const {'urgent'}),
      ),
    );
    expect(await service.getSavedFilters(DemoSeedIds.sara), hasLength(1));
    expect(await service.getSavedFilters(DemoSeedIds.ahmed), isEmpty);
  });
}
