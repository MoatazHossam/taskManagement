import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/dependency_injection/app_providers.dart';
import '../../../app/localization/localization_extensions.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_design_system.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/demo_user_profile.dart';
import '../../home/presentation/home_page.dart';
import '../domain/authentication_models.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override ConsumerState<SplashPage> createState()=>_SplashPageState();
}
class _SplashPageState extends ConsumerState<SplashPage> {
  @override void initState(){super.initState();Future.microtask(() async {await ref.read(databaseInitializationProvider.future);await ref.read(sessionProvider.notifier).initialize(offline:ref.read(connectivityProvider)==SimulatedConnectivityStatus.offline);});}
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

class DemoLoginPage extends ConsumerStatefulWidget {
  const DemoLoginPage({super.key});
  @override ConsumerState<DemoLoginPage> createState()=>_DemoLoginPageState();
}
class _DemoLoginPageState extends ConsumerState<DemoLoginPage> {
  final username=TextEditingController();final password=TextEditingController();bool obscure=true;
  @override void dispose(){username.dispose();password.dispose();super.dispose();}
  @override
  Widget build(BuildContext context) {
    final session=ref.watch(sessionProvider);final expired = session.status == AuthenticationStatus.expired;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName), actions: [IconButton(onPressed: () => ref.read(localeProvider.notifier).state = Locale(Localizations.localeOf(context).languageCode == 'ar' ? 'en' : 'ar'), icon: const Icon(Icons.translate), tooltip: context.l10n.language), const SizedBox(width: AppSpacing.small)]),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSizes.pageMax), child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.tablet;
        final form = _LoginForm(expired: expired, loading:session.status==AuthenticationStatus.authenticating,error:session.failure,username:username,password:password,obscure:obscure,onToggle:()=>setState(()=>obscure=!obscure),onLogin: () => ref.read(sessionProvider.notifier).signInCredentials(username.text,password.text));
        final profiles = _ProfilePicker(onSelected: (profile) => ref.read(sessionProvider.notifier).signInProfile(profile));
        return SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.large), child: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 4, child: form), const SizedBox(width: AppSpacing.large), Expanded(flex: 6, child: profiles)])
            : Column(children: [form, const SizedBox(height: AppSpacing.large), profiles]));
      })))));
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.expired,required this.loading,required this.error,required this.username,required this.password,required this.obscure,required this.onToggle,required this.onLogin});
  final bool expired,loading,obscure;final AuthenticationFailure? error;final TextEditingController username,password;final VoidCallback onToggle;
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(AppSpacing.large), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppPageHeader(eyebrow: context.l10n.demoMode, title: context.l10n.login, subtitle: context.l10n.authenticationSimulated),
        if (expired) ...[const SizedBox(height: AppSpacing.medium), AppBadge(label: context.l10n.sessionExpired, tone: AppBadgeTone.danger, icon: Icons.timer_off_outlined)],
        if(error!=null)...[const SizedBox(height:AppSpacing.medium),Text(_authenticationError(context,error!),style:TextStyle(color:Theme.of(context).colorScheme.error))],
        const SizedBox(height: AppSpacing.large),
        TextField(controller:username,decoration: InputDecoration(labelText: context.l10n.username, prefixIcon: const Icon(Icons.person_outline))),
        const SizedBox(height: AppSpacing.medium),
        TextField(controller:password,obscureText: obscure, decoration: InputDecoration(labelText: context.l10n.password, prefixIcon: const Icon(Icons.lock_outline),suffixIcon:IconButton(onPressed:onToggle,tooltip:obscure?context.l10n.showPassword:context.l10n.hidePassword,icon:Icon(obscure?Icons.visibility:Icons.visibility_off)))),
        const SizedBox(height: AppSpacing.medium),
        Text(context.l10n.demoCredentialsHelper,style:Theme.of(context).textTheme.bodySmall),const SizedBox(height:AppSpacing.medium),
        FilledButton(onPressed: loading?null:onLogin, child: loading?const SizedBox.square(dimension:20,child:CircularProgressIndicator(strokeWidth:2)):Text(context.l10n.login)),
      ])));
}

String _authenticationError(BuildContext context,AuthenticationFailure failure)=>switch(failure){AuthenticationFailure.invalidCredentials=>context.l10n.invalidCredentials,AuthenticationFailure.inactiveUser=>context.l10n.userInactive,AuthenticationFailure.pinInvalid=>context.l10n.incorrectPin,AuthenticationFailure.tooManyPinAttempts=>context.l10n.tooManyAttempts,AuthenticationFailure.offlineAccessExpired=>context.l10n.offlineAccessExpired,AuthenticationFailure.roleMismatch=>context.l10n.permissionError,AuthenticationFailure.databaseUnavailable=>context.l10n.storageError,_=>context.l10n.unknownError};

class PinUnlockPage extends ConsumerStatefulWidget {const PinUnlockPage({super.key});@override ConsumerState<PinUnlockPage> createState()=>_PinUnlockPageState();}
class _PinUnlockPageState extends ConsumerState<PinUnlockPage>{final pin=TextEditingController();@override void dispose(){pin.dispose();super.dispose();}@override Widget build(BuildContext context){final state=ref.watch(sessionProvider);return Scaffold(appBar:AppBar(title:Text(context.l10n.unlockApplication)),body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(AppSpacing.large),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:420),child:Card(child:Padding(padding:const EdgeInsets.all(AppSpacing.large),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Icon(Icons.pin_outlined,size:48,color:Theme.of(context).colorScheme.primary),const SizedBox(height:AppSpacing.medium),Text(context.l10n.demoPinNotice,textAlign:TextAlign.center),const SizedBox(height:AppSpacing.large),TextField(key:const Key('pin-input'),controller:pin,keyboardType:TextInputType.number,maxLength:4,obscureText:true,decoration:InputDecoration(labelText:context.l10n.enterPin)),if(state.failure!=null)Text(_authenticationError(context,state.failure!),style:TextStyle(color:Theme.of(context).colorScheme.error)),FilledButton(onPressed:()=>ref.read(sessionProvider.notifier).unlockPin(pin.text),child:Text(context.l10n.unlockApplication)),TextButton.icon(icon:const Icon(Icons.fingerprint),label:Text(context.l10n.useSimulatedBiometrics),onPressed:()=>showDialog<void>(context:context,builder:(context)=>AlertDialog(icon:const Icon(Icons.fingerprint),title:Text(context.l10n.useSimulatedBiometrics),content:Text(context.l10n.biometricSimulationNotice),actions:[TextButton(onPressed:(){Navigator.pop(context);ref.read(sessionProvider.notifier).unlockBiometric(false);},child:Text(context.l10n.simulateFailure)),FilledButton(onPressed:(){Navigator.pop(context);ref.read(sessionProvider.notifier).unlockBiometric(true);},child:Text(context.l10n.simulateSuccess))]))),TextButton(onPressed:()=>ref.read(sessionProvider.notifier).logout(),child:Text(context.l10n.logout))]))))))));}}

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
