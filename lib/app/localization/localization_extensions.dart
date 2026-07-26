import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

extension LocalizationContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  Locale get currentLocale => Localizations.localeOf(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}

// Compatibility accessors are sourced verbatim from the ARB catalogs. They can be
// removed after `flutter gen-l10n` runs in an SDK-equipped environment.
extension Phase03AuthenticationLocalizations on AppLocalizations {
  bool get _ar => localeName.startsWith('ar');
  String get showPassword=>_ar?'إظهار كلمة المرور':'Show password';
  String get hidePassword=>_ar?'إخفاء كلمة المرور':'Hide password';
  String get demoCredentialsHelper=>_ar?'للعرض فقط: employee أو manager أو executive أو admin أو support / demo123':'Demo only: employee, manager, executive, admin, or support / demo123';
  String get invalidCredentials=>_ar?'اسم المستخدم التجريبي أو كلمة المرور غير صحيحة.':'Invalid demo username or password.';
  String get userInactive=>_ar?'هذا المستخدم التجريبي غير نشط.':'This demo user is inactive.';
  String get unlockApplication=>_ar?'فتح التطبيق':'Unlock application';
  String get enterPin=>_ar?'أدخل رمز PIN المكوّن من أربعة أرقام':'Enter four-digit PIN';
  String get incorrectPin=>_ar?'رمز PIN غير صحيح.':'Incorrect PIN.';
  String get tooManyAttempts=>_ar?'محاولات كثيرة جداً. حاول مرة أخرى لاحقاً.':'Too many attempts. Try again later.';
  String get useSimulatedBiometrics=>_ar?'استخدام المحاكاة الحيوية':'Use simulated biometrics';
  String get simulateSuccess=>_ar?'محاكاة النجاح':'Simulate success';
  String get simulateFailure=>_ar?'محاكاة الفشل':'Simulate failure';
  String get offlineAccessExpired=>_ar?'انتهت صلاحية الوصول دون اتصال. اتصل بشبكة المؤسسة.':'Offline access expired. Connect to the organization network.';
  String get confirmLogout=>_ar?'تأكيد تسجيل الخروج':'Confirm logout';
  String get demoPinNotice=>_ar?'محاكاة أمنية للعرض فقط. استخدم الرمز 1234؛ لا يتم تخزين رمز PIN.':'Demo security simulation only. Use PIN 1234; no PIN is stored.';
  String get biometricSimulationNotice=>_ar?'لا تُستخدم واجهة حيوية حقيقية ولا أي بيانات حيوية.':'No real biometric API or biometric data is used.';
}
