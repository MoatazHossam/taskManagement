import 'package:flutter_test/flutter_test.dart';
import 'package:organization_task_manager/core/demo/demo_data_store.dart';
import 'package:organization_task_manager/core/demo/demo_seed_ids.dart';
import 'package:organization_task_manager/core/demo/in_memory_repositories.dart';
import 'package:organization_task_manager/core/domain/app_clock.dart';
import 'package:organization_task_manager/core/domain/domain_enums.dart';
import 'package:organization_task_manager/features/organization/data/repository_authorization_service.dart';
import 'package:organization_task_manager/features/organization/data/repository_organization_hierarchy_service.dart';
import 'package:organization_task_manager/features/tasks/data/repository_task_creation_service.dart';
import 'package:organization_task_manager/features/tasks/domain/task_creation_models.dart';
import 'package:organization_task_manager/features/tasks/domain/task_identity_service.dart';

void main() {
  final now = DateTime.utc(2026, 7, 26, 12);
  late DemoDataStore store;
  late RepositoryTaskCreationService service;

  setUp(() {
    store = DemoDataStore(clock: FixedAppClock(now));
    final users = InMemoryUserRepository(store);
    final organization = InMemoryOrganizationRepository(store);
    final hierarchy = RepositoryOrganizationHierarchyService(users: users, organization: organization);
    final authorization = RepositoryAuthorizationService(users: users, organization: organization, hierarchy: hierarchy, overrides: InMemoryPermissionOverrideRepository(store));
    service = RepositoryTaskCreationService(tasks: InMemoryTaskRepository(store), users: users, organization: organization, configuration: InMemoryTaskConfigurationRepository(store), audit: InMemoryAuditRepository(store), sync: InMemorySyncRepository(store), authorization: authorization, identities: InMemoryTaskIdentityService(existingIds: store.tasks.map((e) => e.id), existingNumbers: store.tasks.map((e) => e.taskNumber), year: 2026), clock: FixedAppClock(now));
  });

  test('employee defaults to self and cannot inject another owner', () async {
    final defaults = await service.getDefaults(userId: DemoSeedIds.ahmed);
    expect(defaults.ownerLocked, isTrue);
    expect(defaults.draft.ownerUserId, DemoSeedIds.ahmed);
    final result = await service.submit(userId: DemoSeedIds.ahmed, draft: _valid(defaults.draft.copyWith(ownerUserId: DemoSeedIds.khaled), now));
    expect(result.isSuccess, isFalse);
    expect(result.issues.any((e) => e.code == TaskValidationCode.ownerNotAllowed), isTrue);
  });

  test('incomplete draft gets stable deterministic identity and can update', () async {
    final draft = (await service.getDefaults(userId: DemoSeedIds.sara)).draft;
    final first = await service.saveDraft(userId: DemoSeedIds.sara, draft: draft);
    expect(first.isSuccess, isTrue);
    expect(first.task!.status, TaskStatus.draft);
    final loaded = await service.loadDraft(userId: DemoSeedIds.sara, taskId: first.task!.id);
    final second = await service.saveDraft(userId: DemoSeedIds.sara, draft: loaded!.copyWith(titleEn: 'Later'));
    expect(second.task!.id, first.task!.id);
    expect(second.task!.taskNumber, first.task!.taskNumber);
  });

  test('valid employee submit persists assignment audit sync and rejects duplicate', () async {
    final draft = _valid((await service.getDefaults(userId: DemoSeedIds.ahmed)).draft, now);
    final saved = await service.saveDraft(userId: DemoSeedIds.ahmed, draft: draft);
    final loaded = await service.loadDraft(userId: DemoSeedIds.ahmed, taskId: saved.task!.id);
    final submitted = await service.submit(userId: DemoSeedIds.ahmed, draft: loaded!);
    expect(submitted.task!.status, TaskStatus.assigned);
    expect(store.assignments.where((e) => e.taskId == submitted.task!.id), hasLength(1));
    expect(store.auditEvents.where((e) => e.taskId == submitted.task!.id), isNotEmpty);
    expect(store.syncOperations.where((e) => e.entityId == submitted.task!.id), isNotEmpty);
    final duplicate = await service.submit(userId: DemoSeedIds.ahmed, draft: loaded);
    expect(duplicate.status, TaskCreationResultStatus.duplicateSubmission);
    expect(store.tasks.where((e) => e.id == submitted.task!.id), hasLength(1));
  });

  test('manager may assign outside direct reports while admin is denied', () async {
    final manager = _valid((await service.getDefaults(userId: DemoSeedIds.sara)).draft.copyWith(ownerUserId: DemoSeedIds.khaled), now);
    expect((await service.submit(userId: DemoSeedIds.sara, draft: manager)).isSuccess, isTrue);
    await expectLater(service.getDefaults(userId: DemoSeedIds.laila), throwsA(isA<StateError>()));
  });

  test('validation rejects blank, past date, and invalid effort', () async {
    final draft = (await service.getDefaults(userId: DemoSeedIds.ahmed)).draft.copyWith(categoryId: 'category-operations', dueDate: now.subtract(const Duration(days: 1)), estimatedEffortMinutes: 0);
    final result = await service.validate(userId: DemoSeedIds.ahmed, draft: draft);
    expect(result.issues.map((e) => e.code), containsAll([TaskValidationCode.titleRequired, TaskValidationCode.dueDateInPast, TaskValidationCode.effortInvalid]));
  });

  test('creator-only draft delete is audited', () async {
    final saved = await service.saveDraft(userId: DemoSeedIds.sara, draft: (await service.getDefaults(userId: DemoSeedIds.sara)).draft);
    await expectLater(service.deleteDraft(userId: DemoSeedIds.ahmed, taskId: saved.task!.id), throwsA(isA<StateError>()));
    await service.deleteDraft(userId: DemoSeedIds.sara, taskId: saved.task!.id);
    expect(store.tasks.any((e) => e.id == saved.task!.id), isFalse);
    expect(store.auditEvents.any((e) => e.taskId == saved.task!.id && e.eventType == AuditEventType.deleted), isTrue);
  });
}

TaskDraft _valid(TaskDraft draft, DateTime now) => draft.copyWith(titleEn: 'Created task', categoryId: 'category-operations', priorityId: DemoSeedIds.priorityNormal, confidentialityLevelId: DemoSeedIds.confidentialityInternal, dueDate: now.add(const Duration(days: 2)), estimatedEffortMinutes: 60);
