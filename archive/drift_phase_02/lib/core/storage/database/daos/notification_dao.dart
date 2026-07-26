part of '../app_database.dart';

@DriftAccessor(tables: [AppNotifications])
class NotificationDao extends DatabaseAccessor<AppDatabase> with _$NotificationDaoMixin {

  NotificationDao(super.attachedDatabase);

  Future<List<AppNotification>> getNotificationsForUser(String id)=>(attachedDatabase.select(attachedDatabase.appNotifications)..where((t)=>t.recipientId.equals(id))..orderBy([(t)=>OrderingTerm.desc(t.createdAt)])).get();

  Future<List<AppNotification>> getUnreadNotificationsForUser(String id)=>(attachedDatabase.select(attachedDatabase.appNotifications)..where((t)=>t.recipientId.equals(id)&t.isRead.equals(false))).get();

  Future<int> getUnreadCount(String id) async {
  final c=attachedDatabase.appNotifications.id.count(); return (await (attachedDatabase.selectOnly(attachedDatabase.appNotifications)..addColumns([c])..where(attachedDatabase.appNotifications.recipientId.equals(id)&attachedDatabase.appNotifications.isRead.equals(false))).getSingle()).read(c)??0;
} Future<void> insertNotification(AppNotificationsCompanion v)=>attachedDatabase.into(attachedDatabase.appNotifications).insert(v);

  Future<int> markAsRead(String id,DateTime at)=>(attachedDatabase.update(attachedDatabase.appNotifications)..where((t)=>t.id.equals(id))).write(AppNotificationsCompanion(isRead:const Value(true),readAt:Value(at.toUtc())));

  Future<int> markAllAsRead(String user,DateTime at)=>(attachedDatabase.update(attachedDatabase.appNotifications)..where((t)=>t.recipientId.equals(user)&t.isRead.equals(false))).write(AppNotificationsCompanion(isRead:const Value(true),readAt:Value(at.toUtc())));
  }
