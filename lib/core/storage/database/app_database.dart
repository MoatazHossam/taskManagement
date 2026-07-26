import 'package:drift/drift.dart';
import 'app_database_connection.dart';
import 'tables/app_tables.dart';
part 'app_database.g.dart';
@DriftDatabase(tables:[Organizations,Departments,Roles,Permissions,RolePermissions,Users,Teams,TeamMemberships,Priorities,Categories,ConfidentialityLevels,RecurrenceRules,Tasks,TaskAssignments,ChecklistItems,TaskComments,TaskAttachments,TaskBlockers,DeadlineExtensionRequests,TaskApprovals,AppNotifications,AuditEvents,SyncOperations,SavedTaskFilters,AppSettings,ApprovalRules,EscalationRules,NotificationTemplates,TaskTemplates])
class AppDatabase extends _$AppDatabase { AppDatabase():super(openAppDatabaseConnection()); AppDatabase.forTesting(super.executor); @override int get schemaVersion=>1; @override MigrationStrategy get migration=>MigrationStrategy(onCreate:(m)=>m.createAll(),onUpgrade:(m,from,to) async { if(from!=to) throw StateError('Explicit migration required from $from to $to'); },beforeOpen:(details) async { await customStatement('PRAGMA foreign_keys = ON'); }); }
