import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../shared/enums/app_enums.dart';
import '../../authentication/presentation/authentication_pages.dart';
import '../../home/presentation/home_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, required this.openGallery});
  final VoidCallback openGallery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentDemoProfileProvider)!;
    final role = ref.watch(currentSystemRoleProvider)!;
    final language = Localizations.localeOf(context).languageCode;
    return AppPrimaryScrollView(children: [
      AppPageHeader(eyebrow: context.l10n.settings, title: context.l10n.profile, subtitle: context.l10n.demoMode),
      const SizedBox(height: AppSpacing.medium),
      Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: context.surfaces.elevated,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: context.surfaces.border),
        ),
        child: Row(children: [
          AppAvatar(initials: profile.avatarInitials, size: 56, online: true),
          const SizedBox(width: AppSpacing.medium),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(profile.localizedName(language), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(roleLabel(context, role), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            Text(profile.localizedDepartment(language), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xSmall),
            AppBadge(label: context.l10n.online, tone: AppBadgeTone.success, icon: Icons.circle),
          ])),
        ]),
      ),
      const SizedBox(height: AppSpacing.section),
      AppPanel(
        title: context.l10n.settings,
        settings: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _SettingLabel(context.l10n.language),
          SegmentationLanguageSelector(locale: ref.watch(localeProvider), onChanged: (value) => ref.read(localeProvider.notifier).state = value),
          const SizedBox(height: AppSpacing.medium),
          _SettingLabel(context.l10n.theme),
          ThemeModeSelector(value: ref.watch(themeModeProvider), onChanged: (value) => ref.read(themeModeProvider.notifier).state = value),
          const SizedBox(height: AppSpacing.medium),
          _SettingLabel(context.l10n.connectivity),
          ConnectivitySelector(value: ref.watch(connectivityProvider), onChanged: (value) => ref.read(connectivityProvider.notifier).state = value),
        ]),
      ),
      const SizedBox(height: AppSpacing.medium),
      AppPanel(
        title: context.l10n.demoMode,
        child: Column(children: [
          ListTile(key: const Key('access-summary'), leading: const Icon(Icons.shield_outlined), title: Text(context.l10n.accessSummary), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/access-summary')),
          ListTile(leading: const Icon(Icons.palette_outlined), title: Text(context.l10n.foundationGallery), trailing: const Icon(Icons.chevron_right), onTap: openGallery),
          ListTile(leading: const Icon(Icons.switch_account), title: Text(context.l10n.switchProfile), onTap: () async {await ref.read(sessionProvider.notifier).logout();ref.read(sessionProvider.notifier).beginProfileSelection();}),
          ListTile(key: const Key('expire-session'), leading: const Icon(Icons.timer_off_outlined), title: Text(context.l10n.expireSession), onTap: () => ref.read(sessionProvider.notifier).expire()),
          ListTile(key: const Key('logout'), leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error), title: Text(context.l10n.logout), onTap: () => showDialog<void>(context:context,builder:(context)=>AlertDialog(title:Text(context.l10n.confirmLogout),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(context.l10n.cancel)),FilledButton(onPressed:(){Navigator.pop(context);ref.read(sessionProvider.notifier).logout();},child:Text(context.l10n.logout))]))),
        ]),
      ),
      const SizedBox(height: AppSpacing.medium),
      Center(child: AppBadge(label: '${context.l10n.demoMode} • 1.0.0')),
    ]);
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.small),
        child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      );
}

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, required this.value, required this.onChanged});
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(context.l10n.light)),
          ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(context.l10n.dark)),
          ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.settings_brightness_outlined), label: Text(context.l10n.systemDefault)),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      );
}

class ConnectivitySelector extends StatelessWidget {
  const ConnectivitySelector({super.key, required this.value, required this.onChanged});
  final SimulatedConnectivityStatus value;
  final ValueChanged<SimulatedConnectivityStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <(SimulatedConnectivityStatus, IconData, String)>[
      (SimulatedConnectivityStatus.online, Icons.cloud_done_outlined, context.l10n.online),
      (SimulatedConnectivityStatus.offline, Icons.cloud_off_outlined, context.l10n.offline),
      (SimulatedConnectivityStatus.unstable, Icons.signal_wifi_statusbar_connected_no_internet_4, context.l10n.unstableConnection),
    ];
    return Column(children: [
      for (final option in options)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: Semantics(
            selected: value == option.$1,
            button: true,
            child: InkWell(
              key: ValueKey(option.$1),
              onTap: () => onChanged(option.$1),
              borderRadius: BorderRadius.circular(AppRadii.small),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minHeight: AppSizes.control),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: value == option.$1 ? context.surfaces.standard : context.surfaces.disabled,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  border: Border.all(color: value == option.$1 ? Theme.of(context).colorScheme.primary : context.surfaces.border, width: value == option.$1 ? 1.5 : 1),
                ),
                child: Row(children: [
                  Icon(option.$2, color: value == option.$1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(child: Text(option.$3, style: Theme.of(context).textTheme.labelLarge)),
                  Icon(value == option.$1 ? Icons.radio_button_checked : Icons.radio_button_off, color: value == option.$1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}
