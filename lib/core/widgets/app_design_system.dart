import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

enum AppBadgeTone { neutral, info, success, warning, danger, confidential }

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.initials, this.size = AppSizes.avatar, this.online = false});
  final String initials;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          if (online)
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppSemanticColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.surfaces.standard, width: 2),
                ),
              ),
            ),
        ]),
      );
}

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppBadgeTone.neutral, this.icon});
  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  Color _color(ColorScheme scheme) => switch (tone) {
        AppBadgeTone.neutral => scheme.onSurfaceVariant,
        AppBadgeTone.info => scheme.primary,
        AppBadgeTone.success => AppSemanticColors.success,
        AppBadgeTone.warning => AppSemanticColors.warning,
        AppBadgeTone.danger => AppSemanticColors.priorityCritical,
        AppBadgeTone.confidential => AppSemanticColors.confidential,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
        Flexible(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))),
      ]),
    );
  }
}

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({super.key, required this.label, required this.value, required this.icon, this.detail});
  final String label;
  final String value;
  final IconData icon;
  final String? detail;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.surfaces.standard,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: context.surfaces.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.surfaces.elevated, borderRadius: BorderRadius.circular(AppRadii.small)),
              child: Icon(icon, size: AppIconSizes.small, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  if (detail != null) ...[const SizedBox(width: AppSpacing.small), Flexible(child: AppBadge(label: detail!, tone: AppBadgeTone.success))],
                ]),
                Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.3)),
              ]),
            ),
          ]),
        ),
      );
}

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.title, required this.child, this.action, this.settings = false});
  final String title;
  final Widget child;
  final Widget? action;
  final bool settings;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: settings ? context.surfaces.elevated : context.surfaces.standard,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: settings ? null : Border.all(color: context.surfaces.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)), if (action != null) action!]),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

class AppTaskPreviewTile extends StatelessWidget {
  const AppTaskPreviewTile({
    super.key,
    required this.title,
    required this.meta,
    required this.status,
    this.tone = AppBadgeTone.info,
    this.category,
    this.progress,
    this.assigneeInitials,
    this.offline = false,
  });
  final String title;
  final String meta;
  final String status;
  final AppBadgeTone tone;
  final String? category;
  final double? progress;
  final String? assigneeInitials;
  final bool offline;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: context.surfaces.standard,
          borderRadius: BorderRadius.circular(AppRadii.small),
          border: BorderDirectional(start: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
            const SizedBox(width: AppSpacing.small),
            AppBadge(label: status, tone: tone, icon: tone == AppBadgeTone.warning ? Icons.priority_high : null),
          ]),
          const SizedBox(height: AppSpacing.small),
          Wrap(spacing: 10, runSpacing: 5, crossAxisAlignment: WrapCrossAlignment.center, children: [
            _TaskMeta(icon: Icons.schedule_outlined, label: meta),
            if (category != null) _TaskMeta(icon: Icons.folder_outlined, label: category!),
            if (offline) const Icon(Icons.cloud_off_outlined, size: 16),
            if (assigneeInitials != null) AppAvatar(initials: assigneeInitials!, size: 24),
          ]),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.small),
            LinearProgressIndicator(value: progress, minHeight: 5, borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill))),
          ],
        ]),
      );
}

class _TaskMeta extends StatelessWidget {
  const _TaskMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]);
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({super.key, required this.eyebrow, required this.title, required this.subtitle, this.trailing});
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, letterSpacing: .5)),
          const SizedBox(height: 2),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
        if (trailing != null) ...[const SizedBox(width: AppSpacing.medium), trailing!],
      ]);
}

class AppPrimaryScrollView extends StatelessWidget {
  const AppPrimaryScrollView({super.key, required this.children, this.navigationClearance = true});
  final List<Widget> children;
  final bool navigationClearance;

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final bottom = navigationClearance && !tablet
        ? AppSizes.phoneNavigation + MediaQuery.viewPaddingOf(context).bottom + AppSpacing.medium
        : AppSpacing.large;
    return ListView(
      key: const Key('primary-scroll-view'),
      padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.large, AppSpacing.medium, AppSpacing.large, bottom),
      children: children,
    );
  }
}
