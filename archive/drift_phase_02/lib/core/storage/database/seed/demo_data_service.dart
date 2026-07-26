import 'package:drift/drift.dart';

import '../../../domain/app_clock.dart';
import '../app_database.dart';
import 'demo_seed_ids.dart';

/// Installs the deterministic, entirely local data set used by the demo.
class DemoDataService {
  DemoDataService(this.database, this.clock);

  final AppDatabase database;
  final AppClock clock;

  static const seedVersion = 1;

  Future<int?> getSeedVersion() async {
    final row = await (database.select(database.appSettings)
          ..where((setting) => setting.key.equals('demo_seed_version')))
        .getSingleOrNull();
    return int.tryParse(row?.value ?? '');
  }

  Future<void> ensureSeeded() async {
    if (await getSeedVersion() != seedVersion) {
      await resetAndSeed();
    }
  }

  Future<void> resetAndSeed() => database.transaction(() async {
        // Deferral is connection-level SQLite behavior and has no typed Drift API.
        await database.customStatement('PRAGMA defer_foreign_keys = ON');
        await _deleteExistingData();
        await _seed();
      });

  Future<void> _deleteExistingData() async {
    // Children precede their referenced parents.
    await database.delete(database.rolePermissions).go();
    await database.delete(database.teamMemberships).go();
    await database.delete(database.taskApprovals).go();
    await database.delete(database.deadlineExtensionRequests).go();
    await database.delete(database.taskBlockers).go();
    await database.delete(database.taskAttachments).go();
    await database.delete(database.taskComments).go();
    await database.delete(database.checklistItems).go();
    await database.delete(database.taskAssignments).go();
    await database.delete(database.auditEvents).go();
    await database.delete(database.syncOperations).go();
    await database.delete(database.appNotifications).go();
    await database.delete(database.savedTaskFilters).go();
    await database.delete(database.taskTemplates).go();
    await database.delete(database.tasks).go();
    await database.delete(database.recurrenceRules).go();
    await database.delete(database.notificationTemplates).go();
    await database.delete(database.escalationRules).go();
    await database.delete(database.approvalRules).go();
    await database.delete(database.categories).go();
    await database.delete(database.priorities).go();
    await database.delete(database.confidentialityLevels).go();
    await database.delete(database.teams).go();
    await database.delete(database.users).go();
    await database.delete(database.permissions).go();
    await database.delete(database.roles).go();
    await database.delete(database.departments).go();
    await database.delete(database.organizations).go();
    await database.delete(database.appSettings).go();
  }

  Future<void> _seed() async {
    final now = clock.now().toUtc();
    await _seedOrganization(now);
    await _seedConfiguration();
    await _seedTasks(now);
    await _seedScenarioDetails(now);
    await database.into(database.appSettings).insert(
          AppSettingsCompanion.insert(
            key: 'demo_seed_version',
            value: '$seedVersion',
            updatedAt: now,
          ),
        );
  }

