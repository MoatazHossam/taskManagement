import '../enums/app_enums.dart';

class DemoUserProfile {
  const DemoUserProfile({required this.id, required this.nameAr, required this.nameEn, required this.role, required this.departmentAr, required this.departmentEn, required this.avatarInitials});
  final String id;
  final String nameAr;
  final String nameEn;
  final DemoUserRole role;
  final String departmentAr;
  final String departmentEn;
  final String avatarInitials;

  String localizedName(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  String localizedDepartment(String languageCode) => languageCode == 'ar' ? departmentAr : departmentEn;
}

const demoProfiles = <DemoUserProfile>[
  DemoUserProfile(id: 'employee', nameAr: 'أحمد حسن', nameEn: 'Ahmed Hassan', role: DemoUserRole.employee, departmentAr: 'العمليات', departmentEn: 'Operations', avatarInitials: 'AH'),
  DemoUserProfile(id: 'manager', nameAr: 'سارة محمود', nameEn: 'Sara Mahmoud', role: DemoUserRole.manager, departmentAr: 'مديرة العمليات', departmentEn: 'Operations manager', avatarInitials: 'SM'),
  DemoUserProfile(id: 'senior', nameAr: 'عمر النعيمي', nameEn: 'Omar Al Nuaimi', role: DemoUserRole.seniorManagement, departmentAr: 'الإدارة العليا', departmentEn: 'Senior management', avatarInitials: 'ON'),
  DemoUserProfile(id: 'administrator', nameAr: 'ليلى يوسف', nameEn: 'Laila Youssef', role: DemoUserRole.administrator, departmentAr: 'مسؤولة النظام', departmentEn: 'System administrator', avatarInitials: 'LY'),
  DemoUserProfile(id: 'queue', nameAr: 'خالد إبراهيم', nameEn: 'Khaled Ibrahim', role: DemoUserRole.employee, departmentAr: 'موظف الدعم الفني', departmentEn: 'IT support employee', avatarInitials: 'KI'),
];
