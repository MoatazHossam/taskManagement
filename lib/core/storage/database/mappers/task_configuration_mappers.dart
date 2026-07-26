import '../../../domain/entities.dart' as domain;
import '../app_database.dart' as data;
extension PriorityRowMapper on data.Priority { domain.TaskPriority toTaskPriorityDomain()=>domain.TaskPriority(id:id,code:code,labelAr:labelAr,labelEn:labelEn,level:level); }
extension CategoryRowMapper on data.Category { domain.TaskCategory toTaskCategoryDomain()=>domain.TaskCategory(id:id,code:code,labelAr:labelAr,labelEn:labelEn,defaultPriorityId:defaultPriorityId); }
extension ConfidentialityRowMapper on data.ConfidentialityLevel { domain.ConfidentialityLevel toConfidentialityLevelDomain()=>domain.ConfidentialityLevel(id:id,code:code,labelAr:labelAr,labelEn:labelEn,level:level); }
extension ApprovalRuleRowMapper on data.ApprovalRule { domain.ApprovalRule toApprovalRuleDomain()=>domain.ApprovalRule(id:id,code:code,nameAr:nameAr,nameEn:nameEn); }
extension EscalationRuleRowMapper on data.EscalationRule { domain.EscalationRule toEscalationRuleDomain()=>domain.EscalationRule(id:id,code:code,nameAr:nameAr,nameEn:nameEn); }
extension NotificationTemplateRowMapper on data.NotificationTemplate { domain.NotificationTemplate toNotificationTemplateDomain()=>domain.NotificationTemplate(id:id,code:code,titleAr:titleAr,titleEn:titleEn,messageAr:messageAr,messageEn:messageEn); }
extension TaskTemplateRowMapper on data.TaskTemplate { domain.TaskTemplate toTaskTemplateDomain()=>domain.TaskTemplate(id:id,titleAr:titleAr,titleEn:titleEn,categoryId:categoryId,priorityId:priorityId); }