  Future<void> _seedOrganization(DateTime now) async {
    await database.into(database.organizations).insert(
          OrganizationsCompanion.insert(
            id: DemoSeedIds.organization,
            nameAr: 'منظمة العرض',
            nameEn: const Value('Demo Organization'),
          ),
        );
    await database.batch((batch) {
      batch.insertAll(database.roles, const [
        RolesCompanion.insert(id: DemoSeedIds.roleEmployee, code: 'employee', nameAr: 'موظف', nameEn: Value('Employee')),
        RolesCompanion.insert(id: DemoSeedIds.roleManager, code: 'manager', nameAr: 'مدير', nameEn: Value('Manager')),
        RolesCompanion.insert(id: DemoSeedIds.roleSenior, code: 'senior_management', nameAr: 'إدارة عليا', nameEn: Value('Senior Management')),
        RolesCompanion.insert(id: DemoSeedIds.roleAdministrator, code: 'administrator', nameAr: 'مسؤول', nameEn: Value('Administrator')),
      ]);
      final departments = [
        (DemoSeedIds.executive, 'EXEC', 'الإدارة التنفيذية', 'Executive Management'),
        (DemoSeedIds.operations, 'OPS', 'إدارة العمليات', 'Operations Department'),
        (DemoSeedIds.finance, 'FIN', 'الإدارة المالية', 'Finance Department'),
        (DemoSeedIds.humanResources, 'HR', 'الموارد البشرية', 'Human Resources Department'),
        (DemoSeedIds.informationTechnology, 'IT', 'تقنية المعلومات', 'Information Technology Department'),
      ];
      batch.insertAll(
        database.departments,
        departments.indexed.map((entry) => DepartmentsCompanion.insert(
              id: entry.$2.$1,
              code: entry.$2.$2,
              nameAr: entry.$2.$3,
              nameEn: Value(entry.$2.$4),
              sortOrder: Value(entry.$1),
              createdAt: now,
              updatedAt: now,
            )),
      );
    });
    final primaryUsers = [
      (DemoSeedIds.omar, '1001', 'عمر النعيمي', 'Omar Al Nuaimi', DemoSeedIds.executive, null, DemoSeedIds.roleSenior, 'ON'),
      (DemoSeedIds.sara, '1002', 'سارة محمود', 'Sara Mahmoud', DemoSeedIds.operations, DemoSeedIds.omar, DemoSeedIds.roleManager, 'SM'),
      (DemoSeedIds.ahmed, '1003', 'أحمد حسن', 'Ahmed Hassan', DemoSeedIds.operations, DemoSeedIds.sara, DemoSeedIds.roleEmployee, 'AH'),
      (DemoSeedIds.laila, '1004', 'ليلى يوسف', 'Laila Youssef', DemoSeedIds.informationTechnology, DemoSeedIds.omar, DemoSeedIds.roleAdministrator, 'LY'),
      (DemoSeedIds.khaled, '1005', 'خالد إبراهيم', 'Khaled Ibrahim', DemoSeedIds.informationTechnology, DemoSeedIds.laila, DemoSeedIds.roleEmployee, 'KI'),
    ];
    await database.batch((batch) {
      batch.insertAll(
        database.users,
        primaryUsers.map((user) => _user(
              id: user.$1,
              number: user.$2,
              nameAr: user.$3,
              nameEn: user.$4,
              departmentId: user.$5,
              managerId: user.$6,
              roleId: user.$7,
              initials: user.$8,
              now: now,
            )),
      );
      batch.insertAll(
        database.users,
        List.generate(12, (index) {
          final number = index + 1;
          return _user(
            id: 'user-copy-$number',
            number: '20${number.toString().padLeft(2, '0')}',
            nameAr: 'موظف تجريبي $number',
            nameEn: 'Demo Employee $number',
            departmentId: number.isEven ? DemoSeedIds.finance : DemoSeedIds.humanResources,
            managerId: DemoSeedIds.sara,
            roleId: DemoSeedIds.roleEmployee,
            initials: 'DE',
            now: now,
          );
        }),
      );
    });
    final teams = [
      (DemoSeedIds.fieldOperations, 'FIELD', DemoSeedIds.operations, 'العمليات الميدانية', 'Field Operations', false),
      (DemoSeedIds.serviceCoordination, 'SERVICE', DemoSeedIds.operations, 'تنسيق الخدمات', 'Service Coordination', false),
      (DemoSeedIds.accountsPayable, 'AP', DemoSeedIds.finance, 'الحسابات الدائنة', 'Accounts Payable', false),
      (DemoSeedIds.reporting, 'REPORT', DemoSeedIds.finance, 'التقارير', 'Reporting', false),
      (DemoSeedIds.recruitment, 'RECRUIT', DemoSeedIds.humanResources, 'التوظيف', 'Recruitment', false),
      (DemoSeedIds.employeeServices, 'EMP-SVC', DemoSeedIds.humanResources, 'خدمات الموظفين', 'Employee Services', false),
      (DemoSeedIds.technicalSupportQueue, 'TECH-Q', DemoSeedIds.informationTechnology, 'قائمة الدعم الفني', 'Technical Support Queue', true),
      (DemoSeedIds.applicationSupport, 'APP-SUP', DemoSeedIds.informationTechnology, 'دعم التطبيقات', 'Application Support', false),
    ];
    await database.batch((batch) {
      batch.insertAll(
        database.teams,
        teams.indexed.map((entry) => TeamsCompanion.insert(
              id: entry.$2.$1,
              code: entry.$2.$2,
              departmentId: entry.$2.$3,
              nameAr: entry.$2.$4,
              nameEn: Value(entry.$2.$5),
              isQueueEnabled: Value(entry.$2.$6),
              sortOrder: entry.$1,
              createdAt: now,
              updatedAt: now,
            )),
      );
      final memberships = <TeamMembershipsCompanion>[
        _membership('membership-0', DemoSeedIds.fieldOperations, DemoSeedIds.ahmed, 'member', now),
        _membership('membership-1', DemoSeedIds.fieldOperations, DemoSeedIds.sara, 'lead', now),
        _membership('membership-2', DemoSeedIds.technicalSupportQueue, DemoSeedIds.khaled, 'queue_member', now),
        ...List.generate(12, (index) {
          final number = index + 1;
          return _membership(
            'membership-copy-$number',
            number.isEven ? DemoSeedIds.accountsPayable : DemoSeedIds.employeeServices,
            'user-copy-$number',
            'member',
            now,
          );
        }),
      ];
      batch.insertAll(database.teamMemberships, memberships);
    });
  }

