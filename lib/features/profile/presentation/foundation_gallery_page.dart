import 'package:flutter/material.dart';

import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../core/widgets/connectivity_status_banner.dart';
import '../../../core/widgets/foundation_views.dart';

class FoundationGalleryPage extends StatelessWidget {
  const FoundationGalleryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.foundationGallery)),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSizes.pageMax), child: ListView(padding: const EdgeInsets.all(AppSpacing.large), children: [
        AppPageHeader(eyebrow: '01.5', title: context.l10n.foundationGallery, subtitle: arabic ? 'مرجع حي للمكونات والرموز والحالات القابلة لإعادة الاستخدام.' : 'A living reference for reusable components, tokens, and application states.'),
        AppSectionHeader(title: arabic ? 'الشارات الدلالية' : 'Semantic badges'),
        Wrap(spacing: AppSpacing.small, runSpacing: AppSpacing.small, children: [
          AppBadge(label: arabic ? 'قيد التنفيذ' : 'In progress', tone: AppBadgeTone.info),
          AppBadge(label: arabic ? 'مكتملة' : 'Completed', tone: AppBadgeTone.success),
          AppBadge(label: arabic ? 'أولوية عالية' : 'High priority', tone: AppBadgeTone.warning),
          AppBadge(label: arabic ? 'حرجة' : 'Critical', tone: AppBadgeTone.danger),
          AppBadge(label: arabic ? 'سري' : 'Confidential', tone: AppBadgeTone.confidential, icon: Icons.lock_outline),
        ]),
        AppSectionHeader(title: arabic ? 'الأزرار والحقول' : 'Buttons and fields'),
        Wrap(spacing: AppSpacing.small, runSpacing: AppSpacing.small, children: [FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: Text(arabic ? 'إجراء أساسي' : 'Primary action')), OutlinedButton(onPressed: () {}, child: Text(arabic ? 'إجراء ثانوي' : 'Secondary action')), TextButton(onPressed: () {}, child: Text(arabic ? 'رابط نصي' : 'Text action'))]),
        const SizedBox(height: AppSpacing.medium),
        TextField(decoration: InputDecoration(labelText: context.l10n.username, hintText: arabic ? 'أدخل اسماً واضحاً' : 'Enter a clear name', prefixIcon: const Icon(Icons.edit_outlined))),
        AppSectionHeader(title: arabic ? 'البطاقات والعناصر' : 'Cards and list items'),
        const AppPanel(title: 'Operational work', child: Column(children: [AppTaskPreviewTile(title: 'Quarterly access review', meta: 'Today • Information security', status: 'High', tone: AppBadgeTone.warning), Divider(), AppTaskPreviewTile(title: 'Update team playbook', meta: 'Thursday • Operations', status: 'Active')])),
        AppSectionHeader(title: context.l10n.foundationStateExamples),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet ? 3 : 1, childAspectRatio: 1.6, mainAxisSpacing: AppSpacing.small, crossAxisSpacing: AppSpacing.small, children: [Card(child: AppLoadingView(label: context.l10n.loading)), Card(child: AppEmptyView(label: context.l10n.noData)), Card(child: AppErrorView(label: context.l10n.somethingWentWrong, retryLabel: context.l10n.retry))]),
        const SizedBox(height: AppSpacing.medium),
        const ConnectivityStatusBanner(),
        const SizedBox(height: AppSpacing.medium),
        FilledButton(onPressed: () => showAppConfirmationDialog(context, title: context.l10n.demoMode, question: context.l10n.confirmationQuestion, confirm: context.l10n.confirm, cancel: context.l10n.cancel), child: Text(context.l10n.showDialog)),
      ]))),
    );
  }
}
