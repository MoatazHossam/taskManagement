abstract final class DemoSeedIds {
 static const organization='org-demo'; static const executive='department-executive',operations='department-operations',finance='department-finance',humanResources='department-hr',informationTechnology='department-it';
 static const fieldOperations='team-field-operations',serviceCoordination='team-service-coordination',accountsPayable='team-accounts-payable',reporting='team-reporting',recruitment='team-recruitment',employeeServices='team-employee-services',technicalSupportQueue='team-technical-support-queue',applicationSupport='team-application-support';
 static const ahmed='user-ahmed-hassan',sara='user-sara-mahmoud',omar='user-omar-al-nuaimi',laila='user-laila-youssef',khaled='user-khaled-ibrahim';
 static const roleEmployee='role-employee',roleManager='role-manager',roleSenior='role-senior-management',roleAdministrator='role-administrator';
 static const priorityLow='priority-low',priorityNormal='priority-normal',priorityHigh='priority-high',priorityUrgent='priority-urgent',priorityCritical='priority-critical';
 static const confidentialityInternal='confidentiality-internal'; static String scenario(int number)=>'scenario-${number.toString().padLeft(2,'0')}';
}