  UsersCompanion _user({required String id, required String number, required String nameAr, required String nameEn, required String departmentId, required String? managerId, required String roleId, required String initials, required DateTime now}) => UsersCompanion.insert(
        id: id, employeeNumber: number, nameAr: nameAr, nameEn: Value(nameEn),
        jobTitleAr: 'موظف', departmentId: departmentId, managerId: Value(managerId),
        roleId: roleId, avatarInitials: initials, status: 'active', createdAt: now,
        updatedAt: now,
      );

  TeamMembershipsCompanion _membership(String id, String teamId, String userId, String role, DateTime now) => TeamMembershipsCompanion.insert(
        id: id, teamId: teamId, userId: userId, membershipRole: role, joinedAt: now,
      );

  Future<void> _seedConfiguration() async {
    await database.batch((batch) {
      batch.insertAll(database.priorities, const [
        PrioritiesCompanion.insert(id: 'priority-low', code: 'low', labelAr: 'منخفض', labelEn: 'Low', level: 1, iconKey: 'flag', semanticColorKey: 'standard', defaultReminderMinutes: 60, defaultEscalationMinutes: 120, sortOrder: 1, isActive: true),
        PrioritiesCompanion.insert(id: 'priority-normal', code: 'normal', labelAr: 'عادي', labelEn: 'Normal', level: 2, iconKey: 'flag', semanticColorKey: 'standard', defaultReminderMinutes: 60, defaultEscalationMinutes: 120, sortOrder: 2, isActive: true),
        PrioritiesCompanion.insert(id: 'priority-high', code: 'high', labelAr: 'عال', labelEn: 'High', level: 3, iconKey: 'flag', semanticColorKey: 'standard', defaultReminderMinutes: 60, defaultEscalationMinutes: 120, sortOrder: 3, isActive: true),
        PrioritiesCompanion.insert(id: 'priority-urgent', code: 'urgent', labelAr: 'عاجل', labelEn: 'Urgent', level: 4, iconKey: 'flag', semanticColorKey: 'standard', defaultReminderMinutes: 60, defaultEscalationMinutes: 120, sortOrder: 4, isActive: true),
        PrioritiesCompanion.insert(id: 'priority-critical', code: 'critical', labelAr: 'حرج', labelEn: 'Critical', level: 5, iconKey: 'flag', semanticColorKey: 'standard', defaultReminderMinutes: 60, defaultEscalationMinutes: 120, sortOrder: 5, isActive: true),
      ]);
      const confidentiality = [('public', 'عام', 'Public', 0), ('internal', 'داخلي', 'Internal', 1), ('confidential', 'سري', 'Confidential', 2), ('restricted', 'مقيد', 'Restricted', 3)];
      batch.insertAll(database.confidentialityLevels, confidentiality.map((item) => ConfidentialityLevelsCompanion.insert(id: 'confidentiality-${item.$1}', code: item.$1, labelAr: item.$2, labelEn: item.$3, level: item.$4, semanticColorKey: 'standard', isActive: true, sortOrder: item.$4)));
      const categories = ['general_administrative', 'operations', 'finance', 'human_resources', 'information_technology', 'compliance', 'maintenance', 'report_preparation', 'review_approval', 'training_acknowledgement'];
      batch.insertAll(database.categories, categories.indexed.map((entry) => CategoriesCompanion.insert(id: 'category-${entry.$2}', code: entry.$2, labelAr: entry.$2, labelEn: entry.$2, defaultApprovalRequired: false, defaultEvidenceRequired: false, defaultPriorityId: 'priority-normal', allowDecline: true, allowExtension: true, defaultEstimatedEffortMinutes: 60, isActive: true, sortOrder: entry.$1)));
      const permissions = [('permission-view', 'view_tasks'), ('permission-manage', 'manage_tasks'), ('permission-approve', 'approve_tasks'), ('permission-reports', 'view_reports'), ('permission-admin', 'administer_system')];
      batch.insertAll(database.permissions, permissions.map((permission) => PermissionsCompanion.insert(id: permission.$1, code: permission.$2)));
    });
    var rolePermissionNumber = 0;
    final rolePermissions = <RolePermissionsCompanion>[];
    for (final role in [DemoSeedIds.roleEmployee, DemoSeedIds.roleManager, DemoSeedIds.roleSenior, DemoSeedIds.roleAdministrator]) {
      for (final permission in ['permission-view', 'permission-manage', 'permission-approve', 'permission-reports', 'permission-admin']) {
        if (role == DemoSeedIds.roleEmployee && permission != 'permission-view') continue;
        rolePermissions.add(RolePermissionsCompanion.insert(id: 'role-permission-${rolePermissionNumber++}', roleId: role, permissionId: permission));
      }
    }
    await database.batch((batch) => batch.insertAll(database.rolePermissions, rolePermissions));
  }

