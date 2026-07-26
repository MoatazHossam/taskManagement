abstract final class DemoAuthenticationConfig {
  static const demoPassword = 'demo123';
  static const demoPin = '1234';
  static const sessionDuration = Duration(hours: 12);
  static const offlineAccessDuration = Duration(days: 7);
  static const maximumPinAttempts = 3;
  static const credentialProfiles = <String, String>{
    'employee': 'employee', 'manager': 'manager', 'executive': 'senior',
    'admin': 'administrator', 'support': 'queue',
  };
}
