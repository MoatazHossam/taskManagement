import 'package:drift/drift.dart';

import 'app_database_connection.dart';
import 'tables/app_tables.dart';

part 'app_database.g.dart';
part 'daos/audit_dao.dart';
part 'daos/notification_dao.dart';
part 'daos/organization_dao.dart';
part 'daos/settings_dao.dart';
part 'daos/sync_dao.dart';
part 'daos/task_configuration_dao.dart';
part 'daos/task_dao.dart';
part 'daos/user_dao.dart';

@DriftDatabase(
  daos: [
    UserDao,
    OrganizationDao,
    TaskDao,
    TaskConfigurationDao,
    NotificationDao,
    AuditDao,
    SyncDao,
    SettingsDao,
  ],
  tables: [
    Organizations, Departments, Roles, Permissions, RolePermissions, Users,
    Teams, TeamMemberships, Priorities, Categories, ConfidentialityLevels,
    RecurrenceRules, Tasks, TaskAssignments, ChecklistItems, TaskComments,
    TaskAttachments, TaskBlockers, DeadlineExtensionRequests, TaskApprovals,
    AppNotifications, AuditEvents, SyncOperations, SavedTaskFilters,
    AppSettings, ApprovalRules, EscalationRules, NotificationTemplates,
    TaskTemplates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabaseConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from != to) {
            throw StateError('Explicit migration required from $from to $to');
          }
        },
        beforeOpen: (_) async {
          // SQLite doesn't enable foreign-key enforcement per connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
