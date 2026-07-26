import '../../../shared/repositories/repositories.dart';
import '../../domain/entities.dart';
import '../../domain/app_clock.dart';
import '../database/app_database.dart';
import '../database/mappers/notification_mappers.dart';
final class LocalNotificationRepository implements NotificationRepository { const LocalNotificationRepository(this.dao,this.clock); final NotificationDao dao; final AppClock clock; @override Future<List<AppNotification>> getNotificationsForUser(String id) async=>(await dao.getNotificationsForUser(id)).map((e)=>e.toNotificationDomain()).toList(); @override Future<List<AppNotification>> getUnreadNotificationsForUser(String id) async=>(await dao.getUnreadNotificationsForUser(id)).map((e)=>e.toNotificationDomain()).toList(); @override Future<int> getUnreadCount(String id)=>dao.getUnreadCount(id); @override Future<void> markAsRead(String id) async {await dao.markAsRead(id,clock.now());} @override Future<void> markAllAsRead(String id) async {await dao.markAllAsRead(id,clock.now());} }
