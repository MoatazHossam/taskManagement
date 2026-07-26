part of '../app_database.dart';

@DriftAccessor(tables: [Tasks, TaskAssignments, ChecklistItems, TaskComments, TaskAttachments, TaskBlockers, DeadlineExtensionRequests, TaskApprovals])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {

  TaskDao(super.attachedDatabase);
 Future<Task?> getTaskById(String id)=>(attachedDatabase.select(attachedDatabase.tasks)..where((t)=>t.id.equals(id))).getSingleOrNull();

  Future<Task?> getTaskByNumber(String n)=>(attachedDatabase.select(attachedDatabase.tasks)..where((t)=>t.taskNumber.equals(n))).getSingleOrNull();

  Future<List<Task>> getTasks()=>attachedDatabase.select(attachedDatabase.tasks).get();

  Future<List<Task>> getTasksForUser(String id) async {
  final q=attachedDatabase.select(attachedDatabase.tasks).join([innerJoin(attachedDatabase.taskAssignments,attachedDatabase.taskAssignments.taskId.equalsExp(attachedDatabase.tasks.id))]);q.where(attachedDatabase.taskAssignments.userId.equals(id));return (await q.get()).map((r)=>r.readTable(attachedDatabase.tasks)).toList();
  } Future<List<Task>> getTasksForTeam(String id)=>(attachedDatabase.select(attachedDatabase.tasks)..where((t)=>t.assignedTeamId.equals(id))).get();

  Future<List<Task>> getTasksByBatch(String id)=>(attachedDatabase.select(attachedDatabase.tasks)..where((t)=>t.batchId.equals(id))).get();

  Future<List<Task>> getSubtasks(String id)=>(attachedDatabase.select(attachedDatabase.tasks)..where((t)=>t.parentTaskId.equals(id))).get();
 Future<List<TaskAssignment>> getTaskAssignments(String id)=>(attachedDatabase.select(attachedDatabase.taskAssignments)..where((t)=>t.taskId.equals(id))).get();

  Future<List<ChecklistItem>> getChecklistItems(String id)=>(attachedDatabase.select(attachedDatabase.checklistItems)..where((t)=>t.taskId.equals(id))).get();

  Future<List<TaskComment>> getComments(String id)=>(attachedDatabase.select(attachedDatabase.taskComments)..where((t)=>t.taskId.equals(id)&t.isDeleted.equals(false))).get();

  Future<List<TaskAttachment>> getAttachments(String id)=>(attachedDatabase.select(attachedDatabase.taskAttachments)..where((t)=>t.taskId.equals(id))).get();

  Future<List<TaskBlocker>> getBlockers(String id)=>(attachedDatabase.select(attachedDatabase.taskBlockers)..where((t)=>t.taskId.equals(id))).get();

  Future<List<DeadlineExtensionRequest>> getExtensionRequests(String id)=>(attachedDatabase.select(attachedDatabase.deadlineExtensionRequests)..where((t)=>t.taskId.equals(id))).get();

  Future<List<TaskApproval>> getApprovals(String id)=>(attachedDatabase.select(attachedDatabase.taskApprovals)..where((t)=>t.taskId.equals(id))).get();
 Future<void> insertTask(TasksCompanion v)=>attachedDatabase.into(attachedDatabase.tasks).insert(v);

  Future<bool> updateTask(TasksCompanion v)=>attachedDatabase.update(attachedDatabase.tasks).replace(v);

  Future<void> insertAssignments(List<TaskAssignmentsCompanion> v)=>attachedDatabase.batch((b)=>b.insertAll(attachedDatabase.taskAssignments,v));

  Future<void> insertChecklistItems(List<ChecklistItemsCompanion> v)=>attachedDatabase.batch((b)=>b.insertAll(attachedDatabase.checklistItems,v));

  Future<void> insertComment(TaskCommentsCompanion v)=>attachedDatabase.into(attachedDatabase.taskComments).insert(v);

  Future<void> insertAttachmentMetadata(TaskAttachmentsCompanion v)=>attachedDatabase.into(attachedDatabase.taskAttachments).insert(v);

  Future<void> insertBlocker(TaskBlockersCompanion v)=>attachedDatabase.into(attachedDatabase.taskBlockers).insert(v);

  Future<void> insertExtensionRequest(DeadlineExtensionRequestsCompanion v)=>attachedDatabase.into(attachedDatabase.deadlineExtensionRequests).insert(v);

  Future<void> insertApproval(TaskApprovalsCompanion v)=>attachedDatabase.into(attachedDatabase.taskApprovals).insert(v);
}
