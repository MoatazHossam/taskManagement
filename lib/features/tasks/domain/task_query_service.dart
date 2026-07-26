import 'task_query_models.dart';

abstract interface class TaskQueryService {
  Future<TaskQueryResult> queryTasks({required String userId, required TaskQuery query});
  Future<TaskDetails?> getTaskDetails({required String userId, required String taskId});
  Future<List<TaskTimelineEntry>> getTaskTimeline({required String userId, required String taskId});
  Future<List<TaskSavedFilter>> getSavedFilters(String userId);
  Future<void> saveFilter({required String userId, required TaskSavedFilter filter});
  Future<void> deleteSavedFilter({required String userId, required String filterId});
  Future<void> setDefaultFilter({required String userId, required String? filterId});
}
