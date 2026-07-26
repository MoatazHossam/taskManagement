import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/domain/domain_enums.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../home/presentation/home_page.dart';
import 'widgets/authorization_widgets.dart';

class AccessSummaryPage extends ConsumerWidget {
  const AccessSummaryPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: Text(context.l10n.accessSummary)), body: ref.watch(currentOrganizationContextProvider).when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const AccessDeniedState(), data: (value) {
    if (value == null) return const AccessDeniedState();
    final language=Localizations.localeOf(context).languageCode; String name(String ar,String? en)=>language=='ar'?ar:(en??ar);
    Iterable<PermissionCode> group(String prefix)=>value.effectivePermissions.where((p)=>p.code.startsWith(prefix));
    return AppPrimaryScrollView(children:[AppPageHeader(eyebrow:context.l10n.profile,title:context.l10n.accessSummary,subtitle:context.l10n.demoAuthorizationNotice,trailing:AccessScopeBadge(scope:value.maximumAccessScope)),const SizedBox(height:AppSpacing.medium),AppPanel(title:name(value.user.nameAr,value.user.nameEn),child:Column(children:[ListTile(title:Text(context.l10n.roleLabel),subtitle:Text(name(value.role.nameAr,value.role.nameEn))),ListTile(title:Text(context.l10n.department),subtitle:Text(value.department==null?'—':name(value.department!.nameAr,value.department!.nameEn))),ListTile(title:Text(context.l10n.managerLabel),subtitle:Text(value.manager==null?'—':name(value.manager!.nameAr,value.manager!.nameEn))),if(value.teams.isEmpty)ListTile(title:Text(context.l10n.noTeamMemberships)) else for(final team in value.teams)ListTile(title:Text(context.l10n.teams),subtitle:Text(name(team.nameAr,team.nameEn)),trailing:value.queueMemberships.any((q)=>q.id==team.id)?Chip(label:Text(context.l10n.queueMember)):null)])),PermissionGroupCard(title:context.l10n.organization,permissions:group('organization.').followedBy(group('directory.'))),PermissionGroupCard(title:context.l10n.myTasks,permissions:group('task.')),PermissionGroupCard(title:context.l10n.reports,permissions:group('report.')),PermissionGroupCard(title:context.l10n.administration,permissions:group('admin.')),ExpansionTile(title:Text(context.l10n.permissionDiagnostics),subtitle:Text('${context.l10n.permissionCount}: ${value.effectivePermissions.length}'),children:[ListTile(title:Text('ID'),subtitle:Text(value.user.id)),ListTile(title:Text(context.l10n.roleLabel),subtitle:Text(value.role.code.code))]),const SizedBox(height:16)]);
  }));
}
