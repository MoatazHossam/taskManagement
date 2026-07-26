import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_responsive_shell.dart';
import '../../core/widgets/feature_placeholder_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../shared/enums/app_enums.dart';
import '../dependency_injection/app_providers.dart';
import '../localization/localization_extensions.dart';
import 'app_router.dart';
import '../../features/organization/presentation/organization_pages.dart';

class RoleDestination {
  const RoleDestination(this.segment, this.icon, this.label);
  final String segment;
  final IconData icon;
  final String Function(BuildContext) label;
}

List<RoleDestination> destinationsForRole(DemoUserRole role) => switch (role) {
  DemoUserRole.employee => [
    RoleDestination('home', Icons.home_outlined, (c) => c.l10n.home),
    RoleDestination('tasks', Icons.task_alt, (c) => c.l10n.myTasks),
    RoleDestination(
      'calendar',
      Icons.calendar_month_outlined,
      (c) => c.l10n.calendar,
    ),
    RoleDestination(
      'notifications',
      Icons.notifications_outlined,
      (c) => c.l10n.notifications,
    ),
    RoleDestination('profile', Icons.person_outline, (c) => c.l10n.profile),
  ],
  DemoUserRole.manager => [
    RoleDestination('home', Icons.home_outlined, (c) => c.l10n.home),
    RoleDestination(
      'organization',
      Icons.corporate_fare_outlined,
      (c) => c.l10n.organization,
    ),
    RoleDestination('team', Icons.groups_outlined, (c) => c.l10n.teamTasks),
    RoleDestination('create', Icons.add_task, (c) => c.l10n.createTask),
    RoleDestination(
      'approvals',
      Icons.approval_outlined,
      (c) => c.l10n.approvals,
    ),
    RoleDestination('reports', Icons.bar_chart_outlined, (c) => c.l10n.reports),
    RoleDestination('profile', Icons.person_outline, (c) => c.l10n.profile),
  ],
  DemoUserRole.seniorManagement => [
    RoleDestination(
      'executive',
      Icons.dashboard_outlined,
      (c) => c.l10n.executiveDashboard,
    ),
    RoleDestination(
      'departments',
      Icons.account_tree_outlined,
      (c) => c.l10n.departments,
    ),
    RoleDestination(
      'critical',
      Icons.priority_high,
      (c) => c.l10n.criticalTasks,
    ),
    RoleDestination('reports', Icons.bar_chart_outlined, (c) => c.l10n.reports),
    RoleDestination('profile', Icons.person_outline, (c) => c.l10n.profile),
  ],
  DemoUserRole.administrator => [
    RoleDestination(
      'home',
      Icons.admin_panel_settings_outlined,
      (c) => c.l10n.administrationHome,
    ),
    RoleDestination('users', Icons.people_outline, (c) => c.l10n.users),
    RoleDestination(
      'organization',
      Icons.corporate_fare_outlined,
      (c) => c.l10n.organization,
    ),
    RoleDestination('configuration', Icons.tune, (c) => c.l10n.configuration),
    RoleDestination('sync', Icons.sync, (c) => c.l10n.synchronization),
    RoleDestination('audit', Icons.history, (c) => c.l10n.auditLog),
    RoleDestination(
      'settings',
      Icons.settings_outlined,
      (c) => c.l10n.settings,
    ),
  ],
};

class RoleShellPage extends ConsumerWidget {
  const RoleShellPage({super.key, required this.section});
  final String section;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentSystemRoleProvider)!;
    final ds = destinationsForRole(role);
    final index = ds
        .indexWhere((d) => d.segment == section)
        .clamp(0, ds.length - 1);
    final selected = ds[index];
    final label = selected.label(context);
    final isHome = section == 'home' || section == 'executive';
    final isProfile =
        section == 'profile' ||
        (role == DemoUserRole.administrator && section == 'settings');
    final isOrganization =
        section == 'organization' || section == 'departments';
    final child = isOrganization
        ? const OrganizationOverviewPage()
        : isHome
        ? RoleHomePage(title: label)
        : isProfile
        ? ProfilePage(openGallery: () => context.push(AppRoutes.gallery))
        : FeaturePlaceholderPage(
            title: label,
            role: roleLabel(context, role),
            icon: selected.icon,
          );
    return AppResponsiveShell(
      destinations: [
        for (final d in ds)
          AppNavigationDestination(label: d.label(context), icon: d.icon),
      ],
      selectedIndex: index,
      onSelected: (i) => context.go(
        '${roleRoot(role).split('/').take(3).join('/')}/${ds[i].segment}',
      ),
      child: child,
    );
  }
}