  Future<void> _seedTasks(DateTime now) async {
    final tasks = <TasksCompanion>[];
    for (var number = 1; number <= 15; number++) {
      tasks.add(_task(DemoSeedIds.scenario(number), 'SCN-${number.toString().padLeft(2, '0')}', 'سيناريو $number', now));
    }
    for (var number = 1; number <= 12; number++) {
      tasks.add(_task('scenario-06-copy-$number', 'SCN-06-$number', 'إقرار السياسة السنوية', now, batchId: 'batch-policy-annual', status: number <= 4 ? 'completed' : 'assigned'));
    }
    tasks.add(_task('scenario-07-unclaimed', 'SCN-07-U', 'طلب دعم غير مطالب', now, teamId: DemoSeedIds.technicalSupportQueue, status: 'assigned'));
    tasks.add(_task('scenario-07-claimed', 'SCN-07-C', 'طلب دعم مطالب', now, teamId: DemoSeedIds.technicalSupportQueue));
    await database.batch((batch) => batch.insertAll(database.tasks, tasks));
  }

  TasksCompanion _task(String id, String number, String title, DateTime now, {String? batchId, String? teamId, String status = 'in_progress', String? recurrenceRuleId, String? recurrenceSourceTaskId}) => TasksCompanion.insert(
        id: id, taskNumber: number, titleAr: title, titleEn: Value(title),
        descriptionAr: 'وصف تجريبي واقعي', descriptionEn: const Value('Realistic synthetic scenario description'),
        creatorId: DemoSeedIds.sara, creatorRoleCode: 'manager', creationSource: 'manual',
        assignmentMode: batchId != null ? 'individual_copies' : teamId != null ? 'team_queue' : 'single_owner',
        leadOwnerId: const Value(DemoSeedIds.ahmed), assignedTeamId: Value(teamId), batchId: Value(batchId),
        priorityId: DemoSeedIds.priorityNormal, categoryId: 'category-operations', status: status,
        confidentialityLevelId: DemoSeedIds.confidentialityInternal, visibilityType: 'assigned_users',
        dueDate: now.add(const Duration(days: 7)), progressPercentage: 25,
        approvalRequired: false, completionEvidenceRequired: false, allowDecline: true,
        allowExtension: true, approvalStatus: 'not_required', isPersonal: false,
        isRecurring: recurrenceRuleId != null, recurrenceRuleId: Value(recurrenceRuleId),
        recurrenceSourceTaskId: Value(recurrenceSourceTaskId), createdAt: now, updatedAt: now,
        syncState: 'synced', isLocallyModified: false,
      );

