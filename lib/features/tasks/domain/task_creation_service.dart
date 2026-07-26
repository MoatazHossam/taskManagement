import 'task_creation_models.dart';

abstract interface class TaskCreationService {
  Future<TaskCreationDefaults> getDefaults({required String userId});
  Future<TaskCreationOptions> getOptions({required String userId});
  Future<TaskValidationResult> validate({required String userId, required TaskDraft draft});
  Future<TaskCreationResult> saveDraft({required String userId, required TaskDraft draft});
  Future<TaskCreationResult> submit({required String userId, required TaskDraft draft});
  Future<TaskDraft?> loadDraft({required String userId, required String taskId});
  Future<void> deleteDraft({required String userId, required String taskId});
}
