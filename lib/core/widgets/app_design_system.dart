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
        child: Stack(
          children: [
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
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      );
}

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppBadgeTone.neutral, this.icon});
  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  Color _color(ColorScheme scheme) => switch (tone) {
        AppBadgeTone.neutral => scheme.onSurfaceVariant,
        AppBadgeTone.info => AppSemanticColors.information,
        AppBadgeTone.success => AppSemanticColors.success,
        AppBadgeTone.warning => AppSemanticColors.warning,
        AppBadgeTone.danger => AppSemanticColors.priorityCritical,
        AppBadgeTone.confidential => AppSemanticColors.confidential,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 5)],
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(AppRadii.small)),
                child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: AppIconSizes.small, color: Theme.of(context).colorScheme.primary)),
              ),
              const Spacer(),
              if (detail != null) AppBadge(label: detail!, tone: AppBadgeTone.success),
            ]),
            const SizedBox(height: AppSpacing.medium),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xSmall),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
}

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)), if (action != null) action!]),
            const SizedBox(height: AppSpacing.medium),
            child,
          ]),
        ),
      );
}

class AppTaskPreviewTile extends StatelessWidget {
  const AppTaskPreviewTile({super.key, required this.title, required this.meta, required this.status, this.tone = AppBadgeTone.info});
  final String title;
  final String meta;
  final String status;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
        child: Row(children: [
          Container(width: 4, height: 42, decoration: BoxDecoration(color: AppSemanticColors.taskActive, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: AppSpacing.medium),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(meta, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))])),
          const SizedBox(width: AppSpacing.small),
          AppBadge(label: status, tone: tone),
        ]),
      );
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
          Text(eyebrow.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: AppSpacing.xSmall),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xSmall),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
        if (trailing != null) ...[const SizedBox(width: AppSpacing.medium), trailing!],
      ]);
}