  Future<void> _seedScenarioDetails(DateTime now) async {
    final assignments = <TaskAssignmentsCompanion>[];
    for (var number = 1; number <= 15; number++) {
      assignments.add(_assignment('assignment-scenario-$number', DemoSeedIds.scenario(number), DemoSeedIds.ahmed, now, role: number == 5 ? 'lead_owner' : 'owner', status: number == 3 ? 'active' : 'assigned'));
    }
    for (var number = 1; number <= 12; number++) {
      assignments.add(_assignment('assignment-copy-$number', 'scenario-06-copy-$number', 'user-copy-$number', now, status: number <= 4 ? 'completed' : 'assigned'));
    }
    assignments.add(_assignment('assignment-queue-claimed', 'scenario-07-claimed', DemoSeedIds.khaled, now, role: 'queue_claimant', status: 'active'));
    assignments.add(_assignment('assignment-05-fin', 'scenario-05', 'user-copy-2', now, role: 'contributor', status: 'active', primary: false, contribution: 40));
    assignments.add(_assignment('assignment-05-hr', 'scenario-05', 'user-copy-1', now, role: 'contributor', status: 'active', primary: false, contribution: 30));
    await database.batch((batch) {
      batch.insertAll(database.taskAssignments, assignments);
      batch.insertAll(database.checklistItems, [
        ChecklistItemsCompanion.insert(id: 'check-01-a', taskId: 'scenario-01', titleAr: 'التحقق من الطلب', titleEn: const Value('Verify request'), isMandatory: true, isCompleted: true, completedBy: const Value(DemoSeedIds.ahmed), completedAt: Value(now), sortOrder: 1, createdAt: now, updatedAt: now),
        ChecklistItemsCompanion.insert(id: 'check-01-b', taskId: 'scenario-01', titleAr: 'إغلاق الطلب', titleEn: const Value('Close request'), isMandatory: true, isCompleted: false, sortOrder: 2, createdAt: now, updatedAt: now),
      ]);
      batch.insert(database.taskBlockers, TaskBlockersCompanion.insert(id: 'blocker-04', taskId: 'scenario-04', reportedBy: DemoSeedIds.ahmed, blockerType: 'external_dependency', description: 'انتظار اعتماد مالي', responsibleParty: 'External finance vendor', startedAt: now.subtract(const Duration(days: 4)), status: 'active'));
      batch.insert(database.deadlineExtensionRequests, DeadlineExtensionRequestsCompanion.insert(id: 'extension-09', taskId: 'scenario-09', requestedBy: DemoSeedIds.ahmed, currentDueDate: now.add(const Duration(days: 7)), requestedDueDate: now.add(const Duration(days: 14)), reason: 'External dependency requires more time', status: 'pending', reviewedBy: const Value(DemoSeedIds.sara)));
      batch.insert(database.taskComments, TaskCommentsCompanion.insert(id: 'comment-04', taskId: 'scenario-04', authorId: DemoSeedIds.ahmed, body: 'بانتظار الطرف الخارجي', createdAt: now, updatedAt: now, isEdited: false, mentionUserIdsJson: '[]', isDeleted: false, syncState: 'synced'));
      batch.insertAll(database.taskApprovals, [
        TaskApprovalsCompanion.insert(id: 'approval-02', taskId: 'scenario-02', approverId: DemoSeedIds.sara, status: 'pending', submittedAt: now, sequenceNumber: 1),
        TaskApprovalsCompanion.insert(id: 'approval-03', taskId: 'scenario-03', approverId: DemoSeedIds.sara, status: 'returned', submittedAt: now, reviewedAt: Value(now), reviewComment: const Value('يلزم تصحيح الدليل'), sequenceNumber: 1),
      ]);
    });
    await _seedRecurrence(now);
    await _seedAuditAndSync(now);
  }

