import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconColor,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).colorScheme.primary)
                  .withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppIconSizes.large,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.medium),
            action!,
          ],
        ],
      ),
    ),
  );
}

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.medium),
          Text(label),
        ],
      ),
    ),
  );
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => AppStateView(
    icon: Icons.inbox_outlined,
    title: label,
    message: Localizations.localeOf(context).languageCode == 'ar'
        ? 'ستظهر العناصر هنا عند إضافتها.'
        : 'Items will appear here when they are added.',
  );
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.label,
    required this.retryLabel,
    this.onRetry,
  });
  final String label;
  final String retryLabel;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => AppStateView(
    icon: Icons.error_outline,
    iconColor: Theme.of(context).colorScheme.error,
    title: label,
    message: Localizations.localeOf(context).languageCode == 'ar'
        ? 'حاول مرة أخرى أو عد لاحقاً.'
        : 'Try again or return a little later.',
    action: OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(retryLabel),
    ),
  );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.large,
      bottom: AppSpacing.small,
    ),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

Future<bool> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required String question,
  required String confirm,
  required String cancel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.help_outline),
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;
