import '../../../domain/entities.dart' as domain; import '../app_database.dart' as data;
extension PriorityRowMapper on data.Priority { domain.TaskPriority toDomain()=>domain.TaskPriority(id:id,code:code,labelAr:labelAr,labelEn:labelEn,level:level); }
extension CategoryRowMapper on data.Category { domain.TaskCategory toDomain()=>domain.TaskCategory(id:id,code:code,labelAr:labelAr,labelEn:labelEn,defaultPriorityId:defaultPriorityId); }
extension ConfidentialityRowMapper on data.ConfidentialityLevel { domain.ConfidentialityLevel toDomain()=>domain.ConfidentialityLevel(id:id,code:code,labelAr:labelAr,labelEn:labelEn,level:level); }
extension ApprovalRuleRowMapper on data.ApprovalRule { domain.ApprovalRule toDomain()=>domain.ApprovalRule(id:id,code:code,nameAr:nameAr,nameEn:nameEn); }
extension EscalationRuleRowMapper on data.EscalationRule { domain.EscalationRule toDomain()=>domain.EscalationRule(id:id,code:code,nameAr:nameAr,nameEn:nameEn); }
extension NotificationTemplateRowMapper on data.NotificationTemplate { domain.NotificationTemplate toDomain()=>domain.NotificationTemplate(id:id,code:code,titleAr:titleAr,titleEn:titleEn,messageAr:messageAr,messageEn:messageEn); }
extension TaskTemplateRowMapper on data.TaskTemplate { domain.TaskTemplate toDomain()=>domain.TaskTemplate(id:id,titleAr:titleAr,titleEn:titleEn,categoryId:categoryId,priorityId:priorityId); }