  TaskAssignmentsCompanion _assignment(String id, String taskId, String userId, DateTime now, {String role = 'owner', String status = 'assigned', bool primary = true, int? contribution}) => TaskAssignmentsCompanion.insert(
        id: id, taskId: taskId, userId: userId, assignmentRole: role,
        assignmentStatus: status, isPrimary: primary, assignedAt: now,
        contributionPercentage: Value(contribution), createdAt: now, updatedAt: now,
      );

  Future<void> _seedRecurrence(DateTime now) async {
    await database.into(database.recurrenceRules).insert(
          RecurrenceRulesCompanion.insert(
            id: 'recurrence-monthly', frequency: 'monthly', interval: 1,
            dayOfMonth: const Value(1), useLastWorkingDay: false, startDate: now,
            endType: 'after_occurrences', occurrenceCount: const Value(3),
            isPaused: false, createdBy: DemoSeedIds.sara, createdAt: now,
            updatedAt: now,
          ),
        );
    await database.batch((batch) {
      batch.insertAll(database.tasks, [
        _task('scenario-10-completed', 'SCN-10-C', 'مراجعة شهرية', now, status: 'completed', recurrenceRuleId: 'recurrence-monthly', recurrenceSourceTaskId: 'scenario-10'),
        _task('scenario-10-active', 'SCN-10-A', 'مراجعة شهرية', now, recurrenceRuleId: 'recurrence-monthly', recurrenceSourceTaskId: 'scenario-10'),
        _task('scenario-10-future', 'SCN-10-F', 'مراجعة شهرية', now, status: 'assigned', recurrenceRuleId: 'recurrence-monthly', recurrenceSourceTaskId: 'scenario-10'),
      ]);
    });
  }

  Future<void> _seedAuditAndSync(DateTime now) async {
    await database.batch((batch) {
      batch.insertAll(database.auditEvents, [
        _audit('audit-reassignment', 'scenario-08', 'reassigned', DemoSeedIds.sara, now, 'Operational coverage'),
        _audit('audit-queue-claim', 'scenario-07-claimed', 'assigned', DemoSeedIds.khaled, now, 'Queue claim'),
        _audit('audit-01', 'scenario-01', 'status_changed', DemoSeedIds.ahmed, now, 'Started work'),
        _audit('audit-03', 'scenario-03', 'returned', DemoSeedIds.sara, now, 'Correction required'),
        _audit('audit-offline', 'scenario-12', 'updated', DemoSeedIds.ahmed, now, 'Offline progress update', offline: true, syncState: 'pending'),
      ]);
      batch.insertAll(database.syncOperations, [
        SyncOperationsCompanion.insert(id: 'sync-offline', entityType: 'task', entityId: 'scenario-12', operationType: 'update', payloadJson: '{}', createdAt: now, retryCount: 0, status: 'pending', conflictType: 'none'),
        SyncOperationsCompanion.insert(id: 'sync-conflict', entityType: 'task', entityId: 'scenario-13', operationType: 'update', payloadJson: '{}', createdAt: now, retryCount: 1, status: 'conflict', errorMessage: const Value('Assignment changed'), conflictType: 'assignment'),
      ]);
      batch.insert(database.appNotifications, AppNotificationsCompanion.insert(id: 'notification-demo', recipientId: DemoSeedIds.ahmed, type: 'task_assigned', titleAr: 'مهمة جديدة', titleEn: const Value('Task assigned'), messageAr: 'لديك مهمة', messageEn: const Value('You have a task'), taskId: const Value('scenario-01'), createdAt: now, isRead: false, deliveryChannel: 'in_app', deliveryStatus: 'delivered'));
    });
  }

  AuditEventsCompanion _audit(String id, String taskId, String eventType, String userId, DateTime now, String reason, {bool offline = false, String syncState = 'synced'}) => AuditEventsCompanion.insert(
        id: id, taskId: Value(taskId), entityType: 'task', entityId: taskId,
        eventType: eventType, performedBy: userId, performedAt: now,
        reason: Value(reason), deviceId: 'demo-device', isOfflineEvent: offline,
        syncState: syncState,
      );
}
