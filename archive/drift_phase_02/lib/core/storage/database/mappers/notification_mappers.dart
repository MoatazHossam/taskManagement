import '../../../domain/domain_enums.dart';
import '../../../domain/entities.dart' as domain;
import '../app_database.dart' as data;
extension NotificationRowMapper on data.AppNotification { domain.AppNotification toNotificationDomain()=>domain.AppNotification(id:id,recipientId:recipientId,type:NotificationType.fromCode(type),titleAr:titleAr,titleEn:titleEn,messageAr:messageAr,messageEn:messageEn,taskId:taskId,createdAt:createdAt.toUtc(),isRead:isRead,deliveryChannel:NotificationDeliveryChannel.fromCode(deliveryChannel),deliveryStatus:NotificationDeliveryStatus.fromCode(deliveryStatus)); }
