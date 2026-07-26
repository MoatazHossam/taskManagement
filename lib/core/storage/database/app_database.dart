import 'package:drift/drift.dart';
import 'app_database_connection.dart';
import 'tables/app_tables.dart';
import 'daos/user_dao.dart';
import 'daos/organization_dao.dart';
import 'daos/task_dao.dart';
import 'daos/task_configuration_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/audit_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/settings_dao.dart';
part 'app_database.g.dart';
@DriftDatabase(daos:[UserDao,OrganizationDao,TaskDao,TaskConfigurationDao,NotificationDao,AuditDao,SyncDao,SettingsDao],tables:[Organizations,Departments,Roles,Permissions,RolePermissions,Users,Teams,TeamMemberships,Priorities,Categories,ConfidentialityLevels,RecurrenceRules,Tasks,TaskAssignments,ChecklistItems,TaskComments,TaskAttachments,TaskBlockers,DeadlineExtensionRequests,TaskApprovals,AppNotifications,AuditEvents,SyncOperations,SavedTaskFilters,AppSettings,ApprovalRules,EscalationRules,NotificationTemplates,TaskTemplates])
class AppDatabase extends _$AppDatabase { AppDatabase():super(openAppDatabaseConnection()); AppDatabase.forTesting(super.executor); @override int get schemaVersion=>1; @override MigrationStrategy get migration=>MigrationStrategy(onCreate:(m)=>m.createAll(),onUpgrade:(m,from,to) async { if(from!=to) throw StateError('Explicit migration required from $from to $to'); },beforeOpen:(details) async { await customStatement('PRAGMA foreign_keys = ON'); }); }
