// Generated-compatible localization accessor. Regenerate with `flutter gen-l10n`.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  static const supportedLocales=<Locale>[Locale('ar'),Locale('en')];
  static const LocalizationsDelegate<AppLocalizations> delegate=_AppLocalizationsDelegate();
  static AppLocalizations? of(BuildContext context)=>Localizations.of<AppLocalizations>(context,AppLocalizations);
  static const Map<String,Map<String,String>> _values={
    'en':{'appName':'Organization Task Manager','continueLabel':'Continue','login':'Login','logout':'Logout','language':'Language','arabic':'Arabic','english':'English','selectDemoProfile':'Select demo profile','employee':'Employee','manager':'Manager','seniorManagement':'Senior management','systemAdministrator':'System administrator','home':'Home','myTasks':'My tasks','calendar':'Calendar','notifications':'Notifications','profile':'Profile','teamTasks':'Team tasks','createTask':'Create task','approvals':'Approvals','reports':'Reports','executiveDashboard':'Executive dashboard','departments':'Departments','criticalTasks':'Critical tasks','administration':'Administration','administrationHome':'Administration home','users':'Users','organization':'Organization','configuration':'Configuration','synchronization':'Synchronization','auditLog':'Audit log','settings':'Settings','online':'Online','offline':'Offline','unstableConnection':'Unstable connection','loading':'Loading','noData':'No data','somethingWentWrong':'Something went wrong','retry':'Retry','demoMode':'Demo mode','authenticationSimulated':'Authentication is simulated. No credentials leave this device.','theme':'Theme','light':'Light','dark':'Dark','systemDefault':'System default','username':'Username','password':'Password','switchProfile':'Switch demo profile','expireSession':'Simulate session expiry','sessionExpired':'The simulated session expired. Please log in again.','connectivity':'Simulated connectivity','offlineBanner':'Offline simulation is active. Changes are not synchronized.','unstableBanner':'Connection simulation is unstable.','featureLater':'This feature is scheduled for a later phase. No task data is available yet.','currentRole':'Current role','department':'Department','currentLanguage':'Current language','currentTheme':'Current theme','welcome':'Welcome','demoNotice':'Foundation demo environment — task data will be introduced in Phase 05.','foundationGallery':'Foundation UI Gallery','showDialog':'Show confirmation dialog','confirm':'Confirm','cancel':'Cancel','confirmationQuestion':'Continue with this demonstration action?','longTextDemo':'Long-text resilience preview','validationError':'Please check the entered information.','permissionError':'You do not have permission for this action.','notFoundError':'The requested item was not found.','storageError':'Local storage is currently unavailable.','connectivityError':'This action needs a connection.','unknownError':'An unexpected error occurred.','teamQueueMember':'Team queue member','operations':'Operations','operationsManager':'Operations manager','itSupportEmployee':'IT support employee','foundationStateExamples':'Reusable loading, empty, error, and connectivity examples'},
    'ar':{'appName':'إدارة مهام المؤسسة','continueLabel':'متابعة','login':'تسجيل الدخول','logout':'تسجيل الخروج','language':'اللغة','arabic':'العربية','english':'الإنجليزية','selectDemoProfile':'اختر ملفاً تجريبياً','employee':'موظف','manager':'مدير','seniorManagement':'الإدارة العليا','systemAdministrator':'مسؤول النظام','home':'الرئيسية','myTasks':'مهامي','calendar':'التقويم','notifications':'الإشعارات','profile':'الملف الشخصي','teamTasks':'مهام الفريق','createTask':'إنشاء مهمة','approvals':'الموافقات','reports':'التقارير','executiveDashboard':'لوحة الإدارة التنفيذية','departments':'الإدارات','criticalTasks':'المهام الحرجة','administration':'الإدارة','administrationHome':'رئيسية الإدارة','users':'المستخدمون','organization':'المؤسسة','configuration':'التهيئة','synchronization':'المزامنة','auditLog':'سجل التدقيق','settings':'الإعدادات','online':'متصل','offline':'غير متصل','unstableConnection':'اتصال غير مستقر','loading':'جارٍ التحميل','noData':'لا توجد بيانات','somethingWentWrong':'حدث خطأ ما','retry':'إعادة المحاولة','demoMode':'الوضع التجريبي','authenticationSimulated':'المصادقة محاكاة. لا تغادر بيانات الاعتماد هذا الجهاز.','theme':'المظهر','light':'فاتح','dark':'داكن','systemDefault':'إعداد النظام','username':'اسم المستخدم','password':'كلمة المرور','switchProfile':'تبديل الملف التجريبي','expireSession':'محاكاة انتهاء الجلسة','sessionExpired':'انتهت الجلسة التجريبية. يرجى تسجيل الدخول مجدداً.','connectivity':'الاتصال المحاكى','offlineBanner':'المحاكاة دون اتصال مفعلة. لا تتم مزامنة التغييرات.','unstableBanner':'محاكاة الاتصال غير مستقرة.','featureLater':'هذه الميزة مجدولة لمرحلة لاحقة. لا تتوفر بيانات مهام بعد.','currentRole':'الدور الحالي','department':'الإدارة','currentLanguage':'اللغة الحالية','currentTheme':'المظهر الحالي','welcome':'مرحباً','demoNotice':'بيئة العرض التأسيسية — ستتم إضافة بيانات المهام في المرحلة 05.','foundationGallery':'معرض واجهات الأساس','showDialog':'عرض مربع التأكيد','confirm':'تأكيد','cancel':'إلغاء','confirmationQuestion':'هل تريد متابعة هذا الإجراء التجريبي؟','longTextDemo':'معاينة تحمل النص العربي الطويل لضمان وضوح المحتوى وسهولة قراءته على الشاشات الصغيرة ومع أحجام الخط الكبيرة.','validationError':'يرجى التحقق من المعلومات المدخلة.','permissionError':'ليس لديك صلاحية لهذا الإجراء.','notFoundError':'لم يتم العثور على العنصر المطلوب.','storageError':'التخزين المحلي غير متاح حالياً.','connectivityError':'يتطلب هذا الإجراء اتصالاً.','unknownError':'حدث خطأ غير متوقع.','teamQueueMember':'عضو قائمة انتظار الفريق','operations':'العمليات','operationsManager':'مديرة العمليات','itSupportEmployee':'موظف الدعم الفني','foundationStateExamples':'أمثلة قابلة لإعادة الاستخدام للتحميل والفراغ والخطأ والاتصال'},
  };
  String get appName=>_values[locale.languageCode]!['appName']!;
  String get continueLabel=>_values[locale.languageCode]!['continueLabel']!;
  String get login=>_values[locale.languageCode]!['login']!;
  String get logout=>_values[locale.languageCode]!['logout']!;
  String get language=>_values[locale.languageCode]!['language']!;
  String get arabic=>_values[locale.languageCode]!['arabic']!;
  String get english=>_values[locale.languageCode]!['english']!;
  String get selectDemoProfile=>_values[locale.languageCode]!['selectDemoProfile']!;
  String get employee=>_values[locale.languageCode]!['employee']!;
  String get manager=>_values[locale.languageCode]!['manager']!;
  String get seniorManagement=>_values[locale.languageCode]!['seniorManagement']!;
  String get systemAdministrator=>_values[locale.languageCode]!['systemAdministrator']!;
  String get home=>_values[locale.languageCode]!['home']!;
  String get myTasks=>_values[locale.languageCode]!['myTasks']!;
  String get calendar=>_values[locale.languageCode]!['calendar']!;
  String get notifications=>_values[locale.languageCode]!['notifications']!;
  String get profile=>_values[locale.languageCode]!['profile']!;
  String get teamTasks=>_values[locale.languageCode]!['teamTasks']!;
  String get createTask=>_values[locale.languageCode]!['createTask']!;
  String get approvals=>_values[locale.languageCode]!['approvals']!;
  String get reports=>_values[locale.languageCode]!['reports']!;
  String get executiveDashboard=>_values[locale.languageCode]!['executiveDashboard']!;
  String get departments=>_values[locale.languageCode]!['departments']!;
  String get criticalTasks=>_values[locale.languageCode]!['criticalTasks']!;
  String get administration=>_values[locale.languageCode]!['administration']!;
  String get administrationHome=>_values[locale.languageCode]!['administrationHome']!;
  String get users=>_values[locale.languageCode]!['users']!;
  String get organization=>_values[locale.languageCode]!['organization']!;
  String get configuration=>_values[locale.languageCode]!['configuration']!;
  String get synchronization=>_values[locale.languageCode]!['synchronization']!;
  String get auditLog=>_values[locale.languageCode]!['auditLog']!;
  String get settings=>_values[locale.languageCode]!['settings']!;
  String get online=>_values[locale.languageCode]!['online']!;
  String get offline=>_values[locale.languageCode]!['offline']!;
  String get unstableConnection=>_values[locale.languageCode]!['unstableConnection']!;
  String get loading=>_values[locale.languageCode]!['loading']!;
  String get noData=>_values[locale.languageCode]!['noData']!;
  String get somethingWentWrong=>_values[locale.languageCode]!['somethingWentWrong']!;
  String get retry=>_values[locale.languageCode]!['retry']!;
  String get demoMode=>_values[locale.languageCode]!['demoMode']!;
  String get authenticationSimulated=>_values[locale.languageCode]!['authenticationSimulated']!;
  String get theme=>_values[locale.languageCode]!['theme']!;
  String get light=>_values[locale.languageCode]!['light']!;
  String get dark=>_values[locale.languageCode]!['dark']!;
  String get systemDefault=>_values[locale.languageCode]!['systemDefault']!;
  String get username=>_values[locale.languageCode]!['username']!;
  String get password=>_values[locale.languageCode]!['password']!;
  String get switchProfile=>_values[locale.languageCode]!['switchProfile']!;
  String get expireSession=>_values[locale.languageCode]!['expireSession']!;
  String get sessionExpired=>_values[locale.languageCode]!['sessionExpired']!;
  String get connectivity=>_values[locale.languageCode]!['connectivity']!;
  String get offlineBanner=>_values[locale.languageCode]!['offlineBanner']!;
  String get unstableBanner=>_values[locale.languageCode]!['unstableBanner']!;
  String get featureLater=>_values[locale.languageCode]!['featureLater']!;
  String get currentRole=>_values[locale.languageCode]!['currentRole']!;
  String get department=>_values[locale.languageCode]!['department']!;
  String get currentLanguage=>_values[locale.languageCode]!['currentLanguage']!;
  String get currentTheme=>_values[locale.languageCode]!['currentTheme']!;
  String get welcome=>_values[locale.languageCode]!['welcome']!;
  String get demoNotice=>_values[locale.languageCode]!['demoNotice']!;
  String get foundationGallery=>_values[locale.languageCode]!['foundationGallery']!;
  String get showDialog=>_values[locale.languageCode]!['showDialog']!;
  String get confirm=>_values[locale.languageCode]!['confirm']!;
  String get cancel=>_values[locale.languageCode]!['cancel']!;
  String get confirmationQuestion=>_values[locale.languageCode]!['confirmationQuestion']!;
  String get longTextDemo=>_values[locale.languageCode]!['longTextDemo']!;
  String get validationError=>_values[locale.languageCode]!['validationError']!;
  String get permissionError=>_values[locale.languageCode]!['permissionError']!;
  String get notFoundError=>_values[locale.languageCode]!['notFoundError']!;
  String get storageError=>_values[locale.languageCode]!['storageError']!;
  String get connectivityError=>_values[locale.languageCode]!['connectivityError']!;
  String get unknownError=>_values[locale.languageCode]!['unknownError']!;
  String get teamQueueMember=>_values[locale.languageCode]!['teamQueueMember']!;
  String get operations=>_values[locale.languageCode]!['operations']!;
  String get operationsManager=>_values[locale.languageCode]!['operationsManager']!;
  String get itSupportEmployee=>_values[locale.languageCode]!['itSupportEmployee']!;
  String get foundationStateExamples=>_values[locale.languageCode]!['foundationStateExamples']!;
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale)=>AppLocalizations.supportedLocales.any((l)=>l.languageCode==locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale)=>SynchronousFuture(AppLocalizations(locale));
  @override bool shouldReload(_AppLocalizationsDelegate old)=>false;
}
