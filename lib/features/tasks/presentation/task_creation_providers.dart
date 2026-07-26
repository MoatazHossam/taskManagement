import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../core/domain/app_clock.dart';
import '../data/repository_task_creation_service.dart';
import '../domain/task_creation_models.dart';
import '../domain/task_creation_service.dart';
import '../domain/task_identity_service.dart';
import 'task_providers.dart';

final taskIdentityServiceProvider = Provider<TaskIdentityService>((ref) {
  final store = ref.watch(demoDataStoreProvider);
  return InMemoryTaskIdentityService(existingIds: store.tasks.map((e) => e.id), existingNumbers: store.tasks.map((e) => e.taskNumber), year: store.now.year);
});
final taskCreationServiceProvider = Provider<TaskCreationService>((ref) => RepositoryTaskCreationService(tasks: ref.watch(taskRepositoryProvider), users: ref.watch(userRepositoryProvider), organization: ref.watch(organizationRepositoryProvider), configuration: ref.watch(taskConfigurationRepositoryProvider), audit: ref.watch(auditRepositoryProvider), sync: ref.watch(syncRepositoryProvider), authorization: ref.watch(authorizationServiceProvider), identities: ref.watch(taskIdentityServiceProvider), clock: const SystemAppClock()));

class TaskCreationState {
  const TaskCreationState({this.draft, this.defaults, this.options, this.validation, this.result, this.loading = false, this.step = 0});
  final TaskDraft? draft;
  final TaskCreationDefaults? defaults;
  final TaskCreationOptions? options;
  final TaskValidationResult? validation;
  final TaskCreationResult? result;
  final bool loading;
  final int step;
  TaskCreationState copyWith({TaskDraft? draft, TaskCreationDefaults? defaults, TaskCreationOptions? options, TaskValidationResult? validation, TaskCreationResult? result, bool? loading, int? step, bool clearResult = false}) => TaskCreationState(draft: draft ?? this.draft, defaults: defaults ?? this.defaults, options: options ?? this.options, validation: validation ?? this.validation, result: clearResult ? null : result ?? this.result, loading: loading ?? this.loading, step: step ?? this.step);
}

class TaskCreationController extends StateNotifier<TaskCreationState> {
  TaskCreationController(this.ref) : super(const TaskCreationState());
  final Ref ref;
  String? get _userId => ref.read(currentOrganizationUserProvider)?.id;
  Future<void> initialize({String? draftId}) async {
    final userId = _userId; if (userId == null) return;
    state = state.copyWith(loading: true);
    final service = ref.read(taskCreationServiceProvider);
    try { final defaults = await service.getDefaults(userId: userId), options = await service.getOptions(userId: userId); final draft = draftId == null ? defaults.draft : await service.loadDraft(userId: userId, taskId: draftId); state = TaskCreationState(draft: draft ?? defaults.draft, defaults: defaults, options: options); } catch (_) { state = const TaskCreationState(result: TaskCreationResult(status: TaskCreationResultStatus.permissionDenied, reasonCode: 'permission_denied', messageKey: 'permissionDenied')); }
  }
  void update(TaskDraft Function(TaskDraft) change) { final value = state.draft; if (value != null) state = state.copyWith(draft: change(value), clearResult: true); }
  void goTo(int step) => state = state.copyWith(step: step.clamp(0, 3));
  Future<TaskCreationResult?> saveDraft() => _run(false);
  Future<TaskCreationResult?> submit() => _run(true);
  Future<TaskCreationResult?> _run(bool submit) async { if (state.loading || state.draft == null || _userId == null) return null; state = state.copyWith(loading: true, clearResult: true); final service = ref.read(taskCreationServiceProvider); final result = submit ? await service.submit(userId: _userId!, draft: state.draft!) : await service.saveDraft(userId: _userId!, draft: state.draft!); state = state.copyWith(loading: false, result: result, validation: TaskValidationResult(result.issues), draft: result.task == null ? state.draft : await service.loadDraft(userId: _userId!, taskId: result.task!.id)); ref.invalidate(taskQueryResultProvider); if (result.isSuccess && submit) ref.invalidate(taskDetailsProvider(result.task!.id)); return result; }
  Future<void> deleteDraft() async { final id = state.draft?.id; if (id == null || _userId == null) return; await ref.read(taskCreationServiceProvider).deleteDraft(userId: _userId!, taskId: id); ref.invalidate(taskQueryResultProvider); state = const TaskCreationState(); }
  void reset() => state = const TaskCreationState();
}

final taskCreationControllerProvider = StateNotifierProvider.autoDispose<TaskCreationController, TaskCreationState>((ref) {
  final controller = TaskCreationController(ref);
  ref.listen(currentOrganizationUserProvider, (previous, next) {
    if (previous?.id != next?.id) controller.reset();
  });
  return controller;
});
final taskDraftProvider = Provider<TaskDraft?>((ref) => ref.watch(taskCreationControllerProvider).draft);
final taskCreationOptionsProvider = Provider<TaskCreationOptions?>((ref) => ref.watch(taskCreationControllerProvider).options);
final taskCreationDefaultsProvider = Provider<TaskCreationDefaults?>((ref) => ref.watch(taskCreationControllerProvider).defaults);
final taskTemplatesProvider = Provider((ref) => ref.watch(taskCreationControllerProvider).options?.templates ?? const []);
final taskOwnerCandidatesProvider = Provider((ref) => ref.watch(taskCreationControllerProvider).options?.ownerCandidates ?? const []);
final taskCreationValidationProvider = Provider((ref) => ref.watch(taskCreationControllerProvider).validation);
final taskSubmissionStateProvider = Provider((ref) => ref.watch(taskCreationControllerProvider).loading);
