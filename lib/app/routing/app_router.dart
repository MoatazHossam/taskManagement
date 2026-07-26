import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/authentication_pages.dart';
import '../../features/profile/presentation/foundation_gallery_page.dart';
import '../../shared/enums/app_enums.dart';
import '../dependency_injection/app_providers.dart';
import 'role_shell_page.dart';
import '../../core/domain/domain_enums.dart';
import '../../features/organization/presentation/access_summary_page.dart';
import '../../features/organization/presentation/organization_pages.dart';
import '../../features/organization/presentation/widgets/authorization_widgets.dart';
import '../../features/tasks/presentation/task_pages.dart';

abstract final class AppRoutes {
  static const splash = '/splash',
      language = '/language',
      login = '/login',
      unlock = '/unlock',
      app = '/app',
      gallery = '/gallery';
}

String roleRoot(DemoUserRole role) => switch (role) {
  DemoUserRole.employee => '/app/employee/home',
  DemoUserRole.manager => '/app/manager/home',
  DemoUserRole.seniorManagement => '/app/senior/executive',
  DemoUserRole.administrator => '/app/admin/home',
};
bool canAccessRolePath(DemoUserRole role, String path) =>
    path.startsWith(roleRoot(role).split('/').take(3).join('/'));

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen<SessionState>(sessionProvider, (_, __) => refresh.notify());
  ref.listen<Locale?>(localeProvider, (_, __) => refresh.notify());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, routeState) async {
      final session = ref.read(sessionProvider);
      final path = routeState.matchedLocation;
      if (session.status == AuthenticationStatus.initializing) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (path == AppRoutes.splash) {
        if (ref.read(localeProvider) == null) return AppRoutes.language;
        if (session.status == AuthenticationStatus.authenticated) {
          return roleRoot(session.role!);
        }
        return session.status == AuthenticationStatus.locked
            ? AppRoutes.unlock
            : AppRoutes.login;
      }
      if (session.status == AuthenticationStatus.unauthenticated &&
          path != AppRoutes.language &&
          path != AppRoutes.login) {
        return ref.read(localeProvider) == null
            ? AppRoutes.language
            : AppRoutes.login;
      }
      if (session.status == AuthenticationStatus.locked &&
          path != AppRoutes.unlock) {
        return AppRoutes.unlock;
      }
      if (session.status == AuthenticationStatus.selectingProfile ||
          session.status == AuthenticationStatus.expired ||
          session.status == AuthenticationStatus.failure) {
        if (path != AppRoutes.login) return AppRoutes.login;
      }
      if (session.status == AuthenticationStatus.authenticated) {
        final role = session.role!;
        if (path == AppRoutes.login ||
            path == AppRoutes.language ||
            path == AppRoutes.splash ||
            path == AppRoutes.unlock) {
          return roleRoot(role);
        }
        if (path.startsWith('/app/') && !canAccessRolePath(role, path)) {
          return roleRoot(role);
        }
        final user = session.user;
        if (user == null) return AppRoutes.login;
        PermissionCode? required;
        if (path == '/organization')
          required = PermissionCode.organizationViewOwnContext;
        if (path.startsWith('/organization/departments/') ||
            path.startsWith('/organization/teams/') ||
            path.startsWith('/organization/users/'))
          required = PermissionCode.organizationViewAll;
        if (path.contains('/reports'))
          required = role == DemoUserRole.seniorManagement
              ? PermissionCode.reportViewOrganization
              : PermissionCode.reportViewDepartment;
        if (path.startsWith('/app/admin/')) required = PermissionCode.adminView;
        if (path == '/tasks' || path.startsWith('/tasks/')) {
          final permissions = await ref.read(authorizationServiceProvider).getEffectivePermissions(user.id);
          if (!permissions.any(const {PermissionCode.taskViewOwn, PermissionCode.taskViewTeam,
            PermissionCode.taskViewDepartment, PermissionCode.taskViewAll}.contains)) return '/access-denied';
        }
        if (required != null &&
            !await ref
                .read(authorizationServiceProvider)
                .hasPermission(user.id, required))
          return '/access-denied';
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (c, s) => const SplashPage()),
      GoRoute(
        path: '/tasks',
        builder: (c, s) => const TaskListPage(),
      ),
      GoRoute(
        path: '/tasks/:taskId',
        builder: (c, s) => TaskDetailsPage(taskId: s.pathParameters['taskId']!),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (c, s) => const LanguageSelectionPage(),
      ),
      GoRoute(path: AppRoutes.login, builder: (c, s) => const DemoLoginPage()),
      GoRoute(path: AppRoutes.unlock, builder: (c, s) => const PinUnlockPage()),
      GoRoute(
        path: '/app/:role/:section',
        builder: (c, s) => RoleShellPage(section: s.pathParameters['section']!),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (c, s) => const FoundationGalleryPage(),
      ),
      GoRoute(
        path: '/access-denied',
        builder: (c, s) => const Scaffold(body: AccessDeniedState()),
      ),
      GoRoute(
        path: '/access-summary',
        builder: (c, s) => const AccessSummaryPage(),
      ),
      GoRoute(
        path: '/organization',
        builder: (c, s) => const OrganizationOverviewPage(),
      ),
      GoRoute(
        path: '/organization/departments/:departmentId',
        builder: (c, s) => DepartmentDetailsPage(
          departmentId: s.pathParameters['departmentId']!,
        ),
      ),
      GoRoute(
        path: '/organization/teams/:teamId',
        builder: (c, s) => TeamDetailsPage(teamId: s.pathParameters['teamId']!),
      ),
      GoRoute(
        path: '/organization/users/:userId',
        builder: (c, s) =>
            OrganizationUserPage(userId: s.pathParameters['userId']!),
      ),
    ],
  );
});

final class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
