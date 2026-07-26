import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Organization Task Manager'**
  String get appName;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @selectDemoProfile.
  ///
  /// In en, this message translates to:
  /// **'Select demo profile'**
  String get selectDemoProfile;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @seniorManagement.
  ///
  /// In en, this message translates to:
  /// **'Senior management'**
  String get seniorManagement;

  /// No description provided for @systemAdministrator.
  ///
  /// In en, this message translates to:
  /// **'System administrator'**
  String get systemAdministrator;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get myTasks;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @teamTasks.
  ///
  /// In en, this message translates to:
  /// **'Team tasks'**
  String get teamTasks;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTask;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @executiveDashboard.
  ///
  /// In en, this message translates to:
  /// **'Executive dashboard'**
  String get executiveDashboard;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @criticalTasks.
  ///
  /// In en, this message translates to:
  /// **'Critical tasks'**
  String get criticalTasks;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @administrationHome.
  ///
  /// In en, this message translates to:
  /// **'Administration home'**
  String get administrationHome;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @synchronization.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @unstableConnection.
  ///
  /// In en, this message translates to:
  /// **'Unstable connection'**
  String get unstableConnection;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @authenticationSimulated.
  ///
  /// In en, this message translates to:
  /// **'Authentication is simulated. No credentials leave this device.'**
  String get authenticationSimulated;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch demo profile'**
  String get switchProfile;

  /// No description provided for @expireSession.
  ///
  /// In en, this message translates to:
  /// **'Simulate session expiry'**
  String get expireSession;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'The simulated session expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @connectivity.
  ///
  /// In en, this message translates to:
  /// **'Simulated connectivity'**
  String get connectivity;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline simulation is active. Changes are not synchronized.'**
  String get offlineBanner;

  /// No description provided for @unstableBanner.
  ///
  /// In en, this message translates to:
  /// **'Connection simulation is unstable.'**
  String get unstableBanner;

  /// No description provided for @featureLater.
  ///
  /// In en, this message translates to:
  /// **'This feature is scheduled for a later phase. No task data is available yet.'**
  String get featureLater;

  /// No description provided for @currentRole.
  ///
  /// In en, this message translates to:
  /// **'Current role'**
  String get currentRole;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// No description provided for @currentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current theme'**
  String get currentTheme;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Foundation demo environment — task data will be introduced in Phase 05.'**
  String get demoNotice;

  /// No description provided for @foundationGallery.
  ///
  /// In en, this message translates to:
  /// **'Foundation UI Gallery'**
  String get foundationGallery;

  /// No description provided for @showDialog.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation dialog'**
  String get showDialog;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Continue with this demonstration action?'**
  String get confirmationQuestion;

  /// No description provided for @longTextDemo.
  ///
  /// In en, this message translates to:
  /// **'Long-text resilience preview'**
  String get longTextDemo;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Please check the entered information.'**
  String get validationError;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get permissionError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get notFoundError;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Local storage is currently unavailable.'**
  String get storageError;

  /// No description provided for @connectivityError.
  ///
  /// In en, this message translates to:
  /// **'This action needs a connection.'**
  String get connectivityError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unknownError;

  /// No description provided for @teamQueueMember.
  ///
  /// In en, this message translates to:
  /// **'Team queue member'**
  String get teamQueueMember;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// No description provided for @operationsManager.
  ///
  /// In en, this message translates to:
  /// **'Operations manager'**
  String get operationsManager;

  /// No description provided for @itSupportEmployee.
  ///
  /// In en, this message translates to:
  /// **'IT support employee'**
  String get itSupportEmployee;

  /// No description provided for @foundationStateExamples.
  ///
  /// In en, this message translates to:
  /// **'Reusable loading, empty, error, and connectivity examples'**
  String get foundationStateExamples;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @demoCredentialsHelper.
  ///
  /// In en, this message translates to:
  /// **'Demo only: employee, manager, executive, admin, or support / demo123'**
  String get demoCredentialsHelper;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid demo username or password.'**
  String get invalidCredentials;

  /// No description provided for @userInactive.
  ///
  /// In en, this message translates to:
  /// **'This demo user is inactive.'**
  String get userInactive;

  /// No description provided for @unlockApplication.
  ///
  /// In en, this message translates to:
  /// **'Unlock application'**
  String get unlockApplication;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter four-digit PIN'**
  String get enterPin;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get incorrectPin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempts;

  /// No description provided for @useSimulatedBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use simulated biometrics'**
  String get useSimulatedBiometrics;

  /// No description provided for @simulateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Simulate success'**
  String get simulateSuccess;

  /// No description provided for @simulateFailure.
  ///
  /// In en, this message translates to:
  /// **'Simulate failure'**
  String get simulateFailure;

  /// No description provided for @offlineAccessExpired.
  ///
  /// In en, this message translates to:
  /// **'Offline access expired. Connect to the organization network.'**
  String get offlineAccessExpired;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get confirmLogout;

  /// No description provided for @demoPinNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo security simulation only. Use PIN 1234; no PIN is stored.'**
  String get demoPinNotice;

  /// No description provided for @biometricSimulationNotice.
  ///
  /// In en, this message translates to:
  /// **'No real biometric API or biometric data is used.'**
  String get biometricSimulationNotice;

  /// No description provided for @authenticationAudit.
  ///
  /// In en, this message translates to:
  /// **'Authentication audit'**
  String get authenticationAudit;

  /// No description provided for @sessionRestored.
  ///
  /// In en, this message translates to:
  /// **'Session restored'**
  String get sessionRestored;

  /// No description provided for @offlineAccess.
  ///
  /// In en, this message translates to:
  /// **'Offline access'**
  String get offlineAccess;

  /// No description provided for @usePinInstead.
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get usePinInstead;

  /// No description provided for @organizationOverview.
  ///
  /// In en, this message translates to:
  /// **'Organization overview'**
  String get organizationOverview;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @reportingLine.
  ///
  /// In en, this message translates to:
  /// **'Reporting line'**
  String get reportingLine;

  /// No description provided for @directReports.
  ///
  /// In en, this message translates to:
  /// **'Direct reports'**
  String get directReports;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team members'**
  String get teamMembers;

  /// No description provided for @teamLead.
  ///
  /// In en, this message translates to:
  /// **'Team lead'**
  String get teamLead;

  /// No description provided for @queueMember.
  ///
  /// In en, this message translates to:
  /// **'Queue member'**
  String get queueMember;

  /// No description provided for @parentDepartment.
  ///
  /// In en, this message translates to:
  /// **'Parent department'**
  String get parentDepartment;

  /// No description provided for @childDepartments.
  ///
  /// In en, this message translates to:
  /// **'Child departments'**
  String get childDepartments;

  /// No description provided for @organizationAccess.
  ///
  /// In en, this message translates to:
  /// **'Organization access'**
  String get organizationAccess;

  /// No description provided for @selfScope.
  ///
  /// In en, this message translates to:
  /// **'Self scope'**
  String get selfScope;

  /// No description provided for @teamScope.
  ///
  /// In en, this message translates to:
  /// **'Team scope'**
  String get teamScope;

  /// No description provided for @departmentScope.
  ///
  /// In en, this message translates to:
  /// **'Department scope'**
  String get departmentScope;

  /// No description provided for @organizationScope.
  ///
  /// In en, this message translates to:
  /// **'Organization scope'**
  String get organizationScope;

  /// No description provided for @administrationScope.
  ///
  /// In en, this message translates to:
  /// **'Administration scope'**
  String get administrationScope;

  /// No description provided for @effectivePermissions.
  ///
  /// In en, this message translates to:
  /// **'Effective permissions'**
  String get effectivePermissions;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @insufficientScope.
  ///
  /// In en, this message translates to:
  /// **'Insufficient access scope'**
  String get insufficientScope;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDenied;

  /// No description provided for @confidentialContent.
  ///
  /// In en, this message translates to:
  /// **'Confidential content'**
  String get confidentialContent;

  /// No description provided for @restrictedContent.
  ///
  /// In en, this message translates to:
  /// **'Restricted content'**
  String get restrictedContent;

  /// No description provided for @permissionOverride.
  ///
  /// In en, this message translates to:
  /// **'Permission override'**
  String get permissionOverride;

  /// No description provided for @explicitAllow.
  ///
  /// In en, this message translates to:
  /// **'Explicit allow'**
  String get explicitAllow;

  /// No description provided for @explicitDeny.
  ///
  /// In en, this message translates to:
  /// **'Explicit deny'**
  String get explicitDeny;

  /// No description provided for @accessSummary.
  ///
  /// In en, this message translates to:
  /// **'Access summary'**
  String get accessSummary;

  /// No description provided for @demoAuthorizationNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a deterministic demo authorization model.'**
  String get demoAuthorizationNotice;

  /// No description provided for @noDirectReports.
  ///
  /// In en, this message translates to:
  /// **'No direct reports'**
  String get noDirectReports;

  /// No description provided for @noTeamMemberships.
  ///
  /// In en, this message translates to:
  /// **'No team memberships'**
  String get noTeamMemberships;

  /// No description provided for @organizationStructureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Organization structure unavailable'**
  String get organizationStructureUnavailable;

  /// No description provided for @accessLimitations.
  ///
  /// In en, this message translates to:
  /// **'Access limitations'**
  String get accessLimitations;

  /// No description provided for @employeeNumber.
  ///
  /// In en, this message translates to:
  /// **'Employee number'**
  String get employeeNumber;

  /// No description provided for @managerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get managerLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @permissionDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Permission diagnostics'**
  String get permissionDiagnostics;

  /// No description provided for @permissionCount.
  ///
  /// In en, this message translates to:
  /// **'Permission count'**
  String get permissionCount;

  /// No description provided for @readOnlyDirectory.
  ///
  /// In en, this message translates to:
  /// **'Read-only directory'**
  String get readOnlyDirectory;

  /// No description provided for @employeeCount.
  ///
  /// In en, this message translates to:
  /// **'Employee count'**
  String get employeeCount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
