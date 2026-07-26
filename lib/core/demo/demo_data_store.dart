import '../domain/app_clock.dart';
import '../domain/authorization_models.dart';
import '../domain/domain_enums.dart';
import '../domain/entities.dart';
import 'demo_seed_ids.dart';

/// The single deterministic, Flutter-independent source for the deadline demo.
/// Mutations live only for this process and are reset on application restart.
final class DemoDataStore {
  DemoDataStore({AppClock clock = const SystemAppClock()}) : now = clock.now().toUtc() {
    _build();
  }

  final DateTime now;
  final organizations = <Organization>[];
  final users = <OrganizationUser>[];
  final departments = <Department>[];
  final teams = <Team>[];
  final memberships = <TeamMembership>[];
  final roles = <Role>[];
  final permissions = <Permission>[];
  final rolePermissions = <RolePermission>[];
  final permissionOverrides = <PermissionOverride>[];
  final priorities = <TaskPriority>[];
  final categories = <TaskCategory>[];
  final confidentialityLevels = <ConfidentialityLevel>[];
  final approvalRules = <ApprovalRule>[];
  final escalationRules = <EscalationRule>[];
  final notificationTemplates = <NotificationTemplate>[];
  final taskTemplates = <TaskTemplate>[];
  final tasks = <Task>[];
  final assignments = <TaskAssignment>[];
  final checklistItems = <ChecklistItem>[];
  final comments = <TaskComment>[];
  final attachments = <TaskAttachment>[];
  final blockers = <TaskBlocker>[];
  final extensionRequests = <DeadlineExtensionRequest>[];
  final approvals = <TaskApproval>[];
  final notifications = <AppNotification>[];
  final auditEvents = <AuditEvent>[];
  final syncOperations = <SyncOperation>[];
  final settings = <String, String>{};

