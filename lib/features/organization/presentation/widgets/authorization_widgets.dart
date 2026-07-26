import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/dependency_injection/app_providers.dart';
import '../../../../app/localization/localization_extensions.dart';
import '../../../../core/domain/authorization_models.dart';
import '../../../../core/domain/domain_enums.dart';

class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.target,
    this.fallback = const SizedBox.shrink(),
  });
  final PermissionCode permission;
  final AccessTarget? target;
  final Widget child, fallback;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(
        permissionDecisionProvider((permission: permission, target: target)),
      )
      .when(
        data: (decision) => decision.allowed ? child : fallback,
        loading: () => const SizedBox.shrink(),
        error: (_, __) => fallback,
      );
}

class AccessDeniedState extends StatelessWidget {
  const AccessDeniedState({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.accessDenied,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.permissionDenied, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class AccessScopeBadge extends StatelessWidget {
  const AccessScopeBadge({super.key, required this.scope});
  final AccessScope scope;
  @override
  Widget build(BuildContext context) {
    final label = switch (scope) {
      AccessScope.self => context.l10n.selfScope,
      AccessScope.team => context.l10n.teamScope,
      AccessScope.department => context.l10n.departmentScope,
      AccessScope.organization => context.l10n.organizationScope,
      AccessScope.administration => context.l10n.administrationScope,
    };
    return Chip(
      avatar: const Icon(Icons.shield_outlined, size: 18),
      label: Text(label),
    );
  }
}

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: const Icon(Icons.badge_outlined, size: 18),
    label: Text(label),
  );
}

class PermissionGroupCard extends StatelessWidget {
  const PermissionGroupCard({
    super.key,
    required this.title,
    required this.permissions,
  });
  final String title;
  final Iterable<PermissionCode> permissions;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          for (final permission in permissions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(_friendly(permission.code)),
              subtitle: Text(permission.code),
            ),
        ],
      ),
    ),
  );
  String _friendly(String code) => code.split('.').last.replaceAll('_', ' ');
}
