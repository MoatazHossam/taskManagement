import 'package:flutter/widgets.dart';
import '../../../core/domain/domain_enums.dart';
import '../domain/task_query_models.dart';

enum TaskPageKind { employee, manager, seniorManagement, generic }

class TaskPageContext {
  const TaskPageContext(this.kind);
  final TaskPageKind kind;
  String title(BuildContext context) => _pick(context, switch (kind) {
    TaskPageKind.employee => ('My Tasks', 'مهامي'),
    TaskPageKind.manager => ('Team Tasks', 'مهام الفريق'),
    TaskPageKind.seniorManagement => ('Critical Tasks', 'المهام الحرجة'),
    TaskPageKind.generic => ('All Tasks', 'جميع المهام'),
  });
  String searchHint(BuildContext context) => _pick(context, switch (kind) {
    TaskPageKind.employee => ('Search my tasks', 'ابحث في مهامي'),
    TaskPageKind.manager => ('Search team tasks', 'ابحث في مهام الفريق'),
    TaskPageKind.seniorManagement => ('Search critical tasks', 'ابحث في المهام الحرجة'),
    TaskPageKind.generic => ('Search tasks', 'ابحث في المهام'),
  });
  TaskQuery get initialQuery => TaskQuery(
    view: kind == TaskPageKind.seniorManagement ? TaskListView.critical : TaskListView.all,
    scope: kind == TaskPageKind.employee ? TaskQueryScope.self : kind == TaskPageKind.manager ? TaskQueryScope.team : TaskQueryScope.organization,
  );
  bool get showsScope => kind == TaskPageKind.manager;
  bool get isCritical => kind == TaskPageKind.seniorManagement;
}

String _pick(BuildContext context, (String, String) labels) =>
    Localizations.localeOf(context).languageCode == 'ar' ? labels.$2 : labels.$1;