  void _build() {
    organizations.add(const Organization(id: DemoSeedIds.organization, nameAr: 'المنظمة التجريبية', nameEn: 'Demo Organization'));
    roles.addAll(const [
      Role(id: DemoSeedIds.roleEmployee, code: SystemRoleCode.employee, nameAr: 'موظف', nameEn: 'Employee'),
      Role(id: DemoSeedIds.roleManager, code: SystemRoleCode.manager, nameAr: 'مدير', nameEn: 'Manager'),
      Role(id: DemoSeedIds.roleSenior, code: SystemRoleCode.seniorManagement, nameAr: 'إدارة عليا', nameEn: 'Senior Management'),
      Role(id: DemoSeedIds.roleAdministrator, code: SystemRoleCode.administrator, nameAr: 'مسؤول', nameEn: 'Administrator'),
    ]);
    departments.addAll(const [
      Department(id: DemoSeedIds.executive, code: 'EXEC', nameAr: 'الإدارة التنفيذية', nameEn: 'Executive', managerUserId: DemoSeedIds.omar),
      Department(id: DemoSeedIds.operations, code: 'OPS', nameAr: 'العمليات', nameEn: 'Operations', parentDepartmentId: DemoSeedIds.executive, managerUserId: DemoSeedIds.sara),
      Department(id: DemoSeedIds.finance, code: 'FIN', nameAr: 'المالية', nameEn: 'Finance', parentDepartmentId: DemoSeedIds.executive),
      Department(id: DemoSeedIds.humanResources, code: 'HR', nameAr: 'الموارد البشرية', nameEn: 'Human Resources', parentDepartmentId: DemoSeedIds.executive),
      Department(id: DemoSeedIds.informationTechnology, code: 'IT', nameAr: 'تقنية المعلومات', nameEn: 'Information Technology', parentDepartmentId: DemoSeedIds.executive, managerUserId: DemoSeedIds.laila),
    ]);
    users.addAll(const [
      OrganizationUser(id: DemoSeedIds.ahmed, employeeNumber: 'E001', nameAr: 'أحمد حسن', nameEn: 'Ahmed Hassan', departmentId: DemoSeedIds.operations, managerId: DemoSeedIds.sara, roleId: DemoSeedIds.roleEmployee, status: UserStatus.active),
      OrganizationUser(id: DemoSeedIds.sara, employeeNumber: 'M001', nameAr: 'سارة محمود', nameEn: 'Sara Mahmoud', departmentId: DemoSeedIds.operations, managerId: DemoSeedIds.omar, roleId: DemoSeedIds.roleManager, status: UserStatus.active),
      OrganizationUser(id: DemoSeedIds.omar, employeeNumber: 'X001', nameAr: 'عمر النعيمي', nameEn: 'Omar Al Nuaimi', departmentId: DemoSeedIds.executive, roleId: DemoSeedIds.roleSenior, status: UserStatus.active),
      OrganizationUser(id: DemoSeedIds.laila, employeeNumber: 'A001', nameAr: 'ليلى يوسف', nameEn: 'Laila Youssef', departmentId: DemoSeedIds.informationTechnology, managerId: DemoSeedIds.omar, roleId: DemoSeedIds.roleAdministrator, status: UserStatus.active),
      OrganizationUser(id: DemoSeedIds.khaled, employeeNumber: 'E002', nameAr: 'خالد إبراهيم', nameEn: 'Khaled Ibrahim', departmentId: DemoSeedIds.informationTechnology, managerId: DemoSeedIds.laila, roleId: DemoSeedIds.roleEmployee, status: UserStatus.active),
      OrganizationUser(id: 'user-mariam-saleh', employeeNumber: 'E003', nameAr: 'مريم صالح', nameEn: 'Mariam Saleh', departmentId: DemoSeedIds.operations, managerId: DemoSeedIds.sara, roleId: DemoSeedIds.roleEmployee, status: UserStatus.active),
      OrganizationUser(id: 'user-yousef-ali', employeeNumber: 'E004', nameAr: 'يوسف علي', nameEn: 'Yousef Ali', departmentId: DemoSeedIds.operations, managerId: DemoSeedIds.sara, roleId: DemoSeedIds.roleEmployee, status: UserStatus.active),
    ]);
    teams.addAll(const [
      Team(id: DemoSeedIds.fieldOperations, code: 'FIELD', departmentId: DemoSeedIds.operations, nameAr: 'العمليات الميدانية', nameEn: 'Field Operations', managerUserId: DemoSeedIds.sara),
      Team(id: DemoSeedIds.serviceCoordination, code: 'SERVICE', departmentId: DemoSeedIds.operations, nameAr: 'تنسيق الخدمات', nameEn: 'Service Coordination'),
      Team(id: DemoSeedIds.accountsPayable, code: 'AP', departmentId: DemoSeedIds.finance, nameAr: 'الحسابات الدائنة', nameEn: 'Accounts Payable'),
      Team(id: DemoSeedIds.reporting, code: 'REPORT', departmentId: DemoSeedIds.finance, nameAr: 'التقارير', nameEn: 'Reporting'),
      Team(id: DemoSeedIds.recruitment, code: 'RECRUIT', departmentId: DemoSeedIds.humanResources, nameAr: 'التوظيف', nameEn: 'Recruitment'),
      Team(id: DemoSeedIds.employeeServices, code: 'SERVICES', departmentId: DemoSeedIds.humanResources, nameAr: 'خدمات الموظفين', nameEn: 'Employee Services'),
      Team(id: DemoSeedIds.technicalSupportQueue, code: 'SUPPORT', departmentId: DemoSeedIds.informationTechnology, nameAr: 'الدعم الفني', nameEn: 'Technical Support Queue', managerUserId: DemoSeedIds.laila, isQueueEnabled: true),
      Team(id: DemoSeedIds.applicationSupport, code: 'APPS', departmentId: DemoSeedIds.informationTechnology, nameAr: 'دعم التطبيقات', nameEn: 'Application Support'),
    ]);
    memberships.addAll([
      _membership('membership-ahmed', DemoSeedIds.fieldOperations, DemoSeedIds.ahmed, TeamMembershipRole.member),
      _membership('membership-sara', DemoSeedIds.fieldOperations, DemoSeedIds.sara, TeamMembershipRole.lead),
      _membership('membership-mariam', DemoSeedIds.fieldOperations, 'user-mariam-saleh', TeamMembershipRole.member),
      _membership('membership-yousef', DemoSeedIds.fieldOperations, 'user-yousef-ali', TeamMembershipRole.member),
      _membership('membership-khaled', DemoSeedIds.technicalSupportQueue, DemoSeedIds.khaled, TeamMembershipRole.queueMember),
    ]);
    permissions.addAll(PermissionCode.values.where((e) => e != PermissionCode.unknown).map((e) => Permission(id: 'permission-${e.code}', code: e)));
    const matrix = <String, Set<PermissionCode>>{
      DemoSeedIds.roleEmployee: {PermissionCode.profileViewSelf, PermissionCode.organizationViewOwnContext, PermissionCode.taskViewOwn, PermissionCode.taskCreateSelf, PermissionCode.taskAssignSelf, PermissionCode.taskRequestExtension, PermissionCode.reportViewSelf},
      DemoSeedIds.roleManager: {PermissionCode.profileViewSelf, PermissionCode.organizationViewOwnContext, PermissionCode.organizationViewTeam, PermissionCode.organizationViewDepartment, PermissionCode.organizationViewAll, PermissionCode.directoryViewUsers, PermissionCode.directoryViewReportingLines, PermissionCode.taskViewOwn, PermissionCode.taskViewTeam, PermissionCode.taskViewDepartment, PermissionCode.taskCreateSelf, PermissionCode.taskCreateForOthers, PermissionCode.taskAssignSelf, PermissionCode.taskAssignTeam, PermissionCode.taskAssignDepartment, PermissionCode.taskAssignOrganization, PermissionCode.taskReassignTeam, PermissionCode.taskReassignDepartment, PermissionCode.taskReassignOrganization, PermissionCode.taskApprove, PermissionCode.taskRequestExtension, PermissionCode.taskManageRecurrence, PermissionCode.reportViewSelf, PermissionCode.reportViewTeam, PermissionCode.reportViewDepartment, PermissionCode.reportViewEmployeePerformance},
      DemoSeedIds.roleSenior: {PermissionCode.profileViewSelf, PermissionCode.organizationViewOwnContext, PermissionCode.organizationViewAll, PermissionCode.directoryViewUsers, PermissionCode.directoryViewReportingLines, PermissionCode.taskViewOwn, PermissionCode.taskViewAll, PermissionCode.taskViewConfidential, PermissionCode.taskViewRestricted, PermissionCode.taskCreateForOthers, PermissionCode.taskAssignOrganization, PermissionCode.taskReassignOrganization, PermissionCode.taskApprove, PermissionCode.reportViewSelf, PermissionCode.reportViewTeam, PermissionCode.reportViewDepartment, PermissionCode.reportViewOrganization, PermissionCode.reportViewEmployeePerformance},
      DemoSeedIds.roleAdministrator: {PermissionCode.profileViewSelf, PermissionCode.organizationViewOwnContext, PermissionCode.organizationViewAll, PermissionCode.directoryViewUsers, PermissionCode.directoryViewReportingLines, PermissionCode.adminView, PermissionCode.adminManageUsers, PermissionCode.adminManageOrganization, PermissionCode.adminManageRoles, PermissionCode.adminManageConfiguration, PermissionCode.adminViewAudit, PermissionCode.adminManageSync, PermissionCode.adminManageSettings},
    };
    for (final entry in matrix.entries) {
      for (final code in entry.value) {
        rolePermissions.add(RolePermission(id: '${entry.key}-permission-${code.code}', roleId: entry.key, permissionId: 'permission-${code.code}'));
      }
    }
    for (var i = 0; i < 5; i++) {
      const codes = ['low', 'normal', 'high', 'urgent', 'critical'];
      priorities.add(TaskPriority(id: 'priority-${codes[i]}', code: codes[i], labelAr: codes[i], labelEn: codes[i], level: i + 1));
    }
    for (final code in ['operations', 'approval', 'reporting', 'support', 'personal']) {
      categories.add(TaskCategory(id: 'category-$code', code: code, labelAr: code, labelEn: code, defaultPriorityId: DemoSeedIds.priorityNormal));
    }
    confidentialityLevels.addAll(const [
      ConfidentialityLevel(id: 'confidentiality-public', code: 'public', labelAr: 'عام', labelEn: 'Public', level: 1),
      ConfidentialityLevel(id: DemoSeedIds.confidentialityInternal, code: 'internal', labelAr: 'داخلي', labelEn: 'Internal', level: 2),
      ConfidentialityLevel(id: 'confidentiality-restricted', code: 'restricted', labelAr: 'مقيد', labelEn: 'Restricted', level: 3),
    ]);
    approvalRules.add(const ApprovalRule(id: 'approval-rule-manager', code: 'manager', nameAr: 'اعتماد المدير', nameEn: 'Manager approval'));
    escalationRules.add(const EscalationRule(id: 'escalation-rule-overdue', code: 'overdue', nameAr: 'تصعيد التأخير', nameEn: 'Overdue escalation'));
    notificationTemplates.add(const NotificationTemplate(id: 'notification-template-assigned', code: 'assigned', titleAr: 'مهمة جديدة', titleEn: 'New task', messageAr: 'تم تعيين مهمة', messageEn: 'A task was assigned'));
    taskTemplates.add(const TaskTemplate(id: 'task-template-standard', titleAr: 'مهمة قياسية', titleEn: 'Standard task', categoryId: 'category-operations', priorityId: DemoSeedIds.priorityNormal));
    for (var i = 1; i <= 15; i++) {
      final id = DemoSeedIds.scenario(i);
      tasks.add(Task(id: id, taskNumber: 'SCN-${i.toString().padLeft(2, '0')}', titleAr: 'السيناريو $i', titleEn: 'Scenario $i', descriptionAr: 'بيانات عرض حتمية', descriptionEn: 'Deterministic demo data', creatorId: i == 15 ? DemoSeedIds.omar : DemoSeedIds.sara, creatorRoleCode: i == 15 ? SystemRoleCode.seniorManagement : SystemRoleCode.manager, creationSource: TaskCreationSource.manual, assignmentMode: i == 8 ? AssignmentMode.individualCopies : (i == 11 ? AssignmentMode.teamQueue : AssignmentMode.singleOwner), leadOwnerId: DemoSeedIds.ahmed, assignedTeamId: i == 11 || i == 12 ? DemoSeedIds.technicalSupportQueue : DemoSeedIds.fieldOperations, batchId: i == 7 ? 'batch-policy-annual' : null, priorityId: i >= 10 ? DemoSeedIds.priorityUrgent : DemoSeedIds.priorityNormal, categoryId: i == 11 ? 'category-support' : 'category-operations', status: i == 4 ? TaskStatus.blocked : TaskStatus.inProgress, confidentialityLevelId: DemoSeedIds.confidentialityInternal, visibilityType: TaskVisibilityType.assignedUsers, dueDate: now.add(Duration(days: i)), progressPercentage: i * 5, approvalRequired: i == 2 || i == 3, completionEvidenceRequired: i == 1, allowDecline: true, allowExtension: true, approvalStatus: i == 2 ? ApprovalStatus.pending : ApprovalStatus.notRequired, isPersonal: i == 10, isRecurring: i == 7, createdAt: now.subtract(Duration(days: i)), updatedAt: now));
      assignments.add(TaskAssignment(id: 'assignment-$id', taskId: id, userId: i == 11 ? DemoSeedIds.khaled : DemoSeedIds.ahmed, assignmentRole: AssignmentRole.owner, assignmentStatus: AssignmentStatus.active, isPrimary: true, assignedAt: now, createdAt: now, updatedAt: now));
    }
    // Preserve the annual batch and support queue query demonstrations.
    for (var i = 1; i <= 11; i++) {
      final source = tasks[6];
      tasks.add(Task(id: 'batch-copy-$i', taskNumber: 'BATCH-${i.toString().padLeft(2, '0')}', titleAr: source.titleAr, descriptionAr: source.descriptionAr, creatorId: source.creatorId, creatorRoleCode: source.creatorRoleCode, creationSource: TaskCreationSource.recurrence, assignmentMode: AssignmentMode.individualCopies, leadOwnerId: DemoSeedIds.ahmed, batchId: 'batch-policy-annual', priorityId: source.priorityId, categoryId: source.categoryId, status: TaskStatus.upcoming, confidentialityLevelId: source.confidentialityLevelId, visibilityType: source.visibilityType, dueDate: now.add(Duration(days: 30 + i)), progressPercentage: 0, approvalRequired: false, completionEvidenceRequired: false, allowDecline: true, allowExtension: true, approvalStatus: ApprovalStatus.notRequired, isPersonal: false, isRecurring: true, createdAt: now, updatedAt: now));
    }
    checklistItems.addAll(const [ChecklistItem(id: 'check-01-a', taskId: 'scenario-01', titleAr: 'التحقق من الطلب', titleEn: 'Verify request', isMandatory: true, isCompleted: true), ChecklistItem(id: 'check-01-b', taskId: 'scenario-01', titleAr: 'إغلاق الطلب', titleEn: 'Close request', isMandatory: true, isCompleted: false)]);
    blockers.add(TaskBlocker(id: 'blocker-04', taskId: 'scenario-04', reportedBy: DemoSeedIds.ahmed, type: BlockerType.externalDependency, description: 'External finance dependency', startedAt: now.subtract(const Duration(days: 4)), status: BlockerStatus.active));
    extensionRequests.add(DeadlineExtensionRequest(id: 'extension-09', taskId: 'scenario-09', requestedBy: DemoSeedIds.ahmed, currentDueDate: now.add(const Duration(days: 7)), requestedDueDate: now.add(const Duration(days: 14)), reason: 'External dependency', status: ExtensionRequestStatus.pending));
    approvals.add(TaskApproval(id: 'approval-02', taskId: 'scenario-02', approverId: DemoSeedIds.sara, status: ApprovalStatus.pending, submittedAt: now, sequenceNumber: 1));
    notifications.add(AppNotification(id: 'notification-demo', recipientId: DemoSeedIds.ahmed, type: NotificationType.taskAssigned, titleAr: 'مهمة جديدة', titleEn: 'Task assigned', messageAr: 'لديك مهمة', messageEn: 'You have a task', taskId: 'scenario-01', createdAt: now, isRead: false, deliveryChannel: NotificationDeliveryChannel.inApp, deliveryStatus: NotificationDeliveryStatus.delivered));
    syncOperations.addAll([SyncOperation(id: 'sync-pending', entityType: 'task', entityId: 'scenario-12', operationType: SyncOperationType.update, payloadJson: '{}', createdAt: now, status: SyncOperationStatus.pending), SyncOperation(id: 'sync-failed', entityType: 'task', entityId: 'scenario-14', operationType: SyncOperationType.update, payloadJson: '{}', createdAt: now, status: SyncOperationStatus.failed), SyncOperation(id: 'sync-conflict', entityType: 'task', entityId: 'scenario-13', operationType: SyncOperationType.update, payloadJson: '{}', createdAt: now, status: SyncOperationStatus.conflict, conflictType: SyncConflictType.assignment)]);
  }

  TeamMembership _membership(String id, String team, String user, TeamMembershipRole role) => TeamMembership(id: id, teamId: team, userId: user, membershipRole: role, joinedAt: now.subtract(const Duration(days: 365)));
}
