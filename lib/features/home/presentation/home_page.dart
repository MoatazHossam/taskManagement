import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../shared/enums/app_enums.dart';

class RoleHomePage extends ConsumerWidget {
  const RoleHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDemoProfileProvider)!;
    final language = Localizations.localeOf(context).languageCode;
    final arabic = language == 'ar';
    final manager = profile.role == DemoUserRole.manager || profile.role == DemoUserRole.seniorManagement;
    final name = profile.localizedName(language).split(' ').first;

    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= AppBreakpoints.tablet ? 4 : 2;
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          AppPageHeader(
            eyebrow: manager ? (arabic ? 'نظرة عامة للفريق' : 'Team overview') : (arabic ? 'مساحة عملي' : 'My workspace'),
            title: '${context.l10n.welcome}، $name',
            subtitle: manager
                ? (arabic ? 'تابع أداء الفريق واتخذ الإجراءات ذات الأولوية.' : 'Monitor team delivery and act on what needs attention.')
                : (arabic ? 'إليك ملخص واضح ليومك والمهام ذات الأولوية.' : 'Here is a clear view of your day and priority work.'),
            trailing: AppAvatar(initials: profile.avatarInitials, size: 52, online: true),
          ),
          const SizedBox(height: AppSpacing.large),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.small,
            crossAxisSpacing: AppSpacing.small,
            childAspectRatio: columns == 4 ? 1.25 : 1.05,
            children: manager
                ? [
                    AppMetricCard(label: arabic ? 'مهام الفريق' : 'Team tasks', value: '42', icon: Icons.task_alt, detail: '+8%'),
                    AppMetricCard(label: arabic ? 'مكتملة' : 'Completed', value: '28', icon: Icons.check_circle_outline),
                    AppMetricCard(label: arabic ? 'تحتاج انتباه' : 'Need attention', value: '6', icon: Icons.error_outline),
                    AppMetricCard(label: arabic ? 'بانتظار الاعتماد' : 'Awaiting approval', value: '4', icon: Icons.approval_outlined),
                  ]
                : [
                    AppMetricCard(label: arabic ? 'مهامي اليوم' : 'Due today', value: '5', icon: Icons.today_outlined),
                    AppMetricCard(label: arabic ? 'قيد التنفيذ' : 'In progress', value: '3', icon: Icons.pending_actions_outlined),
                    AppMetricCard(label: arabic ? 'مكتملة هذا الأسبوع' : 'Done this week', value: '12', icon: Icons.done_all),
                    AppMetricCard(label: arabic ? 'متأخرة' : 'Overdue', value: '1', icon: Icons.schedule),
                  ],
          ),
          const SizedBox(height: AppSpacing.large),
          Wrap(spacing: AppSpacing.medium, runSpacing: AppSpacing.medium, children: [
            SizedBox(
              width: constraints.maxWidth >= AppBreakpoints.tablet ? (constraints.maxWidth - AppSpacing.medium) * .62 : constraints.maxWidth,
              child: AppPanel(
                title: manager ? (arabic ? 'الأعمال التي تحتاج قرارك' : 'Work needing your decision') : (arabic ? 'أولوية اليوم' : 'Today’s priority'),
                action: TextButton(onPressed: () {}, child: Text(arabic ? 'عرض الكل' : 'View all')),
                child: Column(children: [
                  AppTaskPreviewTile(title: arabic ? 'مراجعة خطة التشغيل الأسبوعية' : 'Review weekly operations plan', meta: arabic ? 'اليوم، ٢:٣٠ م • العمليات' : 'Today, 2:30 PM • Operations', status: arabic ? 'عالية' : 'High', tone: AppBadgeTone.warning),
                  const Divider(),
                  AppTaskPreviewTile(title: arabic ? 'اعتماد طلب تحديث النظام' : 'Approve system update request', meta: arabic ? 'غداً • تقنية المعلومات' : 'Tomorrow • IT support', status: arabic ? 'اعتماد' : 'Approval', tone: AppBadgeTone.info),
                  const Divider(),
                  AppTaskPreviewTile(title: arabic ? 'تقرير الأداء الشهري' : 'Monthly performance report', meta: arabic ? 'الخميس • سري' : 'Thursday • Confidential', status: arabic ? 'سري' : 'Confidential', tone: AppBadgeTone.confidential),
                ]),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth >= AppBreakpoints.tablet ? (constraints.maxWidth - AppSpacing.medium) * .35 : constraints.maxWidth,
              child: AppPanel(
                title: arabic ? 'التقدم الأسبوعي' : 'Weekly progress',
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(arabic ? 'نسبة الإنجاز' : 'Completion rate'), const Spacer(), const Text('78%', style: TextStyle(fontWeight: FontWeight.w800))]),
                  const SizedBox(height: AppSpacing.small),
                  const LinearProgressIndicator(value: .78, minHeight: 8, borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill))),
                  const SizedBox(height: AppSpacing.large),
                  AppBadge(label: context.l10n.demoMode, tone: AppBadgeTone.neutral, icon: Icons.science_outlined),
                  const SizedBox(height: AppSpacing.small),
                  Text(context.l10n.demoNotice, style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ),
          ]),
        ],
      );
    });
  }
}

String roleLabel(BuildContext context, DemoUserRole role) => switch (role) {
      DemoUserRole.employee => context.l10n.employee,
      DemoUserRole.manager => context.l10n.manager,
      DemoUserRole.seniorManagement => context.l10n.seniorManagement,
      DemoUserRole.administrator => context.l10n.systemAdministrator,
    };

String connectivityLabel(BuildContext context, SimulatedConnectivityStatus status) => switch (status) {
      SimulatedConnectivityStatus.online => context.l10n.online,
      SimulatedConnectivityStatus.offline => context.l10n.offline,
      SimulatedConnectivityStatus.unstable => context.l10n.unstableConnection,
    };