abstract final class TaskPresentation {
  static String text(BuildContext c, String en, String ar) => _pick(c, (en, ar));
  static String status(BuildContext c, TaskStatus value) => _pick(c, switch (value) {
    TaskStatus.draft => ('Draft','مسودة'), TaskStatus.assigned => ('Assigned','معينة'),
    TaskStatus.acknowledged => ('Acknowledged','تم الاستلام'), TaskStatus.inProgress => ('In progress','قيد التنفيذ'),
    TaskStatus.paused => ('Paused','متوقفة مؤقتاً'), TaskStatus.blocked => ('Blocked','متوقفة'),
    TaskStatus.completionRequested => ('Completion requested','طُلب إكمالها'), TaskStatus.returnedForCorrection => ('Returned for correction','معادة للتصحيح'),
    TaskStatus.completed => ('Completed','مكتملة'), TaskStatus.declined => ('Declined','مرفوضة'),
    TaskStatus.cancelled => ('Cancelled','ملغاة'), TaskStatus.reopened => ('Reopened','أعيد فتحها'),
    TaskStatus.expired => ('Expired','منتهية'), TaskStatus.upcoming => ('Upcoming','قادمة'), TaskStatus.unknown => ('Unknown','غير معروفة')});
  static String priority(BuildContext c, String? code, {String? en, String? ar}) => _pick(c, switch(code) {
    'low'=>('Low','منخفضة'), 'normal'=>('Normal','عادية'), 'high'=>('High','عالية'), 'urgent'=>('Urgent','عاجلة'),
    'critical'=>('Critical','حرجة'), _=>(en ?? 'Unknown', ar ?? 'غير معروفة')});
  static String confidentiality(BuildContext c, String? code) => _pick(c, switch(code) {
    'public'=>('Public','عامة'), 'internal'=>('Internal','داخلية'), 'confidential'=>('Confidential','سرية'),
    'restricted'=>('Restricted','مقيدة'), _=>('Unknown','غير معروفة')});
  static String sync(BuildContext c, LocalEntitySyncState value) => _pick(c, switch(value) {
    LocalEntitySyncState.synced=>('Synced','تمت المزامنة'), LocalEntitySyncState.pending=>('Pending synchronization','بانتظار المزامنة'),
    LocalEntitySyncState.failed=>('Synchronization failed','فشلت المزامنة'), LocalEntitySyncState.conflict=>('Synchronization conflict','تعارض في المزامنة'),
    LocalEntitySyncState.localOnly=>('Local only','محلية فقط'), LocalEntitySyncState.unknown=>('Unknown','غير معروفة')});
  static String approval(BuildContext c, ApprovalStatus value) => _pick(c, switch(value) {
    ApprovalStatus.notRequired=>('Not required','غير مطلوب'), ApprovalStatus.pending=>('Pending approval','بانتظار الاعتماد'),
    ApprovalStatus.approved=>('Approved','معتمدة'), ApprovalStatus.returned=>('Returned','معادة'),
    ApprovalStatus.rejected=>('Rejected','مرفوضة'), ApprovalStatus.unknown=>('Unknown','غير معروفة')});
  static String assignmentMode(BuildContext c, AssignmentMode value) => _pick(c, switch(value) {
    AssignmentMode.singleOwner=>('Single owner','مسؤول واحد'), AssignmentMode.leadWithContributors=>('Lead with contributors','مسؤول مع مساهمين'),
    AssignmentMode.individualCopies=>('Individual copies','نسخ فردية'), AssignmentMode.teamQueue=>('Team queue','قائمة فريق'),
    AssignmentMode.shared=>('Shared','مشتركة'), AssignmentMode.unknown=>('Unknown','غير معروفة')});
  static String assignmentRole(BuildContext c, AssignmentRole value) => _pick(c, switch(value) {
    AssignmentRole.owner=>('Owner','المسؤول'), AssignmentRole.leadOwner=>('Lead owner','المسؤول الرئيسي'),
    AssignmentRole.contributor=>('Contributor','المساهم'), AssignmentRole.sharedAssignee=>('Shared assignee','المكلف المشترك'),
    AssignmentRole.follower=>('Follower','المتابع'), AssignmentRole.queueClaimant=>('Queue claimant','مستلم قائمة الانتظار'),
    AssignmentRole.approver=>('Approver','المعتمد'), AssignmentRole.unknown=>('Assignee','المكلف')});
  static String event(BuildContext c, AuditEventType value) => _pick(c, switch(value) {
    AuditEventType.created=>('Task created','تم إنشاء المهمة'), AuditEventType.updated=>('Task updated','تم تحديث المهمة'),
    AuditEventType.assigned=>('Task assigned','تم إسناد المهمة'), AuditEventType.reassigned=>('Task reassigned','أعيد إسناد المهمة'),
    AuditEventType.statusChanged=>('Status changed','تم تغيير الحالة'), AuditEventType.approved=>('Task approved','تم اعتماد المهمة'),
    AuditEventType.returned=>('Task returned','تمت إعادة المهمة'), AuditEventType.deleted=>('Task deleted','تم حذف المهمة'),
    AuditEventType.syncConflict=>('Synchronization conflict','تعارض في المزامنة'), _=>('Activity recorded','تم تسجيل نشاط')});
  static String view(BuildContext c, TaskListView v) => _pick(c, switch(v) {
    TaskListView.all=>('All','الكل'), TaskListView.today=>('Today','اليوم'), TaskListView.thisWeek=>('This Week','هذا الأسبوع'),
    TaskListView.overdue=>('Overdue','متأخرة'), TaskListView.blocked=>('Blocked','متوقفة'), TaskListView.awaitingApproval=>('Awaiting Approval','بانتظار الاعتماد'),
    TaskListView.teamQueue=>('Team Queue','قائمة الفريق'), TaskListView.completed=>('Completed','مكتملة'), TaskListView.drafts=>('Drafts','مسودات'),
    TaskListView.critical=>('Critical','حرجة')});
  static String scope(BuildContext c, TaskQueryScope s) => _pick(c, switch(s) {
    TaskQueryScope.self=>('My Tasks','مهامي'), TaskQueryScope.team=>('Team','الفريق'),
    TaskQueryScope.department=>('Department','الإدارة'), TaskQueryScope.organization=>('Organization','المؤسسة')});
}
