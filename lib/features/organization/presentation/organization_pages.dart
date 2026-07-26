import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/domain/authorization_models.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/domain/entities.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../home/presentation/home_page.dart';
import 'widgets/authorization_widgets.dart';

String _name(BuildContext context, String ar, String? en) => context.isArabic ? ar : (en ?? ar);

class OrganizationOverviewPage extends ConsumerWidget {
  const OrganizationOverviewPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentOrganizationContextProvider);
    return Scaffold(appBar: AppBar(title: Text(context.l10n.organization)), body: current.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => Center(child: Text(context.l10n.organizationStructureUnavailable)), data: (value) {
      if (value == null) return const AccessDeniedState();
      return FutureBuilder(future: Future.wait([ref.read(organizationRepositoryProvider).getDepartments(), ref.read(organizationRepositoryProvider).getTeams(), ref.read(userRepositoryProvider).getActiveUsers()]), builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final departments = snapshot.data![0] as List<Department>; final teams = snapshot.data![1] as List<Team>; final users = snapshot.data![2] as List<OrganizationUser>;
        return AppPrimaryScrollView(children: [AppPageHeader(eyebrow: context.l10n.readOnlyDirectory, title: _name(context, value.organization.nameAr, value.organization.nameEn), subtitle: context.l10n.demoAuthorizationNotice, trailing: AccessScopeBadge(scope: value.maximumAccessScope)), const SizedBox(height: AppSpacing.medium), Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('${context.l10n.departments}: ${departments.length}')), Chip(label: Text('${context.l10n.teams}: ${teams.length}')), Chip(label: Text('${context.l10n.employeeCount}: ${users.length}'))]), const SizedBox(height: AppSpacing.medium), PermissionGate(permission: PermissionCode.organizationViewAll, fallback: _OwnContext(context: value), child: AppPanel(title: context.l10n.departments, child: Column(children: [for (final department in departments) ListTile(key: ValueKey(department.id), leading: const Icon(Icons.account_tree_outlined), title: Text(_name(context, department.nameAr, department.nameEn)), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/organization/departments/${department.id}'))])))]);
      });
    }));
  }
}

class _OwnContext extends StatelessWidget {
  const _OwnContext({required this.context}); final OrganizationContext context;
  @override Widget build(BuildContext buildContext) => AppPanel(title: buildContext.l10n.organizationAccess, child: Column(children: [ListTile(leading: const Icon(Icons.corporate_fare), title: Text(_name(buildContext, context.department?.nameAr ?? '', context.department?.nameEn))), ListTile(leading: const Icon(Icons.supervisor_account), title: Text(context.manager == null ? buildContext.l10n.noDirectReports : _name(buildContext, context.manager!.nameAr, context.manager!.nameEn))), for (final team in context.teams) ListTile(leading: const Icon(Icons.groups_outlined), title: Text(_name(buildContext, team.nameAr, team.nameEn))) ]));
}

class DepartmentDetailsPage extends ConsumerWidget {
  const DepartmentDetailsPage({super.key, required this.departmentId}); final String departmentId;
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: Text(context.l10n.department)), body: FutureBuilder(future: _load(ref), builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final data = snapshot.data!; if (data.department == null) return Center(child: Text(context.l10n.organizationStructureUnavailable));
    return AppPrimaryScrollView(children: [AppPageHeader(eyebrow: context.l10n.department, title: _name(context, data.department!.nameAr, data.department!.nameEn), subtitle: context.l10n.readOnlyDirectory), AppPanel(title: context.l10n.teams, child: Column(children: [for (final team in data.teams) ListTile(title: Text(_name(context, team.nameAr, team.nameEn)), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/organization/teams/${team.id}'))])), AppPanel(title: context.l10n.users, child: Column(children: [for (final user in data.users) ListTile(title: Text(_name(context, user.nameAr, user.nameEn)), subtitle: Text(user.employeeNumber), onTap: () => context.push('/organization/users/${user.id}'))]))]);
  }));
  Future<({Department? department, List<Team> teams, List<OrganizationUser> users})> _load(WidgetRef ref) async => (department: await ref.read(organizationRepositoryProvider).getDepartmentById(departmentId), teams: await ref.read(organizationRepositoryProvider).getTeamsByDepartment(departmentId), users: await ref.read(userRepositoryProvider).getUsersByDepartment(departmentId));
}

class TeamDetailsPage extends ConsumerWidget {
  const TeamDetailsPage({super.key, required this.teamId}); final String teamId;
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: Text(context.l10n.teams)), body: FutureBuilder(future: _load(ref), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final data = snapshot.data!; if (data.team == null) return Center(child: Text(context.l10n.organizationStructureUnavailable)); return AppPrimaryScrollView(children: [AppPageHeader(eyebrow: data.team!.isQueueEnabled ? context.l10n.teamQueueMember : context.l10n.teams, title: _name(context, data.team!.nameAr, data.team!.nameEn), subtitle: context.l10n.readOnlyDirectory), AppPanel(title: context.l10n.teamMembers, child: Column(children: [for (final member in data.members) ListTile(title: Text(_name(context, member.user.nameAr, member.user.nameEn)), subtitle: Text(member.membership.membershipRole == TeamMembershipRole.lead ? context.l10n.teamLead : member.membership.membershipRole == TeamMembershipRole.queueMember ? context.l10n.queueMember : context.l10n.teamMembers), onTap: () => context.push('/organization/users/${member.user.id}'))]))]); }));
  Future<({Team? team, List<({OrganizationUser user, TeamMembership membership})> members})> _load(WidgetRef ref) async { final repo=ref.read(organizationRepositoryProvider); final team=await repo.getTeamById(teamId); final memberships=await repo.getTeamMembers(teamId); final result=<({OrganizationUser user, TeamMembership membership})>[]; for(final membership in memberships){final user=await ref.read(userRepositoryProvider).getUserById(membership.userId);if(user!=null)result.add((user:user,membership:membership));} return (team:team,members:result); }
}

class OrganizationUserPage extends ConsumerWidget {
  const OrganizationUserPage({super.key, required this.userId}); final String userId;
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: Text(context.l10n.profile)), body: FutureBuilder(future: ref.read(organizationHierarchyServiceProvider).getUserContext(userId), builder: (context, snapshot) { if (!snapshot.hasData) return snapshot.hasError ? const AccessDeniedState() : const Center(child: CircularProgressIndicator()); final value=snapshot.data!; return AppPrimaryScrollView(children:[AppPageHeader(eyebrow: context.l10n.readOnlyDirectory,title:_name(context,value.user.nameAr,value.user.nameEn),subtitle:value.user.employeeNumber),AppPanel(title:context.l10n.organizationAccess,child:Column(children:[ListTile(title:Text(context.l10n.roleLabel),subtitle:Text(_name(context,value.role.nameAr,value.role.nameEn))),ListTile(title:Text(context.l10n.department),subtitle:Text(_name(context,value.department?.nameAr ?? '',value.department?.nameEn))),ListTile(title:Text(context.l10n.managerLabel),subtitle:Text(value.manager==null?'—':_name(context,value.manager!.nameAr,value.manager!.nameEn))),for(final team in value.teams)ListTile(title:Text(context.l10n.teams),subtitle:Text(_name(context,team.nameAr,team.nameEn))) ]))]); }));
}
