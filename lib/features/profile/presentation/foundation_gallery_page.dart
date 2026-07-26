import 'package:flutter/material.dart';

import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../core/widgets/connectivity_status_banner.dart';
import '../../../core/widgets/foundation_views.dart';
import '../../../shared/enums/app_enums.dart';
import '../../authentication/presentation/authentication_pages.dart';
import 'profile_page.dart';

class FoundationGalleryPage extends StatefulWidget {
  const FoundationGalleryPage({super.key});
  @override
  State<FoundationGalleryPage> createState() => _FoundationGalleryPageState();
}

class _FoundationGalleryPageState extends State<FoundationGalleryPage> {
  ThemeMode appearance = ThemeMode.system;
  SimulatedConnectivityStatus connectivity =
      SimulatedConnectivityStatus.unstable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.foundationGallery)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.pageMax),
          child: AppPrimaryScrollView(
            navigationClearance: false,
            children: [
              AppPageHeader(
                eyebrow: context.l10n.demoMode,
                title: context.l10n.foundationGallery,
                subtitle: context.l10n.longTextDemo,
              ),
              AppSectionHeader(title: context.l10n.currentRole),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  AppBadge(label: context.l10n.online, tone: AppBadgeTone.info),
                  AppBadge(
                    label: context.l10n.approvals,
                    tone: AppBadgeTone.success,
                  ),
                  AppBadge(
                    label: context.l10n.unstableConnection,
                    tone: AppBadgeTone.warning,
                  ),
                  AppBadge(
                    label: context.l10n.criticalTasks,
                    tone: AppBadgeTone.danger,
                  ),
                  AppBadge(
                    label: context.l10n.currentRole,
                    tone: AppBadgeTone.confidential,
                    icon: Icons.lock_outline,
                  ),
                ],
              ),
              AppSectionHeader(title: context.l10n.currentTheme),
              Row(
                children: [
                  for (final color in [
                    context.surfaces.page,
                    context.surfaces.standard,
                    context.surfaces.elevated,
                    context.surfaces.border,
                    context.surfaces.disabled,
                  ])
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: context.surfaces.border),
                        ),
                      ),
                    ),
                ],
              ),
              AppSectionHeader(title: context.l10n.foundationGallery),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                    MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet
                    ? 4
                    : 2,
                childAspectRatio: 1.55,
                mainAxisSpacing: AppSpacing.small,
                crossAxisSpacing: AppSpacing.small,
                children: [
                  AppMetricCard(
                    label: context.l10n.myTasks,
                    value: '5',
                    icon: Icons.today_outlined,
                  ),
                  AppMetricCard(
                    label: context.l10n.approvals,
                    value: '12',
                    icon: Icons.approval_outlined,
                    detail: '+8%',
                  ),
                ],
              ),
              AppSectionHeader(title: context.l10n.showDialog),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.confirm),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text(context.l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(context.l10n.continueLabel),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                decoration: InputDecoration(
                  labelText: context.l10n.username,
                  hintText: context.l10n.validationError,
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
              ),
              AppSectionHeader(title: context.l10n.myTasks),
              AppPanel(
                title: context.l10n.myTasks,
                child: Column(
                  children: [
                    AppTaskPreviewTile(
                      title: context.l10n.longTextDemo,
                      meta: context.l10n.currentTheme,
                      category: context.l10n.operations,
                      status: context.l10n.unstableConnection,
                      tone: AppBadgeTone.warning,
                      progress: .65,
                      assigneeInitials: 'AH',
                      offline: true,
                    ),
                  ],
                ),
              ),
              AppSectionHeader(title: context.l10n.settings),
              SegmentationLanguageSelector(
                locale: Localizations.localeOf(context),
                onChanged: (_) {},
              ),
              const SizedBox(height: AppSpacing.small),
              ThemeModeSelector(
                value: appearance,
                onChanged: (value) => setState(() => appearance = value),
              ),
              const SizedBox(height: AppSpacing.small),
              ConnectivitySelector(
                value: connectivity,
                onChanged: (value) => setState(() => connectivity = value),
              ),
              AppSectionHeader(title: context.l10n.foundationStateExamples),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                    MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet
                    ? 3
                    : 1,
                childAspectRatio: 1.6,
                mainAxisSpacing: AppSpacing.small,
                crossAxisSpacing: AppSpacing.small,
                children: [
                  Card(child: AppLoadingView(label: context.l10n.loading)),
                  Card(child: AppEmptyView(label: context.l10n.noData)),
                  Card(
                    child: AppErrorView(
                      label: context.l10n.somethingWentWrong,
                      retryLabel: context.l10n.retry,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              const ConnectivityStatusBanner(),
              const SizedBox(height: AppSpacing.medium),
              FilledButton(
                onPressed: () => showAppConfirmationDialog(
                  context,
                  title: context.l10n.demoMode,
                  question: context.l10n.confirmationQuestion,
                  confirm: context.l10n.confirm,
                  cancel: context.l10n.cancel,
                ),
                child: Text(context.l10n.showDialog),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
