import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/demo_user_profile.dart';
import '../../home/presentation/home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: AppLoadingIdentity(title: context.l10n.appName, label: context.l10n.loading));
}

class AppLoadingIdentity extends StatelessWidget {
  const AppLoadingIdentity({super.key, required this.title, required this.label});
  final String title;
  final String label;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(AppSpacing.medium), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(AppRadii.large)), child: Icon(Icons.fact_check_outlined, size: 38, color: Theme.of(context).colorScheme.onPrimary)),
        const SizedBox(height: AppSpacing.medium),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.large),
        Semantics(label: label, child: const CircularProgressIndicator()),
      ]));
}

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.large), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Card(child: Padding(padding: const EdgeInsets.all(AppSpacing.xLarge), child: Column(children: [
        Icon(Icons.translate_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.medium),
        Text(context.l10n.language, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xSmall),
        Text('العربية • English', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.large),
        SegmentationLanguageSelector(locale: ref.watch(localeProvider), onChanged: (value) => ref.read(localeProvider.notifier).state = value),
        const SizedBox(height: AppSpacing.large),
        SizedBox(width: double.infinity, child: FilledButton.icon(key: const Key('language-continue'), onPressed: () => ref.read(sessionProvider.notifier).beginProfileSelection(), icon: const Icon(Icons.arrow_forward_rounded), label: Text(context.l10n.continueLabel))),
      ]))))))));
}

class SegmentationLanguageSelector extends StatelessWidget {
  const SegmentationLanguageSelector({super.key, required this.locale, required this.onChanged});
  final Locale? locale;
  final ValueChanged<Locale> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            minimumSize: WidgetStatePropertyAll(Size(0, AppSizes.compactControl)),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.small)),
          ),
          segments: [ButtonSegment(value: 'ar', label: Text(context.l10n.arabic)), ButtonSegment(value: 'en', label: Text(context.l10n.english))],
          selected: {locale?.languageCode ?? Localizations.localeOf(context).languageCode},
          onSelectionChanged: (value) => onChanged(Locale(value.first)),
        ),
      );
}

class DemoLoginPage extends ConsumerWidget {
  const DemoLoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expired = ref.watch(sessionProvider).status == AuthenticationStatus.expired;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName), actions: [IconButton(onPressed: () => ref.read(localeProvider.notifier).state = Locale(Localizations.localeOf(context).languageCode == 'ar' ? 'en' : 'ar'), icon: const Icon(Icons.translate), tooltip: context.l10n.language), const SizedBox(width: AppSpacing.small)]),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSizes.pageMax), child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.tablet;
        final form = _LoginForm(expired: expired, onLogin: () => ref.read(sessionProvider.notifier).beginProfileSelection());
        final profiles = _ProfilePicker(onSelected: (profile) => ref.read(sessionProvider.notifier).authenticate(profile));
        return SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.large), child: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 4, child: form), const SizedBox(width: AppSpacing.large), Expanded(flex: 6, child: profiles)])
            : Column(children: [form, const SizedBox(height: AppSpacing.large), profiles]));
      })))));
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.expired, required this.onLogin});
  final bool expired;
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(AppSpacing.large), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppPageHeader(eyebrow: context.l10n.demoMode, title: context.l10n.login, subtitle: context.l10n.authenticationSimulated),
        if (expired) ...[const SizedBox(height: AppSpacing.medium), AppBadge(label: context.l10n.sessionExpired, tone: AppBadgeTone.danger, icon: Icons.timer_off_outlined)],
        const SizedBox(height: AppSpacing.large),
        TextField(decoration: InputDecoration(labelText: context.l10n.username, prefixIcon: const Icon(Icons.person_outline))),
        const SizedBox(height: AppSpacing.medium),
        TextField(obscureText: true, decoration: InputDecoration(labelText: context.l10n.password, prefixIcon: const Icon(Icons.lock_outline))),
        const SizedBox(height: AppSpacing.medium),
        FilledButton(onPressed: onLogin, child: Text(context.l10n.login)),
      ])));
}

class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({required this.onSelected});
  final ValueChanged<DemoUserProfile> onSelected;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.l10n.selectDemoProfile, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        for (final profile in demoProfiles) DemoProfileCard(profile: profile, onSelected: () => onSelected(profile)),
      ]);
}

class DemoProfileCard extends StatelessWidget {
  const DemoProfileCard({super.key, required this.profile, required this.onSelected});
  final DemoUserProfile profile;
  final VoidCallback onSelected;
  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return Card(key: Key('profile-${profile.id}'), margin: const EdgeInsets.only(top: AppSpacing.small), child: InkWell(borderRadius: BorderRadius.circular(AppRadii.medium), onTap: onSelected, child: Padding(padding: const EdgeInsets.all(AppSpacing.medium), child: Row(children: [
          AppAvatar(initials: profile.avatarInitials, online: true),
          const SizedBox(width: AppSpacing.medium),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profile.localizedName(language), style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text('${roleLabel(context, profile.role)} • ${profile.localizedDepartment(language)}', style: Theme.of(context).textTheme.bodySmall)])),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ]))));
  }
}
